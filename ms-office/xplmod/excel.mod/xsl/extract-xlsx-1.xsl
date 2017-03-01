<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns="http://www.xtpxlib.nl/ns/ms-office" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtpxlib="http://www.xatapult.nl/namespaces/common/xslt/library" xmlns:mso-wb="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:mso-rels="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:local="#local.extract-xlsx-1.xsl" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Extracts xlsx contents into something more manageable.		
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../../xslmod/ms-office.mod.xsl"/>
  
  <xsl:variable name="extracted-office-xml" as="element(xtlcon:document-container)" select="/*"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="@* | node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="/*">
    <workbook dref="{/*/@dref-source-zip}" timestamp="{current-dateTime()}">
      
      <!-- Get the properties: -->
      <xsl:call-template name="xtlmso:get-properties">
        <xsl:with-param name="extracted-office-xml" select="$extracted-office-xml"/>
      </xsl:call-template>
      
      <!-- Find the workbook first: -->
      <xsl:variable name="workbook" as="element(mso-wb:workbook)"
        select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, '', $xtlmso:relationship-type-main-document, true())"/>
      <xsl:variable name="workbook-href" as="xs:string" select="xtlmso:get-href($workbook)"/>
      
      <!-- Get the (optional) shared string table: -->
      <xsl:variable name="shared-strings" as="element(mso-wb:sst)?"
        select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, $workbook-href, $xtlmso:relationship-type-shared-strings, false())"/>
      
      <!-- Process the worksheets: -->
      <xsl:for-each select="$workbook/mso-wb:sheets/mso-wb:sheet">
        <xsl:variable name="sheet-name" as="xs:string" select="string(@name)"/>
        <xsl:call-template name="process-worksheet">
          <xsl:with-param name="worksheet"
            select="xtlmso:get-file-root-from-relationship-id($extracted-office-xml, $workbook-href, @mso-rels:id, true())"/>
          <xsl:with-param name="name" select="$sheet-name"/>
          <xsl:with-param name="shared-strings" select="$shared-strings"/>
          <xsl:with-param name="defined-names" select="local:defined-names($workbook/mso-wb:definedNames, $sheet-name)"/>
        </xsl:call-template>
      </xsl:for-each>
      
    </workbook>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="process-worksheet">
    <xsl:param name="worksheet" as="element(mso-wb:worksheet)" required="yes"/>
    <xsl:param name="shared-strings" as="element(mso-wb:sst)?" required="yes"/>
    <xsl:param name="name" as="xs:string" required="yes"/>
    <xsl:param name="defined-names" as="element(defined-name)*" required="yes"/>
    
    <worksheet name="{$name}">
      
      <!-- Try to find a matching comments file: -->
      <xsl:variable name="worksheet-href" as="xs:string" select="xtlmso:get-href($worksheet)"/>
      <xsl:variable name="comments-root" as="element(mso-wb:comments)?"
        select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, $worksheet-href, $xtlmso:relationship-type-comments, false())"/>
      
      <xsl:for-each select="$worksheet/mso-wb:sheetData/mso-wb:row">
        <row index="{@r}">
          <xsl:for-each select="mso-wb:c">
            
            <xsl:variable name="cell-reference" as="xs:string" select="@r"/>
            <cell index="{local:excelref-to-index($cell-reference)}" ref="{$cell-reference}">
              
              <!-- Find out if this cell has a name: -->
              <xsl:variable name="defined-name" as="element(defined-name)*" select="$defined-names[@ref eq $cell-reference][1]"/>
              <xsl:if test="exists($defined-name)">
                <xsl:attribute name="name" select="$defined-name/@name"/>
              </xsl:if>
              
              <xsl:variable name="celltype" as="xs:string" select="string(@t)"/>
              <xsl:choose>
                
                <!-- String cell type. Lookup contents in shared string table: -->
                <xsl:when test="exists(mso-wb:v) and ($celltype eq 's')">
                  <xsl:variable name="shared-string-index" as="xs:integer" select="xs:integer(mso-wb:v) + 1"/>
                  <xsl:variable name="shared-string-elm" as="element(mso-wb:si)?" select="$shared-strings/mso-wb:si[$shared-string-index]"/>
                  <value>
                    <xsl:call-template name="get-markedup-text">
                      <xsl:with-param name="container-elm" select="$shared-string-elm"/>
                    </xsl:call-template>
                  </value>
                </xsl:when>
                
                <!-- Normal, non-string, contents: -->
                <xsl:otherwise>
                  <value>
                    <xsl:value-of select="mso-wb:v"/>
                  </value>
                </xsl:otherwise>
              </xsl:choose>
              
              <!-- When there is a formula, just record it: -->
              <xsl:if test="exists(mso-wb:f)">
                <formula>
                  <xsl:value-of select="mso-wb:f"/>
                </formula>
              </xsl:if>
              
              <!-- Check for comments: -->
              <xsl:variable name="comment" as="element(mso-wb:comment)?"
                select="$comments-root/mso-wb:commentList/mso-wb:comment[@ref eq $cell-reference][1]"/>
              <xsl:if test="exists($comment)">
                <comment>
                  <xsl:call-template name="get-markedup-text">
                    <xsl:with-param name="container-elm" select="$comment/mso-wb:text"/>
                  </xsl:call-template>
                </comment>
              </xsl:if>
              
            </cell>
          </xsl:for-each>
        </row>
      </xsl:for-each>
    </worksheet>
  </xsl:template>
  
  <!-- ================================================================== -->
  <!-- HELPERS -->
  
  <xsl:template name="get-markedup-text">
    <xsl:param name="container-elm" as="element()" required="yes"/>
    
    <xsl:choose>
      <xsl:when test="exists($container-elm/mso-wb:r)">
        <xsl:for-each select="$container-elm/mso-wb:r">
          <xsl:variable name="style-info" as="xs:string*" select="local:get-relevant-font-info(mso-wb:rPr/*)"/>
          <xsl:choose>
            <xsl:when test="exists($style-info)">
              <span class="{string-join($style-info, ' ')}">
                <xsl:value-of select="mso-wb:t"/>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mso-wb:t"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string-join($container-elm//text()/string(), '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:get-relevant-font-info" as="xs:string*">
    <xsl:param name="font-style-elements" as="element()*"/>
    
    <xsl:variable name="relevant-element-names" as="xs:string+" select="('b', 'u', 'i')"/>
    <xsl:sequence select="distinct-values($font-style-elements[local-name(.) = $relevant-element-names]/local-name(.))"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:excelref-to-index" as="xs:integer">
    <xsl:param name="excelref" as="xs:string"/>
    
    <!-- Use the alphabetic part only: -->
    <xsl:variable name="excelref-alpha" as="xs:string" select="upper-case(replace($excelref, '^([A-Za-z]+).+', '$1'))"/>
    
    <!-- Compute the index: -->
    <xsl:variable name="charindex-A" as="xs:integer" select="string-to-codepoints('A')"/>
    <xsl:variable name="excelref-charindexes" as="xs:integer+" select="string-to-codepoints($excelref-alpha)"/>
    <xsl:variable name="excelref-charindexes-normalized" as="xs:integer+" select="for $ci in $excelref-charindexes return ($ci - $charindex-A + 1)"/>
    <xsl:sequence select="local:excelref-to-index-helper(0, $excelref-charindexes-normalized)"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:excelref-to-index-helper" as="xs:integer">
    <xsl:param name="prev" as="xs:integer"/>
    <xsl:param name="charindexes-normalized" as="xs:integer+"/>
    
    <xsl:choose>
      <xsl:when test="empty($charindexes-normalized)">
        <xsl:sequence select="$prev"/>
      </xsl:when>
      <xsl:when test="count($charindexes-normalized) eq 1">
        <xsl:sequence select="($prev * 26) + $charindexes-normalized[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="index-value" as="xs:integer" select="($prev * 26) + $charindexes-normalized[1]"/>
        <xsl:sequence select="local:excelref-to-index-helper($index-value, subsequence($charindexes-normalized, 2))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:defined-names" as="element(defined-name)*" xmlns="">
    <!-- Finds out on which cells there are defined names. However, it only records the first cell of the name range! -->
    <xsl:param name="defined-names-root" as="element(mso-wb:definedNames)?"/>
    <xsl:param name="worksheet-name" as="xs:string"/>
    
    <xsl:variable name="expected-start-1" as="xs:string" select="concat('&apos;&apos;', $worksheet-name, '&apos;&apos;!')"/>
    <xsl:variable name="expected-start-2" as="xs:string" select="concat($worksheet-name, '!')"/>
    <xsl:for-each
      select="$defined-names-root/mso-wb:definedName[starts-with(string(.), $expected-start-1) or starts-with(string(.), $expected-start-2)]">
      <xsl:variable name="name" as="xs:string" select="string(@name)"/>
      <xsl:variable name="remainder" as="xs:string"
        select="if (starts-with(string(.), $expected-start-1))
          then substring-after(string(.), $expected-start-1) 
          else substring-after(string(.), $expected-start-2)"/>
      <xsl:variable name="ref-with-dollars" as="xs:string" select="replace($remainder, '[:,].+$', '')"/>
      <xsl:variable name="ref" as="xs:string" select="translate($ref-with-dollars, '$', '')"/>
      
      <defined-name ref="{$ref}" name="{$name}"/>
      
    </xsl:for-each>
  </xsl:function>
  
</xsl:stylesheet>

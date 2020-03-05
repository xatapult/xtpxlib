<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlxo="http://www.xtpxlib.nl/ns/xoffice" xmlns:mso-wb="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:mso-rels="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns:local="#local-aa23fg" xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Performs a "raw" insertion of the modification data into the worksheets. After this, the worksheet data must still be sorted and made unique!	
    The input is an <xtlcon:document-container> with all information present.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-handle-cell-contents" on-no-match="fail"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../../xslmod/ms-office.mod.xsl"/>
  <xsl:include href="../../../xslmod/excel-conversions.mod.xsl"/>

  <!-- ================================================================== -->

  <!-- Get the important bits and pieces from the container: -->
  <xsl:variable name="container" as="element(xtlcon:document-container)" select="/*"/>
  <xsl:variable name="modification-specification" as="element(xtlmso:xlsx-modifications)"
    select="$container/xtlcon:document[@type eq 'modification-specification']/*"/>
  <xsl:variable name="main-workbook" as="element(mso-wb:workbook)"
    select="xtlmso:get-file-root-from-relationship-type($container, '', $xtlmso:relationship-type-main-document, true())"/>

  <!-- Some data for the cell index computation: -->
  <xsl:variable name="codepoint-A" as="xs:integer" select="string-to-codepoints('A')"/>
  <xsl:variable name="char-index-max" as="xs:integer" select="26"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document/mso-wb:worksheet/mso-wb:sheetData">


    <!-- Get the name of this worksheet and find any modifications for this worksheet: -->
    <xsl:variable name="worksheet-name" as="xs:string" select="local:worksheet-name(..)"/>
    <xsl:variable name="worksheet-modifications" as="element(xtlmso:worksheet)*"
      select="$modification-specification/xtlmso:worksheet[@name eq $worksheet-name]"/>

    <xsl:choose>

      <!-- When there are any modifications, merge them in: -->
      <xsl:when test="exists($worksheet-modifications/xtlmso:row/xtlmso:column)">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <!-- Remark: We mark this sheet data section as modified down here so we can identify modified section in the next pass. 
            Make sure to remove the MODIFIED attribute there! -->
          <xsl:attribute name="xtlmso:MODIFIED" select="true()"/>

          <!-- Remark: Make sure the new data comes first... This ensures that in sorting (and removing doubles) the new data gets precedence. -->
          <xsl:for-each select="$worksheet-modifications/xtlmso:row">
            <xsl:variable name="row" as="xs:integer" select="xs:integer(@index)"/>
            <row r="{$row}">
              <xsl:for-each select="xtlmso:column">
                <xsl:variable name="col" as="xs:integer" select="xs:integer(@index)"/>
                <c r="{local:cell-index($row, $col)}">
                  <xsl:apply-templates select="xtlmso:*[1]" mode="mode-handle-cell-contents"/>
                </c>
              </xsl:for-each>
            </row>
          </xsl:for-each>

          <!-- Copy the existing information: -->
          <xsl:apply-templates/>

        </xsl:copy>
      </xsl:when>

      <!-- No modifications for this worksheet: -->
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- HANDLE CELL CONTENTS: -->
  <!-- These templates fill the <mso-wb:c> element that holds the cell's contents. -->

  <xsl:template match="xtlmso:string" mode="mode-handle-cell-contents">
    <xsl:attribute name="t" select="'inlineStr'"/>
    <is>
      <t>
        <xsl:value-of select="."/>
      </t>
    </is>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlmso:number" mode="mode-handle-cell-contents">
    <v>
      <xsl:value-of select="."/>
    </v>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xtlmso:date" mode="mode-handle-cell-contents">
    <v>
      <xsl:value-of select="xtlmso:xs-date-to-excel-date(xs:date(.))"/>
    </v>
  </xsl:template>
  
  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:worksheet-name" as="xs:string">
    <xsl:param name="worksheet" as="element(mso-wb:worksheet)"/>
    <xsl:sequence select="$main-workbook/mso-wb:sheets/mso-wb:sheet[local:workbook-worksheet-ref-to-worksheet(.) is $worksheet]/@name"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:workbook-worksheet-ref-to-worksheet" as="element(mso-wb:worksheet)">
    <xsl:param name="workbook-worksheet-ref" as="element(mso-wb:sheet)"/>
    <xsl:sequence
      select="xtlmso:get-file-root-from-relationship-id($container, local:get-dref($main-workbook), $workbook-worksheet-ref/@mso-rels:id, true())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:get-dref" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    
    <xsl:sequence select="($elm/ancestor::xtlcon:document[1])/@dref-source"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:cell-index" as="xs:string">
    <xsl:param name="row" as="xs:integer"/>
    <xsl:param name="col" as="xs:integer"/>
    <xsl:sequence select="concat(local:number2alpha-index($col), string($row))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:number2alpha-index" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$number le $char-index-max">
        <xsl:sequence select="local:number2alpha($number)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current" as="xs:integer" select="$number mod $char-index-max"/>
        <xsl:variable name="remainder" as="xs:integer" select="xs:integer(floor($number div $char-index-max))"/>
        <xsl:sequence select="concat(local:number2alpha-index($remainder), local:number2alpha($current))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:number2alpha" as="xs:string">
    <xsl:param name="number" as="xs:integer"/>
    <!-- $number is supposed to be in-between 1 and $char-index-max! -->
    <xsl:sequence select="codepoints-to-string($number - 1 + $codepoint-A)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:warning-prevention-dummy-template | xtlmso:warning-prevention-dummy-template"/>

</xsl:stylesheet>

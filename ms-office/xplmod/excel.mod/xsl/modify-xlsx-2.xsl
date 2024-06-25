<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xtpxplib="http://www.xatapult.nl/namespaces/common/xproc/library"
  xmlns:mso-wb="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:mso-rels="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns:local="#local-998hy5" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Sorts the worksheet data and removes doubles.	
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <!-- ================================================================== -->

  <xsl:template match="xtlcon:document/mso-wb:worksheet/mso-wb:sheetData[xs:boolean(@xtlmso:MODIFIED)]"
    xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
    <!-- We only need to handle modified sections (identified with @xtlxo:MODIFIED="true"). We take this attribute off again. -->

    <xsl:copy>
      <xsl:copy-of select="@* except @xtlmso:MODIFIED"/>

      <!-- Take all rows with the same row number together: -->
      <xsl:for-each-group select="mso-wb:row" group-by="xs:integer(@r)">
        <xsl:sort select="xs:integer(@r)"/>
        <row>
          <!-- Remark: The next instruction copies *all* attributes of all current rows (this removes attribute doubles automatically). 
            The effect is that when we are merging any existing rows (some created by Excel), we automatically get all those non-understood, 
            Excel generated, maybe relevant, attributes in. -->
          <xsl:copy-of select="current-group()/@*"/>

          <!-- Within these rows, sort the cells and remove doubles: -->
          <xsl:for-each-group select="current-group()/mso-wb:c" group-by="@r">
            <xsl:sort select="local:row-order(xs:string(@r))"/>
            <c>
              <!-- Copy again all attributes of the cells for this coordinate but retain the @t value (type of the cell) of 
                the one we're actually going to use: -->
              <xsl:copy-of select="current-group()/@* except current-group()/@t"/>
              <xsl:copy-of select="current-group()[1]/@t"/>
              <xsl:copy-of select="current-group()[1]/*"/>
            </c>
          </xsl:for-each-group>

        </row>
      </xsl:for-each-group>
    </xsl:copy>

  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:row-order" as="xs:integer">
    <xsl:param name="row-name" as="xs:string">
      <!-- This is an Excel row name, like A3 or AA3. -->
    </xsl:param>
    <xsl:sequence select="local:_row-order(0, string-to-codepoints($row-name))"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:_row-order" as="xs:integer">
    <xsl:param name="value-sofar" as="xs:integer"/>
    <xsl:param name="row-name-codepoints" as="xs:integer*"/>
    
    <xsl:choose>
      <xsl:when test="empty($row-name-codepoints)">
        <xsl:sequence select="$value-sofar"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-value" as="xs:integer" select="$row-name-codepoints[1]"/>
        <xsl:sequence select="local:_row-order(($value-sofar * 256) + $current-value, subsequence($row-name-codepoints, 2))"/>
      </xsl:otherwise>  
    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template match="xtlcon:warning-prevention-dummy-template | xtlmso:warning-prevention-dummy-template"/>

</xsl:stylesheet>

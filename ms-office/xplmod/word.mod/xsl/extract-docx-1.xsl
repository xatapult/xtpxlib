<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns="http://www.xtpxlib.nl/ns/ms-office" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    /TBD: Description/		
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../../xslmod/ms-office.mod.xsl"/>

  <xsl:param name="debug" as="xs:string" required="no" select="string(false())"/>

  <xsl:variable name="extracted-office-xml" as="element(xtlcon:document-container)" select="/*"/>
  <xsl:variable name="do-debug" as="xs:boolean" select="xtlc:str2bln($debug, false())"/>

  <!-- ================================================================== -->

  <xsl:template match="/*">


    <!-- Find the main document: -->
    <xsl:variable name="main-document" as="element(w:document)"
      select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, '', $xtlmso:relationship-type-main-document, true())"/>
    <document dref="{/*/@dref-source-zip}" timestamp="{current-dateTime()}">

      <!-- Get the properties: -->
      <xsl:call-template name="xtlmso:get-properties">
        <xsl:with-param name="extracted-office-xml" select="$extracted-office-xml"/>
      </xsl:call-template>

      <!-- Convert the main body: -->
      <xsl:apply-templates select="$main-document/w:body/*" mode="mode-main-convert"/>

    </document>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text() | processing-instruction() | comment()" mode="mode-main-convert">
    <!-- Remove here... -->
  </xsl:template>

  <!-- ================================================================== -->
  <!-- PARAGRAPH: -->

  <xsl:template match="w:p[not(local:p-is-header-footer(.))]" mode="mode-main-convert">
    <p>

      <!-- Create additional the information for the paragraph: -->
      <xsl:variable name="class" as="xs:string?" select="w:pPr/w:pStyle/@w:val"/>
      <xsl:if test="normalize-space($class) ne ''">
        <xsl:attribute name="class" select="$class"/>
      </xsl:if>

      <xsl:variable name="indent-left" as="xs:string?" select="w:pPr/w:ind/@w:left"/>
      <xsl:if test="normalize-space($indent-left) ne ''">
        <xsl:attribute name="indent-left" select="$indent-left"/>
      </xsl:if>

      <xsl:variable name="indent-level" as="xs:string?" select="w:pPr/w:numPr/w:ilvl/@w:val"/>
      <xsl:if test="normalize-space($indent-level) ne ''">
        <xsl:attribute name="indent-level" select="$indent-level"/>
      </xsl:if>

      <xsl:attribute name="xml:space" select="'preserve'"/>

      <!-- And the contents for the paragraph: -->
      <xsl:for-each select="w:r | w:hyperlink/w:r">
        <xsl:variable name="classes" as="xs:string*" select="local:get-run-classes(.)"/>
        <xsl:choose>
          <xsl:when test="exists($classes)">
            <span class="{string-join($classes, ' ')}">
              <xsl:value-of select="w:t"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="w:t"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </p>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- TABLES: -->

  <xsl:template match="w:tbl" mode="mode-main-convert">
    <table>
      <xsl:apply-templates mode="#current"/>
    </table>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="w:tr" mode="mode-main-convert">
    <tr>
      <xsl:apply-templates mode="#current"/>
    </tr>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="w:tc" mode="mode-main-convert">
    <td>
      <xsl:apply-templates mode="#current"/>
    </td>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:p-is-header-footer" as="xs:boolean">
    <xsl:param name="p" as="element(w:p)"/>

    <xsl:sequence select="exists($p/w:pPr/w:sectPr/(w:headerReference | w:footerReference))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-run-classes" as="xs:string*">
    <xsl:param name="run" as="element(w:r)"/>

    <xsl:for-each select="$run/w:rPr">

      <!-- Bold, italic, underline: -->
      <xsl:if test="exists(w:b)">
        <xsl:sequence select="'b'"/>
      </xsl:if>
      <xsl:if test="exists(w:i)">
        <xsl:sequence select="'i'"/>
      </xsl:if>
      <xsl:if test="exists(w:u)">
        <xsl:sequence select="'u'"/>
      </xsl:if>

      <!-- Specific class: -->
      <xsl:variable name="specific-style" as="xs:string?" select="w:rStyle/@w:val"/>
      <xsl:if test="normalize-space($specific-style) ne ''">
        <xsl:sequence select="$specific-style"/>
      </xsl:if>

    </xsl:for-each>

  </xsl:function>

</xsl:stylesheet>

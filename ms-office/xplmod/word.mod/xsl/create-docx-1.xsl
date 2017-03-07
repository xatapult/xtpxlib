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

  <!-- Find the two parts in the container we have to merge: -->
  <xsl:variable name="main-word-document" as="element(w:document)"
    select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, '', $xtlmso:relationship-type-main-document, true())"/>
  <xsl:variable name="xtpxlib-word-xml-document" as="element(xtlmso:document)" select="/*/xtlcon:document[@document-type eq 'xtpxlib-word-xml']/*"/>

  <!-- ================================================================== -->

  <xsl:template match="@* | node()">
    <!-- Remark: Never do a copy-namespaces="no". This makes the output invalid... -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="w:document[. is $main-word-document]/w:body">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <!-- Keep the contents what is in the template (this will also preserve the headers and footers): -->
      <xsl:apply-templates/>

      <!-- Add new content: -->
      <xsl:if test="$do-debug">
        <w:p>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space="preserve">CONVERTED: <xsl:value-of select="current-dateTime()"/></w:t>
          </w:r>
        </w:p>
      </xsl:if>
      <xsl:apply-templates select="$xtpxlib-word-xml-document/*" mode="mode-process-contents"/>

    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- PROCESS MAIN CONTENTS: -->

  <xsl:template match="xtlmso:p" mode="mode-process-contents">
    <w:p>

      <xsl:if test="normalize-space(@class) ne ''">
        <w:pPr>
          <w:pStyle w:val="{@class}"/>
        </w:pPr>
      </xsl:if>

      <xsl:apply-templates mode="mode-process-inline"/>

    </w:p>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" priority="-10" mode="mode-process-contents">
    <!-- Ignore for now... -->
  </xsl:template>

  <!-- ================================================================== -->
  <!-- PROCESS INLINE STUFF: -->

  <xsl:template match="text()" mode="mode-process-inline">
    <w:r>
      <w:t xml:space="preserve"><xsl:copy/></w:t>
    </w:r>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlmso:span" mode="mode-process-inline">
    <w:r>
      <xsl:call-template name="span-class-list-to-run-properties">
        <xsl:with-param name="span-class-list" select="@class"/>
      </xsl:call-template>
      <w:t xml:space="preserve"><xsl:copy-of select="text()"/></w:t>
    </w:r>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" priority="-10" mode="mode-process-inline">
    <!-- Ignore for now... -->
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="span-class-list-to-run-properties" as="element(w:rPr)?">
    <xsl:param name="span-class-list" as="xs:string" required="yes"/>

    <xsl:variable name="span-classes" as="xs:string*" select="xtlc:str2seq($span-class-list)"/>
    <xsl:if test="exists($span-classes)">
      <w:rPr>
        <xsl:call-template name="span-classes-to-run-properties">
          <xsl:with-param name="span-classes" select="$span-classes"/>
        </xsl:call-template>
      </w:rPr>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="span-classes-to-run-properties" as="element()*">
    <xsl:param name="span-classes" as="xs:string*" required="yes"/>

    <xsl:if test="exists($span-classes)">

      <xsl:variable name="span-class" as="xs:string" select="$span-classes[1]"/>
      <xsl:choose>
        <xsl:when test="$span-class eq 'b'">
          <w:b/>
        </xsl:when>
        <xsl:when test="$span-class eq 'i'">
          <w:i/>
        </xsl:when>
        <xsl:when test="$span-class eq 'u'">
          <w:u w:val="single"/>
        </xsl:when>
        <xsl:otherwise>
          <w:rStyle w:val="{$span-class}"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="span-classes-to-run-properties">
        <xsl:with-param name="span-classes" select="subsequence($span-classes, 2)"/>
      </xsl:call-template>

    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlc:warning-prevention-dummy-template"/>

</xsl:stylesheet>

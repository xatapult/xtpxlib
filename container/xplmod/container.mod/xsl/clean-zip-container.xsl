<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Cleans some paths and other stuff in the zip container.
    Explicitly keep all namespace information (no copy-namespaces="no") to allow copying office stuff.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  
  <xsl:param name="add-document-target-paths" as="xs:string" required="yes"/>
  <xsl:param name="dref-target-path" as="xs:string" required="yes"/>
  
  <xsl:variable name="do-add-document-target-paths" as="xs:boolean" select="xtlc:str2bln($add-document-target-paths, true())"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@* except @dref-source-zip"/>
      
      <xsl:if test="normalize-space($dref-target-path) ne ''">
        <xsl:attribute name="dref-target-path" select="$dref-target-path"/>
      </xsl:if>
      
      <xsl:attribute name="dref-source-zip" select="xtlc:protocol-add(xtlc:dref-canonical(@dref-source-zip), $xtlc:protocol-file, true())"/>
      
      <xsl:apply-templates/>
      
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xtlcon:*[exists(@dref-source)]">
    <xsl:copy>
      <xsl:copy-of select="@* except @dref-source"/>
      
      <xsl:variable name="dref-source-raw" as="xs:string" select="@dref-source"/>
      <xsl:variable name="dref-source" as="xs:string"
        select="if (starts-with($dref-source-raw, '/')) then substring($dref-source-raw, 2) else $dref-source-raw"/>
      
      <xsl:attribute name="dref-source" select="$dref-source"/>
      
      <xsl:if test="$do-add-document-target-paths">
        <xsl:attribute name="dref-target" select="$dref-source"/>
      </xsl:if>
      
      <xsl:apply-templates/>
      
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Flattens the retrieved directory list into a long list of files.
    Each file gets a relative and absolute path. 
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../xslmod/common.mod.xsl"/>
  <xsl:include href="../../../xslmod/dref.mod.xsl"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="@* | node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="/c:directory[not(xtlc:str2bln(@error, false()))]">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@* except @xml:base" copy-namespaces="no"/>
      
      <xsl:variable name="base-dir" as="xs:string" select="xtlc:dref-canonical(@xml:base)"/>
      <xsl:attribute name="xml:base" select="$base-dir"/>
      
      <xsl:for-each select=".//c:file">
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="@name" copy-namespaces="no"/>
          
          <xsl:variable name="dref-abs" as="xs:string" select="xtlc:dref-canonical(xtlc:dref-concat((../@xml:base, @name)))"/>
          <xsl:attribute name="dref-abs" select="$dref-abs"/>
          <xsl:attribute name="dref-rel" select="xtlc:dref-relative-from-path($base-dir, $dref-abs)"/>
          
        </xsl:copy>
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Creates the manifest necessary for creating the zip file	
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:param name="include-base" as="xs:string" required="yes"/>
  
  <xsl:include href="../../../xslmod/common.mod.xsl"/>
  <xsl:include href="../../../xslmod/dref.mod.xsl"/>
  
  <xsl:variable name="do-include-base" as="xs:boolean" select="xtlc:str2bln($include-base, true())"/>
  
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  
  <xsl:template match="/*" xmlns="http://www.w3.org/ns/xproc-step">
    
    <xsl:variable name="base-raw" as="xs:string"
      select="if (ends-with(@xml:base, '/')) then substring(@xml:base, 1, string-length(@xml:base) - 1) else string(@xml:base)"/>
    <xsl:variable name="base" as="xs:string" select="xtlc:dref-path($base-raw)"/>
    
    <zip-manifest>
      <xsl:for-each select="//c:file">
        
        <xsl:variable name="name-for-href" as="xs:string" select="xtlc:dref-concat(ancestor-or-self::*/@name)"/>
        <xsl:variable name="name" as="xs:string">
          <xsl:choose>
            <xsl:when test="$do-include-base">
              <xsl:sequence select="$name-for-href"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="xtlc:dref-concat(subsequence(ancestor-or-self::*/@name, 2))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <entry name="{$name}" href="{xtlc:dref-to-uri(xtlc:dref-concat(($base, $name-for-href)))}"/>
        
      </xsl:for-each>
    </zip-manifest>
    
  </xsl:template>
  
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Reorders a directory list so all files/directories are in order for removal.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../xslmod/common.mod.xsl"/>
  <xsl:include href="../../../xslmod/dref.mod.xsl"/>
  
  <xsl:variable name="minimum-slash-count" as="xs:integer" select="2"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/c:directory[not(xtlc:str2bln(@error, false()))]">
    
    <!-- Do a little sanity check: -->
    <xsl:variable name="main-dref" as="xs:string" select="xtlc:protocol-remove(xtlc:dref-canonical(/*/@xml:base))"/>
    <xsl:variable name="slashcount" as="xs:integer" select="string-length(replace($main-dref, '[^/]', ''))"/>
    <xsl:choose>
      <xsl:when test="not(xtlc:dref-is-absolute($main-dref))">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Directory to remove &quot;', $main-dref, '&quot; is not absolute')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$slashcount le $minimum-slash-count">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Directory to remove &quot;', $main-dref, '&quot; must be further away from root (must contain at least ', 
              string($minimum-slash-count), ' slashes)')"
          />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    <!-- Ok, go: -->
    <removals>
      <xsl:for-each select="//(c:file | c:directory)">
        <xsl:sort select="count(ancestor-or-self::*)" order="descending"/>
        
        <xsl:variable name="dref-full-1" as="xs:string">
          <xsl:choose>
            <xsl:when test="self::c:directory">
              <xsl:sequence select="@xml:base"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="xtlc:dref-concat((../@xml:base, @name))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dref-full-2" as="xs:string" select="xtlc:protocol-add(xtlc:dref-canonical($dref-full-1), $xtlc:protocol-file, true())"/>
        
        <remove dref="{xtlc:dref-to-uri($dref-full-2)}"/>
        
      </xsl:for-each>
    </removals>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="/*" priority="-10">
    <removals/>
  </xsl:template>
  
</xsl:stylesheet>

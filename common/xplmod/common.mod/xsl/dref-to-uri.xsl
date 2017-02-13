<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Transforms dref to uri
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../xslmod/dref.mod.xsl"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@dref"/>
      <xsl:attribute name="uri" select="xtlc:dref-to-uri(@dref)"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

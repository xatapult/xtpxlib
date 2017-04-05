<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dnb_bhp_3z" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Just creates some simple XML output thingy
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xwebgen-report>
      <xsl:copy-of select="/*/@*" copy-namespaces="no"/>
    </xwebgen-report>
  </xsl:template>
  
  
</xsl:stylesheet>

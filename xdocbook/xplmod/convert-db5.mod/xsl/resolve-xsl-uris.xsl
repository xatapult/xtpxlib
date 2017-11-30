<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Converts all xtlxdb:convert/@xsl into absolute uris
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../../xslmod/xdocbook-lib.xsl"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlxdb:convert/@xsl"> 
    <xsl:attribute name="{local-name(.)}" select="xtlxdb:get-full-uri(.., .)"/>
  </xsl:template>

</xsl:stylesheet>

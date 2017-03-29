<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dnb_bhp_3zxx" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Prepares for the copy directory step
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xslmod/xwebgen-lib.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBALS -->

  <xsl:variable name="base-input-dir" as="xs:string" select="/*/@base-input-dir"/>
  <xsl:variable name="base-output-dir" as="xs:string" select="/*/@base-output-dir"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlwg:xwebgen-specification/xtlwg:copy-dir">

    <xsl:variable name="dref-source-dir-raw" as="xs:string" select="@dref-source-dir"/>
    <xsl:variable name="dref-target-dir-raw" as="xs:string" select="(@dref-target-dir, $dref-source-dir-raw)[1]"/>

    <xsl:copy>
      <xsl:attribute name="dref-source-dir" select="xtlc:dref-concat(($base-input-dir, $dref-source-dir-raw))"/>
      <xsl:attribute name="dref-target-dir" select="xtlc:dref-concat(($base-output-dir, $dref-target-dir-raw))"/>
    </xsl:copy>

  </xsl:template>

</xsl:stylesheet>

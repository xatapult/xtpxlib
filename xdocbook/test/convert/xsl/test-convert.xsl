<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.mlj_x3g_1cb" exclude-result-prefixes="#all" xmlns="" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <para role="keep-with-next">
      <xsl:value-of select="."/>
    </para>
  </xsl:template>

</xsl:stylesheet>

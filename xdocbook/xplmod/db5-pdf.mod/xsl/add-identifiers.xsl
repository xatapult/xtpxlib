<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Adds an identifier to every element (all is too much but just to be sure...)		
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="db:*[empty(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:id" select="generate-id(.)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

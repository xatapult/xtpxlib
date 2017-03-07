<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*
    Master file for use in oXygen projects. Chains all XSLT libraries in the right order.
	-->
  <!-- ================================================================== -->
 
  <xsl:include href="../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../common/xslmod/message.mod.xsl"/>
  <xsl:include href="../../common/xslmod/mimetypes.mod.xsl"/>
  <xsl:include href="../../common/xslmod/uri.mod.xsl"/>
  <xsl:include href="../../common/xslmod/uuid.mod.xsl"/>    
  <xsl:include href="../../common/xslmod/parameters.mod.xsl"/>
  <xsl:include href="../../common/xslmod/compare.mod.xsl"/>
  
  <xsl:include href="../../ms-office/xslmod/ms-office.mod.xsl"/>
  
</xsl:stylesheet>



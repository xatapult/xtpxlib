<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dnb_bhp_3z" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Creates the pages in the specification document
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../xslmod/xwebgen-lib.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="filter-attributes" as="attribute()*" select="/*/@xtlwg:*"/>
  <xsl:variable name="base-input-dir" as="xs:string" select="/*/@base-input-dir"/>
  <xsl:variable name="base-output-dir" as="xs:string" select="/*/@base-output-dir"/>

  <xsl:variable name="specification-document" as="element(xtlwg:xwebgen-specification)" select="/*/xtlcon:document/xtlwg:xwebgen-specification"/>

  <!-- ================================================================== -->

  <xsl:template match="/*">
    
    <!-- TBD: Pre-flight check on exists pages  -->
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()"/>
      <xsl:for-each select="$specification-document/xtlwg:page">
        <xsl:call-template name="create-page"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- PAGE CREATION: -->

  <xsl:template name="create-page">
    <!-- Creates an xtlcon:document for a page -->
    <xsl:param name="page-specification-element" as="element(xtlwg:page)" required="no" select="."/>

    <xsl:for-each select="$page-specification-element">

    <!-- Gather all the basic data: -->
      <xsl:variable name="dref-target" as="xs:string" select="xtlc:dref-canonical(xtlc:dref-concat(($base-output-dir, @dref-target)))"/>
      <xsl:variable name="dref-section-document" as="xs:string"
        select="xtlc:dref-canonical(xtlc:dref-concat(($base-input-dir, @dref-section-document)))"/>
      <xsl:variable name="section-idref" as="xs:string?" select="@section-idref"/>
      <xsl:variable name="template-idref" as="xs:string" select="@template-idref"/>
      <!-- 
        - Find template id (check!) and compute the right location
        - Get all properties (local ones first)
        - Get the template (recursively processing section includes) ==> named template
        - Get the section with the main contents (recursively processing section includes)
        - Merge the two (a template contains a <xtlwg:contents> element ?????
      -->
    </xsl:for-each>

  </xsl:template>


</xsl:stylesheet>

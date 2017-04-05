<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dnb_bhp_3zxx" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Creates the pages in the specification document
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="local:mode-page-contents-expand" on-no-match="shallow-copy"/>

  <xsl:include href="../../../xslmod/xwebgen-lib.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="filter-attributes" as="attribute()*" select="/*/@xtlwg:*"/>
  <xsl:variable name="base-input-dir" as="xs:string" select="/*/@base-input-dir"/>
  <xsl:variable name="base-output-dir" as="xs:string" select="/*/@base-output-dir"/>

  <xsl:variable name="dref-specification-document" as="xs:string" select="/*/@dref-specification"/>
  <xsl:variable name="specification-document" as="element(xtlwg:xwebgen-specification)" select="/*/xtlcon:document/xtlwg:xwebgen-specification"/>

  <!-- ================================================================== -->

  <xsl:template match="/*">

    <!--Pre-flight check on exists pages and templates: -->
    <xsl:if test="empty($specification-document/xtlwg:page)">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts"
          select="('No page specifications found in pre-processed specification ', xtlc:q($dref-specification-document))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="empty($specification-document/xtlwg:template)">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts"
          select="('No template specifications found in pre-processed specification ', xtlc:q($dref-specification-document))"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Go and create: -->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()"/>
      <xsl:for-each select="$specification-document/xtlwg:page">
        <xsl:call-template name="create-page">
          <xsl:with-param name="global-properties" select="$specification-document/xtlwg:properties/xtlwg:property"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:copy>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- PAGE CREATION: -->

  <xsl:template name="create-page" xmlns="http://www.xtpxlib.nl/ns/container">
    <!-- Creates an xtlcon:document for a page -->
    <xsl:param name="page-specification-element" as="element(xtlwg:page)" required="no" select="."/>
    <xsl:param name="global-properties" as="element(xtlwg:property)*" required="yes"/>

    <xsl:for-each select="$page-specification-element">

      <!-- Gather all the basic data: -->
      <xsl:variable name="dref-target" as="xs:string" select="xtlc:dref-canonical(xtlc:dref-concat(($base-output-dir, @dref-target)))"/>
      <xsl:variable name="dref-section-document" as="xs:string"
        select="xtlc:dref-canonical(xtlc:dref-concat(($base-input-dir, @dref-section-document)))"/>
      <xsl:variable name="section-idref" as="xs:string?" select="@section-idref"/>
      <xsl:variable name="template-idref" as="xs:string" select="@template-idref"/>
      <xsl:variable name="page-properties" as="element(xtlwg:property)*" select="(xtlwg:properties/xtlwg:property, $global-properties)"/>

      <!-- Get the template, pre-processed: -->
      <xsl:variable name="template-specification" as="element(xtlwg:template)?"
        select="($specification-document/xtlwg:template[@id eq $template-idref])[1]"/>
      <xsl:if test="empty($template-specification)">
        <xsl:call-template name="xtlwg:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Template id=', xtlc:q($template-idref), ' not found in pre-processed specification ', xtlc:q($dref-specification-document))"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="dref-template" as="xs:string" select="xtlc:dref-concat(($base-input-dir, $template-specification/@dref-source))"/>
      <xsl:if test="not(doc-available($dref-template))">
        <xsl:call-template name="xtlwg:raise-error">
          <xsl:with-param name="msg-parts" select="('Template document ', xtlc:q($dref-template), ' not found')"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="template-document" as="element()">
        <xsl:call-template name="xtlwg:pre-process-and-expand-sections">
          <xsl:with-param name="item" select="$dref-template"/>
          <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
          <xsl:with-param name="properties" select="($template-specification/xtlwg:properties/xtlwg:property, $page-properties)"/>
          <xsl:with-param name="base-dir-for-section-expansion" select="xtlc:dref-path($dref-template)"/>
        </xsl:call-template>
      </xsl:variable>

      <!-- Create the document in the container: -->
      <document document-type="{$xtlwg:document-type-page}" dref-target="{$dref-target}" template-id="{$template-idref}"
        dref-template="{$dref-template}" dref-section-document="{$dref-section-document}" section-idref="{$section-idref}">
        <!-- Create the page document by expanding the <page-contents-expand> element in the template: -->
        <xsl:apply-templates select="$template-document" mode="local:mode-page-contents-expand">
          <xsl:with-param name="page-specification-element" as="element(xtlwg:page)" select="$page-specification-element" tunnel="yes"/>
          <xsl:with-param name="base-dir-for-section-expansion" as="xs:string" select="$base-input-dir" tunnel="yes"/>
          <xsl:with-param name="filter-attributes" as="attribute()*" select="$filter-attributes" tunnel="yes"/>
          <xsl:with-param name="properties" as="element(xtlwg:property)*" select="$page-properties" tunnel="yes"/>
        </xsl:apply-templates>
      </document>

    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlwg:page-contents-expand" mode="local:mode-page-contents-expand">
    <xsl:param name="page-specification-element" as="element(xtlwg:page)" required="yes" tunnel="yes"/>
    <xsl:param name="base-dir-for-section-expansion" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes" tunnel="yes"/>
    <xsl:param name="properties" as="element(xtlwg:property)*" required="yes" tunnel="yes"/>

    <xsl:variable name="dref-section-document" as="xs:string"
      select="xtlc:dref-concat(($base-dir-for-section-expansion, $page-specification-element/@dref-section-document))"/>
    <xsl:call-template name="xtlwg:get-section-contents">
      <xsl:with-param name="dref-section-document" select="$dref-section-document"/>
      <xsl:with-param name="section-idref" select="$page-specification-element/@section-idref"/>
      <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
      <xsl:with-param name="properties" select="(xtlwg:properties/xtlwg:property, $properties)"/>
      <xsl:with-param name="dref-base-dir" select="$base-dir-for-section-expansion"/>
    </xsl:call-template>

  </xsl:template>


</xsl:stylesheet>

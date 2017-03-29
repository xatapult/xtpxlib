<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dnb_bhp_3z" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
    Takes an xwebgen specification document, pre-processes it and puts this into a xtpxlib container.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../../xslmod/xwebgen-lib.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="dref-specification" as="xs:string" required="yes"/>
  <xsl:param name="filterstring" as="xs:string" required="yes"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/*" xmlns="http://www.xtpxlib.nl/ns/container">

    <!-- Pre-flight check: -->
    <xsl:variable name="dref-specification-normalized" as="xs:string" select="xtlc:dref-canonical($dref-specification)"/>
    <xsl:variable name="dref-specification-basedir" as="xs:string" select="xtlc:dref-path($dref-specification-normalized)"/>
    <xsl:if test="not(doc-available($dref-specification))">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts" select="'Specification document ', xtlc:q($dref-specification-normalized), ' not found'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="empty(self::xtlwg:xwebgen-specification)">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts" select="'Document ', xtlc:q($dref-specification-normalized), ' is not a xwebgen specification'"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Dissect the filterstring into separate attributes: -->
    <xsl:variable name="filterstring-parts" as="xs:string*" select="tokenize($filterstring, '\|')"/>
    <xsl:variable name="filter-attributes" as="attribute()*">
      <xsl:for-each select="1 to count($filterstring-parts)">
        <xsl:variable name="pos" as="xs:integer" select="."/>
        <xsl:variable name="is-attribute-name" as="xs:boolean" select="(($pos mod 2) eq 1)"/>
        <xsl:if test="$is-attribute-name">
          <xsl:attribute name="{normalize-space($filterstring-parts[$pos])}" select="normalize-space($filterstring-parts[$pos + 1])"
            namespace="{$xtlwg:xwebgen-namespace}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Pre-process the specification file: -->
    <xsl:variable name="pre-processed-specification" as="element(xtlwg:xwebgen-specification)">
      <xsl:call-template name="xtlwg:pre-process">
        <xsl:with-param name="item" select="/*"/>
        <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Get the absolute names of the base in- and output directory: -->
    <xsl:variable name="base-input-dir" as="xs:string" select="xtlc:dref-path($dref-specification-normalized)"/>
    <xsl:variable name="base-output-dir" as="xs:string"
      select="xtlc:dref-canonical(xtlc:dref-concat(($base-input-dir, $pre-processed-specification/@dref-base-output-dir)))"/>

    <!-- Create the container structure: -->
    <document-container timestamp="{current-dateTime()}" filterstring="{$filterstring}">

      <!-- Record some stuff on the root of the container for easy access: -->
      <xsl:attribute name="base-input-dir" select="$base-input-dir"/>
      <xsl:attribute name="base-output-dir" select="$base-output-dir"/>
      <xsl:attribute name="dref-specification" select="$dref-specification-normalized"/>
      <xsl:copy-of select="$filter-attributes"/>

      <document dref-source="{$dref-specification-normalized}" document-type="{$xtlwg:document-type-specification}">
        <xsl:copy-of select="$pre-processed-specification" copy-namespaces="no"/>
      </document>

    </document-container>

  </xsl:template>

</xsl:stylesheet>

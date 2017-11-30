<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.dbx_bzf_1cb" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--	
       Library with functions for the xdocbook module of xtpxlib
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlxdb:xtlxdb-namespace" as="xs:string" select="'http://www.xtpxlib.nl/ns/xdocbook'"/>
  <xsl:variable name="xtlxdb:docbook-namespace" as="xs:string" select="'http://docbook.org/ns/docbook'"/>

  <!-- ================================================================== -->
  <!-- SUPPORT FUNCTIONS AND TEMPLATES: -->

  <xsl:function name="xtlxdb:get-full-uri" as="xs:string">
    <!-- Turns a href into a full path  by looking at the @xml:base attributes on $originating-elm and its ancestors. 
      If this fails (no @xml:base), it tries the standard resolve-uri(). -->
    <xsl:param name="originating-elm" as="element()"/>
    <xsl:param name="href" as="xs:string"/>

    <xsl:variable name="xml-bases" as="xs:string*" select="$originating-elm/ancestor-or-self::*/@xml:base"/>
    <xsl:choose>
      <xsl:when test="xtlc:dref-is-absolute($href)">
        <xsl:sequence select="$href"/>
      </xsl:when>
      <xsl:when test="exists($xml-bases)">
        <xsl:sequence select="xtlc:dref-concat((for $base in $xml-bases return xtlc:dref-path($base), $href))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="resolve-uri($href, base-uri($originating-elm))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:mode name="xtlxdb:mode-output-docbook-contents" on-no-match="shallow-copy"/>

  <xsl:template name="xtlxdb:convert-to-docbook-contents">
    <!-- Will turn all elements in $elms in the $convert-namespaces namespaces into the docbook namespace -->
    <xsl:param name="elms" as="element()*" required="yes"/>
    <xsl:param name="convert-namespaces" as="xs:string*" required="yes"/>

    <xsl:apply-templates select="$elms" mode="xtlxdb:mode-output-docbook-contents">
      <xsl:with-param name="convert-namespaces" as="xs:string*" select="$convert-namespaces" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="xtlxdb:mode-output-docbook-contents">
    <xsl:param name="convert-namespaces" as="xs:string*" required="yes" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="string(namespace-uri(.)) = $convert-namespaces">
        <xsl:element name="{local-name(.)}" namespace="{$xtlxdb:docbook-namespace}">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

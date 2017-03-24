<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:local="#local.fyc_xhp_3z" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--	
       Library for the xwebgen module of xtpxlib.
	-->
  <!-- ================================================================== -->
  <!-- SETUP -->

  <xsl:mode name="local:filter-elements" on-no-match="shallow-copy"/>

  <xsl:include href="../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../common/xslmod/dref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlwg:xwebgen-namespace" as="xs:string" select="'http://www.xtpxlib.nl/ns/xwebgen'"/>

  <xsl:variable name="xtlwg:document-type-specification" as="xs:string" select="'specification'"/>

  <!-- ================================================================== -->
  <!-- FILTERING: -->

  <xsl:template name="xtlwg:filter-elements">
    <xsl:param name="elements" as="element()*" required="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes"/>

    <xsl:apply-templates select="$elements" mode="local:filter-elements">
      <xsl:with-param name="filter-attributes" as="attribute()*" select="$filter-attributes" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*[exists(@xtlwg:*)]" mode="local:filter-elements">
    <xsl:param name="filter-attributes" as="attribute()*" required="yes" tunnel="yes"/>

    <xsl:variable name="current-element" as="element()" select="."/>
    <xsl:variable name="copy-through" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="empty($filter-attributes)">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="filter-results" as="xs:boolean*">
            <xsl:for-each select="$filter-attributes">
              <xsl:variable name="filter-name" as="xs:string" select="local-name(.)"/>
              <xsl:variable name="filter-value" as="xs:string" select="normalize-space(.)"/>
              <xsl:variable name="filter-attribute-on-element" as="attribute()?" select="$current-element/@xtlwg:*[local-name(.) eq $filter-name]"/>
              <xsl:sequence
                select="if (empty($filter-attribute-on-element)) then () else (normalize-space($filter-attribute-on-element) eq $filter-value)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:sequence select="every $filter-result in $filter-results satisfies $filter-result"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$copy-through">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:if>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- GENERIC SUPPORT: -->

  <xsl:template name="xtlwg:raise-error">
    <xsl:param name="msg-parts" as="item()*" required="yes"/>

    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="('xwebgen: ', $msg-parts)"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

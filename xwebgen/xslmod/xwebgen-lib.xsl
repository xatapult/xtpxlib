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

  <xsl:mode name="local:mode-pre-process" on-no-match="shallow-copy"/>
  <xsl:mode name="local:mode-pre-process-and-expand-sections" on-no-match="shallow-copy"/>

  <xsl:include href="../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../common/xslmod/dref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- EXPORTED DECLARATIONS: -->

  <xsl:variable name="xtlwg:xwebgen-namespace" as="xs:string" select="'http://www.xtpxlib.nl/ns/xwebgen'"/>

  <!-- Document types in the xtpxlib container: -->
  <xsl:variable name="xtlwg:document-type-specification" as="xs:string" select="'specification'"/>
  <xsl:variable name="xtlwg:document-type-page" as="xs:string" select="'page'"/>

  <!-- ================================================================== -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:variable name="local:pre-process-property-expand-regexp" as="xs:string" select="'\$\{(\c+)\}'"/>

  <!-- ================================================================== -->
  <!-- PRE-PROCESSING:: -->

  <xsl:template name="xtlwg:pre-process" as="element()">
    <!--* Pre-process a chunk of XML:  
          - Filters on the filter attributes
          - Expands properties (including the properties created from the filter attributes)
          You can pass in any item to designate the XML chunk. This dereferenced using xtlc:item2element().
    -->
    <xsl:param name="item" as="item()" required="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes"/>
    <xsl:param name="properties" as="element(xtlwg:property)*" required="no" select="()"/>

    <!-- Expand the properties with properties created from the filter attributes: -->
    <xsl:variable name="filter-attribute-properties" as="element(xtlwg:property)*">
      <xsl:for-each select="$filter-attributes">
        <xtlwg:property id="{local-name(.)}">
          <xsl:value-of select="string(.)"/>
        </xtlwg:property>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="expanded-properties" as="element(xtlwg:property)*" select="($properties, $filter-attribute-properties)"/>

    <xsl:apply-templates select="xtlc:item2element($item, true())" mode="local:mode-pre-process">
      <xsl:with-param name="filter-attributes" as="attribute()*" select="$filter-attributes" tunnel="yes"/>
      <xsl:with-param name="properties" as="element(xtlwg:property)*" select="$expanded-properties" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*[exists(@xtlwg:*)]" mode="local:mode-pre-process" priority="10">
    <!-- Filter elements that have @xtlwg:* attributes set -->
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
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[matches(., $local:pre-process-property-expand-regexp)]" mode="local:mode-pre-process">
    <!-- Expand properties in text nodes -->
    <xsl:param name="properties" as="element(xtlwg:property)*" required="yes" tunnel="yes"/>

    <xsl:value-of select="local:expand-properties(., $properties)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="@*[matches(., $local:pre-process-property-expand-regexp)]" mode="local:mode-pre-process">
    <!-- Expand properties in attribute values -->
    <xsl:param name="properties" as="element(xtlwg:property)*" required="yes" tunnel="yes"/>

    <xsl:attribute name="{name(.)}" select="local:expand-properties(., $properties)"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- PRE-PROCESS + EXPAND SECTIONS: -->

  <xsl:template name="xtlwg:pre-process-and-expand-sections" as="element()">
    <xsl:param name="item" as="item()" required="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes"/>
    <xsl:param name="properties" as="element(xtlwg:property)*" required="no" select="()"/>
    <xsl:param name="base-dir-for-section-expansion" as="xs:string" required="yes"/>

    <xsl:variable name="pre-processed-item" as="element()">
      <xsl:call-template name="xtlwg:pre-process">
        <xsl:with-param name="item" select="$item"/>
        <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
        <xsl:with-param name="properties" select="$properties"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates select="$pre-processed-item" mode="local:mode-pre-process-and-expand-sections">
      <xsl:with-param name="filter-attributes" as="attribute()*" select="$filter-attributes" tunnel="yes"/>
      <xsl:with-param name="properties" as="element(xtlwg:property)*" select="$properties" tunnel="yes"/>
      <xsl:with-param name="base-dir-for-section-expansion" as="xs:string" select="$base-dir-for-section-expansion" tunnel="yes"/>
    </xsl:apply-templates>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlwg:section-expand" mode="local:mode-pre-process-and-expand-sections">
    <xsl:param name="base-dir-for-section-expansion" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes" tunnel="yes"/>
    <xsl:param name="properties" as="element(xtlwg:property)*" required="yes" tunnel="yes"/>

    <xsl:variable name="dref-section-document" as="xs:string" select="@dref-section-document"/>
    <xsl:variable name="section-idref" as="xs:string?" select="@section-idref"/>
    <xsl:variable name="section-properties" as="element(xtlwg:property)*" select="(xtlwg:properties/xtlwg:property, $properties)"/>

    <xsl:call-template name="xtlwg:get-section-contents">
      <xsl:with-param name="dref-section-document" select="xtlc:dref-concat(($base-dir-for-section-expansion, $dref-section-document))"/>
      <xsl:with-param name="section-idref" select="$section-idref"/>
      <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
      <xsl:with-param name="properties" select="$section-properties"/>
      <xsl:with-param name="dref-base-dir" select="$base-dir-for-section-expansion"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- GET SECTION: -->

  <xsl:template name="xtlwg:get-section-contents" as="element()*">
    <xsl:param name="dref-section-document" as="xs:string" required="yes"/>
    <xsl:param name="section-idref" as="xs:string?" required="yes"/>
    <xsl:param name="filter-attributes" as="attribute()*" required="yes"/>
    <xsl:param name="properties" as="element(xtlwg:property)*" required="no" select="()"/>
    <xsl:param name="dref-base-dir" as="xs:string" required="yes"/>

    <!-- Get the section document in: -->
    <xsl:variable name="dref-section-document-canonical" as="xs:string" select="xtlc:dref-canonical($dref-section-document)"/>
    <xsl:if test="not(doc-available($dref-section-document-canonical))">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts" select="('Section document ', xtlc:q($dref-section-document-canonical), ' not found')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="section-document-raw" as="element()?" select="doc($dref-section-document-canonical)/*"/>
    <xsl:if test="empty($section-document-raw) or empty($section-document-raw/self::xtlwg:xwebgen-sections)">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts" select="(xtlc:q($dref-section-document-canonical), ' is not a valid section document')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="base-dir-section-document" as="xs:string" select="xtlc:dref-path($dref-section-document-canonical)"/>

    <!-- Pre-process it: -->
    <xsl:variable name="section-document" as="element()">
      <xsl:call-template name="xtlwg:pre-process-and-expand-sections">
        <xsl:with-param name="item" select="$section-document-raw"/>
        <xsl:with-param name="filter-attributes" select="$filter-attributes"/>
        <xsl:with-param name="properties" select="$properties"/>
        <xsl:with-param name="base-dir-for-section-expansion" select="$base-dir-section-document"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Find the right section: -->
    <xsl:variable name="section-to-process" as="element(xtlwg:section)?">
      <xsl:choose>
        <xsl:when test="string($section-idref) ne ''">
          <xsl:sequence select="($section-document/xtlwg:section[@id eq $section-idref])[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$section-document/xtlwg:section[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="empty($section-to-process)">
      <xsl:call-template name="xtlwg:raise-error">
        <xsl:with-param name="msg-parts" select="('Section id=', xtlc:q($section-idref), ' in document ',xtlc:q($dref-section-document), ' not found')"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Output the section's contents. If it needs to be transformed, add a <xtlwg:TRANSFORM> root element with the absolute 
      reference to the stylesheet: -->
    <xsl:variable name="dref-transformer" as="xs:string?" select="$section-to-process/@dref-transformer"/>
    <xsl:choose>
      <xsl:when test="string($dref-transformer) eq ''">
        <xsl:copy-of select="$section-to-process/*" copy-namespaces="no"/>
      </xsl:when>
      <xsl:otherwise>
        <xtlwg:TRANSFORM dref-transformer="{xtlc:dref-canonical(xtlc:dref-concat(($base-dir-section-document, $dref-transformer)))}">
          <xsl:copy-of select="$section-to-process/*" copy-namespaces="no"/>
        </xtlwg:TRANSFORM>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- GENERIC SUPPORT: -->

  <xsl:function name="local:expand-properties" as="xs:string">
    <xsl:param name="in" as="xs:string"/>
    <xsl:param name="properties" as="element(xtlwg:property)*"/>

    <xsl:variable name="substituted-parts" as="xs:string*">
      <xsl:analyze-string select="$in" regex="{$local:pre-process-property-expand-regexp}">
        <xsl:matching-substring>
          <xsl:variable name="property-id" as="xs:string" select="regex-group(1)"/>
          <xsl:variable name="property" as="element(xtlwg:property)?" select="($properties[@id eq $property-id])[1]"/>
          <xsl:choose>
            <xsl:when test="exists($property)">
              <xsl:sequence select="local:expand-properties(string($property), $properties)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="xtlwg:raise-error">
                <xsl:with-param name="msg-parts" select="('Property ', xtlc:q($property-id), ' not found')"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <xsl:sequence select="string-join($substituted-parts, '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xtlwg:raise-error">
    <xsl:param name="msg-parts" as="item()*" required="yes"/>

    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="('xwebgen: ', $msg-parts)"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

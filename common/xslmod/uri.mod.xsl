<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:local="#local.dref.mod.xsl"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*
    Generic handling of URIs (URLs, web addresses).
    
    Module dependencies: dref.mod.xsl
	-->
  <!-- ================================================================== -->

  <xsl:function name="xtlc:uri-no-anchor" as="xs:string">
    <!--* Returns a URL/URI without an optional anchor part (after the #). -->
    <xsl:param name="href" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>

    <xsl:sequence select="if (contains($href, '#')) then substring-before($href, '#') else $href"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:uri-anchor" as="xs:string">
    <!--* Returns the anchor part of a reference (without the leading #) -->
    <xsl:param name="href" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>

    <xsl:sequence select="if (contains($href, '#')) then substring-after($href, '#') else ''"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:uri-create" as="xs:string">
    <!--* Creates a URI from path components and parameter specifications. -->
    <xsl:param name="uri-parts" as="xs:string+">
      <!--* Parts that concatenated together are the URI. Concatenation is done by xtlc:dref-concat(). -->
    </xsl:param>
    <xsl:param name="params" as="attribute()*">
      <!--* Parameters for the URI as an attribute sequence. See also xtlc:strseq2attseq(). -->
    </xsl:param>

    <xsl:variable name="base-uri" as="xs:string" select="xtlc:dref-concat($uri-parts)"/>
    <xsl:variable name="params-string" as="xs:string">
      <xsl:variable name="parts-string" as="xs:string*">
        <xsl:for-each select="$params">
          <xsl:sequence select="local-name(.)"/>
          <xsl:sequence select="encode-for-uri(string(.))"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:sequence select="string-join($parts-string, '')"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$params-string eq ''">
        <xsl:sequence select="$base-uri"/>
      </xsl:when>
      <xsl:when test="contains($base-uri, '?')">
        <xsl:sequence select="concat($base-uri, '&amp;', $params-string)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat($base-uri, '?', $params-string)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>

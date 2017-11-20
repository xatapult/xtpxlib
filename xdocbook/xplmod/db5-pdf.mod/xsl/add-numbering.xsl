<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Adds numbers (@number) to whatever things need it
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="db:chapter | db:preface">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="chapter-number" as="xs:integer" select="count(preceding-sibling::db:chapter) + count(preceding-sibling::db:preface) + 1"/>
      <xsl:attribute name="number" select="$chapter-number"/>
      <xsl:apply-templates>
        <xsl:with-param name="chapter-number" as="xs:integer" select="$chapter-number" tunnel="true"/>
        <xsl:with-param name="chapter" as="element(db:chapter)" select="." tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sect1 | db:sect2 | db:sect3">
    <xsl:param name="chapter-number" as="xs:integer" required="yes" tunnel="true"/>
    <xsl:param name="section-number-prefix" as="xs:string?" required="no" select="()" tunnel="true"/>

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="section-element-name" as="xs:string" select="local-name(.)"/>
      <xsl:variable name="section-number" as="xs:integer" select="count(preceding-sibling::db:*[local-name(.) eq $section-element-name]) + 1"/>
      <xsl:variable name="section-number-full" as="xs:string" select="string-join(($section-number-prefix, string($section-number)), '.')"/>
      <xsl:attribute name="number" select="string($chapter-number) || '.' || $section-number-full "/>
      <xsl:apply-templates>
        <xsl:with-param name="section-number-prefix" select="$section-number-full" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:table[local:is-numbered(.)] | db:example[local:is-numbered(.)] | db:figure[local:is-numbered(.)]">
    <xsl:call-template name="copy-with-index-number"/>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="copy-with-index-number">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:param name="chapter-number" as="xs:integer" required="yes" tunnel="true"/>
    <xsl:param name="chapter" as="element(db:chapter)" required="yes" tunnel="true"/>

    <!-- Gather a list of all elements with the same name in the chapter and find out where it is: -->
    <xsl:variable name="all-like-elements" as="element()+" select="$chapter//db:*[node-name(.) eq node-name($elm)]"/>
    <xsl:variable name="elm-index" as="xs:integer"
      select="for $index in (1 to count($all-like-elements)) return if ($all-like-elements[$index] is $elm) then $index else ()"/>

    <!-- Copy it, add number: -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="number" select="string($chapter-number) || '-' || string($elm-index)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:is-numbered" as="xs:boolean">
    <xsl:param name="elm" as="element()"/>
    <xsl:sequence select="not('nonumber' = xtlc:str2seq($elm/@role))"/>
  </xsl:function>

</xsl:stylesheet>

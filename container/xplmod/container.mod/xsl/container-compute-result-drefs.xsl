<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Computes the actual paths the container and files must be written to or read from.	
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>

  <xsl:param name="dref-target" as="xs:string" required="yes"/>


  <xsl:variable name="base-result-path" as="xs:string"
    select="local:dref-normalize(if (normalize-space($dref-target) ne '') then $dref-target else string(/*/@dref-target-path))"/>

  <xsl:variable name="main-source-zip" as="xs:string?" select="/*/@dref-source-zip"/>
  <xsl:variable name="dref-global-zip" as="xs:string"
    select="if (normalize-space($main-source-zip) ne '') then local:dref-normalize(resolve-uri($main-source-zip, base-uri(/*))) else ''"/>

  <!-- ================================================================== -->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- CHANGES ON ROOT: -->

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>

      <!-- Record the base result path on the root element. Make sure we record it with a single trailing /: -->
      <xsl:if test="normalize-space($base-result-path) eq ''">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="'container-to-disk: No target path specified'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:attribute name="dref-target-result-path" select="concat(replace($base-result-path, '/+$', ''), '/')"/>

      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/*/@dref-source-zip">
    <xsl:choose>
      <xsl:when test="normalize-space(.) ne ''">
        <xsl:attribute name="{name(.)}" select="$dref-global-zip"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Empty attribute, remove. -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- CHANGES ON DOCUMENTS: -->

  <xsl:template match="/*/xtlcon:document[normalize-space(@dref-target) ne ''] | /*/xtlcon:external-document[normalize-space(@dref-target) ne '']">
    <xsl:copy>
      <xsl:apply-templates select="@* except (@dref-source-result, @dref-target-result, @dref-source-zip-result)"/>

      <!-- Set the result dref: -->
      <xsl:attribute name="dref-target-result" select="xtlc:dref-to-uri(local:dref-normalize(xtlc:dref-concat(($base-result-path, @dref-target))))"/>

      <!--For external documents, we need to compute some more stuff: -->
      <xsl:if test="self::xtlcon:external-document">
        <xsl:variable name="not-in-global-source-zip" as="xs:boolean" select="xtlc:str2bln(@not-in-global-source-zip, false())"/>

        <!-- Zip reference -->
        <xsl:variable name="dref-zip" as="xs:string?">
          <xsl:choose>
            <!-- When this entry has a source zip file, normalize it: -->
            <xsl:when test="normalize-space(@dref-source-zip) ne ''">
              <xsl:sequence select="local:dref-normalize(resolve-uri(@dref-source-zip, base-uri(/*)))"/>
            </xsl:when>
            <!-- When there is a global zip file, use this (unless it is specifically marked as not-in-global-source-zip):  -->
            <xsl:when test="(normalize-space($dref-global-zip) ne '') and not($not-in-global-source-zip)">
              <xsl:sequence select="$dref-global-zip"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="in-zip" as="xs:boolean" select="normalize-space($dref-zip) ne ''"/>
        <xsl:if test="$in-zip">
          <xsl:attribute name="dref-source-zip-result" select="$dref-zip"/>
        </xsl:if>

        <!-- Source references: -->
        <xsl:choose>

          <!-- Normal reference, make absolute: -->
          <xsl:when test="(normalize-space(@dref-source) ne '') and not($in-zip)">
            <xsl:attribute name="dref-source-result" select="local:dref-normalize(resolve-uri(@dref-source, base-uri(/*)))"/>
          </xsl:when>

          <!-- Reference in zip, make sure it is formatted right No protocol, no leading /): -->
          <xsl:when test="(normalize-space(@dref-source) ne '') and $in-zip">
            <xsl:variable name="dref-source-normalized" as="xs:string" select="xtlc:protocol-remove(xtlc:dref-canonical(@dref-source))"/>
            <xsl:attribute name="dref-source-result" select="replace($dref-source-normalized, '^/+', '')"/>
          </xsl:when>

          <!-- No source info, leave it... -->
          <xsl:otherwise/>

        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:dref-normalize" as="xs:string">
    <xsl:param name="dref" as="xs:string"/>

    <xsl:sequence select="xtlc:protocol-add(xtlc:dref-canonical($dref), $xtlc:protocol-file, true())"/>
  </xsl:function>

</xsl:stylesheet>

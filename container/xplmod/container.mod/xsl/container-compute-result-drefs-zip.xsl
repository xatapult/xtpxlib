<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Computes the actual path of the resulting zipfile
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>

  <xsl:param name="dref-target-zip" as="xs:string" required="yes"/>


  <xsl:variable name="result-zip" as="xs:string"
    select="local:dref-normalize(if (normalize-space($dref-target-zip) ne '') then $dref-target-zip else string(/*/@dref-target-zip))"/>

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

      <xsl:if test="normalize-space($result-zip) eq ''">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="'container-to-zip: No target zipfile specified'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:attribute name="dref-target-zip-result" select="$result-zip"/>
      <xsl:attribute name="dref-target-zip-tmpdir" select="concat($result-zip, '-TMPDIR')"/>

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

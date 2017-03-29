<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Create a list with file copy commands
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../xslmod/dref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="dref-source-dir" as="xs:string" required="yes"/>
  <xsl:param name="dref-target-dir" as="xs:string" required="yes"/>

  <xsl:variable name="dref-source-dir-normalized" as="xs:string" select="xtlc:dref-canonical($dref-source-dir)"/>
  <xsl:variable name="dref-target-dir-normalized" as="xs:string" select="xtlc:dref-canonical($dref-target-dir)"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <dir-copy-file-list timestamp="{current-dateTime()}" dref-source-dir="{$dref-source-dir-normalized}"
      dref-target-dir="{$dref-target-dir-normalized}">
      <xsl:for-each select="//c:file">
        <xsl:variable name="directories" as="xs:string*" select="subsequence(ancestor::c:directory/@name/string(), 2)"/>
        <copy-file source="{xtlc:dref-to-uri(xtlc:dref-concat(($dref-source-dir-normalized, $directories, @name)))}"
          target="{xtlc:dref-to-uri(xtlc:dref-concat(($dref-target-dir-normalized, $directories, @name)))}"/>
      </xsl:for-each>
    </dir-copy-file-list>
  </xsl:template>

</xsl:stylesheet>

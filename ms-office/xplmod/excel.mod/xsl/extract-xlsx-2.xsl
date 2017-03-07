<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns="http://www.xtpxlib.nl/ns/ms-office"
  xmlns:local="#local.extract-xlsx-2.xsl" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Removes emty rows and cells
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <!-- ================================================================== -->

  <xsl:template match="@* | node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template match="xtlmso:row">
    <!-- Check whether this row is actually empty (has only cells without contents). If so, don't copy. -->

    <!-- First gather all the cell information: -->
    <xsl:variable name="cells" as="element(xtlmso:cell)*">
      <xsl:for-each select="xtlmso:cell">
        <xsl:if test="some $child in xtlmso:* satisfies (string($child) ne '')">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:for-each select="xtlmso:*">
              <xsl:if test="string(.) ne ''">
                <xsl:copy-of select="." copy-namespaces="no"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:copy>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="exists($cells)">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" copy-namespaces="no"/>
        <xsl:copy-of select="$cells" copy-namespaces="no"/>
      </xsl:copy>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>

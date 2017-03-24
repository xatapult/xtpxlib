<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtp-data="http://www.xatapult.nl/website/data" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--
    Converts the info column XML into HTML code
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  <!-- -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- -->
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  <!-- -->
    <xsl:template match="/">
        <div id="kolomrechts">
            <div id="nieuws">
                <br/>
                <br/>
                <xsl:apply-templates select="/*/xtp-data:InfoColumn/xtp-data:Section"/>
            </div>
        </div>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="xtp-data:Section">
        <br/>
        <p style="font-weight: bold">
            <xsl:value-of select="@title"/>
        </p>
        <xsl:apply-templates select="xtp-data:Entry"/>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="xtp-data:Entry">
        <p align="right">
            <a style="color: #999; font-size: 10px; font-weight: normal" href="{@href}">
                <xsl:if test="@newwindow = ('yes', 'true')">
                    <xsl:attribute name="target" select="'_blank'"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </a>
        </p>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="node()" priority="-1000"/>
  <!-- -->
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.y5l_s3s_5bb" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!-- 
       Gets all the available system properties out
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <xsl:variable name="property-names" as="xs:string+"
      select="(
        'xsl:version',
        'xsl:vendor',
        'xsl:vendor-url',      
        'xsl:product-name',
        'xsl:product-version',
        'xsl:is-schema-aware',
        'xsl:supports-serialization',
        'xsl:supports-backwards-compatibility',
        'xsl:supports-namespace-axis'
      )"/>

    <system-properties timestamp="{current-dateTime()}">
      <xsl:for-each select="$property-names">
        <property name="{.}">
          <xsl:value-of select="system-property(.)"/>
        </property>
      </xsl:for-each>
    </system-properties>

  </xsl:template>

</xsl:stylesheet>

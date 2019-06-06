<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.${id}"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!-- 
       ${caret}
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->



  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="global:page-title" as="xs:string" select="'PAGE TITLE TBD'"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">

    <html>
      <head>
        <meta HTTP-EQUIV="Content-Type" content="text/html; charset=UTF-8"/>
        <title>
          <xsl:value-of select="$global:page-title"/>
        </title>
      </head>
      <body>
        <h1>
          <xsl:value-of select="$global:page-title"/>
        </h1>
        <p>TBD</p>
      </body>
    </html>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->



</xsl:stylesheet>

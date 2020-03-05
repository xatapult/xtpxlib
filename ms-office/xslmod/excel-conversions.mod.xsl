<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.irt_hdv_skb"
  xmlns:xtlxo="http://www.xtpxlib.nl/ns/xoffice" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~
    Excel data specific conversions     
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlxo:excel-start-date" as="xs:date" select="xs:date('1900-01-01')"/>

  <!-- ================================================================== -->
  <!-- DATES: -->

  <xsl:function name="xtlxo:excel-date-to-xs-date" as="xs:date">
    <!--~ Converts an Excel date integer into an xs:date.  -->
    <xsl:param name="excel-value" as="xs:integer">
      <!--~ The Excel date integer to convert.  -->
    </xsl:param>

    <xsl:variable name="duration-string" as="xs:string" select="concat('P', string($excel-value - 2), 'D')"/>
    <xsl:sequence select="$xtlxo:excel-start-date + xs:dayTimeDuration($duration-string)"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlxo:xs-date-to-excel-date" as="xs:integer">
    <!--~ Converts an xs:date into an Excel date integer.  -->
    <xsl:param name="date" as="xs:date">
      <!--~ The xs:date to convert.  -->
    </xsl:param>
    
    <xsl:variable name="duration" as="xs:dayTimeDuration" select="xs:dayTimeDuration($date - $xtlxo:excel-start-date)"/>
    <xsl:sequence select="days-from-duration($duration) + 2"/>
  </xsl:function>
  
</xsl:stylesheet>

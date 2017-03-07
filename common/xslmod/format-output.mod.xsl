<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.format-output.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    Various functions for formatting output, sometimes based on language.
    When language based, we only distinguish between Dutch and non-Dutch (usually English).
   
    Module dependencies: common.mod.xsl
	-->
  <!-- ================================================================== -->

  <xsl:function name="xtlc:format-double" as="xs:string">
    <!--*
      Formats a double as a string with a given amount of digits. For the Dutch language . and , are swapped. 
    -->
    <xsl:param name="dbl" as="xs:double">
      <!--* Number to convert  -->
    </xsl:param>
    <xsl:param name="digits" as="xs:integer">
      <!--* The number of digits to use. When < 0 this is left open. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language for the conversion. For the Dutch language . and , are swapped. -->
    </xsl:param>

    <xsl:variable name="nr-string" as="xs:string">
      <xsl:choose>
        <xsl:when test="$digits lt 0">
          <xsl:sequence select="string($dbl)"/>
        </xsl:when>
        <xsl:when test="$digits eq 0">
          <xsl:sequence select="format-number($dbl, '0')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="picture" as="xs:string" select="concat('0.', xtlc:char-repeat('0', $digits))"/>
          <xsl:sequence select="format-number($dbl, $picture)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="local:nr-finalize($nr-string, $lang)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:format-amount" as="xs:string">
    <!--*
      Formats an amount by adding a € sign and always use double digits. For the Dutch language . and , are swapped.
    -->
    <xsl:param name="amount" as="xs:double">
      <!--* The amount to format  -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language for the conversion. For the Dutch language . and , are swapped. -->
    </xsl:param>

    <xsl:sequence select="local:nr-finalize(format-number($amount, '&#x20AC;&#xa0;#,##0.00'), $lang)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:size2str" as="xs:string">
    <!--* 
      Turns an integer (e.g. a filesize) into a (rounded) number using the Kb/Mb/Gb suffix.
    -->
    <xsl:param name="size" as="xs:integer">
      <!--* The size to convert. -->
    </xsl:param>

    <xsl:variable name="Kb" as="xs:integer" select="1024"/>
    <xsl:variable name="Mb" as="xs:integer" select="$Kb * $Kb"/>
    <xsl:variable name="Gb" as="xs:integer" select="$Kb * $Mb"/>
    <xsl:choose>
      <xsl:when test="$size lt $Kb">
        <xsl:sequence select="concat(string($size), 'b')"/>
      </xsl:when>
      <xsl:when test="$size lt $Mb">
        <xsl:sequence select="concat(string(round($size div $Kb)), 'Kb')"/>
      </xsl:when>
      <xsl:when test="$size lt $Gb">
        <xsl:sequence select="concat(string(round($size div $Mb)), 'Mb')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat(string(round($size div $Gb)), 'Gb')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:duration2str" as="xs:string">
    <!--* 
      Turns a day/time duration into a more readable string 
    -->
    <xsl:param name="duration" as="xs:dayTimeDuration">
      <!--* The duration to convert. -->
    </xsl:param>
    <xsl:param name="round-seconds" as="xs:boolean">
      <!--* Whether the seconds part must be rounded. -->
    </xsl:param>

    <xsl:variable name="days" as="xs:integer" select="days-from-duration($duration)"/>
    <xsl:variable name="hours" as="xs:integer" select="hours-from-duration($duration)"/>
    <xsl:variable name="minutes" as="xs:integer" select="minutes-from-duration($duration)"/>
    <xsl:variable name="seconds" as="xs:decimal"
      select="if ($round-seconds) then round(seconds-from-duration($duration)) else seconds-from-duration($duration)"/>

    <xsl:variable name="string-parts" as="xs:string*">
      <xsl:sequence select="if ($days gt 0) then concat(string($days), 'd') else ()"/>
      <xsl:sequence select="if ($hours gt 0) then concat(string($hours), 'h') else ()"/>
      <xsl:sequence select="if ($minutes gt 0) then concat(string($minutes), 'm') else ()"/>
      <xsl:sequence select="concat(string($seconds), 's')"/>
    </xsl:variable>
    <xsl:sequence select="string-join($string-parts, '')"/>

  </xsl:function>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:nr-finalize" as="xs:string">
    <!-- Finalizes a number by swapping . and , for Dutch. -->
    <xsl:param name="nr-string" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>

    <xsl:sequence select="if ($lang eq $xtlc:language-nl) then translate($nr-string, '.,', ',.') else $nr-string"/>
  </xsl:function>

</xsl:stylesheet>

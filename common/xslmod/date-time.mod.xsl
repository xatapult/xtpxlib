<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.format-output.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    Various functions for working with dates and times, sometimes based on language.
    When language based, we only distinguish between Dutch and non-Dutch (usually English).
    Some of these functions will not work using Saxon HE (week-numbers for instance)
   
    Module dependencies: common.mod.xsl
	-->
  <!-- ================================================================== -->

  <xsl:function name="xtlc:month-name" as="xs:string">
    <!--* Returns the name of a month. -->
    <xsl:param name="month-number" as="xs:integer">
      <!--* The month number (1-12). -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language you want the month in. -->
    </xsl:param>

    <xsl:variable name="month-names-nl" as="xs:string+"
      select="('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december')"/>
    <xsl:variable name="month-names-en" as="xs:string+"
      select="('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')"/>

    <xsl:choose>
      <xsl:when test="($month-number lt 1) or ($month-number gt 12)">
        <xsl:sequence select="concat('?', $month-number, '?')"/>
      </xsl:when>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence select="$month-names-nl[$month-number]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$month-names-en[$month-number]"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:month-name-short" as="xs:string">
    <!--* Returns the name of a month in short (abbreviated to 3 characters). -->
    <xsl:param name="month-number" as="xs:integer">
      <!--* The month number (1-12). -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language you want the month in. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($lang eq $xtlc:language-nl) and ($month-number eq 3)">
        <xsl:sequence select="'mrt'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="substring(xtlc:month-name($month-number, $lang), 1, 3)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:format-date-as-text" as="xs:string">
    <!--* Formats a date as a string with month name in full.  -->
    <xsl:param name="date" as="xs:date">
      <!--* The date to format. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language for the conversion. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence
          select="concat(day-from-date($date), '&#xa0;', xtlc:month-name(month-from-date($date), $xtlc:language-nl), '&#xa0;', year-from-date($date))"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="concat(xtlc:month-name(month-from-date($date), $xtlc:language-en), '&#xa0;', day-from-date($date), ',&#xa0;', year-from-date($date))"
        />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:format-date-as-text-short" as="xs:string">
    <!--* Formats a date as a string with month name in short.  -->
    <xsl:param name="date" as="xs:date">
      <!--* The date to format. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language for the conversion. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence select="concat(day-from-date($date), '&#xa0;', xtlc:month-name-short(month-from-date($date), $lang))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat(xtlc:month-name-short(month-from-date($date), $lang), '&#xa0;', day-from-date($date))"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:days-in-month" as="xs:integer">
    <!--* Computes the number of days in a particular month. -->
    <xsl:param name="month-number" as="xs:integer"/>
    <xsl:param name="year" as="xs:integer"/>


    <xsl:variable name="base-month-days" as="xs:integer+" select="(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)"/>
    <xsl:choose>
      <xsl:when test="($month-number lt 1) or ($month-number gt 12)">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="($month-number ne 2) or not(xtlc:is-leap-year($year))">
        <xsl:sequence select="$base-month-days[$month-number]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$base-month-days[2] + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:is-leap-year" as="xs:boolean">
    <!--* Returns true when a given year is a leap year  -->
    <xsl:param name="year" as="xs:integer">
      <!--* The year to check  -->
    </xsl:param>

    <xsl:sequence select="((($year mod 4) eq 0) and (($year mod 100) ne 0)) or (($year mod 400) eq 0)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:week-number" as="xs:integer">
    <!--* 
      Computes the week number for a given date.
      Watch out: I'm not completely sure that this uses the system used in The Netherlands...  
    -->
    <xsl:param name="date" as="xs:date">
      <!--* Date to use. -->
    </xsl:param>

    <xsl:sequence select="xtlc:str2int(format-date($date, '[W]', 'nl', (), 'nl'), -1)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:weekday-name" as="xs:string">
    <!--* Computes the name of the weekday for a given language. Will be capitalized. -->
    <xsl:param name="date" as="xs:date">
      <!--* Date to use. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--* The language you want the name in. -->
    </xsl:param>

    <xsl:sequence select="format-date($date, '[F]', $lang, (), 'nl')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:weekday-number" as="xs:integer">
    <!--* The number of the weekday (1=Monday, 7=Sunday). -->
    <xsl:param name="date" as="xs:date">
      <!--* Date to use. -->
    </xsl:param>

    <!-- Get first three characters of weekday: -->
    <xsl:variable name="day-name" as="xs:string" select="lower-case(substring(xtlc:weekday-name($date, $xtlc:language-en), 1, 3))"/>

    <!-- And do a crude compare: -->
    <xsl:choose>
      <xsl:when test="$day-name eq 'mon'">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'tue'">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'wed'">
        <xsl:sequence select="3"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'thu'">
        <xsl:sequence select="4"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'fri'">
        <xsl:sequence select="5"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'sat'">
        <xsl:sequence select="6"/>
      </xsl:when>
      <xsl:when test="$day-name eq 'sun'">
        <xsl:sequence select="7"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="-1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:to-date" as="xs:date">
    <!--* Creates a date from its components. Does not check whether the parameters are in range! -->
    <xsl:param name="day" as="xs:integer"/>
    <xsl:param name="month" as="xs:integer"/>
    <xsl:param name="year" as="xs:integer"/>

    <xsl:variable name="date-string" as="xs:string"
      select="concat(xtlc:str-prefix-to-length(string($year), '0', 4), '-', 
        xtlc:str-prefix-to-length(string($month), '0', 2), '-', 
        xtlc:str-prefix-to-length(string($day), '0', 2))"/>
    <xsl:sequence select="xs:date($date-string)"/>
  </xsl:function>

</xsl:stylesheet>

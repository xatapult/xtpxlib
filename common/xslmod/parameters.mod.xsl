<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local.parameters.mod.xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="2.0" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--* 
    XSL library module with functions and templates to work with generalized parameter sets 
    - Parameter sets are defined in ../xsd/parameters.xsd.
    - The root for finding the parameter can be given as string, URI, document or element.
    - You can specify multiple values for a parameter
    - Values can be filtered based on attributes. For instance for language, system-type, etc.
    
    Module dependencies: common.mod.xsl
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:variable name="local:produce-error-on-non-found" as="xs:boolean" select="false()">
    <!-- It is a tough design decision whether to produce errors on not found or not. Therefore we centralize this here. -->
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- GENERIC FUNCTIONS: -->

  <xsl:function name="xtlc:parameter-get-names" as="xs:string*">
    <!--* 
      Returns all the parameter names in a parameter set.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>

    <xsl:sequence select="distinct-values(xtlc:item2element($parameter-root, $local:produce-error-on-non-found)//xtlc:parameter/@name/string())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:parameter-exists" as="xs:boolean">
    <!--* 
      Checks whether a parameter exists.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="parameter-name" as="xs:string">
      <!--* The name of the parameter. -->
    </xsl:param>

    <xsl:sequence select="exists(local:get-parameter($parameter-root, $parameter-name, false()))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:parameter-get-values" as="xs:string*">
    <!--* 
      Returns the list of values for a parameter. Returns default value(s) when the parameter was not found.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="parameter-name" as="xs:string">
      <!--* The name of the parameter. -->
    </xsl:param>
    <xsl:param name="filters" as="attribute()*">
      <!--* Any filter attributes to apply on the parameter's value. -->
    </xsl:param>
    <xsl:param name="defaults" as="xs:string*">
      <!--* Default value(s) to return when the parameter could not be found. -->
    </xsl:param>

    <xsl:variable name="parameter" as="element(xtlc:parameter)?" select="local:get-parameter($parameter-root, $parameter-name, false())"/>
    <xsl:choose>
      <xsl:when test="empty($parameter)">
        <xsl:sequence select="$defaults"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$parameter/xtlc:value[local:filter-on-attributes(@*, $filters)]/string()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:parameter-get-values" as="xs:string*">
    <!--* 
      Returns the list of values for a parameter. Raises an error when the parameter was not found.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="parameter-name" as="xs:string">
      <!--* The name of the parameter. -->
    </xsl:param>
    <xsl:param name="filters" as="attribute()*">
      <!--* Any filter attributes to apply on the parameter's value. -->
    </xsl:param>

    <xsl:variable name="parameter" as="element(xtlc:parameter)?" select="local:get-parameter($parameter-root, $parameter-name, true())"/>
    <xsl:sequence select="$parameter/xtlc:value[local:filter-on-attributes(@*, $filters)]/string()"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:parameter-get-value" as="xs:string">
    <!--* 
      Returns a single value for a parameter. Returns a default value when the parameter was not found.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="parameter-name" as="xs:string">
      <!--* The name of the parameter. -->
    </xsl:param>
    <xsl:param name="filters" as="attribute()*">
      <!--* Any filter attributes to apply on the parameter's value. -->
    </xsl:param>
    <xsl:param name="default" as="xs:string*">
      <!--* Default value to return when the parameter could not be found. -->
    </xsl:param>

    <xsl:sequence select="string(xtlc:parameter-get-values($parameter-root, $parameter-name, $filters, $default)[1])"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:parameter-get-value" as="xs:string">
    <!--* 
      Returns a single value for a parameter. Raises an error when the parameter was not found.
    -->
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="parameter-name" as="xs:string">
      <!--* The name of the parameter. -->
    </xsl:param>
    <xsl:param name="filters" as="attribute()*">
      <!--* Any filter attributes to apply on the parameter's value. -->
    </xsl:param>

    <xsl:sequence select="string(xtlc:parameter-get-values($parameter-root, $parameter-name, $filters)[1])"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- SUBSTITUTION: -->

  <xsl:function name="xtlc:parameter-simple-substitute" as="xs:string">
    <!--* 
      Simple substitution of parameters referenced by ${...}.
      Watch out: there is no check for circular references!
    -->
    <xsl:param name="substitute-string" as="xs:string">
      <!--* String to substitute the parameter values in. -->
    </xsl:param>
    <xsl:param name="parameter-root" as="item()">
      <!--* The root item for finding the parameters. -->
    </xsl:param>
    <xsl:param name="filters" as="attribute()*">
      <!--* Any filter attributes to apply on the parameter's value. -->
    </xsl:param>

    <xsl:variable name="substituted-parts" as="xs:string*">
      <xsl:analyze-string select="$substitute-string" regex="\$\{{(\S+)\}}">
        <xsl:matching-substring>
          <xsl:variable name="parameter-name" as="xs:string" select="regex-group(1)"/>
          <xsl:variable name="parameter-value" as="xs:string"
            select="xtlc:parameter-get-value($parameter-root, $parameter-name, $filters, concat('?', $parameter-name, '?'))"/>
          <xsl:sequence select="xtlc:parameter-simple-substitute($parameter-value, $parameter-root, $filters)"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <xsl:sequence select="string-join($substituted-parts, '')"/>

  </xsl:function>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:get-parameter" as="element(xtlc:parameter)?">
    <xsl:param name="parameter-root" as="item()"/>
    <xsl:param name="parameter-name" as="xs:string"/>
    <xsl:param name="report-errors" as="xs:boolean"/>

    <xsl:variable name="parameter" as="element(xtlc:parameter)?"
      select="((xtlc:item2element($parameter-root, $local:produce-error-on-non-found)//xtlc:parameter)[@name eq $parameter-name])[1]"/>
    <xsl:choose>
      <xsl:when test="empty($parameter) and $report-errors">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Mandatory parameter &quot;', $parameter-name, '&quot; not found.')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$parameter"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:filter-on-attributes" as="xs:boolean">
    <xsl:param name="attributes" as="attribute()*"/>
    <xsl:param name="filters" as="attribute()*"/>

    <xsl:choose>
      <xsl:when test="empty($attributes) or empty($filters)">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="filter-results" as="xs:boolean*">
          <xsl:for-each select="$attributes">
            <xsl:variable name="name" as="xs:string" select="local-name(.)"/>
            <xsl:variable name="value" as="xs:string" select="string(.)"/>
            <xsl:variable name="filter" as="attribute()?" select="$filters[local-name(.) eq $name]"/>
            <xsl:sequence select="if (empty($filter)) then () else (string($filter) eq $value)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="every $filter-result in $filter-results satisfies $filter-result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

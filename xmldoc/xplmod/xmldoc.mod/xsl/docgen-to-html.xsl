<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xmldoc="http://www.xtpxlib.nl/ns/xmldoc" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
		Turns a bunch of documents described in the xmldoc intermediate format into a nice stand-alone, HTML representation.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- DECLARATIONS: -->

  <xsl:variable name="dref-in" as="xs:string" select="xtlc:protocol-remove(xtlc:dref-canonical(/*/xmldoc:document[1]/@dref))"/>
  <xsl:variable name="filename" as="xs:string" select="xtlc:dref-name($dref-in)"/>

  <xsl:variable name="standard-title" as="xs:string" select="concat($filename, ' documentation')"/>

  <xsl:variable name="dt-format" as="xs:string" select="$xtlc:default-dt-format-nl"/>

  <xsl:variable name="dref-docgen-types" as="xs:string" select="'../data/docgen-types.xml'"/>
  <xsl:variable name="type-translations" as="element(docgen-type)*" select="doc($dref-docgen-types)/*/docgen-type"/>

  <xsl:variable name="dref-css" as="xs:string" select="'../data/docgen.css'"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/*">

    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta HTTP-EQUIV="Content-Type" content="text/html; charset=UTF-8"/>
        <title>
          <xsl:value-of select="$standard-title"/>
        </title>
        <style>
          <xsl:call-template name="insert-css-text"/>
        </style>
      </head>
      <body>
        <h1>
          <xsl:value-of select="$standard-title"/>
        </h1>
        <p>Generated: <xsl:value-of select="format-dateTime(xs:dateTime(root(.)/*/@timestamp), $dt-format)"/></p>

        <!-- Generate contents for all documents: -->
        <xsl:for-each select="xmldoc:document">
          <br/>
          <hr/>
          <xsl:call-template name="generate-document-documentation"/>
        </xsl:for-each>
        <hr/>

      </body>
    </html>

  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="generate-document-documentation">
    <xsl:param name="document" as="element(xmldoc:document)" required="no" select="."/>

    <xsl:for-each select="$document">

      <p>File: <code><xsl:value-of select="xtlc:protocol-remove(xtlc:dref-canonical(@dref))"/></code></p>
      <br/>

      <!-- Main documentation: -->
      <p>
        <xsl:call-template name="documentation-to-html"/>
      </p>

      <!-- Namespaces: -->
      <xsl:call-template name="namespaces-to-html"/>

      <!-- Global parameters: -->
      <xsl:call-template name="parameters-to-html"/>

      <!-- Objects ToC: -->
      <xsl:variable name="object-entries" as="element(xmldoc:object)*" select="xmldoc:objects/xmldoc:object"/>
      <xsl:if test="exists($object-entries)">
        <xsl:for-each-group select="$object-entries" group-by="@type-id">
          <xsl:sort select="local:type-to-priority(current-grouping-key())" order="descending"/>

          <br/>
          <table>
            <tr>
              <th><xsl:value-of select="local:cell-entry(local:type-to-description(current-grouping-key()))"/>s:</th>
              <th>Description:</th>
            </tr>
            <xsl:for-each select="current-group()">
              <xsl:sort select="@name"/>
              <tr>
                <td>
                  <xsl:choose>
                    <xsl:when test="local:object-has-more-info(.)">
                      <a href="#{local:object-to-anchor(.)}">
                        <xsl:value-of select="local:cell-entry(@name)"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="local:cell-entry(@name)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:value-of select="local:cell-entry(local:header-documentation-line(., ''))"/>
                </td>
              </tr>
            </xsl:for-each>
          </table>

        </xsl:for-each-group>
      </xsl:if>

      <!-- Object detail information: -->
      <xsl:for-each select="$object-entries[local:object-has-more-info(.)]">
        <xsl:sort select="@name"/>
        <xsl:call-template name="object-to-html"/>
      </xsl:for-each>

    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- OTHER SUPPORT: -->

  <xsl:function name="local:type-to-description" as="xs:string">
    <xsl:param name="type-id" as="xs:string"/>

    <xsl:variable name="docgen-type-elm" as="element(docgen-type)?" select="$type-translations[@type-id eq $type-id]"/>
    <xsl:choose>
      <xsl:when test="exists($docgen-type-elm)">
        <xsl:value-of select="normalize-space($docgen-type-elm)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('?', $type-id, '?')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:type-to-priority" as="xs:integer">
    <xsl:param name="type-id" as="xs:string"/>

    <xsl:variable name="docgen-type-elm" as="element(docgen-type)?" select="$type-translations[@type-id eq $type-id]"/>
    <xsl:choose>
      <xsl:when test="exists($docgen-type-elm)">
        <xsl:value-of select="xs:integer($docgen-type-elm/@priority)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="-10000"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:header-documentation-line" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="prefix" as="xs:string?"/>

    <xsl:variable name="line" as="xs:string?" select="$elm/xmldoc:documentation/xmldoc:line[1]/string()"/>
    <xsl:sequence select="if (exists($line)) then concat(string($prefix), $line) else ''"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:object-has-more-info" as="xs:boolean">
    <xsl:param name="object" as="element(xmldoc:object)"/>

    <xsl:sequence select="(count($object/xmldoc:documentation/xmldoc:lineline) gt 1) or exists($object/xmldoc:parameters/xmldoc:parameter)"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- HTML GENERIC SUPPORT: -->

  <xsl:function name="local:object-to-anchor" as="xs:string">
    <xsl:param name="object" as="element(xmldoc:object)"/>

    <xsl:variable name="arity" as="xs:integer" select="count($object/xmldoc:parameters/xmldoc:parameter)"/>
    <xsl:sequence select="xtlc:str2id(concat($object/@type-id, '-', $object/@name, '-', string($arity)))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="documentation-to-html">
    <xsl:param name="elm" as="element()?" required="no" select="."/>

    <xsl:variable name="lines" as="element(xmldoc:line)*" select="$elm/xmldoc:documentation/xmldoc:line"/>
    <xsl:for-each select="$lines">
      <xsl:variable name="indent" as="xs:integer" select="xtlc:str2int(@indent, 0)"/>
      <code>
        <xsl:if test="$indent gt 0">
          <xsl:for-each select="1 to $indent">
            <xsl:text>&#160;</xsl:text>
          </xsl:for-each>
        </xsl:if>
        <xsl:value-of select="."/>
      </code>
      <xsl:if test="position() ne last()">
        <br/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="parameters-to-html">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="parameter-entries" as="element(xmldoc:parameter)*" select="$elm/xmldoc:parameters/xmldoc:parameter"/>
    <xsl:if test="exists($parameter-entries)">

      <xsl:variable name="has-required-info" as="xs:boolean" select="exists($parameter-entries/@required)"/>
      <xsl:variable name="has-default-info" as="xs:boolean" select="exists($parameter-entries/@default)"/>
      <xsl:variable name="has-type-info" as="xs:boolean" select="exists($parameter-entries/@type)"/>

      <br/>
      <table>

        <!-- Table header: -->
        <tr>
          <th>Parameter:</th>
          <xsl:if test="$has-type-info">
            <th>Type:</th>
          </xsl:if>
          <xsl:if test="$has-required-info">
            <th>Required:</th>
          </xsl:if>
          <xsl:if test="$has-default-info">
            <th>Default:</th>
          </xsl:if>
          <th>Description:</th>
        </tr>

        <!-- Table contents: -->
        <xsl:for-each select="$parameter-entries">
          <tr>
            <td>
              <xsl:value-of select="local:cell-entry(@name)"/>
            </td>
            <xsl:if test="$has-type-info">
              <td>
                <xsl:value-of select="local:cell-entry(@type)"/>
              </td>
            </xsl:if>
            <xsl:if test="$has-required-info">
              <td>
                <xsl:value-of select="local:cell-entry(@required)"/>
              </td>
            </xsl:if>
            <xsl:if test="$has-default-info">
              <td>
                <xsl:value-of select="local:cell-entry(@default)"/>
              </td>
            </xsl:if>
            <td>
              <xsl:call-template name="documentation-to-html"/>
            </td>
          </tr>
        </xsl:for-each>

      </table>

    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="namespaces-to-html">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="namespace-entries" as="element(xmldoc:namespace)*" select="$elm/xmldoc:namespaces/xmldoc:namespace"/>
    <xsl:if test="exists($namespace-entries)">
      <xsl:variable name="has-description" as="xs:boolean" select="some $ne in $namespace-entries satisfies (normalize-space($ne) ne '')"/>

      <br/>
      <table>
        <tr>
          <th>Prefix:</th>
          <th>Namespace:</th>
          <xsl:if test="$has-description">
            <th>Description:</th>
          </xsl:if>
        </tr>
        <xsl:for-each select="$namespace-entries">
          <tr>
            <td>
              <xsl:value-of select="local:cell-entry(@prefix)"/>
            </td>
            <td>
              <xsl:value-of select="local:cell-entry(@uri)"/>
            </td>
            <xsl:if test="$has-description">
              <xsl:call-template name="documentation-to-html"/>
            </xsl:if>
          </tr>
        </xsl:for-each>
      </table>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="object-to-html">
    <xsl:param name="object" as="element(xmldoc:object)" required="no" select="."/>

    <xsl:for-each select="$object">
      <br/>
      <hr/>
      <h3>
        <a name="{local:object-to-anchor(.)}"/>
        <xsl:value-of select="local:type-to-description(@type-id)"/>
        <xsl:text> </xsl:text>
        <b>
          <xsl:value-of select="@name"/>
        </b>
        <xsl:if test="normalize-space(@type) ne ''">
          <xsl:text> =&gt; </xsl:text>
          <xsl:value-of select="@type"/>
        </xsl:if>
      </h3>

      <br/>
      <p>
        <xsl:call-template name="documentation-to-html"/>
      </p>
      <xsl:call-template name="parameters-to-html"/>

    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:cell-entry" as="item()*">
    <xsl:param name="entry" as="item()*"/>

    <xsl:choose>
      <xsl:when test="exists($entry)">
        <xsl:sequence select="$entry"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'&#160;'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="insert-css-text">
    <xsl:variable name="full-css-text" as="xs:string" select="unparsed-text($dref-css)"/>
    <xsl:value-of select="replace($full-css-text, '&#xD;', '')"/>
  </xsl:template>

</xsl:stylesheet>

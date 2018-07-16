<?xml version="1.0" encoding="UTF-8"?>
<?xtpxlib-public?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    This XSL translates an XSL Module (in xtpxlib style) into a stub for an XQuery Module. 
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="text" indent="no" encoding="UTF-8"/>

  <xsl:include href="../xslmod/common.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL VARIABLES -->

  <xsl:variable name="newline" as="xs:string" select="'&#x0a;'"/>
  <xsl:variable name="element-documentation-start" as="xs:string" select="'*'"/>
  <xsl:variable name="indent-increment" as="xs:integer" select="2"/>
  <xsl:variable name="root-element" as="element()" select="/*"/>

  <!-- Very rough try to get the namespace prefix: -->
  <xsl:variable name="main-namespace-prefix" as="xs:string">
    <xsl:variable name="name" as="xs:string?" select="(//xsl:*/@name[contains(., ':')][not(starts-with(., 'local:'))])[1]"/>
    <xsl:choose>
      <xsl:when test="exists($name)">
        <xsl:sequence select="substring-before($name, ':')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'MODNS'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/*">

    <!-- Output header info: -->
    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line>xquery version "3.0" encoding "UTF-8";</line>
        <xsl:call-template name="create-xqdoc-comment-lines">
          <xsl:with-param name="lines" as="element(line)*">
            <xsl:call-template name="element-documentation-to-lines"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Setup part: -->
    <xsl:call-template name="separator-out">
      <xsl:with-param name="major" select="true()"/>
      <xsl:with-param name="title" select="'SETUP:'"/>
    </xsl:call-template>

    <!-- Main namespace declaration: -->
    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line>
          <xsl:text>module namespace </xsl:text>
          <xsl:value-of select="$main-namespace-prefix"/>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="namespace-uri-for-prefix($main-namespace-prefix, $root-element)"/>
          <xsl:text>"</xsl:text>
        </line>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Other namespace declarations: -->
    <xsl:variable name="namespace-prefixes" as="xs:string*"
      select="in-scope-prefixes($root-element)[not(. =($main-namespace-prefix, 'xml', 'xsl', 'xs', 'fn', 'local'))]"/>
    <xsl:if test="exists($namespace-prefixes)">
      <xsl:call-template name="lines-out">
        <xsl:with-param name="lines" as="element(line)*">
          <line/>
          <xsl:for-each select="$namespace-prefixes">
            <line>
              <xsl:text>declare namespace </xsl:text>
              <xsl:value-of select="."/>
              <xsl:text>="</xsl:text>
              <xsl:value-of select="namespace-uri-for-prefix(., $root-element)"/>
              <xsl:text>";</xsl:text>
            </line>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Global variables: -->
    <xsl:if test="exists(xsl:variable)">

      <xsl:call-template name="separator-out">
        <xsl:with-param name="major" select="true()"/>
        <xsl:with-param name="title" select="'GLOBAL VARIABLES:'"/>
      </xsl:call-template>

      <xsl:for-each select="xsl:variable">
        <xsl:call-template name="lines-out">
          <xsl:with-param name="lines" as="element(line)*">

            <xsl:call-template name="create-xqdoc-comment-lines">
              <xsl:with-param name="lines" as="element(line)*">
                <xsl:call-template name="element-documentation-to-lines"/>
              </xsl:with-param>
            </xsl:call-template>

            <line>
              <xsl:text>declare variable $</xsl:text>
              <xsl:value-of select="@name"/>
              <xsl:if test="exists(@as)">
                <xsl:text> as </xsl:text>
                <xsl:value-of select="@as"/>
              </xsl:if>
              <xsl:text> := </xsl:text>
              <xsl:value-of select="@select"/>
              <xsl:text>;</xsl:text>
            </line>
            <line/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>

    <!-- Do the rest: -->
    <xsl:call-template name="separator-out">
      <xsl:with-param name="major" select="true()"/>
      <xsl:with-param name="title" select="'FUNCTIONS:'"/>
    </xsl:call-template>

    <xsl:apply-templates select="xsl:* except xsl:variable"/>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:function | xsl:template[exists(@name)]">

    <!-- Function header: -->
    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">

        <xsl:call-template name="create-xqdoc-comment-lines">
          <xsl:with-param name="lines" as="element(line)*">
            <xsl:call-template name="element-documentation-to-lines"/>

            <line/>
            <xsl:for-each select="xsl:param">
              <line indent="{$indent-increment}">
                <xsl:text>@param $</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:variable name="par-comment" as="xs:string" select="normalize-space(string-join(comment()/string(), ' '))"/>
                <xsl:if test="starts-with($par-comment, $element-documentation-start)">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(substring-after($par-comment, $element-documentation-start))"/>
                </xsl:if>
              </line>
            </xsl:for-each>

          </xsl:with-param>
        </xsl:call-template>

        <line>
          <xsl:text>declare function </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>(</xsl:text>
        </line>

        <xsl:for-each select="xsl:param">
          <line indent="{$indent-increment}">
            <xsl:text>$</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:if test="exists(@as)">
              <xsl:text> as </xsl:text>
              <xsl:value-of select="@as"/>
            </xsl:if>
            <xsl:if test="position() ne last()">
              <xsl:text>,</xsl:text>
            </xsl:if>
          </line>
        </xsl:for-each>

        <line>
          <xsl:text>)</xsl:text>
          <xsl:if test="exists(@as)">
            <xsl:text> as </xsl:text>
            <xsl:value-of select="@as"/>
          </xsl:if>
        </line>

      </xsl:with-param>
    </xsl:call-template>

    <!-- Function body: -->
    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line>{</line>
      </xsl:with-param>

    </xsl:call-template>
    <xsl:call-template name="xml-fragment-out">
      <xsl:with-param name="elms" select="* except xsl:param"/>
    </xsl:call-template>

    <!-- Dummy processing statement to indicate not implemented yet: -->
    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line indent="{$indent-increment}">
          <xsl:text>error((), 'Not implemented yet (from stub xsl conversion): </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>()')</xsl:text>
        </line>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line>};</line>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Finished: -->
    <xsl:call-template name="separator-out"/>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:*">
    <!-- This something we can't translate? -->
    <xsl:call-template name="xml-fragment-out"/>
    <xsl:call-template name="separator-out"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- XML FRAGMENTS OUT AS COMMENT: -->

  <xsl:template name="xml-fragment-out">
    <xsl:param name="elms" as="element()*" required="no" select="."/>

    <xsl:if test="exists($elms)">
      <xsl:call-template name="lines-out">
        <xsl:with-param name="lines" as="element(line)*">
          <line>(:</line>
          <xsl:apply-templates select="$elms" mode="mode-xml-fragment-out">
            <xsl:with-param name="indent" as="xs:integer" tunnel="yes" select="$indent-increment"/>
          </xsl:apply-templates>
          <line>:)</line>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-xml-fragment-out" as="element(line)+">
    <xsl:param name="indent" as="xs:integer" required="yes" tunnel="yes"/>

    <xsl:variable name="closing-tag" as="xs:string" select="concat('&lt;/', name(.), '&gt;')"/>

    <line indent="{$indent}">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:value-of select="xtlc:att2str(.)"/>
      </xsl:for-each>

      <xsl:choose>
        <xsl:when test="empty(*) and (normalize-space(.) eq '')">
          <xsl:text>/&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="empty(*) and (normalize-space(.) ne '')">
          <xsl:value-of select="string(.)"/>
          <xsl:value-of select="$closing-tag"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </line>

    <xsl:if test="exists(*)">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="indent" as="xs:integer" tunnel="yes" select="$indent + $indent-increment"/>
      </xsl:apply-templates>

      <line indent="{$indent}">
        <xsl:value-of select="$closing-tag"/>
      </line>

    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:sequence" mode="mode-xml-fragment-out" as="element(line)+">
    <xsl:param name="indent" as="xs:integer" required="yes" tunnel="yes"/>

    <line indent="{$indent}">
      <xsl:text>return</xsl:text>
    </line>
    <line indent="{$indent + $indent-increment}">
      <xsl:value-of select="@select"/>
    </line>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:variable" mode="mode-xml-fragment-out" as="element(line)">
    <xsl:param name="indent" as="xs:integer" required="yes" tunnel="yes"/>

    <line indent="{$indent}">
      <xsl:text>let $</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:if test="exists(@as)">
        <xsl:text> as </xsl:text>
        <xsl:value-of select="@as"/>
      </xsl:if>
      <xsl:text> := </xsl:text>
      <xsl:value-of select="@select"/>
    </line>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment()[not(starts-with(., $element-documentation-start))]" mode="mode-xml-fragment-out" as="element(line)">
    <xsl:param name="indent" as="xs:integer" required="yes" tunnel="yes"/>

    <xsl:choose>
      <xsl:when test="normalize-space(.) eq ''">
        <line/>
      </xsl:when>
      <xsl:otherwise>
        <line indent="{$indent}">
          <xsl:text>(: </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text> :)</xsl:text>
        </line>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" mode="mode-xml-fragment-out" priority="-1000"/>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="lines-out">
    <xsl:param name="lines" as="element(line)*" required="yes"/>

    <xsl:for-each select="$lines">
      <xsl:variable name="indent" as="xs:integer" select="xtlc:str2int(@indent, 0)"/>
      <xsl:if test="$indent gt 0">
        <xsl:for-each select="1 to $indent">
          <xsl:value-of select="' '"/>
        </xsl:for-each>
      </xsl:if>
      <xsl:value-of select="."/>
      <xsl:value-of select="$newline"/>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="separator-out">
    <xsl:param name="major" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="title" as="xs:string?" required="no" select="()"/>

    <xsl:call-template name="lines-out">
      <xsl:with-param name="lines" as="element(line)*">
        <line/>
        <line>
          <xsl:choose>
            <xsl:when test="$major">
              <xsl:text>(:============================================================================:)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>(:----------------------------------------------------------------------------:)</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </line>
        <xsl:if test="normalize-space($title) ne ''">
          <line>
            <xsl:text>(:== </xsl:text>
            <xsl:value-of select="$title"/>
            <xsl:text> ==:)</xsl:text>
          </line>
        </xsl:if>
        <line/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-xqdoc-comment-lines" as="element(line)*">
    <xsl:param name="lines" as="element(line)*" required="yes"/>

    <xsl:if test="exists($lines)">
      <line>(:~</line>
      <xsl:for-each select="$lines">
        <line indent="2">
          <xsl:value-of select="."/>
        </line>
      </xsl:for-each>
      <line>:)</line>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="element-documentation-to-lines" as="element(line)*">
    <!-- Tries to find the documentation comment for this element (a documentation comment starts with the string $element-documentation-start)
      and extracts this into separate lines. -->
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:variable name="documentation-comment" as="comment()?"
      select="$elm/comment()[starts-with(., $element-documentation-start)]
      [normalize-space(substring-after(., $element-documentation-start)) ne '']"/>
    <xsl:if test="exists($documentation-comment)">
      <xsl:call-template name="multiline-documentation-text-to-lines">
        <xsl:with-param name="in" select="substring-after($documentation-comment, $element-documentation-start)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="multiline-documentation-text-to-lines">
    <xsl:param name="in" as="xs:string" required="yes"/>

    <!-- Separate into lines but do not take end-whitespace into account:: -->
    <xsl:variable name="in-no-cr-characters" as="xs:string" select="replace($in, '&#x0d;', '')"/>
    <xsl:variable name="lines-raw" as="xs:string*" select="tokenize($in-no-cr-characters, '&#x0a;')"/>

    <!-- Remove leading and trailing empty lines: -->
    <xsl:variable name="lines" as="xs:string*">
      <xsl:for-each select="$lines-raw">
        <xsl:variable name="current-position" as="xs:integer" select="position()"/>
        <xsl:choose>

          <!-- Non empty lines always pass: -->
          <xsl:when test="normalize-space(.) ne ''">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when
            test="(normalize-space(.) eq '') and (every $line in $lines-raw[position() = (1 to ($current-position - 1))] satisfies (normalize-space(.) eq ''))">
            <!-- No lines with content before, discard... -->
          </xsl:when>
          <xsl:when
            test="(normalize-space(.) eq '') and (every $line in $lines-raw[position() = (($current-position + 1) to count($lines-raw))] satisfies (normalize-space(.) eq ''))">
            <!-- No lines with content before, discard... -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <!-- Output the lines: -->
    <xsl:for-each select="$lines">

      <!-- Normalize the line and remove any leading underscores. Underscores will be replaced by indents (there seemed to be no other 
        way, since leading whitespace often contains tabs and it was very hard to compute how much the indent actually had to be. Therefore 
        we use the (ugly) idea of forcing whitespace by adding underscores at the beginning of a line. 
      -->
      <xsl:variable name="line-normalized" as="xs:string" select="normalize-space(.)"/>
      <xsl:variable name="line-normalized-no-prefix" as="xs:string" select="replace($line-normalized, '^_+', '')"/>
      <xsl:variable name="indent" as="xs:integer" select="string-length($line-normalized) - string-length($line-normalized-no-prefix)"/>

      <line>
        <xsl:if test="$indent gt 0">
          <xsl:attribute name="indent" select="$indent"/>
        </xsl:if>
        <xsl:value-of select="$line-normalized-no-prefix"/>
      </line>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>

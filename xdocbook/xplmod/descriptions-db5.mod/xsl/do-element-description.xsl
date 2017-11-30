<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Converts an element description to Docbook 5
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  <xsl:include href="../../../xslmod/xdocbook-lib.xsl"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-coded-description" on-no-match="fail"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="debug" as="xs:string" required="no" select="string(false())"/>
  <xsl:variable name="do-debug" as="xs:boolean" select="xtlc:str2bln($debug, false())"/>

  <xsl:param name="fixed-width-characters-per-cm" as="xs:string" required="no" select="'6.5'"/>
  <xsl:variable name="fixed-width-characters-per-cm-dbl" as="xs:double" select="xs:double($fixed-width-characters-per-cm)"/>

  <!-- ================================================================== -->
  <!-- GLOBALS: -->

  <xsl:variable name="global-root-elm" as="element()" select="/*"/>

  <xsl:variable name="newline" as="xs:string" select="'&#x0a;'"/>
  <xsl:variable name="ellipsis" as="xs:string" select="'&#x2026;'"/>

  <xsl:variable name="standard-coded-description-indent" as="xs:integer" select="2"/>
  <xsl:variable name="show-nr-of-enum-values-for-attribute-in-coded-description" as="xs:integer" select="3">
    <!-- The number of attribute enumeration values to show in the coded description (if there are more this will be followed by an ellipsis) -->
  </xsl:variable>

  <xsl:variable name="description-table-name-column-min-width-cm" as="xs:double" select="1.2"/>
  <xsl:variable name="description-table-name-column-max-width-cm" as="xs:double" select="4.0"/>
  <xsl:variable name="description-table-occurs-column-width-cm" as="xs:double" select="0.35"/>
  <xsl:variable name="description-table-type-column-width-cm" as="xs:double" select="3.5"/>

  <xsl:variable name="enums-table-value-column-min-width-cm" as="xs:double" select="0.8"/>
  <xsl:variable name="enums-table-value-column-max-width-cm" as="xs:double" select="2"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlxdb:insert-global-descriptions">
    <!-- Ignore it in the input, we handle this when we handle the xtlxdb:insert-element-description -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlxdb:insert-element-description">

    <!-- Get the element description, either by external document or by direct contents: -->
    <xsl:variable name="element-description" as="element(xtlxdb:element-description)?">
      <xsl:choose>
        <xsl:when test="exists(xtlxdb:element-description)">
          <xsl:sequence select="xtlxdb:element-description"/>
        </xsl:when>
        <xsl:when test="exists(@href)">
          <xsl:variable name="full-href" as="xs:string" select="xtlxdb:get-full-uri(., @href)"/>
          <xsl:if test="doc-available($full-href)">
            <xsl:variable name="description-doc-root" as="element()" select="doc($full-href)/*"/>
            <xsl:if test="exists($description-doc-root/self::xtlxdb:element-description)">
              <xsl:sequence select="$description-doc-root"/>
            </xsl:if>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <!-- Error if not found: -->
    <xsl:if test="empty($element-description)">
      <xsl:choose>
        <xsl:when test="exists(@href)">
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts"
              select="('Could not find element-description for ', xtlc:elm2str(.), ' in ', xtlc:q(xtlxdb:get-full-uri(., @href)))"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Could not find direct element-description for ', xtlc:elm2str(.))"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <!-- Find the global description that apply: -->
    <xsl:variable name="global-descriptions" as="element()*">
      <xsl:call-template name="find-global-descriptions"/>
    </xsl:variable>
    <!-- Turn this on to get the full global descriptions visible: -->
    <!--<programlisting>
      <xsl:for-each select="$global-descriptions">
        <xsl:value-of select="xtlc:elm2str(.)"/>
        <xsl:value-of select="$newline"/>
      </xsl:for-each>
    </programlisting>-->

    <!-- Output the element description: -->
    <xsl:for-each select="$element-description">

      <!-- We start with the coded description: -->
      <xsl:call-template name="create-coded-description">
        <xsl:with-param name="global-descriptions" as="element()*" select="$global-descriptions" tunnel="true"/>
      </xsl:call-template>

      <!-- The output the general description: -->
      <xsl:call-template name="output-docbook-contents">
        <xsl:with-param name="encompassing-element" select="xtlxdb:description"/>
      </xsl:call-template>

      <!-- Attributes table: -->
      <xsl:call-template name="output-description-table">
        <xsl:with-param name="descriptions" select="xtlxdb:attribute"/>
        <xsl:with-param name="header" as="element()*" select="xtlxdb:attribute-table-header/*"/>
        <xsl:with-param name="global-descriptions" as="element()*" select="$global-descriptions" tunnel="true"/>
      </xsl:call-template>

      <!-- Elements table (remove doubles): -->
      <xsl:call-template name="output-description-table">
        <xsl:with-param name="descriptions" as="element(xtlxdb:element)*">
          <xsl:for-each-group select=".//xtlxdb:element" group-by="@name">
            <xsl:sequence select="current-group()[1]"/>
          </xsl:for-each-group>
        </xsl:with-param>
        <xsl:with-param name="header" as="element()*" select="xtlxdb:element-table-header/*"/>
        <xsl:with-param name="global-descriptions" as="element()*" select="$global-descriptions" tunnel="true"/>
      </xsl:call-template>

    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- GLOBAL DESCRIPTIONS: -->

  <xsl:template name="find-global-descriptions">
    <xsl:param name="elm" as="element()" required="no" select="."/>

    <xsl:for-each select="$elm/preceding::xtlxdb:insert-global-descriptions">

      <!-- Get the contents for the global descriptions: -->
      <xsl:variable name="global-descriptions" as="element(xtlxdb:global-descriptions)?">
        <xsl:choose>
          <xsl:when test="exists(xtlxdb:global-descriptions)">
            <xsl:sequence select="xtlxdb:global-descriptions"/>
          </xsl:when>
          <xsl:when test="exists(@href)">
            <xsl:variable name="full-href" as="xs:string" select="xtlxdb:get-full-uri(., @href)"/>
            <xsl:if test="doc-available($full-href)">
              <xsl:variable name="global-descriptions-doc-root" as="element()" select="doc($full-href)/*"/>
              <xsl:if test="exists($global-descriptions-doc-root/self::xtlxdb:global-descriptions)">
                <xsl:sequence select="$global-descriptions-doc-root"/>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="empty($global-descriptions)">
        <xsl:choose>
          <xsl:when test="exists(@href)">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts"
                select="('Could not find global-descriptions for ', xtlc:elm2str(.), ' in ', xtlc:q(xtlxdb:get-full-uri(., @href)))"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="('Could not find direct global-descriptions for ', xtlc:elm2str(.))"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- Output the found definitions: -->
      <xsl:sequence select="$global-descriptions/xtlxdb:*"/>
    </xsl:for-each>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- CODED DESCRIPTION: -->

  <xsl:template name="create-coded-description">
    <xsl:param name="element-description" as="element(xtlxdb:element-description)" required="no" select="."/>

    <xsl:for-each select="$element-description">
      <xsl:variable name="id" as="xs:string" select="(@id, xtlc:str2id(@name, 'element-'))[1]"/>
      <xsl:variable name="element-name" as="xs:string" select="@name"/>
      <xsl:variable name="attributes" as="element(xtlxdb:attribute)*" select="xtlxdb:attribute"/>
      <xsl:variable name="contents" as="element()*" select="xtlxdb:choice | xtlxdb:element"/>
      <xsl:variable name="additional-text-elm" as="element(xtlxdb:additional-text-coded-description)?"
        select="xtlxdb:additional-text-coded-description"/>
      <xsl:variable name="additional-text" as="xs:string" select="string($additional-text-elm)"/>

      <!-- Create the formatted example: -->
      <programlisting xml:id="{$id}">

        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$element-name"/>

        <xsl:choose>
          <!-- Nothing, just an empty element: -->
          <xsl:when test="empty($attributes) and empty($contents) and (normalize-space($additional-text) eq '')">
            <xsl:text>/&gt;</xsl:text>
          </xsl:when>

          <!-- We have contents... -->
          <xsl:otherwise>

            <!-- Attributes: -->
            <xsl:choose>
              <xsl:when test="empty($attributes)">
                <xsl:text>&gt;</xsl:text>
                <xsl:value-of select="$newline"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="indent" as="xs:integer" select="string-length($element-name) + 2"/>
                <xsl:for-each select="$attributes">
                  <xsl:if test="position() ne 1">
                    <xsl:value-of select="local:spaces($indent)"/>
                  </xsl:if>
                  <xsl:if test="position() eq 1">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                  <xsl:call-template name="output-code-description-attribute"/>
                  <xsl:if test="position() ne last()">
                    <xsl:value-of select="$newline"/>
                  </xsl:if>
                </xsl:for-each>
                <xsl:value-of select="if (empty($contents)) then ' /&gt;' else concat(' &gt;', $newline)"/>
              </xsl:otherwise>
            </xsl:choose>

            <!-- Elements and choices: -->
            <xsl:apply-templates select="$contents" mode="mode-coded-description">
              <xsl:with-param name="indent" select="$standard-coded-description-indent"/>
            </xsl:apply-templates>

            <!-- Additional text: -->
            <xsl:variable name="as-comment" as="xs:boolean" select="xtlc:str2bln($additional-text-elm/@as-comment, false())"/>
            <xsl:if test="normalize-space($additional-text) ne ''">
              <xsl:value-of select="local:spaces($standard-coded-description-indent)"/>
              <xsl:choose>
                <xsl:when test="$as-comment">
                  <xsl:text>&lt;!-- </xsl:text>
                  <xsl:value-of select="$additional-text"/>
                  <xsl:text> --&gt;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$additional-text"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$newline"/>
            </xsl:if>

            <!-- Closing tag: -->
            <xsl:if test="exists($contents)">
              <xsl:text>&lt;/</xsl:text>
              <xsl:value-of select="$element-name"/>
              <xsl:text>&gt;</xsl:text>
            </xsl:if>

          </xsl:otherwise>
        </xsl:choose>
      </programlisting>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlxdb:element" mode="mode-coded-description">
    <xsl:param name="indent" as="xs:integer" required="yes"/>
    <xsl:param name="do-newline" as="xs:boolean" required="no" select="true()"/>
    <xsl:param name="global-descriptions" as="element()*" required="yes" tunnel="true"/>

    <xsl:for-each select="local:find-actual-describing-element(., $global-descriptions)">
      <xsl:value-of select="local:spaces($indent)"/>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:value-of select="local:occurs-indicator(.)"/>
      <xsl:if test="$do-newline">
        <xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlxdb:choice" mode="mode-coded-description">
    <xsl:param name="indent" as="xs:integer" required="yes"/>

    <xsl:variable name="occurs" as="xs:string" select="(@occurs, '*')[1]"/>
    <xsl:variable name="opening-prefix" as="xs:string" select="'( '"/>
    <xsl:variable name="elements" as="element(xtlxdb:element)+" select="xtlxdb:element"/>

    <xsl:value-of select="local:spaces($indent)"/>
    <xsl:value-of select="$opening-prefix"/>
    <!-- The first element is not indented (it follows the opening bracket): -->
    <xsl:apply-templates select="$elements[1]" mode="#current">
      <xsl:with-param name="indent" select="0"/>
      <xsl:with-param name="do-newline" select="false()"/>
    </xsl:apply-templates>
    <!-- Do the rest, if any, separated by pipes: -->
    <xsl:if test="count($elements) gt 1">
      <xsl:text> |</xsl:text>
      <xsl:value-of select="$newline"/>
    </xsl:if>
    <xsl:for-each select="$elements[position() gt 1]">
      <xsl:apply-templates select="." mode="#current">
        <xsl:with-param name="indent" select="$indent + string-length($opening-prefix)"/>
        <xsl:with-param name="do-newline" select="false()"/>
      </xsl:apply-templates>
      <xsl:if test="position() lt last()">
        <xsl:text> |</xsl:text>
        <xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> )</xsl:text>
    <xsl:value-of select="local:occurs-indicator(.)"/>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-code-description-attribute">
    <xsl:param name="attribute" as="element(xtlxdb:attribute)" required="no" select="."/>
    <xsl:param name="global-descriptions" as="element()*" required="yes" tunnel="true"/>

    <xsl:for-each select="local:find-actual-describing-element($attribute, $global-descriptions)">

      <!-- Output attribute name and occurrences: -->
      <xsl:value-of select="@name"/>
      <xsl:if test="not(xtlc:str2bln(@required, false()))">
        <xsl:text>?</xsl:text>
      </xsl:if>

      <!-- Output type information (if any): -->
      <xsl:for-each select="local:find-actual-describing-element(xtlxdb:type, $global-descriptions)">
        <xsl:text> = </xsl:text>
        <xsl:variable name="enums" as="element(xtlxdb:enum)*" select="local:find-actual-describing-element(xtlxdb:enum, $global-descriptions)"/>
        <xsl:choose>
          <xsl:when test="exists($enums)">
            <!-- Remark: What we do here is that when there are many enums, we only show the first 
              $show-nr-of-enum-values-for-attribute-in-coded-description ones.
              Of course we could do elaborate stuff here by computing how much space there is on this line, but not now. 
              And anyway, we have no idea how wide this thing actually is, so this is made a parameter. -->
            <xsl:value-of
              select="string-join(for $e in $enums[position() le $show-nr-of-enum-values-for-attribute-in-coded-description] return xtlc:q($e/@value), ' | ')"/>
            <xsl:if test="count($enums) gt $show-nr-of-enum-values-for-attribute-in-coded-description">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$ellipsis"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="(@base, @name)[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- ATTRIBUTES/ELEMENTS TABLE: -->

  <xsl:template name="output-description-table">
    <xsl:param name="descriptions" as="element()*" required="yes"/>
    <xsl:param name="header" as="element()*" required="no" select="()"/>
    <xsl:param name="global-descriptions" as="element()*" required="yes" tunnel="true"/>

    <xsl:variable name="descriptions-to-use" as="element()*" select="$descriptions[xtlc:str2bln(@describe, true())]"/>
    <xsl:variable name="is-attributes" as="xs:boolean" select="exists($descriptions[1]/self::xtlxdb:attribute)"/>
    <xsl:variable name="has-type-info" as="xs:boolean" select="exists($descriptions-to-use/xtlxdb:type)"/>


    <!-- Output if anything left: -->
    <xsl:if test="exists($descriptions-to-use)">
      <para role="halfbreak"/>
      <xsl:call-template name="output-docbook-contents">
        <xsl:with-param name="elms" select="$header"/>
      </xsl:call-template>
      <xsl:variable name="name-column-width" as="xs:double"
        select="local:compute-fixed-width-column-width($descriptions-to-use/@name, 
          $description-table-name-column-min-width-cm, $description-table-name-column-max-width-cm)"/>
      <table role="nonumber">
        <title/>
        <tgroup>
          <colspec colname="name" colwidth="{$name-column-width}cm"/>
          <colspec colname="occurrences" colwidth="{$description-table-occurs-column-width-cm}cm"/>
          <xsl:if test="$has-type-info">
            <colspec colname="type" colwidth="{$description-table-type-column-width-cm}cm"/>
          </xsl:if>
          <colspec colname="description"/>
          <thead>
            <row>
              <entry>
                <xsl:value-of select="if ($is-attributes) then 'Attribute' else 'Child element'"/>
              </entry>
              <entry>#</entry>
              <xsl:if test="$has-type-info">
                <entry>Type</entry>
              </xsl:if>
              <entry>Description</entry>
            </row>
          </thead>
          <tbody>
            <xsl:for-each select="local:find-actual-describing-element($descriptions-to-use, $global-descriptions)">
              <row>
                <entry>
                  <xsl:call-template name="text-out-fixed-width-limited">
                    <xsl:with-param name="text" select="@name"/>
                    <xsl:with-param name="width-cm" select="$name-column-width"/>
                  </xsl:call-template>
                </entry>
                <entry>
                  <para>
                    <xsl:choose>
                      <xsl:when test="$is-attributes">
                        <xsl:value-of select="if (xtlc:str2bln(@required, false())) then '1' else '?'"/>
                      </xsl:when>
                      <xsl:when test="exists(parent::xtlxdb:choice)">
                        <!-- In case this element is in a choice we take the occurrences of the choice. That is not exactly correct but better
                          than taking them from the element in a case like this... -->
                        <xsl:value-of select="(../@occurs, '1')[1]"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="(@occurs, '1')[1]"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </para>
                </entry>
                <xsl:if test="$has-type-info">
                  <entry>
                    <xsl:call-template name="output-type-info-in-description-table">
                      <xsl:with-param name="type" select="xtlxdb:type"/>
                      <xsl:with-param name="column-width-cm" select="$description-table-type-column-width-cm"/>
                    </xsl:call-template>
                  </entry>
                </xsl:if>
                <entry>
                  <xsl:if test="(normalize-space(@default) ne '') and not(xtlc:str2bln(@required, false()))">
                    <para>Default: <code><xsl:value-of select="@default"/></code></para>
                  </xsl:if>
                  <xsl:call-template name="output-docbook-contents">
                    <xsl:with-param name="encompassing-element" select="xtlxdb:description"/>
                  </xsl:call-template>
                  <xsl:call-template name="output-type-enums-table">
                    <xsl:with-param name="type" select="xtlxdb:type"/>
                  </xsl:call-template>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </table>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-type-info-in-description-table">
    <xsl:param name="type" as="element(xtlxdb:type)?" required="yes"/>
    <xsl:param name="column-width-cm" as="xs:double" required="yes"/>
    <xsl:param name="global-descriptions" as="element()*" required="yes" tunnel="true"/>

    <xsl:for-each select="local:find-actual-describing-element($type, $global-descriptions)">
      <xsl:call-template name="text-out-fixed-width-limited">
        <xsl:with-param name="text" select="(@base, @name)[1]"/>
        <xsl:with-param name="width-cm" select="$column-width-cm"/>
      </xsl:call-template>
      <xsl:call-template name="output-docbook-contents">
        <xsl:with-param name="encompassing-element" select="xtlxdb:description"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-type-enums-table">
    <xsl:param name="type" as="element(xtlxdb:type)?" required="yes"/>
    <xsl:param name="global-descriptions" as="element()*" required="yes" tunnel="true"/>

    <xsl:for-each select="local:find-actual-describing-element($type, $global-descriptions)">
      <xsl:variable name="enums" as="element(xtlxdb:enum)*" select="local:find-actual-describing-element(xtlxdb:enum, $global-descriptions)"/>
      <xsl:if test="exists($enums)">
        <xsl:variable name="value-column-width" as="xs:double"
          select="local:compute-fixed-width-column-width($enums/@value, 
            $enums-table-value-column-min-width-cm, $enums-table-value-column-max-width-cm)"/>
        <table role="nonumber">
          <title/>
          <tgroup cols="2">
            <colspec colname="value" colnum="1" colwidth="{$value-column-width}cm"/>
            <colspec colname="description" colnum="1"/>
            <thead>
              <row>
                <entry>Value</entry>
                <entry>Description</entry>
              </row>
            </thead>
            <tbody>
              <xsl:for-each select="$enums">
                <row>
                  <entry>
                    <xsl:call-template name="text-out-fixed-width-limited">
                      <xsl:with-param name="text" select="@value"/>
                      <xsl:with-param name="width-cm" select="$value-column-width"/>
                    </xsl:call-template>
                  </entry>
                  <entry>
                    <xsl:call-template name="output-docbook-contents">
                      <xsl:with-param name="encompassing-element" select="xtlxdb:description"/>
                    </xsl:call-template>
                  </entry>
                </row>
              </xsl:for-each>
            </tbody>
          </tgroup>
        </table>
        <para role="smallbreak"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="output-docbook-contents">
    <!-- Will turn everything in the empty or in the xtlxdb namespace into the docbook namespace.
      Use either $elms or $encompassing-elements.-->
    <xsl:param name="elms" as="element()*" required="no" select="()"/>
    <xsl:param name="encompassing-element" as="element()?" required="no" select="()"/>

    <xsl:call-template name="xtlxdb:convert-to-docbook-contents">
      <xsl:with-param name="elms" as="element()*" select="($elms, $encompassing-element/*)"/>
      <xsl:with-param name="convert-namespaces" as="xs:string*" select="($xtlxdb:xtlxdb-namespace, '')"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:find-actual-describing-element" as="element()*">
    <!-- This function takes action on @use-global. When true it tries to find the appropriate global element with the same name. -->
    <xsl:param name="elm" as="element()*"/>
    <xsl:param name="global-descriptions" as="element()*"/>

    <xsl:for-each select="$elm">
      <xsl:choose>
        <xsl:when test="xtlc:str2bln(@use-global, false())">
          <xsl:variable name="name" as="xs:string" select="(@name, @value)[1]"/>
          <xsl:variable name="element-name" as="xs:string" select="local-name(.)"/>
          <xsl:variable name="global-description" as="element()?"
            select="($global-descriptions[local-name(.) eq $element-name][(@name eq $name) or (@value eq $name)])[last()]"/>
          <xsl:if test="empty($global-description)">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="('Could not find required global description for ', xtlc:elm2str(.))"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:sequence select="$global-description"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:spaces" as="xs:string">
    <xsl:param name="length" as="xs:integer"/>
    <xsl:sequence select="xtlc:char-repeat(' ', $length)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:occurs-indicator" as="xs:string">
    <!-- This routine is here for future extension of the occurs mechanism. For now we only have 1, ?, +, * but maybe we need more 
      later (like specific numbers). -->
    <xsl:param name="element-with-occurs" as="element()"/>
    <xsl:variable name="occurs" as="xs:string" select="($element-with-occurs/@occurs, '1')[1]"/>
    <xsl:sequence select="if ($occurs eq '1') then '' else $occurs"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="text-out-fixed-width-limited">
    <xsl:param name="text" as="xs:string" required="true"/>
    <xsl:param name="width-cm" as="xs:double" required="true"/>

    <xsl:variable name="characters-per-line" as="xs:integer" select="xs:integer(floor($width-cm * $fixed-width-characters-per-cm-dbl))"/>
    <xsl:variable name="nr-of-lines" as="xs:integer" select="xs:integer(ceiling(string-length($text) div $characters-per-line))"/>
    <xsl:for-each select="1 to $nr-of-lines">
      <xsl:variable name="line-nr" as="xs:integer" select="."/>
      <para>
        <code>
          <xsl:value-of select="substring($text, 1 + (($line-nr - 1) * $characters-per-line), $characters-per-line)"/>
        </code>
      </para>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:compute-fixed-width-column-width" as="xs:double">
    <xsl:param name="names" as="xs:string*"/>
    <xsl:param name="min-width" as="xs:double"/>
    <xsl:param name="max-width" as="xs:double"/>

    <xsl:variable name="max-nr-of-characters" as="xs:integer" select="max(for $n in $names return string-length($n))"/>
    <xsl:variable name="width-based-on-nr-of-characters" as="xs:double" select="$max-nr-of-characters div $fixed-width-characters-per-cm-dbl"/>
    <!-- Find the right width and add just a  tiny bit to make sure everything goes ok (otherwise sometimes words still go to the next line) -->
    <xsl:variable name="width" as="xs:double" select="max(($min-width, $width-based-on-nr-of-characters)) + 0.1"/>
    <xsl:sequence select="if ($width gt $max-width) then $max-width else $width"/>
  </xsl:function>

</xsl:stylesheet>

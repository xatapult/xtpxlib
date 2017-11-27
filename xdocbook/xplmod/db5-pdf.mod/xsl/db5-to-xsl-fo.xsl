<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns="http://www.w3.org/1999/XSL/Format" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--*	
    Turns the db5 (in XProc book dialect) into XSL-FO 	
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>

  <xsl:mode on-no-match="fail"/>
  <xsl:mode name="mode-structure" on-no-match="fail"/>
  <xsl:mode name="mode-block" on-no-match="fail"/>
  <xsl:mode name="mode-inline" on-no-match="fail"/>
  <xsl:mode name="mode-create-toc" on-no-match="fail"/>

  <xsl:variable name="id-index-name" as="xs:string" select="'id-index'" static="true"/>
  <xsl:key _name="{$id-index-name}" match="db:*" use="@xml:id"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="debug" as="xs:string" required="no" select="string(false())"/>
  <xsl:param name="chapter-id" as="xs:string" required="no" select="''">
    <!-- With this parameter you can provide the identifier of a chapter (or preface) to output only. Front page and TOC will not be output.
      Use for debugging. -->
  </xsl:param>

  <xsl:variable name="do-debug" as="xs:boolean" select="xtlc:str2bln($debug, false())"/>
  <xsl:variable name="do-chapter-id" as="xs:string" select="normalize-space($chapter-id)"/>
  <xsl:variable name="chapter-id-provided" as="xs:boolean" select="$do-chapter-id ne ''"/>

  <!-- ================================================================== -->
  <!-- LAYOUT STUFF -->
  <!-- Remark: Everything uses cm, except font-sizes or specified otherwise. -->

  <!-- Page master names: -->
  <xsl:variable name="spm-frontpage" as="xs:string" select="'spm-frontpage'"/>
  <xsl:variable name="spm-contents" as="xs:string" select="'spm-contents'"/>

  <!-- Standard A4 page dimensions: -->
  <xsl:variable name="page-width-a4" as="xs:double" select="21.0"/>
  <xsl:variable name="page-height-a4" as="xs:double" select="29.7"/>
  <xsl:attribute-set name="attributes-dimensions-page">
    <xsl:attribute name="page-height" select="local:dimcm($page-height-a4)"/>
    <xsl:attribute name="page-width" select="local:dimcm($page-width-a4)"/>
  </xsl:attribute-set>

  <!-- Standard page margins: -->
  <xsl:variable name="standard-page-margin-top" as="xs:double" select="1"/>
  <xsl:variable name="standard-page-margin-bottom" as="xs:double" select="1"/>
  <xsl:variable name="standard-page-margin-left" as="xs:double" select="4"/>
  <xsl:variable name="standard-page-margin-right" as="xs:double" select="2"/>
  <xsl:attribute-set name="attributes-standard-page-margins">
    <xsl:attribute name="margin-top" select="local:dimcm($standard-page-margin-top)"/>
    <xsl:attribute name="margin-bottom" select="local:dimcm($standard-page-margin-bottom)"/>
    <xsl:attribute name="margin-left" select="local:dimcm($standard-page-margin-left)"/>
    <xsl:attribute name="margin-right" select="local:dimcm($standard-page-margin-right)"/>
  </xsl:attribute-set>

  <!-- Standard attribute sets and other settings: -->
  <xsl:variable name="standard-font-size" as="xs:double" select="8"/>
  <xsl:variable name="special-titles-font-size" as="xs:double" select="$standard-font-size - 2"/>
  <xsl:variable name="super-sub-font-size" as="xs:double" select="$standard-font-size - 3"/>
  <xsl:variable name="chapter-font-size-addition" as="xs:double" select="6"/>
  <xsl:variable name="standard-small-indent" as="xs:double" select="0.15"/>
  <xsl:variable name="standard-itemized-list-indent" as="xs:double" select="0.3"/>

  <xsl:attribute-set name="attributes-standard-font-settings">
    <xsl:attribute name="font-family" select="'Verdana, sans-serif'"/>
    <xsl:attribute name="font-size" select="local:dimpt($standard-font-size)"/>
  </xsl:attribute-set>

  <xsl:variable name="code-font-family" as="xs:string" select="'&apos;&apos;Courier New&apos;&apos;, monospace'"/>
  <xsl:attribute-set name="attributes-codeblock-font-settings">
    <xsl:attribute name="font-family" select="$code-font-family"/>
    <xsl:attribute name="font-size" select="local:dimpt($standard-font-size - 2)"/>
    <xsl:attribute name="background-color" select="'#E0E0E0'"/>
    <xsl:attribute name="space-before" select="0"/>
    <xsl:attribute name="space-after" select="0"/>
  </xsl:attribute-set>

  <!-- Distance between paragraphs -->
  <xsl:variable name="standard-paragraph-distance-pt" as="xs:double" select="2"/>
  <xsl:variable name="break-paragraph-distance-pt" as="xs:double" select="$standard-paragraph-distance-pt * 5"/>
  <xsl:variable name="standard-extra-paragraph-distance-pt" as="xs:double" select="$standard-paragraph-distance-pt * 2"/>

  <!-- Others: -->
  <xsl:variable name="bookmark-final-page-block" as="xs:string" select="'bookmark-final-page-block'"/>
  <xsl:variable name="link-color" as="xs:string" select="'blue'"/>

  <!-- Debug info: -->
  <xsl:variable name="debug-info-block" as="element(fo:block)?">
    <xsl:if test="$do-debug">
      <fo:block font-style="italic" font-size="{local:dimpt($standard-font-size - 1)}" font-weight="bold">Debug version (<xsl:value-of
          select="format-dateTime(current-dateTime(), $xtlc:default-dt-format-en)"/>)</fo:block>
    </xsl:if>
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/">
    <xsl:apply-templates>
      <xsl:with-param name="phase-description" as="xs:string" select="'main'" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/db:book">
    <root>

      <!-- Define the pages: -->
      <layout-master-set>
        <!-- Front page: -->
        <simple-page-master master-name="{$spm-frontpage}" xsl:use-attribute-sets="attributes-dimensions-page attributes-standard-page-margins">
          <!-- The front page uses the full available page, no headers or footers. -->
          <region-body margin-top="0cm"/>
        </simple-page-master>
        <!-- Content pages -->
        <simple-page-master master-name="{$spm-contents}" xsl:use-attribute-sets="attributes-dimensions-page attributes-standard-page-margins">
          <!-- The normal content page defines a header. -->
          <region-body margin-top="2cm"/>
          <region-before extent="1.5cm"/>
        </simple-page-master>
      </layout-master-set>

      <!-- Front page: -->
      <xsl:if test="not($chapter-id-provided)">
        <xsl:call-template name="create-frontpage"/>
      </xsl:if>

      <!-- And the contents: -->
      <xsl:call-template name="create-main-contents"/>

    </root>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- FRONT PAGE: -->

  <xsl:template name="create-frontpage">
    <xsl:param name="book" as="element(db:book)" required="no" select="."/>

    <page-sequence master-reference="{$spm-frontpage}" xsl:use-attribute-sets="attributes-standard-font-settings">
      <flow flow-name="xsl-region-body">

        <!-- Logo's at the top: -->
        <xsl:variable name="logo-imagedata" as="element(db:imagedata)?" select="/*/db:info/db:mediaobject/db:imageobject/db:imagedata"/>
        <xsl:if test="exists($logo-imagedata)">
          <block-container>
            <block vertical-align="middle">
              <xsl:call-template name="handle-imagedata">
                <xsl:with-param name="imagedata" select="$logo-imagedata"/>
              </xsl:call-template>
            </block>
          </block-container>
        </xsl:if>

        <!-- Title information: -->
        <block-container absolute-position="fixed" top="{local:dimcm($standard-page-margin-top + 5)}" left="{local:dimcm($standard-page-margin-left)}"
          font-variant="small-caps" letter-spacing="1pt" font-weight="bold">
          <block space-after="1cm" font-size="18pt">
            <xsl:value-of select="/*/db:info/db:title"/>
          </block>
          <block font-size="14pt">
            <xsl:value-of select="/*/db:info/db:subtitle"/>
          </block>
        </block-container>

        <!-- Some more information at the bottom: -->
        <block-container absolute-position="fixed" top="{local:dimcm($page-height-a4 - 3)}" left="{local:dimcm($standard-page-margin-left)}">
          <xsl:variable name="publication-date" as="xs:string?" select="/*/db:info/db:pubdate"/>
          <xsl:variable name="author" as="xs:string?" select="/*/db:info/db:author/db:personname"/>
          <xsl:variable name="organization" as="xs:string?" select="/*/db:info/db:orgname"/>
          <xsl:if test="exists($author) or exists($organization)">
            <block>
              <xsl:value-of select="string-join(($author, $organization), ' - ')"/>
            </block>
          </xsl:if>
          <xsl:if test="exists($publication-date)">
            <block>
              <xsl:value-of select="/*/db:info/db:pubdate"/>
            </block>
          </xsl:if>
          <xsl:copy-of select="$debug-info-block"/>
        </block-container>
      </flow>

    </page-sequence>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- MAIN CONTENTS: -->

  <xsl:template name="create-main-contents">
    <xsl:param name="book" as="element(db:book)" required="no" select="."/>

    <page-sequence master-reference="{$spm-contents}" xsl:use-attribute-sets="attributes-standard-font-settings" initial-page-number="1">

      <!-- Setup a header: -->
      <static-content flow-name="xsl-region-before">
        <block>
          <xsl:value-of select="string-join((/*/db:info/db:title, /*/db:info/db:subtitle), ' - ')"/>
        </block>
        <block text-align="right" space-before="{local:dimpt(-$standard-font-size)}"><page-number/>&#160;/&#160;<page-number-citation
            ref-id="{$bookmark-final-page-block}"/></block>
        <xsl:copy-of select="$debug-info-block"/>
      </static-content>

      <!-- Do the rest: -->
      <flow flow-name="xsl-region-body">
        <xsl:if test="not($chapter-id-provided)">
          <xsl:call-template name="create-toc"/>
        </xsl:if>
        <xsl:call-template name="handle-structure">
          <xsl:with-param name="book" select="$book"/>
        </xsl:call-template>
        <!-- Mark the end so we can get the final page number: -->
        <block id="{$bookmark-final-page-block}"/>
      </flow>

    </page-sequence>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- HANDLE OVERARCHING DOCUMENT STRUCTURE: -->

  <xsl:template name="handle-structure">
    <xsl:param name="book" as="element(db:book)" required="no" select="."/>

    <xsl:apply-templates select="$book/*" mode="mode-structure">
      <xsl:with-param name="phase-description" as="xs:string" select="'structure'" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:info" mode="mode-structure">
    <!-- Ignore -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:chapter | db:preface" mode="mode-structure">

    <xsl:choose>
      <xsl:when test="not($chapter-id-provided) or (@xml:id eq $chapter-id)">
        <xsl:call-template name="chapter-section-header-title-out">
          <xsl:with-param name="font-size" select="$standard-font-size + $chapter-font-size-addition"/>
          <xsl:with-param name="page-break" select="true()"/>
        </xsl:call-template>

        <xsl:call-template name="handle-block-contents">
          <xsl:with-param name="contents" select="* except db:title"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Do not output... -->
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sect1 | db:sect2 | db:sect3" mode="mode-block">

    <xsl:variable name="element-name" as="xs:string" select="local-name(.)"/>
    <xsl:variable name="section-level" as="xs:integer" select="xs:integer(substring-after($element-name, 'sect'))"/>
    <xsl:variable name="section-number" as="xs:integer" select="count(preceding-sibling::db:*[local-name(.) eq $element-name]) + 1"/>
    <xsl:variable name="font-size" as="xs:double"
      select="if ($section-level le 3) then ($standard-font-size + $chapter-font-size-addition - $section-level - 1) else ($standard-font-size + 1)"/>

    <xsl:call-template name="chapter-section-header-title-out">
      <xsl:with-param name="font-size" select="$font-size"/>
    </xsl:call-template>
    <xsl:call-template name="handle-block-contents">
      <xsl:with-param name="contents" select="* except db:title"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- BLOCK CONTENTS: -->

  <xsl:template name="handle-block-contents">
    <xsl:param name="contents" as="element()*" required="yes"/>

    <xsl:apply-templates select="$contents" mode="mode-block">
      <xsl:with-param name="phase-description" as="xs:string" select="'block'" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:para" mode="mode-block">

    <xsl:variable name="roles" as="xs:string*" select="xtlc:str2seq(@role)"/>
    <xsl:variable name="is-halfbreak" as="xs:boolean" select="$roles = ('halfbreak')"/>
    <xsl:variable name="is-break" as="xs:boolean" select="$roles = ('break')"/>

    <block space-after="{local:dimpt($standard-paragraph-distance-pt)}" keep-together.within-page="always">
      <xsl:if test="$is-halfbreak">
        <xsl:attribute name="font-size" select="local:dimpt($standard-font-size div 4)"/>
      </xsl:if>
      <xsl:if test="$roles = ('header', 'keep-with-next')">
        <xsl:attribute name="keep-with-next" select="'always'"/>
      </xsl:if>
      <xsl:if test="$roles = ('break-after')">
        <xsl:attribute name="space-after" select="local:dimpt($break-paragraph-distance-pt)"/>
      </xsl:if>
      <xsl:if test="$roles = ('break-before')">
        <xsl:attribute name="space-before" select="local:dimpt($break-paragraph-distance-pt)"/>
      </xsl:if>
      <xsl:if test="$is-break or ($roles = ('small'))">
        <xsl:attribute name="font-size" select="local:dimpt($standard-font-size - 1)"/>
      </xsl:if>
      <xsl:call-template name="copy-id"/>
      <xsl:choose>
        <xsl:when test="$is-break or $is-halfbreak">
          <!-- Ignore any contents, just emit a hard-space: -->
          <xsl:text>&#160;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="handle-inline-contents">
            <xsl:with-param name="contents" select="node()"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:bridgehead" mode="mode-block">
    <block space-before.minimum="{local:dimpt(1.5 * $standard-font-size)}" space-after="{local:dimpt($standard-font-size div 2)}" font-weight="bold"
      text-decoration="underline" keep-with-next="always">
      <xsl:call-template name="copy-id"/>
      <xsl:call-template name="handle-inline-contents">
        <xsl:with-param name="contents" select="node()"/>
      </xsl:call-template>
    </block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:remark" mode="mode-block">
    <!-- We will only output remarks when debug is on! -->
    <xsl:choose>
      <xsl:when test="$do-debug">
        <block font-style="italic" background-color="yellow" border="thin solid black" margin-top="{local:dimpt($standard-font-size div 2)}"
          margin-bottom="{local:dimpt($standard-font-size div 2)}">
          <xsl:text>***&#160;</xsl:text>
          <xsl:call-template name="handle-inline-contents">
            <xsl:with-param name="contents" select="node()"/>
          </xsl:call-template>
        </block>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:itemizedlist | db:orderedlist" mode="mode-block">

    <xsl:variable name="in-ordered-list" as="xs:boolean" select="exists(self::db:orderedlist)"/>

    <list-block provisional-distance-between-starts="{local:dimcm($standard-itemized-list-indent)}"
      space-after="{local:dimpt($standard-paragraph-distance-pt)}" keep-with-previous="always">
      <xsl:call-template name="copy-id"/>

      <xsl:for-each select="db:listitem">
        <list-item space-after="{local:dimpt($standard-paragraph-distance-pt)}">
          <xsl:call-template name="copy-id"/>

          <xsl:variable name="position" as="xs:integer" select="count(preceding-sibling::db:listitem) + 1"/>
          <xsl:variable name="is-last" as="xs:boolean" select="empty(following-sibling::db:listitem)"/>
          <xsl:choose>
            <xsl:when test="$position le 2">
              <xsl:attribute name="keep-with-next" select="'always'"/>
            </xsl:when>
            <xsl:when test="$is-last">
              <xsl:attribute name="keep-with-previous" select="'always'"/>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>

          <list-item-label end-indent="label-end()">
            <xsl:choose>
              <xsl:when test="$in-ordered-list">
                <xsl:variable name="item-number" as="xs:integer" select="count(preceding-sibling::db:listitem) + 1"/>
                <block><xsl:value-of select="$item-number"/>.</block>
              </xsl:when>
              <xsl:otherwise>
                <block font-weight="bold">-</block>
              </xsl:otherwise>
            </xsl:choose>
          </list-item-label>
          <list-item-body start-indent="body-start()">
            <xsl:call-template name="handle-block-contents">
              <xsl:with-param name="contents" select="*"/>
            </xsl:call-template>
          </list-item-body>
        </list-item>
      </xsl:for-each>

    </list-block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:figure | db:informalfigure" mode="mode-block">

    <block text-align="center" space-before="{local:dimpt(2 * $standard-paragraph-distance-pt)}"
      space-after="{local:dimpt(3 * $standard-paragraph-distance-pt)}" keep-with-previous="always">
      <xsl:call-template name="copy-id"/>
      <xsl:call-template name="handle-imagedata">
        <xsl:with-param name="imagedata" select="db:mediaobject/db:imageobject/db:imagedata"/>
      </xsl:call-template>
    </block>
    <xsl:if test="exists(self::db:figure)">
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Figure'"/>
        <xsl:with-param name="align-left" select="false()"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:programlisting" mode="mode-block">
    <xsl:param name="in-example" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <!-- Break the contents down in lines (before that, remove any CR characters): -->
    <xsl:variable name="contents-no-cr" as="xs:string" select="replace(string(.), '&#x0d;', '')"/>
    <xsl:variable name="lines" as="xs:string*" select="tokenize($contents-no-cr, '&#x0a;')"/>

    <xsl:variable name="space-before-after" as="xs:double" select="$standard-font-size div 2.0"/>
    <block keep-together.within-column="always" space-before="{local:dimpt($space-before-after)}" space-after="{local:dimpt($space-before-after)}">
      <xsl:if test="not($in-example)">
        <xsl:attribute name="margin-left" select="local:dimcm($standard-small-indent)"/>
        <xsl:attribute name="margin-right" select="local:dimcm($standard-small-indent)"/>
      </xsl:if>
      <xsl:call-template name="copy-id"/>
      <xsl:for-each select="$lines">
        <block xsl:use-attribute-sets="attributes-codeblock-font-settings">
          <!-- Replace spaces with hard spaces so we keep the indent: -->
          <xsl:choose>
            <xsl:when test=". eq ''">
              <xsl:text>&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="translate(., ' ', '&#160;')"/>
            </xsl:otherwise>
          </xsl:choose>
        </block>
      </xsl:for-each>
    </block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:simplelist" mode="mode-block">


    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <xsl:for-each select="db:member">
      <block margin-left="{local:dimcm($standard-small-indent)}">
        <xsl:variable name="position" as="xs:integer" select="count(preceding-sibling::db:member) + 1"/>
        <xsl:variable name="is-last" as="xs:boolean" select="empty(following-sibling::db:member)"/>
        <xsl:choose>
          <xsl:when test="$position le 2">
            <xsl:attribute name="keep-with-next" select="'always'"/>
          </xsl:when>
          <xsl:when test="$is-last">
            <xsl:attribute name="keep-with-previous" select="'always'"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        <xsl:value-of select="."/>
      </block>
    </xsl:for-each>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:variablelist" mode="mode-block">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <xsl:for-each select="db:varlistentry">
      <block keep-with-next="always">
        <xsl:call-template name="handle-inline-text">
          <xsl:with-param name="text" select="db:term"/>
          <xsl:with-param name="italic" select="true()"/>
        </xsl:call-template>
      </block>
      <block-container margin-left="{local:dimcm($standard-small-indent)}">
        <xsl:apply-templates select="db:listitem/db:*" mode="#current"/>
      </block-container>
    </xsl:for-each>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:note | db:warning" mode="mode-block">

    <xsl:variable name="is-note" as="xs:boolean" select="exists(self::db:note)"/>
    <xsl:variable name="color" as="xs:string" select="if ($is-note) then 'navy' else 'purple'"/>

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block margin-left="{local:dimcm($standard-small-indent)}" margin-right="{local:dimcm($standard-small-indent)}"
      padding-left="{local:dimcm($standard-small-indent)}" padding-right="{local:dimcm($standard-small-indent)}" border="thin solid {$color}">
      <block font-weight="bold" keep-with-next="always" color="{$color}">
        <xsl:value-of select="if ($is-note) then 'NOTE:' else 'WARNING:'"/>
      </block>
      <xsl:apply-templates mode="#current"/>
    </block>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:sidebar" mode="mode-block">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block-container border="solid 0.2mm black">
      <block font-weight="bold" keep-with-next="always" margin-top="{local:dimpt($standard-paragraph-distance-pt)}" text-align="center"
        font-size="{local:dimpt($standard-font-size + 2)}">
        <xsl:call-template name="handle-inline-text">
          <xsl:with-param name="contents" select="db:title/node()"/>
          <xsl:with-param name="bold" select="true()"/>
        </xsl:call-template>
      </block>
      <xsl:apply-templates select="db:* except db:title" mode="#current"/>
    </block-container>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:example" mode="mode-block">

    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
      <xsl:with-param name="keep-with-next" select="true()"/>
    </xsl:call-template>
    <block-container margin-left="{local:dimcm($standard-small-indent)}" margin-right="{local:dimcm($standard-small-indent)}">
      <xsl:apply-templates select="db:* except db:title" mode="#current">
        <xsl:with-param name="in-example" as="xs:boolean" select="true()" tunnel="true"/>
      </xsl:apply-templates>
      <xsl:call-template name="add-object-title">
        <xsl:with-param name="object-name" select="'Example'"/>
      </xsl:call-template>
    </block-container>
    <xsl:call-template name="empty-line">
      <xsl:with-param name="size-pt" select="$standard-extra-paragraph-distance-pt"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-object-title">
    <xsl:param name="object" as="element()" required="no" select="."/>
    <xsl:param name="object-name" as="xs:string?" required="no" select="()"/>
    <xsl:param name="align-left" as="xs:boolean" required="no" select="true()"/>

    <xsl:if test="(normalize-space($object/db:title) ne '') or exists($object/@number)">
      <block text-align="{if ($align-left) then 'left' else 'center'}" font-style="italic" font-size="{local:dimpt($special-titles-font-size)}"
        space-after="{local:dimpt($standard-font-size)}" keep-with-previous="always">
        <xsl:if test="exists($object-name) and exists($object/@number)">
          <xsl:value-of select="$object-name"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$object/@number"/>
          <xsl:if test="normalize-space(db:title) ne ''">
            <xsl:text>&#160;-&#160;</xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:call-template name="handle-inline-contents">
          <xsl:with-param name="contents" select="db:title/node()"/>
          <xsl:with-param name="small-font-size" select="true()"/>
        </xsl:call-template>
      </block>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SPECIAL BLOCK: TABLES: -->

  <xsl:template match="db:table | db:informaltable" mode="mode-block">

    <xsl:variable name="in-informal-table" as="xs:boolean" select="exists(self::db:informaltable)"/>

    <table space-before="{local:dimpt(2 * $standard-paragraph-distance-pt)}" space-after="{local:dimpt(3 * $standard-paragraph-distance-pt)}"
      font-size="{local:dimpt($standard-font-size - 1)}">
      <xsl:call-template name="copy-id"/>
      <xsl:if test="local:element-is-in-table(.)">
        <!-- For a table-in-a-table, take a little more space at the right. -->
        <xsl:attribute name="margin-right" select="local:dimpt($standard-font-size div 2.0)"/>
      </xsl:if>
      <xsl:apply-templates mode="mode-table" select="db:* except db:title">
        <xsl:with-param name="phase-description" as="xs:string" select="'table'" tunnel="true"/>
        <xsl:with-param name="in-informal-table" as="xs:boolean" select="$in-informal-table" tunnel="true"/>
        <xsl:with-param name="in-table" as="xs:boolean" select="true()" tunnel="true"/>
      </xsl:apply-templates>
    </table>

    <xsl:choose>
      <xsl:when test="$in-informal-table">
        <!-- Not sure about this... -->
        <!--<xsl:call-template name="empty-line">
          <xsl:with-param name="size-pt" select="$table-spacing-pt"/>
        </xsl:call-template>-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="add-object-title">
          <xsl:with-param name="object-name" select="'Table'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tgroup" mode="mode-table">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:colspec" mode="mode-table">
    <table-column>
      <xsl:if test="exists(@colwidth)">
        <xsl:attribute name="column-width" select="@colwidth"/>
      </xsl:if>
    </table-column>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:thead" mode="mode-table">
    <xsl:param name="in-informal-table" as="xs:boolean" required="true" tunnel="true"/>

    <table-header>
      <xsl:if test="not($in-informal-table)">
        <xsl:attribute name="color" select="'white'"/>
        <xsl:attribute name="background-color" select="'black'"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </table-header>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:tbody" mode="mode-table">
    <table-body>
      <xsl:apply-templates mode="#current"/>
    </table-body>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:row" mode="mode-table">
    <table-row keep-together.within-column="always">
      <xsl:call-template name="copy-id"/>

      <xsl:choose>
        <xsl:when test="position() le 2">
          <xsl:attribute name="keep-with-next" select="'always'"/>
        </xsl:when>
        <xsl:when test="position() eq last()">
          <xsl:attribute name="keep-with-previous" select="'always'"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>

      <xsl:call-template name="copy-id"/>
      <xsl:apply-templates mode="#current"/>
    </table-row>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:entry" mode="mode-table">
    <xsl:param name="in-informal-table" as="xs:boolean" required="true" tunnel="true"/>

    <table-cell padding="{local:dimpt(1)}" margin-left="0">
      <xsl:if test="not($in-informal-table)">
        <xsl:attribute name="border" select="'solid 0.1mm black'"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="empty(db:para)">
          <!-- No surrounding <para> or so it seems, create one: -->
          <xsl:call-template name="handle-block-contents">
            <xsl:with-param name="contents" as="element()*">
              <db:para>
                <xsl:sequence select="node()"/>
              </db:para>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="handle-block-contents">
            <xsl:with-param name="contents" select="*"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </table-cell>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- INLINE CONTENTS: -->

  <xsl:template name="handle-inline-contents">
    <xsl:param name="contents" as="node()*" required="yes"/>
    <xsl:param name="small-font-size" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="fixed-font-size-adjust" as="xs:integer?" required="no" select="()" tunnel="true"/>

    <xsl:apply-templates select="$contents" mode="mode-inline">
      <xsl:with-param name="phase-description" as="xs:string" select="'inline'" tunnel="true"/>
      <xsl:with-param name="fixed-font-size-adjust" as="xs:integer?" select="if ($small-font-size) then -2 else $fixed-font-size-adjust" tunnel="true"
      />
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:xref" mode="mode-inline">

    <xsl:variable name="id" as="xs:string" select="@linkend"/>
    <xsl:variable name="referenced-element" as="element()?" select="key($id-index-name, $id)"/>

    <xsl:choose>
      <xsl:when test="exists($referenced-element)">
        <basic-link internal-destination="{$id}">
          <xsl:choose>
            <xsl:when test="$referenced-element/self::db:chapter">
              <xsl:text>Chapter&#160;</xsl:text>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:when test="matches(local-name($referenced-element), '^sect[0-9]$')">
              <xsl:text>"</xsl:text>
              <xsl:value-of select="normalize-space($referenced-element/db:title)"/>
              <xsl:text>" on page&#160;</xsl:text>
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:when>
            <xsl:when
              test="$referenced-element/self::db:figure[exists(@number)] or $referenced-element/self::db:table[exists(@number)] or
                $referenced-element/self::db:example[exists(@number)]">
              <xsl:value-of select="xtlc:str-capitalize(local-name($referenced-element))"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$referenced-element/@number"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>page&#160;</xsl:text>
              <page-number-citation ref-id="{$referenced-element/@xml:id}"/>
            </xsl:otherwise>
          </xsl:choose>
        </basic-link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Referenced linkend id ', xtlc:q(@linkend), ' not found')"/>
          <xsl:with-param name="block" select="false()"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:emphasis" mode="mode-inline">

    <xsl:variable name="role" as="xs:string*" select="normalize-space(@role)"/>
    <xsl:variable name="bold" as="xs:boolean" select="$role eq 'bold'"/>
    <xsl:variable name="underline" as="xs:boolean" select="$role eq 'underline'"/>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="$bold"/>
      <xsl:with-param name="underline" select="$underline"/>
      <xsl:with-param name="italic" select="not($bold) and not($underline)"/>
    </xsl:call-template>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:code | db:literal" mode="mode-inline">
    <xsl:param name="fixed-font-size-adjust" as="xs:integer?" required="no" select="()" tunnel="true"/>
    <xsl:param name="in-table" as="xs:boolean" required="no" select="false()" tunnel="true"/>

    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="fixed-width" select="true()"/>
      <xsl:with-param name="fixed-font-size-adjust" as="xs:integer?" select="if ($in-table) then -1 else $fixed-font-size-adjust" tunnel="true"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:link" mode="mode-inline">
    <basic-link external-destination="{@xlink:href}">
      <xsl:call-template name="handle-inline-text">
        <xsl:with-param name="color" select="$link-color"/>
        <xsl:with-param name="text" select="if (normalize-space(.) eq '') then @xlink:href else ()"/>
      </xsl:call-template>
    </basic-link>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:inlinemediaobject" mode="mode-inline">
    <xsl:call-template name="handle-imagedata">
      <xsl:with-param name="imagedata" select="db:imageobject/db:imagedata"/>
      <xsl:with-param name="block" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:citation" mode="mode-inline">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:command" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:email" mode="mode-inline">
    <basic-link external-destination="mailto:{normalize-space(.)}">
      <xsl:call-template name="handle-inline-text">
        <xsl:with-param name="italic" select="true()"/>
        <xsl:with-param name="color" select="$link-color"/>
      </xsl:call-template>
    </basic-link>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:filename" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:replaceable" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="italic" select="true()"/>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:userinput" mode="mode-inline">
    <xsl:call-template name="handle-inline-text">
      <xsl:with-param name="bold" select="true()"/>
      <xsl:with-param name="fixed-width" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:keycap" mode="mode-inline">
    <inline border="solid 0.1mm black">
      <xsl:apply-templates mode="#current"/>
    </inline>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:superscript" mode="mode-inline">
    <inline vertical-align="sup" baseline-shift="{local:dimpt($super-sub-font-size)}" font-size="{local:dimpt($super-sub-font-size)}">
      <xsl:apply-templates mode="#current"/>
    </inline>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:subscript" mode="mode-inline">
    <inline vertical-align="sub" font-size="{local:dimpt($super-sub-font-size)}">
      <xsl:apply-templates mode="#current"/>
    </inline>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()" mode="mode-inline">
    <!-- Mark anything like [TBD...] -->
    <xsl:analyze-string select="string(.)" regex="\[TBD.*\]">
      <xsl:matching-substring>
        <inline background-color="yellow">
          <xsl:copy/>
        </inline>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:copy/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-inline-text" as="element(fo:inline)">
    <xsl:param name="contents" as="node()*" required="no" select="node()"/>
    <xsl:param name="text" as="xs:string?" required="no" select="()"/>
    <!-- When $text is specified, $contents is ignored. -->
    <xsl:param name="bold" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="italic" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="underline" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="fixed-width" as="xs:boolean" required="no" select="false()"/>
    <xsl:param name="color" as="xs:string?" required="no" select="()"/>
    <xsl:param name="fixed-font-size-adjust" as="xs:integer?" required="no" select="()" tunnel="true"/>

    <xsl:variable name="inline-attributes" as="attribute()*">
      <xsl:if test="$bold">
        <xsl:attribute name="font-weight" select="'bold'"/>
      </xsl:if>
      <xsl:if test="$italic">
        <xsl:attribute name="font-style" select="'italic'"/>
      </xsl:if>
      <xsl:if test="$underline">
        <xsl:attribute name="text-decoration" select="'underline'"/>
      </xsl:if>
      <xsl:if test="exists($color)">
        <xsl:attribute name="color" select="$color"/>
      </xsl:if>
      <xsl:if test="$fixed-width">
        <xsl:attribute name="font-family" select="$code-font-family"/>
        <xsl:attribute name="font-size" select="local:dimpt($standard-font-size + ($fixed-font-size-adjust, 0)[1])"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="inline-contents" as="item()*">
      <xsl:choose>
        <xsl:when test="exists($text)">
          <xsl:value-of select="$text"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$contents" mode="mode-inline"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <inline>
      <xsl:sequence select="$inline-attributes"/>
      <xsl:sequence select="$inline-contents"/>
    </inline>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- TOC: -->

  <xsl:template name="create-toc">

    <xsl:call-template name="chapter-section-header-title-out">
      <xsl:with-param name="id" select="'TOC'"/>
      <xsl:with-param name="number" select="'0'"/>
      <xsl:with-param name="title" as="element(db:title)">
        <db:title>Table of Contents</db:title>
      </xsl:with-param>
      <xsl:with-param name="font-size" select="$standard-font-size + $chapter-font-size-addition"/>
      <xsl:with-param name="page-break" select="false()"/>
    </xsl:call-template>

    <xsl:apply-templates mode="mode-create-toc"/>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:chapter | db:preface" mode="mode-create-toc">

    <xsl:call-template name="toc-entry-out">
      <xsl:with-param name="level" select="0"/>
    </xsl:call-template>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="db:*[matches(local-name(.), 'sect[1-9]')]" mode="mode-create-toc">

    <xsl:variable name="element-name" as="xs:string" select="local-name(.)"/>
    <xsl:variable name="section-level" as="xs:integer" select="xs:integer(substring-after($element-name, 'sect'))"/>
    <xsl:call-template name="toc-entry-out">
      <xsl:with-param name="level" select="$section-level"/>
    </xsl:call-template>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*" mode="mode-create-toc" priority="-10">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" mode="mode-create-toc" priority="-20"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="toc-entry-out">
    <xsl:param name="id" as="xs:string" required="no" select="@xml:id"/>
    <xsl:param name="number" as="xs:string" required="no" select="@number"/>
    <xsl:param name="title" as="element(db:title)" required="no" select="db:title"/>
    <xsl:param name="level" as="xs:integer" required="yes"/>

    <xsl:variable name="top-level" as="xs:boolean" select="$level le 0"/>
    <xsl:variable name="left-indent" as="xs:double"
      select="if ($level le 1) then ($level * $standard-itemized-list-indent) else (($level + 1) * $standard-itemized-list-indent)"/>

    <block text-align-last="justify" margin-left="{local:dimcm($left-indent)}">
      <xsl:if test="$top-level">
        <xsl:attribute name="space-before" select="local:dimpt($standard-font-size div 2)"/>
      </xsl:if>

      <basic-link internal-destination="{$id}">
        <inline>
          <xsl:if test="$top-level">
            <xsl:attribute name="font-weight" select="'bold'"/>
          </xsl:if>
          <xsl:value-of select="$number"/>
          <xsl:text>&#160;&#160;</xsl:text>
          <xsl:value-of select="$title"/>
        </inline>

        <xsl:text> </xsl:text>
        <leader leader-pattern="dots"/>
        <page-number-citation ref-id="{$id}"/>
      </basic-link>

    </block>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- ERROR HANDLING: -->

  <xsl:template match="node()" mode="#all" priority="-1000">

    <xsl:choose>
      <xsl:when test="(. instance of text()) and (normalize-space(.) ne '')">
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Unhandled text node encountered: ', xtlc:q(.))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test=". instance of element()">
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="('Unhandled element encountered: ', .)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Ignore... -->
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="insert-error">
    <xsl:param name="msg-parts" as="item()+" required="yes"/>
    <xsl:param name="block" as="xs:boolean" required="no" select="true()"/>
    <xsl:param name="phase-description" as="xs:string?" required="false" select="()" tunnel="true"/>

    <xsl:variable name="phase-phrase" as="xs:string" select="if (empty($phase-description)) then '' else concat(' (phase: ', $phase-description, ')')"/>
    <xsl:variable name="base-message-fo" as="element(fo:inline)">
      <inline font-weight="bold" color="red">[*** {xtlc:items2str(($msg-parts, $phase-phrase))}]</inline>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$block">
        <block>
          <xsl:copy-of select="$base-message-fo"/>
        </block>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$base-message-fo"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="handle-imagedata">
    <xsl:param name="imagedata" as="element(db:imagedata)?" required="yes"/>
    <xsl:param name="block" as="xs:boolean" required="no" select="true()"/>

    <xsl:choose>
      <xsl:when test="exists($imagedata)">
        <xsl:variable name="uri" as="xs:string" select="local:get-full-uri($imagedata/@fileref, .)"/>
        <xsl:variable name="width" as="xs:string?" select="$imagedata/@width"/>
        <xsl:variable name="height" as="xs:string?" select="$imagedata/@height"/>
        <external-graphic src="url({$uri})" content-width="scale-to-fit" content-height="scale-to-fit" scaling="uniform"
          inline-progression-dimension.maximum="90%">
          <xsl:if test="exists($width)">
            <xsl:attribute name="content-width" select="$width"/>
          </xsl:if>
          <xsl:if test="exists($height)">
            <xsl:attribute name="content-height" select="$height"/>
          </xsl:if>
        </external-graphic>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insert-error">
          <xsl:with-param name="msg-parts" select="'Invalid image reference (no imagedata)'"/>
          <xsl:with-param name="block" select="$block"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="chapter-section-header-title-out">
    <!-- This is a simple layout here, but we might later move the number to the left of the left margin? -->
    <xsl:param name="id" as="xs:string" required="no" select="@xml:id"/>
    <xsl:param name="number" as="xs:string" required="no" select="@number"/>
    <xsl:param name="title" as="element(db:title)" required="no" select="db:title"/>
    <xsl:param name="font-size" as="xs:double" required="yes"/>
    <xsl:param name="page-break" as="xs:boolean" required="no" select="false()"/>

    <xsl:variable name="number-left-indent-cm" as="xs:double" select="1.75"/>

    <list-block start-indent="{local:dimcm($number-left-indent-cm * -1.0)}"
      provisional-distance-between-starts="{local:dimcm($number-left-indent-cm)}" id="{$id}" font-size="{local:dimpt($font-size)}" font-weight="bold"
      space-after="{local:dimpt($standard-font-size * 0.8)}" keep-with-next="always">
      <xsl:if test="$page-break">
        <xsl:attribute name="page-break-before" select="'always'"/>
      </xsl:if>
      <xsl:if test="not($page-break)">
        <xsl:attribute name="space-before" select="local:dimpt($font-size * 1.2)"/>
      </xsl:if>

      <list-item>
        <list-item-label end-indent="label-end()">
          <block>
            <xsl:value-of select="$number"/>
          </block>
        </list-item-label>
        <list-item-body start-indent="body-start()">
          <block>
            <xsl:value-of select="$title"/>
          </block>
        </list-item-body>
      </list-item>
    </list-block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="empty-line">
    <xsl:param name="size-pt" as="xs:double" required="no" select="$standard-font-size"/>
    <xsl:param name="keep-with-next" as="xs:boolean" required="no" select="false()"/>

    <block font-size="{local:dimpt($size-pt)}">
      <xsl:if test="$keep-with-next">
        <xsl:attribute name="keep-with-next" select="'always'"/>
      </xsl:if>
      <xsl:text>&#160;</xsl:text>
    </block>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:dim" as="xs:string">
    <xsl:param name="dimension" as="xs:double"/>
    <xsl:param name="unit" as="xs:string"/>
    <xsl:sequence select="concat(string($dimension), $unit)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:dimcm" as="xs:string">
    <xsl:param name="dimension" as="xs:double"/>
    <xsl:sequence select="local:dim($dimension, 'cm')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:dimpt" as="xs:string">
    <xsl:param name="dimension" as="xs:double"/>
    <xsl:sequence select="local:dim($dimension, 'pt')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="copy-id">
    <xsl:param name="elm" as="element()" required="no" select="."/>
    <xsl:if test="exists($elm/@xml:id)">
      <xsl:attribute name="id" select="$elm/@xml:id"/>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:element-is-in-table" as="xs:boolean">
    <xsl:param name="elm" as="element()"/>
    <xsl:sequence select="exists($elm/ancestor::db:table) or exists($elm/ancestor::db:informaltable)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-full-uri" as="xs:string">
    <xsl:param name="base" as="xs:string"/>
    <xsl:param name="from-elm" as="element()"/>
    <xsl:sequence select="local:get-full-uri-helper($base, $from-elm/ancestor-or-self::*/@xml:base/string())"/>
  </xsl:function>

  <xsl:function name="local:get-full-uri-helper" as="xs:string">
    <xsl:param name="base" as="xs:string"/>
    <xsl:param name="xml-base-values" as="xs:string*"/>
    <xsl:choose>
      <xsl:when test="empty($xml-base-values) or xtlc:dref-is-absolute($base)">
        <xsl:sequence select="$base"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="new-base" as="xs:string" select="xtlc:dref-canonical(xtlc:dref-concat((xtlc:dref-path($xml-base-values[last()]), $base)))"/>
        <xsl:sequence select="local:get-full-uri-helper($new-base, remove($xml-base-values, count($xml-base-values)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

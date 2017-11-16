<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Converts an element description in to Docbook 5
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>
  <xsl:include href="../../../../common/xslmod/dref.mod.xsl"/>
  
  <xsl:mode on-no-match="fail"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:param name="debug" as="xs:string" required="no" select="string(false())"/>
  <xsl:variable name="do-debug" as="xs:boolean" select="xtlc:str2bln($debug, false())"/>

  <!-- ================================================================== -->
  <!-- GLOBALS: -->

  <xsl:variable name="newline" as="xs:string" select="'&#x0a;'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlxdb:group>
      <xsl:apply-templates/>
    </xtlxdb:group>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/*">
    <xsl:context-item use="required" as="element(xtlxdb:insert-element-description)"/>

    <!-- Get the element description document: -->
    <xsl:variable name="full-href" as="xs:string" select="string(resolve-uri(@href, base-uri()))"/>
    <xsl:variable name="description-doc" as="document-node()" select="doc($full-href)"/>

    <!-- Output it on debug: -->
    <xsl:if test="$do-debug">
      <para><emphasis role="bold">DEBUG</emphasis>: Element description <code><xsl:value-of select="xtlc:q($full-href)"/></code>:</para>
      <programlisting><xsl:value-of select="serialize($description-doc)"/></programlisting>
      <para role="break"/>
    </xsl:if>

    <!-- Create output: -->
    <xsl:call-template name="create-description">
      <xsl:with-param name="element-description" select="$description-doc/*"/>
      <xsl:with-param name="id" select="($description-doc/*/@id, xtlc:dref-name-noext($full-href))[1]"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="create-description">
    <xsl:param name="element-description" as="element(xtlxdb:element-description)" required="yes"/>
    <xsl:param name="id" as="xs:string" required="yes"/>

    <xsl:for-each select="$element-description">
      <xsl:variable name="element-name" as="xs:string" select="@name"/>
      <xsl:variable name="attributes" as="element(xtlxdb:attribute)*" select="xtlxdb:attribute"/>
      <xsl:variable name="contents" as="element()*" select="xtlxdb:* except (xtlxdb:description, xtlxdb:attribute)"/>

      <!-- Create the formatted example: -->
      <programlisting xml:id="{$id}">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$element-name"/>
        <xsl:if test="empty($attributes)">
          <xsl:text>&gt;</xsl:text>
        </xsl:if>
        
        <!-- Attributes: -->
        <xsl:variable name="indent" as="xs:integer" select="string-length($element-name) + 2"/>
        <xsl:for-each select="$attributes">
          <xsl:if test="position() ne 1">
            <xsl:value-of select="local:spaces($indent)"/>
          </xsl:if>
          <xsl:if test="position() eq 1">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:call-template name="output-attribute"/>
          <xsl:if test="position() ne last()">
            <xsl:value-of select="$newline"/>
          </xsl:if>  
        </xsl:for-each>
        <xsl:value-of select="if (empty($contents)) then ' /&gt;' else concat(' &gt;', $newline)"/>
        
        
        <!-- Closing tag: -->
        <xsl:if test="exists($contents)">
           <xsl:value-of select="$newline"/>
           <xsl:text>&lt;/</xsl:text>
           <xsl:value-of select="$element-name"/>
           <xsl:text>&gt;</xsl:text>
        </xsl:if>
        
      </programlisting>

      <!-- Main description: -->
      <xsl:copy-of select="description/*"/>

    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-attribute">
    <xsl:param name="attribute" as="element(xtlxdb:attribute)" required="no" select="."/>

    <xsl:for-each select="$attribute">
      <xsl:variable name="required" as="xs:boolean" select="xtlc:str2bln(@required, false())"/>
      <xsl:value-of select="@name"/>
      <xsl:if test="not($required)">
        <xsl:text>?</xsl:text>
      </xsl:if>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="xtlxdb:type/@base"/>
      <!-- TBD -->
    </xsl:for-each>

  </xsl:template>


  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:spaces" as="xs:string">
    <xsl:param name="length" as="xs:integer"/>
    <xsl:sequence select="string-join(for $ s in (1 to $length) return ' ')"/>
  </xsl:function>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtpxplib="http://www.xatapult.nl/namespaces/common/xproc/library" xmlns:mso-wb="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:mso-rels="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlxo="http://www.xtpxlib.nl/ns/ms-office"  xmlns:local="#local-998hy5"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Prepares the xlsx modification part by finding all named cell references and compute the @index for them. 
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-do-worksheet" on-no-match="shallow-copy"/>

  <xsl:include href="../../../../common/xslmod/common.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="container" as="element(xtlcon:document-container)" select="/*"/>
  <xsl:variable name="extract-format" as="element(xtlxo:workbook)" select="$container/xtlcon:document[@type eq 'xlsx-in-extract-format']/*"/>

  <!-- ================================================================== -->

  <xsl:template match="xtlxo:xlsx-modifications/xtlxo:worksheet">
    <!-- Find the modification specification section for a particular worksheet. -->

    <!-- Check the name of the worksheet: -->
    <xsl:variable name="worksheet-name" as="xs:string" select="string(@name)"/>
    <xsl:variable name="worksheet-extract" as="element(xtlxo:worksheet)?" select="$extract-format/xtlxo:worksheet[@name eq $worksheet-name]"/>
    <xsl:if test="empty($worksheet-extract)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Specified worksheet to modify not found: ', xtlc:q($worksheet-name))"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Copy and modify this worksheet: -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*" mode="mode-do-worksheet">
        <xsl:with-param name="worksheet-extract" as="element(xtlxo:worksheet)" select="$worksheet-extract" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlxo:row[empty(@index)] | xtlxo:column[empty(@index)]" mode="mode-do-worksheet">
    <xsl:call-template name="handle-named-cell-reference"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="handle-named-cell-reference">
    <xsl:param name="row-or-column-element" as="element()" required="no" select="."/>
    <xsl:param name="worksheet-extract" as="element(xtlxo:worksheet)" required="yes" tunnel="true"/>

    <xsl:variable name="type-name" as="xs:string" select="local-name($row-or-column-element)"/>
    <xsl:variable name="is-row" as="xs:boolean" select="$type-name eq 'row'"/>
    <xsl:variable name="cell-name" as="xs:string?" select="$row-or-column-element/@name"/>
    <xsl:variable name="offset" as="xs:integer" select="xtlc:str2int($row-or-column-element/@offset, 0)"/>

    <!-- Pre-flight checks: -->
    <xsl:if test="empty($cell-name)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Invalid ', $type-name, ' reference for worksheet ', xtlc:q($worksheet-extract/@name), ': either @name or @index must be specified')"
        />
      </xsl:call-template>
    </xsl:if>

    <!-- Find the named cell: -->
    <xsl:variable name="named-cell" as="element(xtlxo:cell)?" select="($worksheet-extract/xtlxo:row/xtlxo:cell[@name eq $cell-name])[1]"/>
    <xsl:if test="empty($named-cell)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Named cell ', xtlc:q($cell-name), ' not found on worksheet ', xtlc:q($worksheet-extract/@name))"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Get the row or column index of the named cell and compute the final one: -->
    <xsl:variable name="cell-index" as="xs:integer" select="xs:integer(if ($is-row) then $named-cell/../@index else $named-cell/@index)"/>
    <xsl:variable name="final-index" as="xs:integer" select="$cell-index + $offset"/>
    <xsl:if test="$final-index lt 1">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts"
          select="('Offset ', $type-name, ' index less than 1 for cell ', xtlc:q($cell-name), ', offset ', $offset, ', worksheet ', 
            xtlc:q($worksheet-extract/@name))"
        />
      </xsl:call-template>
    </xsl:if>

    <!-- Copy the element and add the @index: -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="index" select="$final-index"/>
      <xsl:apply-templates select="*" mode="#current"/>
    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-named-cell" as="element(xtlxo:cell)">
    <xsl:param name="worksheet-extract" as="element(xtlxo:worksheet)"/>
    <xsl:param name="cell-name" as="xs:string"/>

    <xsl:variable name="named-cell" as="element(xtlxo:cell)?" select="($worksheet-extract/xtlxo:row/xtlxo:cell[@name eq $cell-name])[1]"/>
    <xsl:if test="empty($named-cell)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="('Named cell ', xtlc:q($cell-name), ' not found on worksheet ', xtlc:q($worksheet-extract/@name))"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:sequence select="$named-cell"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlcon:warning-prevention-dummy-template | xtlxo:warning-prevention-dummy-template"/>

</xsl:stylesheet>

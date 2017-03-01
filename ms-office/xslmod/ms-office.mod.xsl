<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:local="#local.ms-office.mod.xsl"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" xmlns:mso-rels="http://schemas.openxmlformats.org/package/2006/relationships"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
		Library with support code for the office file handling.
		
		Module dependencies:
		- ../../common/xslmod/common.mod.xsl
		- ../../common/xslmod/dref.mod.xsl
	-->
  
  <!-- ================================================================== -->
  <!-- COMMON DEFINITIONS: -->
  
  <!-- Relationships: -->
  <xsl:variable name="xtlmso:relationship-type-main-document" as="xs:string"
    select="'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument'"/>
  <xsl:variable name="xtlmso:relationship-type-shared-strings" as="xs:string"
    select="'http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings'"/>
  <xsl:variable name="xtlmso:relationship-type-comments" as="xs:string"
    select="'http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments'"/>
  
  <!-- Property relationships: -->
  <xsl:variable name="xtlmso:relationship-type-core-properties" as="xs:string"
    select="'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties'"/>
  <xsl:variable name="xtlmso:relationship-type-custom-properties" as="xs:string"
    select="'http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties'"/>
  <xsl:variable name="xtlmso:relationship-type-extended-properties" as="xs:string"
    select="'http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties'"/>
  
  <xsl:variable name="local:message-prefix" as="xs:string" select="'*xtlmso: '"/>
  
  <!-- ================================================================== -->
  <!-- NAVIGATING AROUND: -->
  
  <xsl:function name="xtlmso:get-file-root-from-relationship-type" as="element()?">
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    <xsl:param name="basefile-href" as="xs:string">
      <!-- The file in the office zip for which you want the relationship checked -->
    </xsl:param>
    <xsl:param name="relationship-type" as="xs:string">
      <!-- The URI of the relationship 
        (e.g. http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument) -->
    </xsl:param>
    <xsl:param name="is-mandatory" as="xs:boolean"/>
    
    <xsl:variable name="relationships" as="element(mso-rels:Relationships)*"
      select="xtlmso:get-file-root-relationship($extracted-office-xml, $basefile-href, $is-mandatory)"/>
    <xsl:variable name="relationship" as="element(mso-rels:Relationship)?" select="$relationships/mso-rels:Relationship[@Type eq $relationship-type]"/>
    <xsl:choose>
      <xsl:when test="empty($relationship) and not($is-mandatory)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="empty($relationship) and $is-mandatory">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Relationship type &quot;', $relationship-type, '&quot; not found for &quot;', $basefile-href, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="rels-dir" as="xs:string" select="xtlc:dref-path(xtlc:dref-path(xtlmso:get-rels-href($basefile-href)))"/>
        <xsl:variable name="target-ref" as="xs:string" select="xtlc:dref-canonical(xtlmso:doc-href(($rels-dir, $relationship/@Target)))"/>
        <!-- Always retrieve the file root as mandatory, because once here, it must be there! -->
        <xsl:sequence select="xtlmso:get-file-root($extracted-office-xml, $target-ref, true())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:get-file-root-from-relationship-id" as="element()?">
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    <xsl:param name="basefile-href" as="xs:string">
      <!-- The file in the office zip for which you want the relationship checked -->
    </xsl:param>
    <xsl:param name="relationship-id" as="xs:string"/>
    <xsl:param name="is-mandatory" as="xs:boolean"/>
    
    <xsl:variable name="relationships" as="element(mso-rels:Relationships)"
      select="xtlmso:get-file-root-relationship($extracted-office-xml, $basefile-href, $is-mandatory)"/>
    <xsl:variable name="relationship" as="element(mso-rels:Relationship)?" select="$relationships/mso-rels:Relationship[@Id eq $relationship-id]"/>
    <xsl:choose>
      <xsl:when test="empty($relationship) and not($is-mandatory)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="empty($relationship) and $is-mandatory">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Relationship id &quot;', $relationship-id, '&quot; not found for &quot;', $basefile-href, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="rels-dir" as="xs:string" select="xtlc:dref-path(xtlc:dref-path(xtlmso:get-rels-href($basefile-href)))"/>
        <xsl:variable name="target-ref" as="xs:string" select="xtlc:dref-canonical(xtlmso:doc-href(($rels-dir, $relationship/@Target)))"/>
        <!-- Always retrieve the file root as mandatory, because once here, it must be there! -->
        <xsl:sequence select="xtlmso:get-file-root($extracted-office-xml, $target-ref, true())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:get-file-root-relationship" as="element(mso-rels:Relationships)?">
    <!-- Returns the root element of the relationship document belonging to the given basefile. When
      $basefile-hrf is '', it returns the root of the root relationships document. -->
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    <xsl:param name="basefile-href" as="xs:string">
      <!-- The file in the office zip for which you want the relationship checked -->
    </xsl:param>
    <xsl:param name="is-mandatory" as="xs:boolean"/>
    
    <xsl:sequence select="xtlmso:get-file-root($extracted-office-xml, xtlmso:get-rels-href($basefile-href), $is-mandatory)"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:get-rels-href" as="xs:string">
    <xsl:param name="basefile-href" as="xs:string"/>
    
    <xsl:variable name="rels-subdir" as="xs:string" select="'_rels'"/>
    <xsl:variable name="rels-extension" as="xs:string" select="'.rels'"/>
    
    <xsl:choose>
      <xsl:when test="$basefile-href eq ''">
        <xsl:sequence select="xtlmso:doc-href(($rels-subdir, $rels-extension))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="basedir" as="xs:string" select="xtlc:dref-path($basefile-href)"/>
        <xsl:variable name="rels-filename" as="xs:string" select="concat(xtlc:dref-name($basefile-href), $rels-extension)"/>
        <xsl:sequence select="xtlmso:doc-href(($basedir, $rels-subdir, $rels-filename))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:get-file-root" as="element()?">
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    <xsl:param name="href-parts" as="xs:string+"/>
    <xsl:param name="is-mandatory" as="xs:boolean"/>
    
    <xsl:variable name="href" as="xs:string" select="xtlmso:doc-href($href-parts)"/>
    <xsl:variable name="doc-elm" as="element(xtlcon:document)?" select="($extracted-office-xml/xtlcon:document[@dref-source eq $href])[1]"/>
    <xsl:choose>
      <xsl:when test="empty($doc-elm) and $is-mandatory">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Document not found: &quot;', $href, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$doc-elm/*[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:doc-href" as="xs:string">
    <!-- Turns a sequence of href parts/fragments into a full href, suitable to find a file in 
      an extracted office XML document. -->
    <xsl:param name="href-parts" as="xs:string+"/>
    
    <!-- Maybe conanicalize name (clean up .. 's)? -->
    <xsl:variable name="doc-href" as="xs:string" select="xtlc:dref-concat($href-parts)"/>
    <xsl:sequence select="if (starts-with($doc-href, '/')) then substring($doc-href, 2) else $doc-href"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlmso:get-href" as="xs:string">
    <xsl:param name="elm" as="element()"/>
    
    <xsl:sequence select="($elm/ancestor::xtlcon:document[1])/@dref-source"/>
  </xsl:function>
  
  <!-- ================================================================== -->
  <!-- PROPERTY HANDLING: -->
  
  <xsl:template name="xtlmso:get-properties" xmlns="http://www.xtpxlib.nl/ns/ms-office">
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    
    <properties>
      
      <xsl:call-template name="local:handle-property-document">
        <xsl:with-param name="extracted-office-xml" select="$extracted-office-xml"/>
        <xsl:with-param name="relationship-type" select="$xtlmso:relationship-type-core-properties"/>
        <xsl:with-param name="type-name" select="'core'"/>
      </xsl:call-template>
      
      <xsl:call-template name="local:handle-property-document">
        <xsl:with-param name="extracted-office-xml" select="$extracted-office-xml"/>
        <xsl:with-param name="relationship-type" select="$xtlmso:relationship-type-custom-properties"/>
        <xsl:with-param name="type-name" select="'custom'"/>
      </xsl:call-template>
      
      <xsl:call-template name="local:handle-property-document">
        <xsl:with-param name="extracted-office-xml" select="$extracted-office-xml"/>
        <xsl:with-param name="relationship-type" select="$xtlmso:relationship-type-extended-properties"/>
        <xsl:with-param name="type-name" select="'extended'"/>
      </xsl:call-template>
      
    </properties>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="local:handle-property-document" xmlns="http://www.xtpxlib.nl/ns/ms-office">
    <xsl:param name="extracted-office-xml" as="element(xtlcon:document-container)"/>
    <xsl:param name="relationship-type" as="xs:string" required="yes"/>
    <xsl:param name="type-name" as="xs:string" required="yes"/>
    
    <xsl:variable name="root-elm" as="element()?"
      select="xtlmso:get-file-root-from-relationship-type($extracted-office-xml, '', $relationship-type, false())"/>
    <xsl:for-each select="$root-elm/*">
      <xsl:variable name="property-name-to-use" as="xs:string" select="if (exists(@name)) then @name else local-name(.)"/>
      <property name="{$property-name-to-use}" type="{$type-name}">
        <xsl:for-each select=".//text()[normalize-space(.) ne '']">
          <value>
            <xsl:value-of select="normalize-space(.)"/>
          </value>
        </xsl:for-each>
      </property>
    </xsl:for-each>
    
  </xsl:template>
  
</xsl:stylesheet>

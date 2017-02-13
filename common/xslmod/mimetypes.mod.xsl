<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.mimetypes.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtl-mimetypes="http://www.xtpxlib.nl/ns/mimetypes" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    MIME type conversion related functions.
    
    Module dependencies: None
	-->
  <!-- ================================================================== -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:variable name="local:mime-types-table" as="element(xtl-mimetypes:mimetypes)" select="doc('../data/mimetypes-table.xml')/*"/>

  <!-- ================================================================== -->

  <xsl:function name="xtlc:ext2mimetype" as="xs:string">
    <!--* 
      Turns a dref extension (e.g. 'xml') into the correct MIME type ('text/xml').
      When it cannot find the extension, it returns the empty string.
    
      This conversion works with an external MIME type/extension table in data/mime-types-table.xml
    -->
    <xsl:param name="ext" as="xs:string">
      <!--* The extension to convert. -->
    </xsl:param>

    <xsl:sequence select="string((($local:mime-types-table/xtl-mimetypes:mimetype[@extension eq $ext])[1])/@type)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:mimetype2ext" as="xs:string">
    <!--* 
      Turns a MIME type (e.g. 'text/xml') into a corresponding dref extension ('xml').
      When it cannot find the MIME type, it returns the empty string.
    
      This conversion works with an external MIME type/extension table in data/mime-types-table.xml
    -->
    <xsl:param name="mimetype" as="xs:string">
      <!--* The MIME type to convert. -->
    </xsl:param>

    <xsl:sequence select="string((($local:mime-types-table/xtl-mimetypes:mimetype[@type eq $mimetype])[1])/@extension)"/>
  </xsl:function>

</xsl:stylesheet>

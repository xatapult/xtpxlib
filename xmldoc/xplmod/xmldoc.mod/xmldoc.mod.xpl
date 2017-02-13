<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.hq4_xvn_vy"
  xmlns:xmldoc="http://www.xtpxlib.nl/ns/xmldoc" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <!-- ================================================================== -->

  <p:declare-step type="xmldoc:xmldoc">

    <p:documentation>
      Takes an XML document and tries to create some sensible documentation from these. The resuts are delivered as stand-alone HTML.
      Rules and guideliness for the documentation are in the accompanying xmldoc/readme.md file.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation> 
        The XML file to create the documentation for.
      </p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation> 
        The resulting stand-alone HTML file with documentation.
      </p:documentation>
    </p:output>

    <p:variable name="debug" select="false()"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/document-to-docgen.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/docgen-to-html.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
  </p:declare-step>

  <!-- ================================================================== -->

</p:library>

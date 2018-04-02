<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:declare-step type="xtlxdb:db5-pdf">

    <p:documentation>
      This turns Docbook 5 into a PDF.
      All necessary pre-processing (resolving xincludes, expanding variables, examples, etc.) must have been done before this.
      To make sure we can find the images and other stuff, add appropriate xml:base attributes.
      
      This is the code you would usually want to include before running this step:
      <p:xinclude>
        <p:with-option name="fixup-xml-base" select="true()"/> 
      </p:xinclude>
      <p:add-attribute attribute-name="xml:base" match="/*">
        <p:with-option name="attribute-value" select="$dref-source"/>
      </p:add-attribute>
      
    </p:documentation>

    <!-- ================================================================== -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>The db5 source document, fully expanded (with appropriate xml:base attributes)</p:documentation>
    </p:input>

    <p:option name="dref-pdf" required="true">
      <p:documentation>The name of the resulting PDF file</p:documentation>
    </p:option>

    <p:option name="debug" required="false" select="false()">
      <p:documentation>Add debug output</p:documentation>
    </p:option>

    <p:option name="chapter-id" required="false" select="''">
      <p:documentation>Specific chapter identifier to output (for debugging purposes)</p:documentation>
    </p:option>

    <p:option name="fop-config" required="false" select="resolve-uri('data/fop-config.xml', static-base-uri())">
      <p:documentation>Reference to the FOP configuration file</p:documentation>
    </p:option>

    <p:option name="main-font-size" required="false" select="10">
      <p:documentation>Main font size as an integer. Usual values somewhere between 8 and 10.</p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>Some XML report about the conversion</p:documentation>
      <p:pipe port="result" step="final-output"/>
    </p:output>

    <!-- ================================================================== -->

    <!-- Add identifiers and numbering: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/add-identifiers.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/add-numbering.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <!-- Create the XSL-FO: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/db5-to-xsl-fo.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
      <p:with-param name="chapter-id" select="$chapter-id"/>
      <p:with-param name="main-font-size" select="$main-font-size"/>
    </p:xslt>

    <p:identity name="final-output"/>

    <p:xsl-formatter name="step-create-pdf" content-type="application/pdf">
      <p:with-option name="href" select="$dref-pdf"/>
      <p:with-param name="UserConfig" select="$fop-config"/>
    </p:xsl-formatter>

  </p:declare-step>

</p:library>

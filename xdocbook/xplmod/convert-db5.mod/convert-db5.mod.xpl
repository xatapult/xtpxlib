<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:declare-step type="xtlxdb:convert-db5">

    <p:documentation>
      This checks for elements xtlxdb:convert that trigger a conversion from some XML into docbook.
      It then performs the conversion and turns everything in the resulting XML that is in no-namespace into the docbook namespace.
      Example:
      
      <xtlxdb:convert xsl="some/path/to/an/xsl">
        <somexml>
          <somemore/>
        </somexml> 
      </xtlxdb:convert>
      
      Watch out: The XSLT gets the *full* xtlxdb:convert element as its input. This allows for adding additional attributes to this element as
      stylesheet parameters.
      
    </p:documentation>

    <!-- ================================================================== -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>The db5 source document</p:documentation>
    </p:input>

    <p:option name="debug" required="false" select="false()">
      <p:documentation>Add debug output</p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The resulting docbook 5 output</p:documentation>
    </p:output>

    <!-- ================================================================== -->

    <!-- Resolve URIs (in a standardized way): -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/resolve-xsl-uris.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <!-- Convert: -->
    <p:viewport match="xtlxdb:convert">
      <p:variable name="xsl" select="/*/@xsl"/>

      <!-- Run the xslt:  -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:pipe port="result" step="loaded-xsl"/>
        </p:input>
        <p:with-param name="debug" select="$debug"/>
      </p:xslt>
      <p:identity name="conversion-result"/>
      <p:sink/>

      <!-- Get the XSL on board: -->
      <p:load dtd-validate="false">
        <p:with-option name="href" select="$xsl"/>
      </p:load>
      <p:identity name="loaded-xsl"/>
      <p:sink/>

      <!-- Output the conversion result: -->
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="conversion-result"/>
        </p:input>
      </p:identity>
    </p:viewport>

    <!-- Adjust the namespace: -->
    <p:namespace-rename apply-to="elements" from="" to="http://docbook.org/ns/docbook"/>

  </p:declare-step>

</p:library>

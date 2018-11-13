<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook" version="1.0"
  xpath-version="2.0" exclude-inline-prefixes="#all">

  <!-- ================================================================== -->

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
      
      Use a <xtlxdb:GROUP>...</xtlxdb:GROUP> construction if you want to output multiple elements. 
      Any such GROUP element is unwrapped.
      
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
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

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Resolve URIs (in a standardized way): -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/resolve-xsl-uris.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <!-- Convert: -->
    <p:viewport match="xtlxdb:convert" name="convert-xsl-viewport">
      <p:variable name="xsl" select="/*/@xsl"/>

      <!-- Get the XSL on board: -->
      <p:load dtd-validate="false">
        <p:with-option name="href" select="$xsl"/>
      </p:load>
      <p:identity name="loaded-xsl"/>

      <!-- Run the xslt:  -->
      <p:xslt>
        <p:input port="source">
          <p:pipe port="current" step="convert-xsl-viewport"/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="result" step="loaded-xsl"/>
        </p:input>
        <p:with-param name="debug" select="$debug"/>
      </p:xslt>

      <!-- Adjust the namespace: -->
      <p:namespace-rename apply-to="elements" from="" to="http://docbook.org/ns/docbook"/>

    </p:viewport>
    <p:unwrap match="xtlxdb:GROUP"/>
    
  </p:declare-step>

  <!-- ================================================================== -->

  <p:declare-step type="xtlxdb:convert-xproc-db5">

    <p:documentation>
      This checks for elements xtlxdb:convert-xproc that trigger a conversion from some XML into docbook using an XProc
      pipeline. The *full* xtlxdb:convert-xproc element (with all its optional children) is passed to the pipeline on 
      the source port.
      It then performs the conversion and turns everything in the resulting XML that is in no-namespace 
      into the docbook namespace.
      Example:
      
      <xtlxdb:convert-xproc-db5 pipeline="some/path/to/an/xproc-pipeline">
        <somexml>
          <somemore/>
        </somexml> 
      </xtlxdb:convert-xproc-db5>
      
      Use a <xtlxdb:GROUP>...</xtlxdb:GROUP> construction if you want to output multiple elements. 
      Any such GROUP element is unwrapped.
      
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
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

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Resolve URIs (in a standardized way): -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/resolve-xproc-uris.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>

    <!-- Convert: -->
    <p:viewport match="xtlxdb:convert-xproc" name="convert-xproc-viewport">
      <p:variable name="pipeline" select="/*/@pipeline"/>

      <!-- Get the pipeline on board: -->
      <p:load dtd-validate="false">
        <p:with-option name="href" select="$pipeline"/>
      </p:load>
      <p:identity name="loaded-pipeline"/>

      <!-- Run the pipeline:  -->
      <cx:eval>
        <p:input port="source">
          <p:pipe port="current" step="convert-xproc-viewport"/>
        </p:input>
        <p:input port="pipeline">
          <p:pipe port="result" step="loaded-pipeline"/>
        </p:input>
        <p:input port="options">
          <p:inline exclude-inline-prefixes="#all">
            <!-- No options (yet): -->
            <cx:options xmlns:cx="http://xmlcalabash.com/ns/extensions"/>
          </p:inline>
        </p:input>
      </cx:eval>

      <!-- Adjust the namespace: -->
      <p:namespace-rename apply-to="elements" from="" to="http://docbook.org/ns/docbook"/>
      
    </p:viewport>
    <p:unwrap match="xtlxdb:GROUP"/>
    
  </p:declare-step>
  
</p:library>

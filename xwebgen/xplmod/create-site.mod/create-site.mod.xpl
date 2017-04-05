<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:declare-step type="xtlwg:create-site">

    <p:documentation>
      Creates a site using the xwebgen method.
    </p:documentation>

    <p:option name="dref-specification" required="true">
      <p:documentation>Document reference to the xwebgen specification file for this website. 
        This document must be valid against ../../xsd/specification.xsd</p:documentation>
    </p:option>

    <p:option name="filterstring" required="false" select="''">
      <p:documentation>Processing filters. Format: "name|value|name|value|..."</p:documentation>
    </p:option>

    <p:option name="debug" required="false" select="false()"/>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The raw xtpxlib container structure the website was created with</p:documentation>
    </p:output>

    <p:import href="../../../common/xplmod/common.mod/common.mod.xpl"/>
    <p:import href="../../../container/xplmod/container.mod/container.mod.xpl"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Load the specification document, pre-process this and create a basic xtpxlib container from it: -->
    <p:load dtd-validate="false">
      <p:with-option name="href" select="$dref-specification"/>
    </p:load>
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/create-basic-container.xsl"/>
      </p:input>
      <p:with-param name="dref-specification" select="$dref-specification"/>
      <p:with-param name="filterstring" select="$filterstring"/>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <!-- Create the pages: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/create-pages.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>

    <!-- Check for any transformations to be done: -->
    <p:viewport match="xtlwg:TRANSFORM">
      <p:variable name="dref-transformer" select="/*/@dref-transformer"/>
      <p:xslt>
        <p:input port="stylesheet">
          <p:pipe port="result" step="transformation-stylesheet"/>
        </p:input>
        <p:input port="source" select="/*/*[1]"/>
        <p:with-param name="debug" select="$debug"/>
      </p:xslt>
      <p:identity name="transformed-contents"/>
      <p:sink/>

      <!-- Sub-pipeline to get the transformer on board: -->
      <p:load dtd-validate="false">
        <p:with-option name="href" select="$dref-transformer"/>
      </p:load>
      <p:identity name="transformation-stylesheet"/>
      <p:sink/>

      <!-- Get the transformed contents as output of the viewport: -->
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="transformed-contents"/>
        </p:input>
      </p:identity>
    </p:viewport>
    
    <!-- Write the container to disk: -->
    <xtlcon:container-to-disk>
      <p:with-option name="dref-target" select="/*/@base-output-dir"/>
      <p:with-option name="remove-target" select="true()"/>
    </xtlcon:container-to-disk>

    <!-- Copy directories: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/prepare-copy-dir.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    <p:viewport match="xtlwg:xwebgen-specification/xtlwg:copy-dir"> 
      <xtlc:copy-directory>
        <p:with-option name="dref-source-dir" select="/*/@dref-source-dir"/>
        <p:with-option name="dref-target-dir" select="/*/@dref-target-dir"/> 
      </xtlc:copy-directory>
      <p:add-attribute attribute-name="result" match="/*">
        <p:with-option name="attribute-value" select="'ok'"/>
      </p:add-attribute>
    </p:viewport>

    <!-- Create some output report: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/create-final-report.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
  </p:declare-step>

</p:library>

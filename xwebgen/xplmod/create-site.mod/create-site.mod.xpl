<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:declare-step type="xtlwg:create-site">

    <p:option name="dref-specification" required="true">
      <p:documentation>Document reference to the xwebgen specification file for this website. 
        This document must be valid against ../../xsd/specification.xsd</p:documentation>
    </p:option>

    <p:option name="filterstring" required="false" select="''">
      <p:documentation>Processing filters. Format: "name|value|name|value|..."</p:documentation>
    </p:option>

    <p:option name="debug" required="false" select="false()"/>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>TBD</p:documentation>
    </p:output>

    <p:documentation>
      Creates a site using the xwebgen method.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Load the specification document, fitre this and create a basic xtpxlib container from it: -->
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
    
    

  </p:declare-step>

</p:library>

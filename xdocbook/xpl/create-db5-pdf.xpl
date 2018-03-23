<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Driver to create a pdf from a DocBook 5 source
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:input port="source" primary="true" sequence="false">
    <p:documentation>The DocBook5 to convert</p:documentation>
  </p:input>

  <p:option name="dref-pdf" required="true">
    <p:documentation>Document reference of the resulting PDF</p:documentation>
  </p:option> 
  
  <p:option name="debug" required="false" select="false()"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../xplmod/db5-pdf.mod/db5-pdf.mod.xpl"/>

  <!-- ================================================================== -->

  <!-- Convert the input into something suitable and add xml:base attribute at the root: -->
  <p:xinclude>
    <p:with-option name="fixup-xml-base" select="true()"/> 
  </p:xinclude>
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="base-uri(/*)"/>
  </p:add-attribute>
  
  <!-- Go, create: -->
  <xtlxdb:db5-pdf>
    <p:with-option name="dref-pdf" select="$dref-pdf"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="main-font-size" select="9"/> 
  </xtlxdb:db5-pdf>
  <p:sink/>
  
  <!-- Create a very simple report: -->
  <p:identity>
    <p:input port="source">
      <p:inline>
        <create-db5-pdf/>
      </p:inline>
    </p:input>
  </p:identity>
  <p:add-attribute attribute-name="timestamp" match="/*">
    <p:with-option name="attribute-value" select="current-dateTime()"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="result" match="/*">
    <p:with-option name="attribute-value" select="$dref-pdf"/>
  </p:add-attribute>
  
</p:declare-step>

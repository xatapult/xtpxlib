<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Driver to create the db5 dialect description pdf
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="dref-source" required="false" select="resolve-uri('db5-dialect-description.xml', static-base-uri())"/>
  <p:option name="dref-pdf" required="false" select="resolve-uri('db5-dialect-description.pdf', static-base-uri())"/>
  
  <p:option name="debug" required="false" select="true()"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../xplmod/db5-pdf.mod/db5-pdf.mod.xpl"/>

  <!-- ================================================================== -->

  <!-- Convert the input into something suitable and add xml:base attribute at the root: -->
  <p:load dtd-validate="false">
    <p:with-option name="href" select="$dref-source"/> 
  </p:load>
  <p:xinclude>
    <p:with-option name="fixup-xml-base" select="true()"/> 
  </p:xinclude>
  <p:add-attribute attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="$dref-source"/>
  </p:add-attribute>
  
  <!-- Go, test: -->
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
        <create-db5-dialect-description/>
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

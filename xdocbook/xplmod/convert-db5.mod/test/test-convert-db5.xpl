<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for descriptions-db5.mod
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="dref-source" required="false"
    select="resolve-uri('../../../test/convert/test-convert-db5-source.xml', static-base-uri())"/>
  <p:option name="debug" required="false" select="true()"/>
  <p:option name="chapter-id" required="false" select="'test-chapter-convert-db5.mod'"/>
  <p:option name="dref-pdf" required="true"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../convert-db5.mod.xpl"/>
  <p:import href="../../db5-pdf.mod/db5-pdf.mod.xpl"/>

  <!-- ================================================================== -->

  <!-- Convert the input into something suitable for docbook2pdf and add xml:base attribute at the root: -->
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
  <xtlxdb:convert-db5>
    <p:with-option name="debug" select="$debug"/>
  </xtlxdb:convert-db5>
  <p:identity name="description-conversion-out"/>

  <!-- Make PDF: -->
  <xtlxdb:db5-pdf>
    <p:with-option name="dref-pdf" select="$dref-pdf"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="chapter-id" select="$chapter-id"/>
  </xtlxdb:db5-pdf>
  <p:sink/>

  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="description-conversion-out"/>
    </p:input>
  </p:identity>

</p:declare-step>

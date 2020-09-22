<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the xtlxo:modify-xlsx step
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="specification-href" required="false" select="resolve-uri('test-modify-xlsx-input-2.xml', static-base-uri())"/>
  <p:option name="xlsx-href-in" required="false" select="resolve-uri('test-modify-2.xlsx', static-base-uri())"/>
  <p:option name="xlsx-href-out" required="false" select="resolve-uri('tmp/modify-xlsx-result.xlsx', static-base-uri())"/>

  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true"/>

  <p:import href="../excel.mod.xpl"/>

  <!-- ================================================================== -->

  <p:load dtd-validate="false">
    <p:with-option name="href" select="$specification-href"/>
  </p:load>

  <xtlmso:modify-xlsx>
    <p:with-option name="xlsx-dref-in" select="$xlsx-href-in"/>
    <p:with-option name="xlsx-dref-out" select="$xlsx-href-out"/>
  </xtlmso:modify-xlsx>

</p:declare-step>

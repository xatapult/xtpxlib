<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.c1j_xs3_bz"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the extract-xlsx step
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="xlsx-dref" required="false" select="resolve-uri('test.xlsx', static-base-uri())"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../excel.mod.xpl"/>

  <!-- ================================================================== -->

  <xtlmso:extract-xlsx>
    <p:with-option name="xlsx-dref" select="$xlsx-dref"/>
  </xtlmso:extract-xlsx>

</p:declare-step>

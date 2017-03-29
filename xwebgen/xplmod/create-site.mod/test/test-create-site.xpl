<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.wvj_t5q_3z"
  xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the xtlwg:create-site step
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="dref-specification" required="false" select="resolve-uri('../../../test/test-specification.xml', static-base-uri())"/>
  <p:option name="filterstring" required="false" select="'lang|nl|system|DEV'"/>

  <p:option name="debug" required="false" select="false()"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../create-site.mod.xpl"/>

  <!-- ================================================================== -->

  <xtlwg:create-site>
    <p:with-option name="dref-specification" select="$dref-specification"/>
    <p:with-option name="filterstring" select="$filterstring"/>
    <p:with-option name="debug" select="$debug"/>
  </xtlwg:create-site>

</p:declare-step>

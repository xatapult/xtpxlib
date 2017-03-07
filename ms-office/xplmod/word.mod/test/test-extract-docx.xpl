<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.c1j_xs3_bz"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the extract-docx step
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="docx-dref" required="false" select="resolve-uri('test.docx', static-base-uri())"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../word.mod.xpl"/>

  <!-- ================================================================== -->

  <xtlmso:extract-docx>
    <p:with-option name="docx-dref" select="$docx-dref"/>
  </xtlmso:extract-docx>

</p:declare-step>

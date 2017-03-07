<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.c1j_xs3_bz"
  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Test driver for the create-docx step
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="template-docx-dref" required="false" select="resolve-uri('test-xtp-template.docx', static-base-uri())"/>
  <p:option name="word-xml-dref" required="false" select="resolve-uri('test-extract-docx-result.xml', static-base-uri())"/>
  <p:option name="tempdir" required="true"/>

  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../word.mod.xpl"/>

  <!-- ================================================================== -->

  <p:load dtd-validate="false">
    <p:with-option name="href" select="$word-xml-dref"/> 
  </p:load>

  <xtlmso:create-docx>
    <p:with-option name="template-docx-dref" select="$template-docx-dref"/>
    <p:with-option name="result-docx-dref" select="concat($tempdir, '/', 'test-create-docx-result.docx')"/> 
  </xtlmso:create-docx>

</p:declare-step>

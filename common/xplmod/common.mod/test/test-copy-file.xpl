<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
   Test driver for the library tee step.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="../common.mod.xpl"/>

  <!-- ================================================================== -->

  <p:identity>
    <p:input port="source">
      <p:inline>
        <COPYTEST/>
      </p:inline>
    </p:input>
  </p:identity>

  <!-- Straight copy of XML file: -->
  <xtlc:copy-file>
    <p:with-option name="dref-source" select="static-base-uri()"/>
    <p:with-option name="dref-target" select="resolve-uri('../../../../../xtpxlib2-tmp/test-copy-file-result 1.xml', static-base-uri())"/>
  </xtlc:copy-file>

  <!-- Copy of text file with spaces in name: -->
  <xtlc:copy-file>
    <p:with-option name="dref-source" select="resolve-uri('test document for copy.txt', static-base-uri())"/>
    <p:with-option name="dref-target" select="resolve-uri('../../../../../xtpxlib2-tmp/test-copy-file-result 2.txt', static-base-uri())"/>
  </xtlc:copy-file>
  
  <!-- Copy of text file with spaces in name: -->
  <xtlc:copy-file>
    <p:with-option name="dref-source" select="'common/data/test-xml.xml'"/>
    <p:with-option name="dref-source-zip" select="resolve-uri('test zip for copy.zip', static-base-uri())"/>
    <p:with-option name="dref-target" select="resolve-uri('../../../../../xtpxlib2-tmp/test-copy-file-result 3.xml', static-base-uri())"/>
  </xtlc:copy-file>
  
</p:declare-step>

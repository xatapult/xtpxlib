<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the library zip directory step. Zips the xtpxlib tree.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:option name="debug" required="false" select="string(false())"/>
  
  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true"/>
  
  <p:import href="../common.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <xtlc:zip-directory>
    <p:with-option name="base-path" select="resolve-uri('../../..', static-base-uri())"/>
    <p:with-option name="dref-target-zip" select="resolve-uri('../../../../../xtpxlib2-tmp/test-zip-directory-result.zip', static-base-uri())"/>
    <p:with-option name="include-base" select="'true'"/>
  </xtlc:zip-directory>
  
</p:declare-step>

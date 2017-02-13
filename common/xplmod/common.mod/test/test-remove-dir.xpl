<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the library zip directory step.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:option name="debug" required="false" select="string(false())"/>
  
  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true"/>
  
  <p:import href="../common.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <p:identity>
    <p:input port="source">
      <p:inline>
        <dummy/>
      </p:inline>
    </p:input>
  </p:identity>
  
  <xtlc:remove-dir>
    <p:with-option name="dref-dir" select="resolve-uri('../../../../../xtpxlib2-tmp/test-dir', static-base-uri())"/>
  </xtlc:remove-dir>
  
</p:declare-step>

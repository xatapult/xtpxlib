<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the log step.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>
  
  <p:import href="../common.mod.xpl"/>
  
  <p:variable name="href-log" select="resolve-uri('../../../../../xtpxlib2-tmp/test-log.xml', static-base-uri())"/>
  
  <!-- ================================================================== -->
  
  <p:identity>
    <p:input port="source">
      <p:inline>
        <LOGTEST/>
      </p:inline>
    </p:input>
  </p:identity>
  
  <xtlc:log>
    <p:with-option name="href-log" select="$href-log"/>
    <p:with-option name="message" select="'Testing 1 2 3'"/>
    <p:with-option name="status" select="'warning'"/>
  </xtlc:log>
  
  <xtlc:log>
    <p:with-option name="href-log" select="$href-log"/>
    <p:with-option name="message" select="'Testing 4 5 6'"/>
    <p:with-option name="status" select="'error'"/>
  </xtlc:log>
  
</p:declare-step>

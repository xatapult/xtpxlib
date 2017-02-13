<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container">
  
  <p:documentation>
   Test driver for the zip-to-container step.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>
  
  <p:import href="../container.mod.xpl"/>

  <p:variable name="dref-source-zip" select="resolve-uri('test.xlsx', static-base-uri())"/>
  
  <!-- ================================================================== -->
  
  <xtlcon:zip-to-container>
    <p:with-option name="dref-source-zip" select="$dref-source-zip"/>
    <p:with-option name="dref-target-path" select="'zip-to-container-target'"/>
  </xtlcon:zip-to-container>
  
</p:declare-step>

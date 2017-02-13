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
  
  <p:option name="dref-source-directory" required="true"/>    
  
  <p:import href="../container.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <xtlcon:directory-to-container>
    <p:with-option name="dref-source-directory" select="$dref-source-directory"/>
  </xtlcon:directory-to-container>
  
</p:declare-step>

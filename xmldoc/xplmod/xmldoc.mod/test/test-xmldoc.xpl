<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xmldoc="http://www.xtpxlib.nl/ns/xmldoc"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the xmldoc step.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:input port="source" primary="true" sequence="false"/>
  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>
  
  <p:import href="../xmldoc.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <xmldoc:xmldoc/>
  
</p:declare-step>

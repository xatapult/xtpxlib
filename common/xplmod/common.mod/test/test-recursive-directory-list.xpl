<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
   Test driver for the library recursive directory list step. Creates a recursive directory list from the xtpxlib library's common tree
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <p:option name="debug" required="false" select="string(false())"/>
  
  <p:output port="result"/>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true"/>
  
  <p:import href="../common.mod.xpl"/>
  
  <!-- ================================================================== -->
  
  <xtlc:recursive-directory-list>
    <p:with-option name="path" select="resolve-uri('../../../..', static-base-uri())"/>
    <p:with-option name="exclude-filter" select="'^\.git'"/> 
    <p:with-option name="flatten" select="true()"/> 
  </xtlc:recursive-directory-list>
  
</p:declare-step>

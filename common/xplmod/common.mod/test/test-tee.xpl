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
        <TEETEST a="b">
          <SOMEJUNK/>
          <SOMEMOREJUNK/>
        </TEETEST>
      </p:inline>
    </p:input>
  </p:identity>
  
  <xtlc:tee>
    <p:with-option name="href" select="resolve-uri('../../../../../xtpxlib2-tmp/test-tee-result.xml', static-base-uri())"/> 
    <p:with-option name="enable" select="true()"/>
    <p:with-option name="root-attribute-href" select="'teefile'"/> 
  </xtlc:tee>
  
</p:declare-step>

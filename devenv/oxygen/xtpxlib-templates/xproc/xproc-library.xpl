<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.${id}" version="1.0" xpath-version="2.0"
  exclude-inline-prefixes="#all">

  <!-- ================================================================== -->

  <p:declare-step type="local:step">
    
    <p:documentation>
      ${caret}
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:input>

    <p:option name="debug" required="false" select="false()"/>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation> </p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:identity/>

  </p:declare-step>

  <!-- ================================================================== -->

</p:library>

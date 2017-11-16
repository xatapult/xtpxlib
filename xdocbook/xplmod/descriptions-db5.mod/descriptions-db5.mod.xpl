<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlxdb="http://www.xtpxlib.nl/ns/xdocbook"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:declare-step type="xtlxdb:descriptions-db5">

    <p:documentation>
      This checks for special elements that point to xdocbook description files (for elements etc.) and turns them into docbook 5.
    </p:documentation>

    <!-- ================================================================== -->
    <!-- SETUP: -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>The db5 source document</p:documentation>
    </p:input>

    <p:option name="debug" required="false" select="false()">
      <p:documentation>Add debug output</p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The resulting docbook 5 output</p:documentation>
    </p:output>

    <!-- ================================================================== -->

    <p:viewport match="xtlxdb:insert-element-description">
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xsl/do-element-description.xsl"/>
        </p:input>
        <p:with-param name="debug" select="$debug"/>
      </p:xslt>
    </p:viewport>
    
    <!-- Now unwrap the groups created (we needed to group the XSLT output elements, otherwise it wouldn't be valid XML): -->
    <p:unwrap match="xtlxdb:group"/>

  </p:declare-step>

</p:library>

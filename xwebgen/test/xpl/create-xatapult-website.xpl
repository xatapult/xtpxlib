<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:local="#local.jsx_yjb_kz" version="1.0"
  xpath-version="2.0" exclude-inline-prefixes="#all" xmlns:xtlwg="http://www.xtpxlib.nl/ns/xwebgen">

  <p:documentation>
    TBD
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:option name="dref-specification" required="false" select="resolve-uri('../source/website-xatapult-specification.xml', static-base-uri())">
    <p:documentation>Reference to the xwebgen specification file</p:documentation>
  </p:option>

  <p:option name="debug" required="false" select="false()"/>

  <p:output port="result" primary="true" sequence="false">
    <p:documentation>TBD</p:documentation>
  </p:output>
  <p:serialization port="result" method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false"/>

  <p:import href="urn:x-xtpxlib.nl://xwebgen/xplmod/create-site.mod/create-site.mod.xpl"/>

  <!-- ================================================================== -->

  <xtlwg:create-site>
    <p:with-option name="dref-specification" select="$dref-specification"/>
    <p:with-option name="filterstring" select="'lang|nl|system|TST'"/>
  </xtlwg:create-site>
  <p:identity name="nl-TST"/>
  <p:sink/>

  <xtlwg:create-site>
    <p:with-option name="dref-specification" select="$dref-specification"/>
    <p:with-option name="filterstring" select="'lang|en|system|TST'"/>
  </xtlwg:create-site>
  <p:identity name="en-TST"/>
  <p:sink/>

  <xtlwg:create-site>
    <p:with-option name="dref-specification" select="$dref-specification"/>
    <p:with-option name="filterstring" select="'lang|nl|system|PRD'"/>
  </xtlwg:create-site>
  <p:identity name="nl-PRD"/>
  <p:sink/>

  <xtlwg:create-site>
    <p:with-option name="dref-specification" select="$dref-specification"/>
    <p:with-option name="filterstring" select="'lang|en|system|PRD'"/>
  </xtlwg:create-site>
  <p:identity name="en-PRD"/>
  <p:sink/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Generate some report thingy: -->

  <p:identity>
    <p:input port="source">
      <p:inline>
        <xatapult-website-generation-results/>
      </p:inline>
    </p:input>
  </p:identity>
  <p:add-attribute attribute-name="timestamp" match="/*">
    <p:with-option name="attribute-value" select="current-dateTime()"/>
  </p:add-attribute>
  <p:add-attribute attribute-name="dref-specification" match="/*">
    <p:with-option name="attribute-value" select="$dref-specification"/>
  </p:add-attribute>
  <p:insert match="/*" position="last-child">
    <p:input port="insertion">
      <p:pipe port="result" step="nl-TST"/>
    </p:input>
  </p:insert>
  <p:insert match="/*" position="last-child">
    <p:input port="insertion">
      <p:pipe port="result" step="en-TST"/>
    </p:input>
  </p:insert>
  <p:insert match="/*" position="last-child">
    <p:input port="insertion">
      <p:pipe port="result" step="nl-PRD"/>
    </p:input>
  </p:insert>
  <p:insert match="/*" position="last-child">
    <p:input port="insertion">
      <p:pipe port="result" step="en-PRD"/>
    </p:input>
  </p:insert>

</p:declare-step>

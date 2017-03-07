<?xml version="1.0" encoding="UTF-8"?>
<?xtpxlib-public?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:local="#local.excel-to-xml.mod.xpl" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  <!-- ================================================================== -->
  <!--* 
    Various conversions for Excel (.xlsx) files	
  -->
  <!-- ================================================================== -->

  <p:declare-step type="xtlmso:extract-xlsx">

    <p:documentation>
      Extracts the contents of an Excel file in a more useable XML format.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->

    <p:option name="xlsx-dref" required="true">
      <p:documentation>Document reference of the xlsx file to process (must have file:// in front).</p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The resulting XML representation of the Excel file.
      </p:documentation>
    </p:output>

    <p:import href="../../../container/xplmod/container.mod/container.mod.xpl"/>

    <p:variable name="debug" select="false()"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Extract all XML content: -->
    <xtlcon:zip-to-container>
      <p:with-option name="dref-source-zip" select="$xlsx-dref"/>
      <p:with-option name="add-document-target-paths" select="false()"/>
    </xtlcon:zip-to-container>

    <!-- Transform the contents into something manageable: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/extract-xlsx-1.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
    <!-- Remove any empty rows and cells: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/extract-xlsx-2.xsl"/>
      </p:input>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
  </p:declare-step>

</p:library>

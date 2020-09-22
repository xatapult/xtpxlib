<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"  xmlns:xtlmso="http://www.xtpxlib.nl/ns/ms-office"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:local="#local.excel-to-xml.mod.xpl" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
    Conversions for Excel (`.xlsx`) files.
  </p:documentation>
  
  <!-- ================================================================== -->
  
  <p:declare-step type="xtlmso:extract-xlsx">
    
    <p:documentation>
      Extracts the contents of an Excel (`.xlsx`) file in a more useable [XML format](%xlsx-extract.xsd).
    </p:documentation>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->
    
    <p:option name="xlsx-dref" required="true">
      <p:documentation>Document reference of the `.xlsx` file to process (must have `file://` in front).</p:documentation>
    </p:option>
    
    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The resulting XML representation of the Excel file.
      </p:documentation>
    </p:output>
    
    <p:import href="../../../container/xplmod/container.mod/container.mod.xpl"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Extract all XML content: -->
    <xtlcon:zip-to-container>
      <p:with-option name="dref-source-zip" select="$xlsx-dref"/>
      <p:with-option name="add-document-target-paths" select="false()"/>
    </xtlcon:zip-to-container>
    
    <!-- Transform it into extract format: -->
    <local:transfer-xlsx-zip-container/>
    
  </p:declare-step>
  
  <!-- ================================================================== -->
  
  <p:declare-step type="xtlmso:modify-xlsx" name="step-modify-xlsx">
    
    <p:documentation>
      Takes an input/template Excel (`.xlsx`)  and a [modification specification](%xlsx-modify.xsd) and from this creates a 
      new modified Excel file that merges these two sources.
    </p:documentation>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- SETUP: -->
    
    <p:input port="source" primary="true" sequence="false">
      <p:documentation>The [modification specification](%xlsx-modify.xsd).</p:documentation>
    </p:input>
    
    <p:option name="xlsx-dref-in" required="true">
      <p:documentation>URI of the input (template) `.xlsx` file to process</p:documentation>
    </p:option>
    
    <p:option name="xlsx-dref-out" required="true">
      <p:documentation>URI of the output `.xlsx` file.</p:documentation>
    </p:option>
    
    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The output is identical to the input but with `@timestamp`, `@xlsx-dref-in` and `@xlsx-dref-out` added to 
        the root element.</p:documentation>
    </p:output>
    
    <p:import href="../../../container/xplmod/container.mod/container.mod.xpl"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <p:identity name="modify-xlsx-original-input"/>
    
    <!-- Wrap the modification document in in an appropriate <xtlcon:document> element so we can insert it in the container: -->
    <p:wrap match="/*" wrapper="xtlcon:document"/>
    <p:add-attribute match="/*" attribute-name="type" attribute-value="modification-specification"/>
    <p:identity name="modification-specification-xtlcon-document"/>
    
    <!-- Create a container for the Excel input: -->
    <xtlcon:zip-to-container>
      <p:with-option name="dref-source-zip" select="$xlsx-dref-in"/>
      <p:with-option name="add-document-target-paths" select="true()"/>
    </xtlcon:zip-to-container>
    <p:identity name="xlsx-container"/>
    
    <!-- Get the .xlsx information in extract format so we can more easily lookup names. Out in an appropriate <xtlcon:document> element 
      so we can insert it in the container: -->
    <local:transfer-xlsx-zip-container/>
    <p:wrap match="/*" wrapper="xtlcon:document"/>
    <p:add-attribute match="/*" attribute-name="type" attribute-value="xlsx-in-extract-format"/>
    <p:identity name="xlsx-in-extract-format-xtlcon-document"/>
    
    <!-- Put the extract format and the modification into the original zip file container so now we have everything in one document: -->
    <p:insert match="/*" position="first-child">
      <p:input port="source">
        <p:pipe port="result" step="xlsx-container"/>
      </p:input>
      <p:input port="insertion">
        <p:pipe port="result" step="xlsx-in-extract-format-xtlcon-document"/>
      </p:input>
    </p:insert>
    <p:insert match="/*" position="first-child">
      <p:input port="insertion">
        <p:pipe port="result" step="modification-specification-xtlcon-document"/>
      </p:input>
    </p:insert>
    
    <!-- Prepare the modification part (convert name references into index coordinates): -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/modify-xlsx-prepare.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    
    <!-- First perform a rather raw merge of the modifications in the Excel contents: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/modify-xlsx-1.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    
    <!-- Now sort and remove doubles: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/modify-xlsx-2.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    
    <!-- Create the output xlsx: -->
    <xtlcon:container-to-zip>
      <p:with-option name="dref-target-zip" select="$xlsx-dref-out"/>
    </xtlcon:container-to-zip>
    <p:sink/>
    
    <!-- Create the output xml: -->
    <p:identity>
      <p:input port="source">
        <p:pipe port="result" step="modify-xlsx-original-input"/>
      </p:input>
    </p:identity>
    <p:add-attribute attribute-name="xlsx-dref-in" match="/*">
      <p:with-option name="attribute-value" select="$xlsx-dref-in"/>
    </p:add-attribute>
    <p:add-attribute attribute-name="xlsx-dref-out" match="/*">
      <p:with-option name="attribute-value" select="$xlsx-dref-out"/>
    </p:add-attribute>
    <p:add-attribute attribute-name="timestamp" match="/*">
      <p:with-option name="attribute-value" select="current-dateTime()"/>
    </p:add-attribute>
    
  </p:declare-step>
  
  <!-- ================================================================== -->
  
  <p:declare-step type="local:transfer-xlsx-zip-container">
    <p:documentation>
      Local step that turns a (direct) zip container made from an .xlsx file into the extract format (see ../../xsd/xlsx-extract.xsd).
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="false">
      <p:documentation>The .xlsx file zip container</p:documentation>
    </p:input>
    
    <p:output port="result" primary="true" sequence="false">
      <p:documentation>The .xlsx file in extract format </p:documentation>
    </p:output>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Transform the contents into something manageable: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/extract-xlsx-1.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    
    <!-- Remove any empty rows and cells: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/extract-xlsx-2.xsl"/>
      </p:input>
      <p:with-param name="null" select="()"/>
    </p:xslt>
    
  </p:declare-step>
  
  
</p:library>

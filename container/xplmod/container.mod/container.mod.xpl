<?xml version="1.0" encoding="UTF-8"?>
<?xtpxlib-public?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:pxp="http://exproc.org/proposed/steps" xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">
  
  <p:documentation>
    XProc library with steps for handling xtpxlib containers.
  </p:documentation>
  
  <!-- ================================================================== -->
  <!-- WRITE A CONTAINER TO DISK: -->
  
  <p:declare-step type="xtlcon:container-to-disk">
    
    <p:documentation>
      Writes the contents of a container to disk.
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        The container to process.
      </p:documentation>
    </p:input>
    
    <p:option name="dref-target" required="false">
      <p:documentation>
        Base path where to write the container. When you specify this it will have precedence over /*/@dref-target-path.
      </p:documentation>
    </p:option>
    
    <p:option name="indent-xml" required="false" select="false()">
      <p:documentation>
        Whether to indent the XML we create or not.
      </p:documentation>
    </p:option>
    
    <p:option name="remove-target" required="false" select="true()">
      <p:documentation>
        Whether to attempt to remove the target directory before writing.
      </p:documentation>
    </p:option>
    
    <p:option name="dref-fop-config" required="false" select="''">
      <p:documentation>
        Optional reference to an Apache FOP configuration file. Must be absolute!
        When not present a default file will be used. 
      </p:documentation>
    </p:option>
    
    <p:output port="result">
      <p:documentation>
        The input container, but with all the changes in links, paths, etc.
      </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="../../../common/xplmod/common.mod/common.mod.xpl"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- PREPARATIONS: -->
    
    <p:variable name="debug" select="false()"/>
    
    <p:variable name="xpl-base-dir-raw" select="replace(static-base-uri(), '(.*)[/\\][^/\\]+$', '$1')"/>
    <p:variable name="xpl-base-dir" select="replace($xpl-base-dir-raw, '^file:/+', 'file:///')"/>
    
    <p:variable name="dref-default-fop-config" select="concat($xpl-base-dir-raw, '/../../data/fop-default-config.xml')"/>
    <p:variable name="dref-fop-config-to-use" select="if ($dref-fop-config ne '') then $dref-fop-config else $dref-default-fop-config"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Compute the target result paths: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/container-compute-result-drefs.xsl"/>
      </p:input>
      <p:with-param name="dref-target" select="$dref-target"/>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
    <!-- This is the xml we're going to use and return. Remember it: -->
    <p:identity name="amended-container-xml"/>
    
    <!-- Delete the target if requested: -->
    <p:choose>
      <p:when test="xs:boolean($remove-target)">
        <xtlc:remove-dir>
          <p:with-option name="dref-dir" select="/*/@dref-target-result-path"/>
        </xtlc:remove-dir>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>
    
    <!-- Write all documents to disk: -->
    <p:for-each>
      <p:iteration-source select="/*/xtlcon:document[normalize-space(@dref-target-result) ne '']"/>
      <p:variable name="dref-target-result" select="string(/*/@dref-target-result)"/>
      <p:variable name="mime-type" select="string(/*/@mime-type)"/>
      
      <!-- Get the contents: -->
      <p:filter select="/*/*[1]"/>
      
      <!-- Store: -->
      <!-- When the mime-type of a document is application/pdf *and* it has a fo:root element, it is assumed to contain XSL-FO and will 
        be processed by FOP into a PDF. -->
      <p:choose>
        
        <!-- PDF generation: -->
        <p:when test="($mime-type eq 'application/pdf') and exists(/*/self::fo:root)">
          <p:xsl-formatter name="step-create-pdf" content-type="application/pdf">
            <p:with-option name="href" select="$dref-target-result"/>
            <p:with-param name="UserConfig" select="$dref-fop-config-to-use"/>
          </p:xsl-formatter>
        </p:when>
        
        <!-- Normal XML: -->
        <p:otherwise>
          <p:store method="xml" omit-xml-declaration="false" encoding="UTF-8" >
            <p:with-option name="href" select="$dref-target-result"/>
            <p:with-option name="indent" select="$indent-xml"/>
          </p:store>
        </p:otherwise>
        
      </p:choose>
      
    </p:for-each>
    
    <!-- Return to the amended container xml and do the external documents: -->
    <p:identity>
      <p:input port="source">
        <p:pipe port="result" step="amended-container-xml"/>
      </p:input>
    </p:identity>
    
    <p:for-each>
      <p:iteration-source select="/*/xtlcon:external-document[normalize-space(@dref-target-result) ne ''][normalize-space(@dref-source-result) ne '']"/>
      <p:variable name="dref-target-result" select="string(/*/@dref-target-result)"/>
      <p:variable name="dref-source-result" select="string(/*/@dref-source-result)"/>
      <p:variable name="dref-source-zip" select="string(/*/@dref-source-zip-result)"/>
      
      <xtlc:copy-file>
        <p:with-option name="dref-source-zip" select="$dref-source-zip"/>
        <p:with-option name="dref-source" select="$dref-source-result"/>
        <p:with-option name="dref-target" select="$dref-target-result"/>
      </xtlc:copy-file>
      
      <p:sink/>
    </p:for-each>
    
    <!-- Ready, revert back to the amended container XML as a result: -->
    <p:identity>
      <p:input port="source">
        <p:pipe port="result" step="amended-container-xml"/>
      </p:input>
    </p:identity>
    
  </p:declare-step>
  
  <!-- ================================================================== -->
  <!-- ZIP A CONTAINER: -->
  
  <p:declare-step type="xtlcon:container-to-zip">
    
    <p:documentation>
      Writes the contents of a container to a zip file.
    </p:documentation>
    
    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        The container to process.
      </p:documentation>
    </p:input>
    
    <p:option name="dref-target-zip" required="false">
      <p:documentation>
        Base path where to write the container. When you specify this it will have precedence over /*/@dref-target-zip.
      </p:documentation>
    </p:option>
    
    <p:option name="indent-xml" required="false" select="false()">
      <p:documentation>
        Whether to indent the XML we create or not.
      </p:documentation>
    </p:option>
    
    <p:option name="dref-fop-config" required="false" select="''">
      <p:documentation>
        Optional reference to an Apache FOP configuration file. Must be absolute!
        When not present a default file will be used. 
      </p:documentation>
    </p:option>
    
    <p:output port="result">
      <p:documentation>
        The input container, but with all the changes in links, paths, etc.
      </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="../../../common/xplmod/common.mod/common.mod.xpl"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- PREPARATIONS: -->
    
    <p:variable name="debug" select="false()"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Compute the target result paths for zipping: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/container-compute-result-drefs-zip.xsl"/>
      </p:input>
      <p:with-param name="dref-target-zip" select="$dref-target-zip"/>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
    <p:group>
      <p:variable name="dref-target-zip-tmpdir" select="/*/@dref-target-zip-tmpdir"/>
      <p:variable name="dref-target-zip-result" select="/*/@dref-target-zip-result"/>
      
      <!-- Write the container to disk on a temporary directory: -->
      <xtlcon:container-to-disk>
        <p:with-option name="dref-target" select="$dref-target-zip-tmpdir"/>  
        <p:with-option name="remove-target" select="true()"/>
        <p:with-option name="indent-xml" select="$indent-xml"/>
        <p:with-option name="dref-fop-config" select="$dref-fop-config"/> 
      </xtlcon:container-to-disk>
      <p:identity name="container-to-zip-result"/>
      
      <!-- Zip the resulting directory: -->
      <xtlc:zip-directory>
        <p:with-option name="base-path" select="$dref-target-zip-tmpdir"/>
        <p:with-option name="include-base" select="false()"/>
        <p:with-option name="dref-target-zip" select="$dref-target-zip-result"/> 
      </xtlc:zip-directory>
      
      <!-- Remove the temporary directory again: -->
      <xtlc:remove-dir>
        <p:with-option name="dref-dir" select="$dref-target-zip-tmpdir"/> 
      </xtlc:remove-dir>
      
      <!-- Switch back to the right XML: -->
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="container-to-zip-result"/>
        </p:input>
      </p:identity>
      
    </p:group>

  </p:declare-step>
  
  <!-- ================================================================== -->
  <!-- READ A DIRECTORY INTO A CONTAINER: -->
  
  <p:declare-step type="xtlcon:directory-to-container">
    
    <p:documentation>
      Reads a directory into a container. 
      All XML files will be read into the container, all other files will be included/referenced as external contents. 
    </p:documentation>
    
    <p:option name="dref-source-directory" required="true">
      <p:documentation>
        Reference to the directory to read.
      </p:documentation>
    </p:option>
    
    <p:option name="add-document-target-paths" required="false" select="true()">
      <p:documentation>
        Adds (relative) source paths as the target paths to the individual documents. 
      </p:documentation>
    </p:option>
    
    <p:option name="dref-target-path" required="false" select="''">
      <p:documentation>
        Optional target path to record on the container.
      </p:documentation>
    </p:option>
    
    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The output container.
      </p:documentation>
    </p:output>
    
    <p:import href="../../../common/xplmod/common.mod/common.mod.xpl"/>
    
    <p:variable name="debug" select="false()"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Get the contents of the directory: -->
    <xtlc:recursive-directory-list>
      <p:with-option name="path" select="$dref-source-directory"/>
      <p:with-option name="flatten" select="true()"/>
    </xtlc:recursive-directory-list>
    
    <p:group>
      <p:variable name="base-dir" select="/*/@xml:base"/>
      
      <!-- Loop over all contents and try to get it in: -->
      <p:for-each>
        <p:iteration-source select="//c:file"/>
        
        <p:variable name="dref-source-abs" select="/*/@dref-abs"/>
        <p:variable name="dref-source-rel" select="/*/@dref-rel"/>
        
        <p:try>
          
          <!-- Try to get it as XML: -->
          <p:group>
            <p:load dtd-validate="false">
              <p:with-option name="href" select="$dref-source-abs"/>
            </p:load>
            <p:wrap match="/*" wrapper="xtlcon:document"/>
          </p:group>
          
          <!-- Something went wrong, so this is not XML... Add it as an external document:-->
          <p:catch>
            <p:identity>
              <p:input port="source">
                <p:inline exclude-inline-prefixes="#all">
                  <xtlcon:external-document/>
                </p:inline>
              </p:input>
            </p:identity>
          </p:catch>
          
        </p:try>
        
        <!-- Add the relative reference to the document: -->
        <p:add-attribute match="/*" attribute-name="dref-source">
          <p:with-option name="attribute-value" select="$dref-source-rel"/>
        </p:add-attribute>
        
      </p:for-each>
      
      <!-- Add root and attributes: -->
      <p:wrap-sequence wrapper="xtlcon:document-container"/>
      <p:add-attribute attribute-name="timestamp" match="/*">
        <p:with-option name="attribute-value" select="current-dateTime()"/>
      </p:add-attribute>
      <p:add-attribute attribute-name="dref-source-path" match="/*">
        <p:with-option name="attribute-value" select="$base-dir"/>
      </p:add-attribute>
      
    </p:group>
    
    <!-- Final cleanup and other stuff: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/clean-directory-container.xsl"/>
      </p:input>
      <p:with-param name="add-document-target-paths" select="$add-document-target-paths"/>
      <p:with-param name="dref-target-path" select="$dref-target-path"/>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
  </p:declare-step>
  
  <!-- ================================================================== -->
  <!-- READ A ZIP FILE INTO A CONTAINER: -->
  
  <p:declare-step type="xtlcon:zip-to-container">
    
    <p:documentation>
      Reads a zip file into a container. 
      All XML files will be read into the container, all other files will be included/referenced as external contents. 
    </p:documentation>
    
    <p:option name="dref-source-zip" required="true">
      <p:documentation>
        Reference to the zip file to read.
      </p:documentation>
    </p:option>
    
    <p:option name="add-document-target-paths" required="false" select="true()">
      <p:documentation>
        Adds source paths as the target paths to the individual documents. 
      </p:documentation>
    </p:option>
    
    <p:option name="dref-target-path" required="false" select="''">
      <p:documentation>
        Optional target path to record on the container.
      </p:documentation>
    </p:option>
    
    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The output container.
      </p:documentation>
    </p:output>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="debug" select="false()"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Get the contents of the zip file: -->
    <pxp:unzip>
      <p:with-option name="href" select="$dref-source-zip"/>
    </pxp:unzip>
    
    <!-- Loop over all contents and try to get it in: -->
    <p:for-each>
      <p:iteration-source select="//c:file"/>
      
      <p:variable name="dref-source" select="/*/@name"/>
      
      <p:try>
        
        <!-- Try to get it as XML: -->
        <p:group>
          <pxp:unzip>
            <p:with-option name="href" select="$dref-source-zip"/>
            <p:with-option name="file" select="$dref-source"/>
          </pxp:unzip>
          <p:wrap match="/*" wrapper="xtlcon:document"/>
        </p:group>
        
        <!-- Something went wrong, so this is not XML... Add it as an external document:-->
        <p:catch>
          <p:identity>
            <p:input port="source">
              <p:inline>
                <xtlcon:external-document/>
              </p:inline>
            </p:input>
          </p:identity>
        </p:catch>
        
      </p:try>
      
      <!-- Add the reference to the document in the zip: -->
      <p:add-attribute match="/*" attribute-name="dref-source">
        <p:with-option name="attribute-value" select="$dref-source"/>
      </p:add-attribute>
      
    </p:for-each>
    
    <!-- Add root and attributes: -->
    <p:wrap-sequence wrapper="xtlcon:document-container"/>
    <p:add-attribute attribute-name="timestamp" match="/*">
      <p:with-option name="attribute-value" select="current-dateTime()"/>
    </p:add-attribute>
    <p:add-attribute attribute-name="dref-source-zip" match="/*">
      <p:with-option name="attribute-value" select="$dref-source-zip"/>
    </p:add-attribute>
    
    <!-- Final cleanup and other stuff: -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:document href="xsl/clean-zip-container.xsl"/>
      </p:input>
      <p:with-param name="add-document-target-paths" select="$add-document-target-paths"/>
      <p:with-param name="dref-target-path" select="$dref-target-path"/>
      <p:with-param name="debug" select="$debug"/>
    </p:xslt>
    
  </p:declare-step>
  
</p:library>

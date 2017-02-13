<?xml version="1.0" encoding="UTF-8"?>
<?xtpxlib-public?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps" xmlns:pxf="http://exproc.org/proposed/steps/file"
  version="1.0" xpath-version="2.0" exclude-inline-prefixes="#all">

  <p:documentation>
    XProc library with generic steps.
  </p:documentation>

  <!-- ================================================================== -->
  <!-- READ A DIRECTORY, RECURSIVE: -->

  <p:declare-step type="xtlc:recursive-directory-list">

    <p:documentation>
      Returns the contents of a directory, going into sub-directories recursively.
      When the requested directory does not exist, it returns only a c:directory root element with @error="true".
    
      Adapated from Norman Walsh example code at https://github.com/xquery/xquerydoc/blob/master/deps/xmlcalabash/recursive-directory-list.xpl
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:option name="path" required="true">
      <p:documentation>
        The path to get the directory listing from.
      </p:documentation>
    </p:option>

    <p:option name="include-filter" required="false">
      <p:documentation>
        An optional regexp include filter.
      </p:documentation>
    </p:option>

    <p:option name="exclude-filter" required="false">
      <p:documentation>
        An optional regexp exclude filter.
      </p:documentation>
    </p:option>

    <p:option name="depth" required="false" select="-1">
      <p:documentation>
        The sub-directory depth to go. When le 0, all sub-directories are processed.
      </p:documentation>
    </p:option>

    <p:option name="flatten" required="false" select="false()">
      <p:documentation>
        When true, the list will be "flattened": Only c:file children within the root c:directory element. All c:file elements have a
        @name, @dref-abs (absolute filename) and @dref-rel (relative filename) attribute.
      </p:documentation>
    </p:option>

    <p:output port="result">
      <p:documentation>
        The resulting directory structure listing in XML format.
      </p:documentation>
    </p:output>

    <!-- Get the list for the current directory. This fails when the directory isn't there, therefore the try/catch: -->
    <p:try>
      <p:group>
        <p:choose>
          <p:when test="p:value-available('include-filter')
            and p:value-available('exclude-filter')">
            <p:directory-list>
              <p:with-option name="path" select="$path"/>
              <p:with-option name="include-filter" select="$include-filter"/>
              <p:with-option name="exclude-filter" select="$exclude-filter"/>
            </p:directory-list>
          </p:when>
          <p:when test="p:value-available('include-filter')">
            <p:directory-list>
              <p:with-option name="path" select="$path"/>
              <p:with-option name="include-filter" select="$include-filter"/>
            </p:directory-list>
          </p:when>
          <p:when test="p:value-available('exclude-filter')">
            <p:directory-list>
              <p:with-option name="path" select="$path"/>
              <p:with-option name="exclude-filter" select="$exclude-filter"/>
            </p:directory-list>
          </p:when>
          <p:otherwise>
            <p:directory-list>
              <p:with-option name="path" select="$path"/>
            </p:directory-list>
          </p:otherwise>
        </p:choose>
      </p:group>

      <!-- Directory not found: -->
      <p:catch>
        <p:identity>
          <p:input port="source">
            <p:inline exclude-inline-prefixes="#all">
              <c:directory error="true"/>
            </p:inline>
          </p:input>
        </p:identity>
        <p:add-attribute attribute-name="xml:base" match="/*">
          <p:with-option name="attribute-value" select="$path"/>
        </p:add-attribute>
      </p:catch>
    </p:try>

    <!-- Descend for every other directory: -->
    <p:viewport match="/c:directory/c:directory">
      <p:variable name="name" select="/*/@name"/>
      <p:choose>
        <p:when test="$depth != 0">
          <p:choose>
            <p:when test="p:value-available('include-filter') and p:value-available('exclude-filter')">
              <xtlc:recursive-directory-list>
                <p:with-option name="path" select="concat($path,'/',$name)"/>
                <p:with-option name="include-filter" select="$include-filter"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
                <p:with-option name="depth" select="$depth - 1"/>
              </xtlc:recursive-directory-list>
            </p:when>
            <p:when test="p:value-available('include-filter')">
              <xtlc:recursive-directory-list>
                <p:with-option name="path" select="concat($path,'/',$name)"/>
                <p:with-option name="include-filter" select="$include-filter"/>
                <p:with-option name="depth" select="$depth - 1"/>
              </xtlc:recursive-directory-list>
            </p:when>
            <p:when test="p:value-available('exclude-filter')">
              <xtlc:recursive-directory-list>
                <p:with-option name="path" select="concat($path,'/',$name)"/>
                <p:with-option name="exclude-filter" select="$exclude-filter"/>
                <p:with-option name="depth" select="$depth - 1"/>
              </xtlc:recursive-directory-list>
            </p:when>
            <p:otherwise>
              <xtlc:recursive-directory-list>
                <p:with-option name="path" select="concat($path,'/',$name)"/>
                <p:with-option name="depth" select="$depth - 1"/>
              </xtlc:recursive-directory-list>
            </p:otherwise>
          </p:choose>
        </p:when>
        <p:otherwise>
          <p:identity/>
        </p:otherwise>
      </p:choose>
    </p:viewport>

    <!-- Flatten when requested: -->
    <p:choose>
      <p:when test="xs:boolean($flatten)">
        <p:xslt>
          <p:input port="stylesheet">
            <p:document href="xsl/flatten-directory-list.xsl"/>
          </p:input>
          <p:with-param name="debug" select="false()"/>
        </p:xslt>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>
    </p:choose>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- ZIP A DIRECTORY: -->

  <p:declare-step type="xtlc:zip-directory">

    <p:documentation>
      Zips a directory and its sub-directories into a single zip file.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:option name="dref-target-zip" required="true">
      <p:documentation>
         Document reference for the zip file to produce (must have a leading file:// specifier!)
      </p:documentation>
    </p:option>

    <p:option name="include-base" required="false" select="true()">
      <p:documentation>
        When true, the last part of $base-path (e.g. a/b/c ==> c) is used as the root directory in the zip file.
      </p:documentation>
    </p:option>

    <p:option name="base-path" required="true">
      <p:documentation>Directory which contents will be stored in the zip (must have a leading file:// specifier!)</p:documentation>
    </p:option>

    <p:output port="result">
      <p:documentation>
        The output of the actual zip step, listing all the files that went in         
      </p:documentation>
    </p:output>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Get the contents of the directory: -->
    <xtlc:recursive-directory-list>
      <p:with-option name="path" select="$base-path"/>
      <p:with-option name="flatten" select="false()"/>
    </xtlc:recursive-directory-list>

    <!-- Prepare the manifest: -->
    <p:xslt name="xtpxplib-prepare-zip-manifest">
      <p:input port="stylesheet">
        <p:document href="xsl/zip-directory-create-manifest.xsl"/>
      </p:input>
      <p:with-param name="include-base" select="$include-base"/>
    </p:xslt>

    <!-- Create the zip: -->
    <pxp:zip command="create">
      <p:input port="source">
        <p:empty/>
      </p:input>
      <p:input port="manifest">
        <p:pipe port="result" step="xtpxplib-prepare-zip-manifest"/>
      </p:input>
      <p:with-option name="href" select="$dref-target-zip"/>
    </pxp:zip>

    <!-- Remove superfluous attributes (there is no information in them): -->
    <p:delete match="@compressed-size"/>
    <p:delete match="@size"/>
    <p:delete match="@date"/>

    <!-- Add some additional information to the result: -->
    <p:add-attribute attribute-name="base-path" match="/*">
      <p:with-option name="attribute-value" select="$base-path"/>
    </p:add-attribute>
    <p:add-attribute attribute-name="include-base" match="/*">
      <p:with-option name="attribute-value" select="$include-base"/>
    </p:add-attribute>
    <p:add-attribute attribute-name="timestamp" match="/*">
      <p:with-option name="attribute-value" select="current-dateTime()"/>
    </p:add-attribute>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- TEE TO A FILE -->

  <p:declare-step type="xtlc:tee">

    <p:documentation>
      Tees the input to a file and passes it unchanged (like the Unix tee command).
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        Input to the tee.
      </p:documentation>
    </p:input>

    <p:option name="href" required="true">
      <p:documentation>
        Name of the file to write to (must have a leading file:// specifier!)
      </p:documentation>
    </p:option>

    <p:option name="enable" required="false" select="true()">
      <p:documentation>Whether to actually do the write. When false nothing happens.</p:documentation>
    </p:option>

    <p:option name="root-attribute-href" required="false" select="''">
      <p:documentation>
        If filled, $href is recorded as an attribute with this name on the root element of the original input. Must be a valid attribute name.
      </p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The input unchanged (unless $root-attribute-href was specified).
      </p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:identity name="tee-input"/>

    <p:choose>

      <!-- Do a store: -->
      <p:when test="xs:boolean($enable) and ($href ne '')">

        <!-- Store the file: -->
        <p:store method="xml" encoding="UTF-8" indent="true" omit-xml-declaration="false">
          <!-- Since normal usage will be for debug outputs, we always indent so the result 
            is more directly legible. -->
          <p:with-option name="href" select="$href"/>
        </p:store>

        <!-- Get the input back (we're not interested in the store result -->
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="tee-input"/>
          </p:input>
        </p:identity>

        <!-- Record the $href on the root element if required: -->
        <p:choose>
          <p:when test="$root-attribute-href ne ''">
            <p:add-attribute match="/*">
              <p:with-option name="attribute-name" select="$root-attribute-href"/>
              <p:with-option name="attribute-value" select="$href"/>
            </p:add-attribute>
          </p:when>
          <p:otherwise>
            <p:identity/>
          </p:otherwise>
        </p:choose>

      </p:when>

      <!-- Don't store, just pass the input on: -->
      <p:otherwise>
        <p:identity/>
      </p:otherwise>

    </p:choose>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- ADD MESSAGE TO LOGFILE: -->

  <p:declare-step type="xtlc:log">

    <p:documentation>
      Writes a message to a log file.
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        Input to the logging, will be passed unchanged to the output
      </p:documentation>
    </p:input>

    <p:option name="href-log" required="true">
      <p:documentation>
        Name of the file to write the logmessages to (must have a leading file:// specifier!)
      </p:documentation>
    </p:option>

    <p:option name="enable" required="false" select="true()">
      <p:documentation>
        Whether the logging is done at all.
      </p:documentation>
    </p:option>

    <p:option name="status" required="false" select="'ok'">
      <p:documentation>
        Status of the message. Must be ok, warning, error or debug.
      </p:documentation>
    </p:option>

    <p:option name="message" required="true">
      <p:documentation>
        The actual log message
      </p:documentation>
    </p:option>

    <p:option name="keep-messages" required="false" select="100">
      <p:documentation>
        The number of messages to keep in the logfile. If le 0, all messages are kept.
        Set by default to 100 to prevent overflowing files...
      </p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The input unchanged.
      </p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:choose>

      <!-- Do logging: -->
      <p:when test="xs:boolean($enable) and ($href-log ne '')">
        <p:identity name="log-input"/>

        <!-- Since we don't know how big the input is and we don't want our simple log message stylesheet burdened with too much input, 
          (which it won't use anyway), switch to some dummy XML:-->
        <p:identity>
          <p:input port="source">
            <p:inline>
              <dummy/>
            </p:inline>
          </p:input>
        </p:identity>

        <!-- Create or amend the logfile: -->
        <p:xslt>
          <p:input port="stylesheet">
            <p:document href="xsl/perform-logging.xsl"/>
          </p:input>
          <p:with-param name="href-log" select="$href-log"/>
          <p:with-param name="status" select="$status"/>
          <p:with-param name="message" select="$message"/>
          <p:with-param name="keep-messages" select="$keep-messages"/>
        </p:xslt>

        <p:store method="xml" encoding="UTF-8" omit-xml-declaration="false" indent="true">
          <p:with-option name="href" select="$href-log"/>
        </p:store>

        <!-- Get the original input back in: -->
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="log-input"/>
          </p:input>
        </p:identity>

      </p:when>

      <!-- No logging enabled: -->
      <p:otherwise>
        <p:identity/>
      </p:otherwise>

    </p:choose>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- COPY A FILE: -->

  <p:declare-step type="xtlc:copy-file">

    <p:documentation>
      Copies a file, if necessary from inside a zip file.

      IMPORTANT: For older versions of Clabash (before Janyary 2017) there is a huge bug in this step: A file inside a zip file must have a straight      
      filename without any characters that normally would have been escaped (like, the most inportant one, spaces).
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        Input, will be passed unchanged.
      </p:documentation>
    </p:input>

    <p:option name="dref-source" required="true">
      <p:documentation>
        Reference to the source file to copy.
      </p:documentation>
    </p:option>

    <p:option name="dref-source-zip" required="false" select="''">
      <p:documentation>
        Document reference to a zip file. When filled, $dref-source is assumed to be a path inside this zip.
      </p:documentation>
    </p:option>

    <p:option name="dref-target" required="true">
      <p:documentation>
        Reference to the target.
      </p:documentation>
    </p:option>

    <p:option name="enable" required="false" select="true()">
      <p:documentation>
        Whether the copying is done at all.
      </p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The input unchanged.
      </p:documentation>
    </p:output>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:choose>

      <p:when test="xs:boolean($enable) and ($dref-source ne '')">
        <p:identity name="copy-input"/>

        <!-- Since we don't know how big the input is and we don't want our copying stuff burdened with too much input, 
          which it won't use anyway, switch to some dummy XML:-->
        <p:identity>
          <p:input port="source">
            <p:inline>
              <dummy/>
            </p:inline>
          </p:input>
        </p:identity>

        <!-- Get the contents in: -->
        <p:choose>

          <!-- Copy from straight file on disk: -->
          <p:when test="$dref-source-zip eq ''">
            <pxf:copy>
              <p:with-option name="href" select="$dref-source"/>
              <p:with-option name="target" select="$dref-target"/>
              <p:with-option name="fail-on-error" select="true()"/>
            </pxf:copy>
          </p:when>

          <!-- Copy from zip: -->
          <p:otherwise>
            <pxp:unzip content-type="application/octet-stream">
              <p:with-option name="href" select="$dref-source-zip"/>
              <!-- The dref for the file in the must be without any leading slashes/backslashes, and it must be a uri: -->
              <p:with-option name="file" select="replace($dref-source, '^[/\\]+', '')"/>
            </pxp:unzip>
            <p:store cx:decode="true">
              <p:with-option name="href" select="$dref-target"/>
            </p:store>
          </p:otherwise>
        </p:choose>

        <!-- Revert back to original input: -->
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="copy-input"/>
          </p:input>
        </p:identity>

      </p:when>

      <!-- No copying enabled: -->
      <p:otherwise>
        <p:identity/>
      </p:otherwise>

    </p:choose>
  </p:declare-step>

  <!-- ================================================================== -->
  <!-- REMOVE A DIRECTORY: -->

  <p:declare-step type="xtlc:remove-dir">
    <p:documentation>
      Removes a full directory (since the normal processing using pxf:delete does not work properly some older Calabash versions... :-( )
      When the directory does not exist everything continues without error.
    </p:documentation>

    <p:input port="source" primary="true" sequence="false">
      <p:documentation>
        Input, will be passed unchanged.
      </p:documentation>
    </p:input>

    <p:option name="dref-dir" required="true">
      <p:documentation>
        Reference to the directory to remove.
      </p:documentation>
    </p:option>

    <p:option name="enable" required="false" select="true()">
      <p:documentation>
        Whether the removal is done at all.
      </p:documentation>
    </p:option>

    <p:output port="result" primary="true" sequence="false">
      <p:documentation>
        The input unchanged.
      </p:documentation>
    </p:output>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:variable name="debug" select="false()"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:choose>

      <p:when test="xs:boolean($enable)">
        <p:identity name="remove-dir-input"/>

        <!-- Since we don't know how big the input is and we don't want our copying stuff burdened with too much input, 
          which it won't use anyway, switch to some dummy XML:-->
        <p:identity>
          <p:input port="source">
            <p:inline>
              <dummy/>
            </p:inline>
          </p:input>
        </p:identity>

        <!-- Get a directory listing: -->
        <xtlc:recursive-directory-list>
          <p:with-option name="path" select="$dref-dir"/>
        </xtlc:recursive-directory-list>

        <!-- Create a list in the right order: -->
        <p:xslt>
          <p:input port="stylesheet">
            <p:document href="xsl/remove-dir-reorder.xsl"/>
          </p:input>
          <p:with-param name="debug" select="$debug"/>
        </p:xslt>

        <!-- Remove: -->
        <p:for-each>
          <p:iteration-source select="/*/remove[@dref]"/>
          <p:variable name="dref-for-remove" select="/*/@dref"/>

          <pxf:delete recursive="false" fail-on-error="true">
            <p:with-option name="href" select="$dref-for-remove"/>
          </pxf:delete>

        </p:for-each>

        <!-- Revert back to original input: -->
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="remove-dir-input"/>
          </p:input>
        </p:identity>

      </p:when>

      <!-- No removal enabled: -->
      <p:otherwise>
        <p:identity/>
      </p:otherwise>

    </p:choose>
  </p:declare-step>

</p:library>

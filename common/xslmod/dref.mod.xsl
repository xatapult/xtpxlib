<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.dref.mod.xsl" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    Generic handling of document references.
    
    Module dependencies: None
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL CONSTANTS: -->

  <xsl:variable name="xtlc:protocol-file" as="xs:string" select="'file'">
    <!--* File protocol specifier.  -->
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:variable name="local:protocol-match-regexp" as="xs:string" select="'^[a-zA-Z]+://'"/>
  <xsl:variable name="local:protocol-file-special" as="xs:string" select="concat($xtlc:protocol-file, ':/')"/>

  <!-- ================================================================== -->
  <!-- BASIC DREF FUNCTIONS:  -->

  <xsl:function name="xtlc:dref-concat" as="xs:string">
    <!--* 
      Performs a safe concatenation of document reference path components: 
      - Translates all backslashes into slashes
			- Makes sure that all components are separated with a single slash
      - If somewhere in the list is an absolute path, the concatenation stops.
      
      Examples:
      - xtlc:dref-concat(('a', 'b', 'c')) ==> a/b/c
      - xtlc:dref-concat(('a', '/b', 'c')) ==> /b/c
		-->
    <xsl:param name="dref-path-components" as="xs:string*">
      <!--* The path components that will be concatenated into a document reference. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($dref-path-components)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Take the last path in the list and translate all backslashes to slashes: -->
        <xsl:variable name="current-dref-1" as="xs:string" select="translate($dref-path-components[last()], '\', '/')"/>
        <!-- Remove any trailing slashes: -->
        <xsl:variable name="current-dref" as="xs:string" select="replace($current-dref-1, '/+$', '')"/>
        <xsl:choose>
          <xsl:when test="xtlc:dref-is-absolute($current-dref)">
            <xsl:sequence select="$current-dref"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="prefix" as="xs:string"
              select="xtlc:dref-concat(remove($dref-path-components, count($dref-path-components)))"/>
            <xsl:sequence select="concat($prefix, if ($prefix eq '') then () else '/', $current-dref)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-concat-noabs" as="xs:string">
    <!--* 
      Performs a safe concatenation of document reference path components: 
      - Translates all backslashes into slashes
			- Makes sure that all components are separated with a single slash
      - This version does not stop at an absolute path. Leading slashes are removed
      
      Examples:
      - xtlc:dref-concat-noabs(('a', 'b/', 'c')) ==> a/b/c
      - xtlc:dref-concat-noabs(('a', '/b', 'c')) ==> a/b/c
		-->
    <xsl:param name="dref-path-components" as="xs:string*">
      <!--* The path components that will be concatenated into a document reference. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($dref-path-components)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="is-first-component" as="xs:boolean" select="count($dref-path-components) eq 1"/>
        <!-- Take the last path in the list and translate all backslashes to slashes: -->
        <xsl:variable name="current-dref-1" as="xs:string" select="translate($dref-path-components[last()], '\', '/')"/>
        <!-- The first part of a list can have leading slashes (signifying an absolute path or UNC), so leave them there. 
          Otherwise remove: -->
        <xsl:variable name="current-dref-2" as="xs:string"
          select="if ($is-first-component) then $current-dref-1 else replace($current-dref-1, '^/+', '')"/>
        <!-- Remove any trailing slashes: -->
        <xsl:variable name="current-dref" as="xs:string" select="replace($current-dref-2, '/+$', '')"/>
        <!-- Get the part before this (by a recursive call): -->
        <xsl:variable name="prefix" as="xs:string"
          select="xtlc:dref-concat-noabs(remove($dref-path-components, count($dref-path-components)))"/>
        <xsl:sequence select="concat($prefix, if ($prefix eq '') then () else '/', $current-dref)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-is-absolute" as="xs:boolean">
    <!--* 
      Returns true if the document reference can be considered absolute.
      
      A path is considered absolute when it starts with a / or \, contains a protocol specifier (e.g. file://) or
      starts with a Windows drive letter (e.g. C:).
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:sequence
      select="starts-with($dref, '/') or starts-with($dref, '\') or contains($dref, ':/') or matches($dref, '^[a-zA-Z]:')"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-name" as="xs:string">
    <!--* 
      Returns the (file)name part of a complete document reference path. 
    
      Examples:
      - xtlc:dref-name('a/b/c') ==> c
      - xtlc:dref-name('c') ==> c
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:sequence select="replace($dref, '.*[/\\]([^/\\]+)$', '$1')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-noext" as="xs:string">
    <!--* 
      Returns the complete document reference path but without its extension.
    
      Examples:
      - xtlc:dref-noext('a/b/c.xml') ==> a/b/c
      - xtlc:dref-noext('a/b/c') ==> a/b/c      
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:sequence select="replace($dref, '\.[^\.]+$', '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-name-noext" as="xs:string">
    <!--* 
      Returns the (file)name part of a document reference path but without its extension. 
    
      Examples:
      - xtlc:dref-name-noext('a/b/c.xml') ==> c
      - xtlc:dref-name-noext('a/b/c') ==> c   
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:sequence select="xtlc:dref-noext(xtlc:dref-name($dref))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-ext" as="xs:string">
    <!--* 
      Returns the extension part of a document reference path. 
    
      Examples:
      - xtlc:dref-ext('a/b/c.xml') ==> xml
      - xtlc:dref-ext('a/b/c') ==> ''
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:variable name="name-only" as="xs:string" select="xtlc:dref-name($dref)"/>
    <xsl:choose>
      <xsl:when test="contains($name-only, '.')">
        <xsl:sequence select="replace($name-only, '.*\.([^\.]+)$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-path" as="xs:string">
    <!--* 
      Returns the path part of a document reference path.
    
      Examples:
      - xtlc:dref-path('a/b/c') ==> a/b
      - xtlc:dref-path('c') ==> ''
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="matches($dref, '[/\\]')">
        <xsl:sequence select="replace($dref, '(.*)[/\\][^/\\]+$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No slash or backslash in name, so no base path: -->
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-result-doc" as="xs:string">
    <!--* 
      Transforms a document reference into something <xsl:result-document> can use. 
      
      <xsl:result-document> instruction always needs a file:// in front and has some strict rules about the 
      formatting. Make sure the input is an absolute dref! 
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:sequence select="xtlc:protocol-add($dref, $xtlc:protocol-file, true())"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- CANONICALIZATION OF DREFs: -->

  <xsl:function name="xtlc:dref-canonical" as="xs:string">
    <!--* 
      Makes a document reference canonical (remove any .. and . directory specifiers).
      
      Examples:
      - dref-canonical('a/b/../c') ==> a/c
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <!-- Split the document reference into parts: -->
    <xsl:variable name="protocol" as="xs:string" select="xtlc:protocol($dref)"/>
    <xsl:variable name="dref-no-protocol" as="xs:string" select="xtlc:protocol-remove($dref)"/>
    <xsl:variable name="dref-components" as="xs:string*" select="tokenize($dref-no-protocol, '/')"/>

    <!-- Assemble it together again: -->
    <xsl:variable name="dref-canonical-filename" as="xs:string"
      select="string-join(local:dref-canonical-process-components($dref-components, 0), '/')"/>
    <xsl:sequence select="xtlc:protocol-add($dref-canonical-filename, $protocol, false())"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:dref-canonical-process-components" as="xs:string*">
    <!-- Helper function for xtlc:dref-canonical -->
    <xsl:param name="dref-components-unprocessed" as="xs:string*"/>
    <xsl:param name="parent-directory-marker-count" as="xs:integer"/>

    <!-- Get the last component to process here and get the remainder of the components: -->
    <xsl:variable name="component-to-process" as="xs:string?" select="$dref-components-unprocessed[last()]"/>
    <xsl:variable name="remainder-components" as="xs:string*"
      select="subsequence($dref-components-unprocessed, 1, count($dref-components-unprocessed) - 1)"/>

    <xsl:choose>

      <!-- No input, no output: -->
      <xsl:when test="empty($component-to-process)">
        <xsl:sequence select="()"/>
      </xsl:when>

      <!-- On a parent directory marker (..) we output the remainder and increase the $parent-directory-marker-count. This will cause the
        next name-component of the remainders to be removed:-->
      <xsl:when test="$component-to-process eq '..'">
        <xsl:sequence
          select="local:dref-canonical-process-components($remainder-components, $parent-directory-marker-count + 1)"/>
      </xsl:when>

      <!-- Ignore any current directory (.) markers: -->
      <xsl:when test="$component-to-process eq '.'">
        <xsl:sequence select="local:dref-canonical-process-components($remainder-components, $parent-directory-marker-count)"/>
      </xsl:when>

      <!-- Check if $parent-directory-marker-count is >= 0. If so, do not take the current component into account: -->
      <xsl:when test="$parent-directory-marker-count gt 0">
        <xsl:sequence
          select="local:dref-canonical-process-components($remainder-components, $parent-directory-marker-count - 1)"/>
      </xsl:when>

      <!-- Normal directory name and no $parent-directory-marker-count. This must be part of the output: -->
      <xsl:otherwise>
        <xsl:sequence select="(local:dref-canonical-process-components($remainder-components, 0), $component-to-process)"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- RELATIVE DREFs: -->

  <xsl:function name="xtlc:dref-relative" as="xs:string">
    <!--* 
      Computes a relative document reference from one document to another.
      
      Examples:
      - dref-relative('a/b/c/from.xml', 'a/b/to.xml') ==> ../to.xml
      - dref-relative('a/b/c/from.xml', 'a/b/d/to.xml') ==> ../d/to.xml      
    -->
    <xsl:param name="from-dref" as="xs:string">
      <!--* Document reference (of a document) of the starting point.  -->
    </xsl:param>
    <xsl:param name="to-dref" as="xs:string">
      <!--* Document reference (of a document) of the target. -->
    </xsl:param>

    <xsl:sequence select="xtlc:dref-relative-from-path(xtlc:dref-path($from-dref), $to-dref)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-relative-from-path" as="xs:string">
    <!--*
      Computes a relative document reference from a path to a document.
      
      Examples:
      - dref-relative-from-path('a/b/c', 'a/b/to.xml') ==> ../to.xml
      - dref-relative-from-path('a/b/c', 'a/b/d/to.xml') ==> ../d/to.xml            
    -->
    <xsl:param name="from-dref-path" as="xs:string">
      <!--* Document reference (of a directory) of the starting point. -->
    </xsl:param>
    <xsl:param name="to-dref" as="xs:string">
      <!--* Document reference (of a document) of the target. -->
    </xsl:param>

    <!-- Get all the bits and pieces: -->
    <xsl:variable name="from-dref-path-canonical" as="xs:string" select="xtlc:dref-canonical($from-dref-path)"/>
    <xsl:variable name="from-protocol" as="xs:string" select="xtlc:protocol($from-dref-path-canonical, $xtlc:protocol-file)"/>
    <xsl:variable name="from-no-protocol" as="xs:string" select="xtlc:protocol-remove($from-dref-path-canonical)"/>
    <xsl:variable name="from-components-no-filename" as="xs:string*" select="tokenize($from-no-protocol, '/')[. ne '']"/>

    <xsl:variable name="to-dref-canonical" as="xs:string" select="xtlc:dref-canonical($to-dref)"/>
    <xsl:variable name="to-protocol" as="xs:string" select="xtlc:protocol($to-dref-canonical, $xtlc:protocol-file)"/>
    <xsl:variable name="to-no-protocol" as="xs:string" select="xtlc:protocol-remove($to-dref-canonical)"/>
    <xsl:variable name="to-components" as="xs:string*" select="tokenize($to-no-protocol, '/')[. ne '']"/>
    <xsl:variable name="to-components-no-filename" as="xs:string*"
      select="subsequence($to-components, 1, count($to-components) - 1)"/>
    <xsl:variable name="to-filename" as="xs:string" select="$to-components[last()]"/>

    <!-- Now find it out: -->
    <xsl:choose>

      <!-- Unequal protocols or no from-dref/to-dref means there is no relative path... -->
      <xsl:when test="empty($to-components-no-filename) or (lower-case($from-protocol) ne lower-case($to-protocol))">
        <xsl:sequence select="$to-dref-canonical"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="xtlc:dref-concat((local:relative-dref-components-compare($from-components-no-filename, $to-components-no-filename), $to-filename))"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:relative-dref-components-compare" as="xs:string*">
    <!-- Local helper function for computing relative paths. -->
    <xsl:param name="from-components" as="xs:string*"/>
    <xsl:param name="to-components" as="xs:string*"/>

    <xsl:choose>
      <xsl:when test="$from-components[1] eq $to-components[1]">
        <xsl:sequence
          select="local:relative-dref-components-compare(subsequence($from-components, 2), subsequence($to-components, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="(for $p in (1 to count($from-components)) return '..', $to-components)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- DREF/URI PROTOCOL RELATED FUNCTIONS: -->

  <xsl:function name="xtlc:protocol-present" as="xs:boolean">
    <!--* Returns true when a reference has a protocol specifier (e.g. file:// or http://). -->
    <xsl:param name="ref" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>

    <!-- Usually a protocol is something that ends with ://, e.g. http://, but for the file protocol we also encounter file:/ (single slash).
      We have to adjust for this.-->
    <xsl:sequence select="starts-with($ref, $local:protocol-file-special) or matches($ref, $local:protocol-match-regexp)"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:protocol-remove" as="xs:string">
    <!--* 
      Removes the protocol part from a document reference.  
    
      Examples (it is tricky and inconsistent!)
      - xtlc:protocol-remove('file:///a/b/c') ==> /a/b/c
      Weird exceptions:
      - xtlc:protocol-remove('file:/a/b/c') ==> /a/b/c
      - xtlc:protocol-remove('file:/C:/a/b/c') ==> C:/a/b/c
    -->
    <xsl:param name="ref" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>

    <xsl:variable name="protocol-windows-special" as="xs:string"
      select="concat('^', $local:protocol-file-special, '[a-zA-Z]:/')"/>

    <!-- First remove any protocol specifier: -->
    <xsl:variable name="ref-0" as="xs:string" select="translate($ref, '\', '/')"/>
    <xsl:variable name="ref-1" as="xs:string">
      <xsl:choose>
        <!-- Normal case, anything starting with protocol:// -->
        <xsl:when test="matches($ref-0, $local:protocol-match-regexp)">
          <xsl:sequence select="replace($ref, $local:protocol-match-regexp, '')"/>
        </xsl:when>
        <!-- Windows file:/ exception, single slash, drive letter (file:/C:/bla/bleh):  -->
        <xsl:when test="matches($ref-0, $protocol-windows-special)">
          <xsl:sequence select="substring-after($ref-0, $local:protocol-file-special)"/>
        </xsl:when>
        <!-- Unix file:/ exception, single slash but absolute path (file:/home/beheer): -->
        <xsl:when test="starts-with($ref-0, $local:protocol-file-special)">
          <xsl:sequence select="concat('/', substring-after($ref-0, $local:protocol-file-special))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$ref-0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Check for a Windows absolute path with a slash in front. That must be removed: -->
    <xsl:sequence select="if (matches($ref-1, '^/[a-zA-Z]:/')) then substring($ref-1, 2) else $ref-1"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:protocol-add" as="xs:string">
    <!--* Adds a protocol part (written without the trailing ://) to a reference. -->
    <xsl:param name="ref" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>
    <xsl:param name="protocol" as="xs:string">
      <!--* The protocol to add, without a leading :// part (e.g. just 'file' or 'http'). -->
    </xsl:param>
    <xsl:param name="force" as="xs:boolean">
      <!--* When true an existing protocol is removed first. When false, a reference with an existing protocol is left unchanged.  -->
    </xsl:param>

    <xsl:variable name="ref-1" as="xs:string"
      select="if ($force) then xtlc:protocol-remove($ref) else translate($ref, '\', '/')"/>
    <xsl:choose>

      <!-- When $force is false, do not add a protocol when one is present already: -->
      <xsl:when test="not($force) and xtlc:protocol-present($ref-1)">
        <xsl:sequence select="$ref-1"/>
      </xsl:when>

      <!-- When this is a Windows dref with drive letter, make sure to add an extra / : -->
      <xsl:when test="($protocol eq $xtlc:protocol-file) and matches($ref-1, '^[a-zA-Z]:/')">
        <xsl:sequence select="concat($protocol, ':///', $ref-1)"/>
      </xsl:when>
      
      <xsl:when test="($protocol ne '')">
        <xsl:sequence select="concat($protocol, '://', $ref-1)"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:sequence select="$ref-1"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:protocol" as="xs:string">
    <!--* Returns the protocol part of a reference (without the ://). -->
    <xsl:param name="ref" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>

    <xsl:sequence select="xtlc:protocol($ref, '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:protocol" as="xs:string">
    <!--* Returns the protocol part of a reference (without the ://) or a default value when none present. -->
    <xsl:param name="ref" as="xs:string">
      <!--* Reference to work on. -->
    </xsl:param>
    <xsl:param name="default-protocol" as="xs:string">
      <!--* Default protocol to return when $ref contains none. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="xtlc:protocol-present($ref)">
        <xsl:sequence select="replace($ref, '(^[a-z]+):/.*$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default-protocol"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:dref-to-uri" as="xs:string">
    <!--* 
      Turns a dref into a uri. It will replace all "strange" characters with %xx.
      Any existing %xx parts will be kept as is.
    -->
    <xsl:param name="dref" as="xs:string">
      <!--* Document reference to work on. -->
    </xsl:param>

    <xsl:variable name="protocol" as="xs:string" select="xtlc:protocol($dref)"/>
    <xsl:variable name="dref-no-protocol" as="xs:string" select="xtlc:protocol-remove($dref)"/>
    <xsl:variable name="dref-parts" as="xs:string*" select="tokenize($dref-no-protocol, '/')"/>

    <xsl:variable name="dref-parts-uri" as="xs:string*">
      <xsl:for-each select="$dref-parts">
        <xsl:choose>
          <xsl:when test="(position() eq 1) and matches(., '^[a-zA-Z]:$')">
            <!-- Windows drive letter, just keep: -->
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="local:dref-part-to-uri(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="xtlc:protocol-add(string-join($dref-parts-uri, '/'), $protocol, false())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:dref-part-to-uri" as="xs:string">
    <!-- Support function for xtlc:dref-to-uri() -->
    <xsl:param name="dref-part" as="xs:string"/>

    <xsl:variable name="dref-part-parts" as="xs:string*">
      <xsl:analyze-string select="$dref-part" regex="%[0-9][0-9]">
        <xsl:matching-substring>
          <xsl:sequence select="."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="encode-for-uri(.)"/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="string-join($dref-part-parts, '')"/>
  </xsl:function>

</xsl:stylesheet>

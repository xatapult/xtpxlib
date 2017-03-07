<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:local="#local.common.mod.xsl"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    XSLT library module with common constants and code.
    
    Module dependencies: None
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL CONSTANTS: -->

  <!-- Date time formatting: -->
  <xsl:variable name="xtlc:default-dt-format-nl" as="xs:string" select="'[D01]-[M01]-[Y] [H01]:[m01]:[s01]'">
    <!--* Default date/time format string (Dutch: dd-mm-yyyy ...). -->
  </xsl:variable>
  <xsl:variable name="xtlc:default-dt-format-en" as="xs:string" select="'[M01]-[D01]-[Y] [H01]:[m01]:[s01]'">
    <!--* Default date/time format string (English: mm-dd-yyyy ...). -->
  </xsl:variable>

  <!-- Language codes: -->
  <xsl:variable name="xtlc:language-nl" as="xs:string" select="'nl'">
    <!--* Language code for Dutch -->
  </xsl:variable>
  <xsl:variable name="xtlc:language-en" as="xs:string" select="'en'">
    <!--* Language code for English -->
  </xsl:variable>

  <!-- Generic status codes: -->
  <xsl:variable name="xtlc:status-ok" as="xs:string" select="'ok'">
    <!--* Generic ok status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-warning" as="xs:string" select="'warning'">
    <!--* Generic warning status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-error" as="xs:string" select="'error'">
    <!--* Generic error status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-debug" as="xs:string" select="'debug'">
    <!--* Generic debug status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-codes" as="xs:string+" select="($xtlc:status-ok, $xtlc:status-warning, $xtlc:status-error, $xtlc:status-debug)">
    <!--* Sequence with all valid status codes.  -->
  </xsl:variable>

  <!-- Namespaces: -->
  <xsl:variable name="xtlc:namespace-xtlc-common" as="xs:string" select="'http://www.xtpxlib.nl/ns/common'">
    <!--* Name of the xtpxlib common namespace.  -->
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- VARIOUS: -->

  <xsl:function name="xtlc:char-repeat" as="xs:string">
    <!-- Returns a string with a character repeated a given number of times. -->
    <xsl:param name="char" as="xs:string">
      <!--* The first character of this string is the character to repeat.  -->
    </xsl:param>
    <xsl:param name="repeat" as="xs:integer">
      <!--* The number of repeats  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$repeat le 0">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="char-to-use" as="xs:string" select="substring($char, 1, 1)"/>
        <xsl:sequence select="string-join(for $c in 1 to $repeat return $char-to-use, '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:q" as="xs:string">
    <!--* Returns the input string quoted ("$in") -->
    <xsl:param name="in" as="xs:string?">
      <!--* String to convert. -->
    </xsl:param>

    <xsl:sequence select="concat('&quot;', $in, '&quot;')"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:item2element" as="element()?">
    <!--* 
      Tries to find the element belonging to a given item:
      - When the item is of type string or anyURI, it is assumed to be a document reference. The root element of this is returned.
      - When the item is of type document-node(), the root element of this document is returned
      - When the item is of type element(), this is returned
      
      You can choose whether or not to produce an error message or () when the item cannot be resolved into an element.
    -->
    <xsl:param name="item" as="item()">
      <!--* The item to work on -->
    </xsl:param>
    <xsl:param name="error-on-non-resolve" as="xs:boolean">
      <!--* Whether to generate an error when $item could not be resolved. Otherwise, the function will return (). -->
    </xsl:param>

    <xsl:variable name="function-name-prompt" as="xs:string" select="'item2element: '"/>
    <xsl:choose>

      <!-- String or URI: -->
      <xsl:when test="($item instance of xs:string) or ($item instance of xs:anyURI)">
        <xsl:choose>
          <xsl:when test="doc-available($item)">
            <xsl:sequence select="doc($item)/*"/>
          </xsl:when>
          <xsl:when test="$error-on-non-resolve">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="($function-name-prompt, 'Document &#34;', $item, '&#34; not found')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Document: -->
      <xsl:when test="$item instance of document-node()">
        <xsl:sequence select="$item/*"/>
      </xsl:when>

      <!-- Element: -->
      <xsl:when test="$item instance of element()">
        <xsl:sequence select="$item"/>
      </xsl:when>

      <!-- Nothing recognizable... -->
      <xsl:when test="$error-on-non-resolve">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="($function-name-prompt, 'Could not resolve item to element')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- STRING CONVERSIONS: -->

  <xsl:function name="xtlc:str2bln" as="xs:boolean">
    <!--* 
      Safe conversion of a string into a boolean.
      When $in is empty or not convertible into a boolean, $default is returned.
    -->
    <xsl:param name="in" as="xs:string?">
      <!--* String to convert. -->
    </xsl:param>
    <xsl:param name="default" as="xs:boolean">
      <!--* Default value to return when $in is empty or cannot be converted. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:when test="$in castable as xs:boolean">
        <xsl:sequence select="xs:boolean($in)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2int" as="xs:integer">
    <!--* 
      Safe conversion of a string into an integer.
      When $in is empty or not convertible into an integer, $default is returned.
    -->
    <xsl:param name="in" as="xs:string?">
      <!--* String to convert. -->
    </xsl:param>
    <xsl:param name="default" as="xs:integer">
      <!--* Default value to return when $in is empty or cannot be converted. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:when test="$in castable as xs:integer">
        <xsl:sequence select="xs:integer($in)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2seq" as="xs:string*">
    <!--* Converts a string with a list of words into a sequence of words. -->
    <xsl:param name="in" as="xs:string?">
      <!--* String to convert. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="tokenize($in, '\s+')[.]"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2id" as="xs:string">
    <!--* 
      Turns a string into a valid identifier, adding a prefix.
      All characters that are not allowed in an identifier are converted into underscores. 
      When the result does not start with a letter or underscore, the extra prefix 'id-' is added.
    -->
    <xsl:param name="in" as="xs:string">
      <!--* String to convert. -->
    </xsl:param>
    <xsl:param name="prefix" as="xs:string?">
      <!--* Prefix to apply. -->
    </xsl:param>

    <xsl:variable name="id" as="xs:string" select="replace(concat(string($prefix), $in), '[^a-zA-Z0-9_\-\.]', '_')"/>
    <xsl:choose>
      <xsl:when test="matches(substring($id, 1, 1), '[a-zA-Z_]')">
        <xsl:sequence select="$id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('id-', $id)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2id" as="xs:string">
    <!--* 
      Turns a string into a valid identifier.
      All characters that are not allowed in an identifier are converted into underscores. 
      When the result does not start with a letter or underscore, the extra prefix 'id-' is added.
    -->
    <xsl:param name="in" as="xs:string">
      <!--* String to convert. -->
    </xsl:param>

    <xsl:sequence select="xtlc:str2id($in, ())"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:strseq2attseq" as="attribute()*">
    <!--* 
      Turns a string sequence with tuples of strings into a sequence of attributes.
      
      Examples:
      - xtlcstrseq2attseq(('a', 'b', 'c', 'd')) ==> Attributes a="b", c="d"
      - xtlcstrseq2attseq(('a', 'b', 'c')) ==> Attributes a="b", c=""      
    -->
    <xsl:param name="strseq" as="xs:string*">
      <!--* String sequence to turn into attributes. -->
    </xsl:param>

    <xsl:for-each select="1 to count($strseq)">
      <xsl:variable name="pos" as="xs:integer" select="."/>
      <xsl:variable name="is-attribute-name" as="xs:boolean" select="(($pos mod 2) eq 1)"/>
      <xsl:if test="$is-attribute-name">
        <xsl:attribute name="{$strseq[$pos]}" select="string($strseq[$pos + 1])"/>
      </xsl:if>
    </xsl:for-each>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str-capitalize" as="xs:string">
    <!--* Capitalizes a string (makes the first character uppercase). -->
    <xsl:param name="in" as="xs:string">
      <!--* The string to work on. -->
    </xsl:param>

    <xsl:sequence select="concat(upper-case(substring($in, 1, 1)), substring($in, 2))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str-prefix-to-length" as="xs:string">
    <!--* Prefixes a string with a given character so it will get at least a given length. -->
    <xsl:param name="in" as="xs:string">
      <!--* String to prefix -->
    </xsl:param>
    <xsl:param name="prefix-char" as="xs:string">
      <!--* String to prefix with. Only first character is used. If empty, a * is used. -->
    </xsl:param>
    <xsl:param name="length" as="xs:integer">
      <!--* The length to reach. -->
    </xsl:param>

    <xsl:variable name="prefix-char-to-use" as="xs:string" select="if (string-length($prefix-char) lt 1) then '*' else substring($prefix-char, 1, 1)"/>
    <xsl:choose>
      <xsl:when test="string-length($in) ge $length">
        <xsl:sequence select="$in"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="prefix-string" as="xs:string" select="xtlc:char-repeat($prefix-char-to-use, $length - string-length($in))"/>
        <xsl:sequence select="concat($prefix-string, $in)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- ================================================================== -->
  <!-- CONVERSION OF THINGS INTO STRINGS: -->

  <xsl:function name="xtlc:att2str" as="xs:string">
    <!--* Turns an attribute into a string representation, suitable for display. -->
    <xsl:param name="att" as="attribute()?">
      <!--* Attribute to convert. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($att)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat(name($att), '=', xtlc:q($att))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:elm2str" as="xs:string">
    <!--* Turns an element into a descriptive string (the element with all the attributes (excluding schema references). -->
    <xsl:param name="elm" as="element()?">
      <!--* Element to convert  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($elm)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="description-parts" as="xs:string+">
          <xsl:sequence select="'&lt;'"/>
          <xsl:sequence select="name($elm)"/>
          <xsl:for-each select="$elm/@*[namespace-uri(.) ne 'http://www.w3.org/2001/XMLSchema-instance']">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="xtlc:att2str(.)"/>
          </xsl:for-each>
          <xsl:sequence select="'&gt;'"/>
        </xsl:variable>
        <xsl:sequence select="string-join($description-parts, '')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:items2str" as="xs:string">
    <!--* Creates a string from a sequence of items. Useful for easy creation of messages consisting of multiple parts and pieces. -->
    <xsl:param name="items" as="item()*">
      <!--* The message parts to combine  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($items)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="string-parts" as="xs:string*">
          <xsl:for-each select="$items">
            <xsl:choose>
              <xsl:when test=". instance of element()">
                <xsl:sequence select="xtlc:elm2str(.)"/>
              </xsl:when>
              <xsl:when test=". instance of attribute()">
                <xsl:sequence select="xtlc:att2str(.)"/>
              </xsl:when>
              <xsl:when test=". castable as xs:string">
                <xsl:sequence select="string(.)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="''"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($string-parts, '')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- ================================================================== -->
  <!-- ERROR HANDLING/RAISING -->

  <xsl:template name="xtlc:raise-error">
    <!--* Stops any processing by raising an error. -->
    <xsl:param name="msg-parts" as="item()+" required="yes">
      <!--* Error message to show (in parts, all parts will be concatenated by xtlc:items2str()). -->
    </xsl:param>
    <xsl:param name="error-name" as="xs:string" required="no" select="$xtlc:status-error">
      <!--* The (optional) name of the error. Must be a NCName. -->
    </xsl:param>

    <xsl:value-of select="error(QName($xtlc:namespace-xtlc-common, $error-name), xtlc:items2str($msg-parts))"/>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:raise-error">
    <!--* Stops any processing by raising an error. You can specify the error's name. -->
    <xsl:param name="msg-parts" as="item()+" required="yes">
      <!--* Error message to show (in parts, all parts will be concatenated by xtlc:items2str()). -->
    </xsl:param>
    <xsl:param name="error-name" as="xs:string">
      <!--* The name of the error (must be a NCName). -->
    </xsl:param>

    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="$msg-parts"/>
      <xsl:with-param name="error-name" select="$error-name"/>
    </xsl:call-template>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:raise-error">
    <!--* Stops any processing by raising an error. -->
    <xsl:param name="msg-parts" as="item()+" required="yes">
      <!--* Error message to show (in parts, all parts will be concatenated by xtlc:items2str()). -->
    </xsl:param>

    <xsl:call-template name="xtlc:raise-error">
      <xsl:with-param name="msg-parts" select="$msg-parts"/>
    </xsl:call-template>

  </xsl:function>

</xsl:stylesheet>

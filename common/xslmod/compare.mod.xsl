<?xml version="1.0" encoding="UTF-8"?>
<?xtpxlib-public?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="http://www.xtpxlib.nl/ns/common/xslmod/container/local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    XSL library module with support for comparing XML documents/elements.
    - Comment and processing instructions are ignored
    - Text nodes are normalized before comparison 
    - Empty text nodes (after normalization) are ignored
    - The comparison stops after the first (set of) differences are encountered. 
    - The result is either:
      - An empty set in no differences found
      - One or more xtlc:message elements, status="error" when differences were found (you can only get more than one message 
        on attribute differences)

    Module dependencies: common.mod.xsl, message.mod.xsl
	-->
 
  <!-- ================================================================== -->
  
  <xsl:template name="xtlc:compare-documents" as="element(xtlc:message)*">
    <xsl:param name="doc1" as="document-node()" required="yes"/>
    <xsl:param name="doc2" as="document-node()" required="yes"/>
    
    <xsl:call-template name="xtlc:compare-elements">
      <xsl:with-param name="elm1" select="$doc1/*"/>
      <xsl:with-param name="elm2" select="$doc2/*"/>
    </xsl:call-template>
    
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="xtlc:compare-elements" as="element(xtlc:message)*">
    <xsl:param name="elm1" as="element()" required="yes"/>
    <xsl:param name="elm2" as="element()" required="yes"/>
    <xsl:param name="path" as="xs:string" required="no" select="''"/>
    
    <xsl:variable name="current-path" as="xs:string" select="concat($path, '/', name($elm1), local:elm-seq-nr-string($elm1))"/>
    <xsl:variable name="att-compare" as="element(xtlc:message)*" select="xtlc:compare-attributes($current-path, $elm1/@*, $elm2/@*)"/>
    
    <xsl:choose>
      
      <!-- Compare the element itself: -->
      <xsl:when test="not(local:elm-eq($elm1, $elm2))">
        <xsl:call-template name="xtlc:msg-create">
          <xsl:with-param name="msg-parts" select="('Elements differ at ', $current-path)"/>
          <xsl:with-param name="status" select="$xtlc:status-error"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- Compare the attributes: -->
      <xsl:when test="exists($att-compare)">
        <xsl:sequence select="$att-compare"/>
      </xsl:when>
      
      <!-- This element checks out, go deeper -->
      <xsl:otherwise>
        <xsl:call-template name="xtlc:compare-node-lists">
          <xsl:with-param name="nodes1" select="$elm1/node()"/>
          <xsl:with-param name="nodes2" select="$elm2/node()"/>
          <xsl:with-param name="path" select="$current-path"/>
        </xsl:call-template>
      </xsl:otherwise>
      
    </xsl:choose>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="xtlc:compare-node-lists" as="element(xtlc:message)*">
    <xsl:param name="nodes1" as="node()*" required="yes"/>
    <xsl:param name="nodes2" as="node()*" required="yes"/>
    <xsl:param name="path" as="xs:string" required="yes"/>
    
    <xsl:variable name="node1" as="node()?" select="$nodes1[1]"/>
    <xsl:variable name="node2" as="node()?" select="$nodes2[1]"/>
    
    <xsl:choose>
      
      <!-- Nothing to compare: -->
      <xsl:when test="empty($nodes1) and empty($nodes2)">
        <!-- Ok -->
      </xsl:when>
      
      <!-- Do not compare on processing instructions and comments: -->
      <xsl:when test="($node1 instance of processing-instruction()) or ($node1 instance of comment())">
        <xsl:call-template name="xtlc:compare-node-lists">
          <xsl:with-param name="nodes1" select="subsequence($nodes1, 2)"/>
          <xsl:with-param name="nodes2" select="$nodes2"/>
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="($node2 instance of processing-instruction()) or ($node2 instance of comment())">
        <xsl:call-template name="xtlc:compare-node-lists">
          <xsl:with-param name="nodes1" select="$nodes1"/>
          <xsl:with-param name="nodes2" select="subsequence($nodes2, 2)"/>
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- Do not compare empty text nodes: -->
      <xsl:when test="($node1 instance of text()) and (normalize-space($node1) eq '')">
        <xsl:call-template name="xtlc:compare-node-lists">
          <xsl:with-param name="nodes1" select="subsequence($nodes1, 2)"/>
          <xsl:with-param name="nodes2" select="$nodes2"/>
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="($node2 instance of text()) and (normalize-space($node2) eq '')">
        <xsl:call-template name="xtlc:compare-node-lists">
          <xsl:with-param name="nodes1" select="$nodes1"/>
          <xsl:with-param name="nodes2" select="subsequence($nodes2, 2)"/>
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- Elements: -->
      <xsl:when test="($node1 instance of element()) and ($node2 instance of element())">
        <xsl:variable name="compare-elements-result" as="element(xtlc:message)*">
          <xsl:call-template name="xtlc:compare-elements">
            <xsl:with-param name="elm1" select="$node1"/>
            <xsl:with-param name="elm2" select="$node2"/>
            <xsl:with-param name="path" select="$path"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="exists($compare-elements-result)">
            <xsl:sequence select="$compare-elements-result"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xtlc:compare-node-lists">
              <xsl:with-param name="nodes1" select="subsequence($nodes1, 2)"/>
              <xsl:with-param name="nodes2" select="subsequence($nodes2, 2)"/>
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <!-- Text nodes: -->
      <xsl:when test="($node1 instance of text()) and ($node2 instance of text())">
        <xsl:choose>
          <xsl:when test="normalize-space($node1) ne normalize-space($node2)">
            <xsl:call-template name="xtlc:msg-create">
              <xsl:with-param name="msg-parts"
                select="('Text nodes differ on ', $path, ' (&quot;', normalize-space($node1), '&quot;, &quot;', normalize-space($node2), '&quot;)')"/>
              <xsl:with-param name="status" select="$xtlc:status-error"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xtlc:compare-node-lists">
              <xsl:with-param name="nodes1" select="subsequence($nodes1, 2)"/>
              <xsl:with-param name="nodes2" select="subsequence($nodes2, 2)"/>
              <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <!-- Can't compare: -->
      <xsl:otherwise>
        <xsl:call-template name="xtlc:msg-create">
          <xsl:with-param name="msg-parts" select="('Unequal sets of child nodes at ', $path)"/>
          <xsl:with-param name="status" select="$xtlc:status-error"/>
        </xsl:call-template>
      </xsl:otherwise>
      
    </xsl:choose>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlc:compare-attributes" as="element(xtlc:message)*">
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="attlist1" as="attribute()*"/>
    <xsl:param name="attlist2" as="attribute()*"/>
    
    <xsl:choose>
      
      <!-- Must have the same number of attributes: -->
      <xsl:when test="count($attlist1) ne count($attlist2)">
        <xsl:call-template name="xtlc:msg-create">
          <xsl:with-param name="msg-parts" select="('Number of attributes differs at ', $path)"/>
          <xsl:with-param name="status" select="$xtlc:status-error"/>
        </xsl:call-template>
      </xsl:when>
      
      <!-- Compare them one-by one: -->
      <xsl:otherwise>
        <xsl:for-each select="$attlist1">
          <xsl:variable name="att-name" as="xs:string" select="local-name(.)"/>
          <xsl:variable name="att-namespace" as="xs:anyURI" select="namespace-uri(.)"/>
          <xsl:variable name="att-value" as="xs:string" select="string(.)"/>
          <xsl:variable name="matching-att" as="attribute()?" select="$attlist2[local-name(.) eq $att-name][namespace-uri(.) eq $att-namespace]"/>
          
          <xsl:choose>
            <xsl:when test="empty($matching-att)">
              <xsl:call-template name="xtlc:msg-create">
                <xsl:with-param name="msg-parts" select="('Attribute ', name(.), ' on ', $path, ' not present in both sets')"/>
                <xsl:with-param name="status" select="$xtlc:status-error"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$att-value ne string($matching-att)">
              <xsl:call-template name="xtlc:msg-create">
                <xsl:with-param name="msg-parts"
                  select="('Values differ on attribute ', name(.), ' on ', $path, ' (&quot;', $att-value, '&quot;, &quot;', string($matching-att), '&quot;)')"/>
                <xsl:with-param name="status" select="$xtlc:status-error"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!-- Ok -->
            </xsl:otherwise>
          </xsl:choose>
          
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:elm-eq" as="xs:boolean">
    <xsl:param name="elm1" as="element()"/>
    <xsl:param name="elm2" as="element()"/>
    
    <xsl:sequence select="(local-name($elm1) eq local-name($elm2)) and (namespace-uri($elm1) eq namespace-uri($elm2))"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:elm-seq-nr-string" as="xs:string?">
    <!-- Determines a sequence number string for an XPath. When () it means that a sequence number is not necessary -->
    <xsl:param name="elm" as="element()"/>
    
    <xsl:variable name="seq-nr" as="xs:integer?">
      <xsl:choose>
        
        <!-- We have to display a sequence number when there are siblings with the same name: -->
        <xsl:when test="exists($elm/preceding-sibling::*[local:elm-eq(., $elm)]) or exists($elm/following-sibling::*[local:elm-eq(., $elm)])">
          <xsl:sequence select="count($elm/preceding-sibling::*[local:elm-eq(., $elm)]) + 1"/>
        </xsl:when>
        
        <!-- No same siblings, no sequence number necessary... -->
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="if (exists($seq-nr)) then concat('[', $seq-nr, ']') else ()"/>
  </xsl:function>
  
</xsl:stylesheet>

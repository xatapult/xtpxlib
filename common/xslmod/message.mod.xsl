<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.message.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    Message related templates.
    
    A message is a standardized piece of XML used for inserting error, debug, etc., messages into XML documents.
    Message schema: ../xsd/message.xsd
	-->
  <!-- ================================================================== -->

  <xsl:template name="xtlc:msg-create" as="element(xtlc:message)">
    <!--* 
      Generates a standard xtlc:message construct.
    -->
    <xsl:param name="msg-parts" as="xs:string+" required="yes">
      <!--* Message to show (in parts, all parts will be concatenated). -->
    </xsl:param>
    <xsl:param name="status" as="xs:string" required="yes">
      <!--* The status of the message. Must be one of the $xtlc:status-* constants. -->
    </xsl:param>
    <xsl:param name="extra-attributes" as="attribute()*" required="no" select="()">
      <!--* Any extra attributes to add to the message. -->
    </xsl:param>
    <xsl:param name="extra-contents" as="element()*" required="no" select="()">
      <!--* Any extra elements to add to the message. -->
    </xsl:param>
    
    <xtlc:message status="{$status}" timestamp="{current-dateTime()}">
      <xsl:copy-of select="$extra-attributes"/>
      <xtlc:text>
        <xsl:value-of select="string-join($msg-parts, '')"/>
      </xtlc:text>
      <xsl:copy-of select="$extra-contents"/>
    </xtlc:message>
    
  </xsl:template>
  
</xsl:stylesheet>

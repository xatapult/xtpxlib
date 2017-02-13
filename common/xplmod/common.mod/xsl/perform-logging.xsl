<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
		Creates or amends a logfile
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:param name="href-log" as="xs:string" required="yes"/>
  <xsl:param name="status" as="xs:string" required="yes"/>
  <xsl:param name="message" as="xs:string" required="yes"/>
  <xsl:param name="keep-messages" as="xs:string" required="yes"/>
  
  <xsl:include href="../../../xslmod/common.mod.xsl"/>
  <xsl:include href="../../../xslmod/message.mod.xsl"/>
  
  <xsl:variable name="keep-messages-count" as="xs:integer" select="xtlc:str2int($keep-messages, -1)"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/*">
    
    <!-- Create the message: -->
    <xsl:variable name="message-elm" as="element(xtlc:message)">
      <xsl:call-template name="xtlc:msg-create">
        <xsl:with-param name="msg-parts" select="$message"/>
        <xsl:with-param name="status" select="$status"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- Log it: -->
    <xsl:choose>
      
      <!-- There is not a log file available. Create it: -->
      <xsl:when test="not(doc-available($href-log))">
        <xtlc:log timestamp="{current-dateTime()}">
          <xsl:copy-of select="$message-elm" copy-namespaces="no"/>
        </xtlc:log>
      </xsl:when>
      
      <!-- Yes, there is a logfile, amend it: -->
      <xsl:otherwise>
        <xsl:for-each select="doc($href-log)/*">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            
            <!-- Copy new message first: -->
            <xsl:copy-of select="$message-elm" copy-namespaces="no"/>
            
            <!-- Copy existing messages: -->
            <xsl:choose>
              <xsl:when test="$keep-messages-count gt 0">
                <xsl:copy-of select="xtlc:message[position() lt $keep-messages-count]" copy-namespaces="no"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="xtlc:message" copy-namespaces="no"/>
              </xsl:otherwise>
            </xsl:choose>
            
          </xsl:copy>
        </xsl:for-each>
      </xsl:otherwise>
      
    </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>

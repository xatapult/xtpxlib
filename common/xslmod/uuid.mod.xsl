<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:local="#local.uuid.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*
    UUID related functions.
    
    Works only in Saxon PE or EE (not in the free HE), because we are calling an underlying Java function.
    
    Module dependencies: None
	-->
  <!-- ================================================================== -->

  <xsl:function name="xtlc:get-uuid" as="xs:string" xmlns:uuid="java:java.util.UUID">
    <!--* Returns a random unique UUID (by calling an underlying Java function)  -->

    <xsl:sequence select="uuid:randomUUID()"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:is-real-uuid" as="xs:boolean">
    <!--* Checks whether a string contains a "real" UUID (conforms to the UUID formatting rules).  -->
    <xsl:param name="id" as="xs:string?">
      <!--* UUID to check. -->
    </xsl:param>

    <!-- Example: 5EAE5C68-7394-48d7-A50B-1669E8D3A6C9 (upper/lower-case both admitted) -->

    <xsl:sequence select="matches(string($id), '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')"/>

  </xsl:function>

</xsl:stylesheet>

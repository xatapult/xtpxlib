<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtp-data="http://www.xatapult.nl/website/data" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
		
		SVN: $Id: convert-customer-list.xsl 1272 2013-03-07 13:38:21Z erik $
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  <!-- -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- -->
    <xsl:variable name="ImageRoot" as="xs:string" select="/*/@imageroot"/>
  <!-- -->
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  <!-- -->
    <xsl:template match="/*">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="/*/xtp-data:Title">
        <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="/*/xtp-data:Content">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <div xmlns="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates select="xtp-data:Customer"/>
            </div>
        </xsl:copy>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template xmlns="http://www.w3.org/1999/xhtml" match="xtp-data:Customer">
        <xsl:variable name="Pos" as="xs:integer" select="count(preceding-sibling::xtp-data:Customer)"/>
        <xsl:variable name="ImgLeft" as="xs:boolean" select="($Pos mod 2) eq 0"/>
    <!-- -->
        <br/>
        <table class="noborder" cellspacing="5">
            <tr valign="middle">
                <td class="noborder">
                    <xsl:choose>
                        <xsl:when test="$ImgLeft">
                            <xsl:if test="string(@imgcolwidth) ne ''">
                                <xsl:attribute name="width" select="@imgcolwidth"/>
                            </xsl:if>
                            <xsl:call-template name="AddImage"/>
                            <xsl:text>&#160;&#160;&#160;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="xtp-data:Text/node()" copy-namespaces="no"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td class="noborder">
                    <xsl:choose>
                        <xsl:when test="$ImgLeft">
                            <xsl:copy-of select="xtp-data:Text/node()" copy-namespaces="no"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string(@imgcolwidth) ne ''">
                                <xsl:attribute name="width" select="@imgcolwidth"/>
                            </xsl:if>
                            <xsl:text>&#160;&#160;&#160;</xsl:text>
                            <xsl:call-template name="AddImage"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template xmlns="http://www.w3.org/1999/xhtml" name="AddImage">
        <xsl:param name="Customer" as="element(xtp-data:Customer)" required="no" select="."/>
    <!-- -->
        <xsl:for-each select="$Customer">
            <a href="{@href}" target="_blank">
                <img src="{$ImageRoot}/{@img}">
                    <xsl:if test="string(@imgwidth) ne ''">
                        <xsl:attribute name="width" select="@imgwidth"/>
                    </xsl:if>
                </img>
            </a>
        </xsl:for-each>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="node()" priority="-1000"/>
  <!-- -->
</xsl:stylesheet>
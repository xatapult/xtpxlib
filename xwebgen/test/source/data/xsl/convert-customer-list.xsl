<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="#all" xmlns="http://www.w3.org/1999/xhtml">
 
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:variable name="image-root" as="xs:string" select="'images/klanten'"/>

  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/*">
    <div>
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="heading">
    <h1>
      <xsl:value-of select="."/>
    </h1>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="customer">
    <xsl:variable name="pos" as="xs:integer" select="count(preceding-sibling::customer)"/>
    <xsl:variable name="img-left" as="xs:boolean" select="($pos mod 2) eq 0"/>

    <br/>
    <table class="noborder" cellspacing="5">
      <tr valign="middle">
        <td class="noborder">
          <xsl:choose>
            <xsl:when test="$img-left">
              <xsl:if test="string(@imgcolwidth) ne ''">
                <xsl:attribute name="width" select="@imgcolwidth"/>
              </xsl:if>
              <xsl:call-template name="add-image"/>
              <xsl:text>&#160;&#160;&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="text/node()" copy-namespaces="no"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td class="noborder">
          <xsl:choose>
            <xsl:when test="$img-left">
              <xsl:copy-of select="text/node()" copy-namespaces="no"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="string(@imgcolwidth) ne ''">
                <xsl:attribute name="width" select="@imgcolwidth"/>
              </xsl:if>
              <xsl:text>&#160;&#160;&#160;</xsl:text>
              <xsl:call-template name="add-image"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template xmlns="http://www.w3.org/1999/xhtml" name="add-image">
    <xsl:param name="customer" as="element(customer)" required="no" select="."/>

    <xsl:for-each select="$customer">
      <a href="{@href}" target="_blank">
        <img src="{$image-root}/{@img}">
          <xsl:if test="string(@imgwidth) ne ''">
            <xsl:attribute name="width" select="@imgwidth"/>
          </xsl:if>
        </img>
      </a>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="node()" priority="-1000"/>

</xsl:stylesheet>

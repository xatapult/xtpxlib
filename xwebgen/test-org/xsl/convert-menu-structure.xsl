<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xtp-data="http://www.xatapult.nl/website/data" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  version="2.0" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--	
    Converts the menu XML in a datasection to the html used by the menu creating Javascript
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  
  <xsl:template match="/">
    <div id="mainMenu">
      <ul id="menuList">
        <xsl:apply-templates select="/*/xtp-data:MainMenu/xtp-data:Menu"/>
      </ul>
    </div>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xtp-data:Menu">
    <li>
      <a href="{@href}" class="starter" accesskey="{count(preceding-sibling::xtp-data:Menu) + 1}">
        <xsl:if test="string(@newwindow) eq 'yes'">
          <xsl:attribute name="target" select="'_blank'"/>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="normalize-space(@image) ne ''">
            <xsl:attribute name="title" select="@caption"/>
            <img src="{@image}" style="margin-top: 4px"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@caption"/>
          </xsl:otherwise>
        </xsl:choose>
      </a>
      
      <ul class="menu_level_1">
        <xsl:apply-templates select="xtp-data:Submenu"/>
      </ul>
    </li>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="xtp-data:Submenu">
    <li>
      <a href="{@href}">
        <xsl:if test="string(@newwindow) eq 'yes'">
          <xsl:attribute name="target" select="'_blank'"/>
        </xsl:if>
        <xsl:value-of select="@caption"/>
      </a>
    </li>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="node()" priority="-1000"/>
  
</xsl:stylesheet>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local" xmlns:xtpel-xpar="http://www.xtpel.nl/namespaces/xslmod/parameters" version="2.0" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	/TBD/
    
    Also changes in attributes:
    {HOME-EN} and {HOME-NL} Specific home pages for the languages
		
		SVN: $Id: pre-process-datasection.xsl 1278 2013-05-21 13:32:38Z erik $
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  <!-- -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <!-- -->
    <xsl:param name="pardoc" as="xs:string" required="yes"/>
    <xsl:param name="lang" as="xs:string" required="yes"/>
    <xsl:param name="servertype" as="xs:string" required="yes"/>
  <!-- -->
    <xsl:include href="../../xtpel/xslmod/parameters.xsl"/>
  <!-- -->
    <xsl:variable name="parameters-filters" as="attribute()+">
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="servertype" select="$servertype"/>
    </xsl:variable>
  <!-- -->
  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->
  <!-- -->
    <xsl:template match="node()" priority="-1">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
  <!-- -->
    <xsl:template match="@*" priority="10">
        <xsl:attribute name="{local-name(.)}" select="local:substitute-parameters(string(.))"/>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="/*">
        <xsl:copy copy-namespaces="no">
            <xsl:sequence select="$parameters-filters"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="*[exists(@lang) and (normalize-space(@lang) ne $lang)]" priority="10">
    <!-- Ignore these. All others: pass -->
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="*[exists(@servertype) and (normalize-space(@servertype) ne $servertype)]" priority="5">
    <!-- Ignore these. All others: pass -->
    </xsl:template>
  <!-- -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- -->
    <xsl:template match="text()">
        <xsl:value-of select="local:substitute-parameters(string(.))"/>
    </xsl:template>
  <!-- -->
  <!-- ================================================================== -->
  <!-- HELPERS -->
  <!-- -->
    <xsl:function name="local:substitute-parameters" as="xs:string">
        <xsl:param name="input" as="xs:string"/>
    <!-- -->
        <xsl:variable name="outputs" as="xs:string*">
            <xsl:analyze-string select="$input" regex="\{{(.+)\}}">
                <xsl:matching-substring>
                    <xsl:variable name="parname" as="xs:string" select="regex-group(1)"/>
                    <xsl:choose>
                        <xsl:when test="xtpel-xpar:parameter-exists($pardoc, $parname)">
                            <xsl:sequence select="xtpel-xpar:get-value($pardoc, $parname, $parameters-filters, '')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($outputs, '')"/>
    </xsl:function>
  <!-- -->
</xsl:stylesheet>
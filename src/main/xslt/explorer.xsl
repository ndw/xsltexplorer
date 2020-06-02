<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="m xs"
                version="3.0">

<xsl:import href="VERSION.xsl"/>
<xsl:import href="parse.xsl"/>
<xsl:import href="resolve.xsl"/>
<xsl:import href="analyze.xsl"/>
<xsl:import href="summarize.xsl"/>

<xsl:output method="xhtml" encoding="utf-8" indent="no"
            omit-xml-declaration="yes"/>

<xsl:param name="source-listings" select="'true'"/>

<xsl:param name="debug-parse" select="()" static="yes"/>
<xsl:param name="debug-resolve" select="()" static="yes"/>
<xsl:param name="debug-analyze" select="()" static="yes"/>
<xsl:param name="format" select="'visual'"/>
<xsl:param name="xspec-tests" select="'false'"/>

<xsl:template match="/">
  <xsl:variable name="parsed">
    <xsl:apply-templates select="/" mode="m:parse"/>
  </xsl:variable>

  <xsl:result-document use-when="exists($debug-parse)"
                       href="{$debug-parse}" method="xml" indent="yes">
    <xsl:sequence select="$parsed"/>
  </xsl:result-document>

  <xsl:variable name="resolved">
    <xsl:apply-templates select="$parsed" mode="m:resolve"/>
  </xsl:variable>

  <xsl:result-document use-when="exists($debug-resolve)"
                       href="{$debug-resolve}" method="xml" indent="yes">
    <xsl:sequence select="$resolved"/>
  </xsl:result-document>

  <xsl:variable name="analyzed">
    <xsl:apply-templates select="$resolved" mode="m:analyze"/>
  </xsl:variable>

  <xsl:result-document use-when="exists($debug-analyze)"
                       href="{$debug-analyze}" method="xml" indent="yes">
    <xsl:sequence select="$analyzed"/>
  </xsl:result-document>

  <xsl:choose>
    <xsl:when test="$format = 'data'">
      <xsl:choose>
        <xsl:when test="$xspec-tests = ('true','yes','1')">
          <xsl:apply-templates select="$analyzed" mode="m:fix-base-uri"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$analyzed"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$analyzed" mode="m:summarize"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="m:fix-base-uri">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="m:fix-base-uri"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@xml:base" mode="m:fix-base-uri">
  <xsl:attribute name="xml:base" select="'...'"/>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="m:fix-base-uri">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>

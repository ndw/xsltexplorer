<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="m xs"
                version="3.0">

<xsl:import href="VERSION.xsl"/>
<xsl:import href="analyze.xsl"/>
<xsl:import href="summarize.xsl"/>

<xsl:output method="xhtml" encoding="utf-8" indent="yes"
            omit-xml-declaration="yes"/>

<xsl:param name="source-listings" select="'true'"/>

<xsl:template match="/">
  <xsl:variable name="analyzed">
    <xsl:apply-templates select="/" mode="m:analyze"/>
  </xsl:variable>

  <xsl:result-document href="analyzed.xml" method="xml" indent="yes">
    <xsl:sequence select="$analyzed"/>
  </xsl:result-document>

  <xsl:apply-templates select="$analyzed" mode="m:summarize"/>
</xsl:template>

</xsl:stylesheet>

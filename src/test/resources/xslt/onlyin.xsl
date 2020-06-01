<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://example.com/function"
                xmlns:t="http://example.com/template"
                exclude-result-prefixes="f t xs"
                version="2.0">

<xsl:import href="onlyin-a.xsl"/>
<xsl:import href="onlyin-b.xsl"/>

<xsl:template match="/">
  <doc>
    <xsl:call-template name="t:template">
      <xsl:with-param name="arg1" select="f:function(3)"/>
    </xsl:call-template>
  </doc>
</xsl:template>

</xsl:stylesheet>

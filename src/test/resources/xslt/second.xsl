<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:a="http://example.com/second"
                xmlns:b="http://example.com/first"
                xmlns:t="http://example.com/third"
                exclude-result-prefixes="xs"
                version="2.0">

<xsl:param name="b" as="xs:string"/>
<xsl:variable name="shadowed" select="1"/>

<xsl:template match="a:baz" name="a:baz">
  <xsl:sequence select="b:f(34)"/>
</xsl:template>

<xsl:template match="a:moo" name="a:foo">
  <xsl:call-template name="a:bar"/>
  <xsl:variable name="shadowed" select="2"/>
  <xsl:sequence select="a:f($shadowed)"/>
</xsl:template>

<xsl:template name="a:bar">
  <xsl:sequence select="t:third-function()"/>
</xsl:template>

<xsl:function name="a:f" as="xs:integer">
  <xsl:param name="num" as="xs:integer"/>
  <xsl:sequence select="min((0, $num))"/>
</xsl:function>

</xsl:stylesheet>

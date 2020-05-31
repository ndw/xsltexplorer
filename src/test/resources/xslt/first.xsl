<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:a="http://example.com/first"
                xmlns:b="http://example.com/second"
                xmlns:t="http://example.com/third"
                exclude-result-prefixes="xs"
                version="2.0">

<xsl:param name="a" as="xs:string"/>
<xsl:variable name="shadowed" select="0"/>

<xsl:template match="a:foo" name="a:foo">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
  <xsl:call-template name="a:foo"/>
</xsl:template>

<xsl:template match="a:bar">
  <xsl:call-template name="b:foo"/>
  <xsl:sequence select="$a"/>
</xsl:template>

<xsl:function name="a:f" as="xs:integer">
  <xsl:param name="num" as="xs:integer"/>
  <xsl:sequence select="max((0, $num))"/>
</xsl:function>

<xsl:function name="a:g" as="xs:integer">
  <xsl:call-template name="t:third-template"/>
  <xsl:sequence select="5"/>
</xsl:function>

</xsl:stylesheet>

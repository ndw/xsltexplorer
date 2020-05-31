<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:first="http://example.com/first"
                xmlns:a="http://example.com/third"
                exclude-result-prefixes="xs"
                version="2.0">

<xsl:template name="a:third-template">
</xsl:template>

<xsl:function name="a:third-function">
</xsl:function>

<xsl:template name="first:foo">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>

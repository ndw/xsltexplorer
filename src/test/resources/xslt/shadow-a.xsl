<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://example.com/function"
                xmlns:t="http://example.com/template"
                xmlns:v="http://example.com/variable"
                exclude-result-prefixes="f t xs"
                version="2.0">

<xsl:variable name="v:variable" select="1"/>

<xsl:template name="t:template">
  <xsl:param name="arg1"/>
  <xsl:sequence select="$arg1"/>
</xsl:template>

<xsl:function name="f:function">
  <xsl:param name="arg1"/>
  <xsl:sequence select="$arg1"/>
</xsl:function>

</xsl:stylesheet>

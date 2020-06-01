<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://example.com/function"
                xmlns:t="http://example.com/template"
                exclude-result-prefixes="f t xs"
                version="2.0">

<xsl:template name="t:template2">
  <xsl:param name="arg1"/>
  <xsl:sequence select="$arg1"/>
</xsl:template>

<xsl:function name="f:function">
  <xsl:param name="arg1"/>
  <xsl:sequence select="$arg1"/>
</xsl:function>

<xsl:variable name="varname" select="3"/>

</xsl:stylesheet>

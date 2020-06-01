<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://example.com/function"
                xmlns:t="http://example.com/template"
                exclude-result-prefixes="f t xs"
                version="2.0">

<xsl:template name="t:template">
  <xsl:param name="arg1"/>

  <!-- this will never succeed, but statically it counts
       as a reference to this function from this module. -->
  <xsl:if test="false()">
    <xsl:call-template name="t:template">
      <xsl:with-param name="arg1" select="$arg1"/>
    </xsl:call-template>
  </xsl:if>

  <xsl:call-template name="t:template2">
    <xsl:with-param name="arg1" select="$varname"/>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>

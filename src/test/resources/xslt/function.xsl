<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://example.org/ns/functions"
                exclude-result-prefixes="f xs"
                version="2.0">

<xsl:output method="xml" encoding="utf-8" indent="no"
            omit-xml-declaration="yes"/>

<xsl:template match="/">
  <doc>
    <xsl:sequence select="f:func()"/>
  </doc>
</xsl:template>

<xsl:function name="f:func">
  <xsl:sequence select="3"/>
</xsl:function>

<xsl:function name="f:ufunc" as="xs:integer">
  <xsl:sequence select="3"/>
</xsl:function>

<xsl:function name="f:rfunc">
  <xsl:if test="false()">
    <xsl:sequence select="f:rfunc()"/>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>

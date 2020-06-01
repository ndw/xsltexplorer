<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

<xsl:output method="xml" encoding="utf-8" indent="no"
            omit-xml-declaration="yes"/>

<xsl:template match="/">
  <doc>
    <xsl:call-template name="temp"/>
  </doc>
</xsl:template>

<xsl:template name="temp">
  <xsl:sequence select="'temp'"/>
</xsl:template>

<xsl:template name="utemp"/>

<xsl:template name="rtemp">
  <xsl:if test="false()">
    <xsl:call-template name="rtemp"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>

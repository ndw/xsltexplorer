<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

<xsl:output method="xml" encoding="utf-8" indent="no"
            omit-xml-declaration="yes"/>

<xsl:variable name="var" select="1" as="xs:integer"/>
<xsl:variable name="uvar" select="2"/>

<xsl:template match="/">
  <doc><xsl:sequence select="$var"/>
  </doc>
</xsl:template>

</xsl:stylesheet>

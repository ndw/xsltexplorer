<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://nwalsh.com/ns/xslt/analysis"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:fp="http://nwalsh.com/ns/xslt/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:t="http://nwalsh.com/ns/xslt/templates"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://nwalsh.com/ns/xslt/analysis"
                default-mode="m:resolve"
                exclude-result-prefixes="a f fp h m t xs"
                version="3.0">

<xsl:template match="a:variable-ref">
  <xsl:variable name="ref" select="f:xvariable(., @ref)"/>

  <!-- If it's a reference to a top-level variable, then the last one wins. -->
  <xsl:variable name="ref" select="if (empty($ref) or $ref/parent::a:stylesheet)
                                   then (//a:stylesheet/a:variable[@name = $ref/@name])[last()]
                                   else $ref"/>

  <xsl:copy>
    <xsl:apply-templates select="@*"/>

    <xsl:choose>
      <xsl:when test="empty($ref)">
        <xsl:message select="'No variable:', @ref/string()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="xref" select="$ref/@id"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="a:call-template">
  <xsl:variable name="ref" select="@ref"/>
  <xsl:variable name="ref" select="(//a:stylesheet/a:template[@name = $ref])[last()]"/>

  <xsl:copy>
    <xsl:apply-templates select="@*"/>

    <xsl:choose>
      <xsl:when test="empty($ref)">
        <xsl:message select="'No template:', @ref/string()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="xref" select="$ref/@id"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="a:function-call">
  <xsl:variable name="ref" select="@ref"/>
  <xsl:variable name="ref" select="(//a:stylesheet/a:function[@name = $ref])[last()]"/>

  <xsl:copy>
    <xsl:apply-templates select="@*"/>

    <xsl:choose>
      <xsl:when test="empty($ref)">
        <xsl:choose>
          <xsl:when test="starts-with(@ref, '{http://www.w3.org/2005/xpath-functions}')
                          or starts-with(@ref, '{http://www.w3.org/2001/XMLSchema}')
                          or starts-with(@ref, '{http://saxon.sf.net/}')
                          or starts-with(@ref, '{http://www.w3.org/2005/xpath-functions/math}')
                          or starts-with(@ref, '{http://www.w3.org/2005/xpath-functions/array}')
                          or starts-with(@ref, '{http://www.w3.org/2005/xpath-functions/map}')">
            <!-- ignore standard, builtin functions -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="'No function:', @ref/string()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="xref" select="$ref/@id"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<xsl:function name="f:xvariable" as="element(a:variable)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:variable[@name=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:variable[@name=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:sequence select="(root($context)//a:stylesheet/a:variable[@name = $ref])[last()]"/>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:xvariable($context/parent::*, $ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>

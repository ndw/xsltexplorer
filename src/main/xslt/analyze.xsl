<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/terms/"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:p="xpath-31"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://nwalsh.com/ns/xslt/analysis"
                default-mode="m:analyze"
                exclude-result-prefixes="dc f m p xs"
                version="3.0">

<xsl:import href="xpath-31.xslt"/>

<xsl:template match="/">
  <xsl:variable name="doc">
    <xsl:apply-templates/>
  </xsl:variable>

  <xsl:element name="{local-name($doc/*)}" namespace="{namespace-uri($doc/*)}">
    <xsl:copy-of select="$doc/*/@*"/>
    <xsl:if test="empty($doc/*/@base-uri)">
      <xsl:attribute name="xml:base" select="base-uri(/*)"/>
    </xsl:if>
    <xsl:sequence select="$doc/*/node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="xsl:stylesheet|xsl:transform">
  <xsl:param name="href" as="xs:string?" select="()"/>

  <stylesheet uri="{resolve-uri(base-uri(.))}">
    <xsl:copy-of select="namespace::*[local-name(.) != '']"/>
    <xsl:if test="$href">
      <xsl:attribute name="href" select="$href"/>
    </xsl:if>
    <xsl:apply-templates select="@*,*"/>
  </stylesheet>
</xsl:template>

<xsl:template match="xsl:import">
  <xsl:if test="not(preceding-sibling
                    ::processing-instruction('xsltexplorer-skip-import'))">
    <xsl:message select="'Importing', @href/string(), '…'"/>
    <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))/*">
      <xsl:with-param name="href" select="@href"/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

<xsl:template match="xsl:include">
  <xsl:message select="'Including', @href/string(), '…'"/>
  <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))/*/*"/>
</xsl:template>

<xsl:template match="xsl:template">
  <xsl:message use-when="false()" select="'xsl:template', @name/string()"/>

  <xsl:variable name="match" as="xs:string*">
    <xsl:for-each select="tokenize(@match, '\|')">
      <xsl:sequence select="if (contains(., '['))
                            then normalize-space(substring-before(., '['))
                            else normalize-space(.)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="match" as="xs:string*">
    <xsl:for-each select="distinct-values($match)">
      <xsl:sort select="."/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="mode" as="xs:string?">
    <xsl:choose>
      <xsl:when test="@mode">
        <xsl:sequence select="f:clark-name(@mode)"/>
      </xsl:when>
      <xsl:when test="ancestor::xsl:stylesheet[1]/@default-mode">
        <xsl:sequence select="f:clark-name(ancestor::xsl:stylesheet[1]/@default-mode)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <template>
    <xsl:copy-of select="@name,@priority"/>
    <xsl:if test="exists($mode)">
      <xsl:attribute name="mode" select="$mode"/>
    </xsl:if>
    <xsl:if test="exists($match)">
      <xsl:attribute name="match" select="string-join($match,'|')"/>
    </xsl:if>
    <xsl:if test="@name">
      <xsl:attribute name="id" select="f:clark-name(@name)"/>
    </xsl:if>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </template>
</xsl:template>

<xsl:template match="xsl:function">
  <xsl:message use-when="false()" select="'xsl:function', @name/string()"/>

  <function id="{f:clark-name(@name)}#{count(xsl:param)}"
            noarity-id="{f:clark-name(@name)}"
            name="{@name}#{count(xsl:param)}">
    <xsl:apply-templates select="@*"/>
    <xsl:for-each select="xsl:param">
      <param>
        <xsl:copy-of select="@name,@as"/>
      </param>
    </xsl:for-each>
    <xsl:apply-templates/>
  </function>
</xsl:template>

<xsl:template match="xsl:variable|xsl:param">
  <xsl:message use-when="false()" select="node-name(.), @name/string()"/>

  <variable class="{local-name(.)}">
    <xsl:copy-of select="@name,@static"/>
    <xsl:attribute name="id" select="f:clark-name(@name)"/>
    <xsl:copy-of select="namespace::*[local-name(.) != '']"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </variable>
</xsl:template>

<xsl:template match="xsl:call-template">
  <xsl:message use-when="false()" select="node-name(.), @name/string()"/>

  <call-template ref="{f:clark-name(@name)}">
    <xsl:copy-of select="@name"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </call-template>
</xsl:template>

<xsl:template match="xsl:apply-templates">
  <xsl:message use-when="false()" select="node-name(.), @name/string()"/>

  <xsl:variable name="to" as="xs:string*">
    <xsl:for-each select="tokenize(@select, '\|')">
      <xsl:sequence select="if (contains(., '['))
                            then normalize-space(substring-before(., '['))
                            else normalize-space(.)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="to" as="xs:string*">
    <xsl:for-each select="distinct-values($to)">
      <xsl:sort select="."/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <apply-templates>
    <xsl:if test="exists($to)">
      <xsl:attribute name="to" select="string-join($to,'|')"/>
    </xsl:if>
    <xsl:copy-of select="@name,@mode"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </apply-templates>
</xsl:template>

<xsl:template match="dc:*">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="."/>
  </xsl:copy>
</xsl:template>

<xsl:template match="element()">
  <xsl:apply-templates select="@*,*"/>
</xsl:template>

<xsl:template match="@select[namespace-uri(parent::*)
                             ='http://www.w3.org/1999/XSL/Transform']
                     |xsl:if/@test
                     |xsl:when/@test">
  <xsl:sequence select="f:parse-expr(parent::*, .)"/>
</xsl:template>

<xsl:template match="@*">
  <xsl:if test="contains(string(.), '{')">
    <!-- this is primitive -->
    <xsl:variable name="value" select="replace(., '\{\{', '')"/>
    <xsl:variable name="value" select="replace($value, '\}\}', '')"/>
    <xsl:sequence select="f:process-avts(parent::*, $value)"/>
  </xsl:if>
</xsl:template>

<xsl:template match="text()|comment()|processing-instruction()"/>

<xsl:function name="f:process-avts">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="value" as="xs:string"/>

  <xsl:if test="contains($value, '{')">
    <xsl:variable name="expr" select="substring-after($value, '{')"/>
    <xsl:variable name="rest" select="substring-after($expr, '}')"/>
    <xsl:variable name="expr" select="substring-before($expr, '}')"/>
    <xsl:sequence select="f:parse-expr($context, $expr)"/>
    <xsl:sequence select="f:process-avts($context, $rest)"/>
  </xsl:if>
</xsl:function>

<xsl:function name="f:parse-expr">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="expr" as="xs:string"/>

  <!-- If there are no $ signs and no parens, then there
       are no variable references or function calls, so
       don't bother trying to parse the whole thing -->
  <xsl:if test="contains($expr, '$') or contains($expr, '(')">
    <xsl:variable name="parsetree">
      <xsl:sequence select="p:parse-XPath($expr)"/>
    </xsl:variable>    

    <xsl:variable name="functions" as="element()*">
      <xsl:for-each select="$parsetree//FunctionCall">
        <xsl:variable name="arity" select="count(ArgumentList/Argument)"/>
        <xsl:variable name="qname" select="FunctionEQName/FunctionName/QName"/>

        <xsl:variable name="ns" as="xs:string">
          <xsl:choose>
            <xsl:when test="not(contains($qname, ':'))"> <!-- default -->
              <xsl:sequence select="'http://www.w3.org/2005/xpath-functions'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="prefix" select="substring-before($qname, ':')"/>
              <xsl:sequence select="namespace-uri-for-prefix($prefix, $context)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="name"
                      select="if (contains($qname, ':'))
                              then substring-after($qname, ':')
                              else string($qname)"/>
        <xsl:variable name="id"
                      select="'{'||$ns||'}'||$name"/>
        <function-call name="{$qname}" ref="{$id}#{$arity}">
          <xsl:copy-of select="$context/namespace::*[local-name(.) != '']"/>
        </function-call>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each-group select="$functions" group-by="@ref">
      <xsl:sequence select="current-group()[1]"/>
    </xsl:for-each-group>

    <xsl:variable name="variables" as="element()*">
      <xsl:for-each select="$parsetree//VarRef//FunctionName/QName">
        <xsl:variable name="ns" as="xs:string">
          <xsl:choose>
            <xsl:when test="not(contains(., ':'))"> <!-- default -->
              <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="prefix" select="substring-before(., ':')"/>
              <xsl:sequence select="namespace-uri-for-prefix($prefix, $context)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="name"
                      select="if (contains(., ':'))
                              then substring-after(., ':')
                              else string(.)"/>
        <xsl:variable name="id"
                      select="'{'||$ns||'}'||$name"/>
        <variable-ref name="{.}" ref="{$id}">
          <xsl:copy-of select="$context/namespace::*[local-name(.) != '']"/>
        </variable-ref>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each-group select="$variables" group-by="@ref">
      <xsl:sequence select="current-group()[1]"/>
    </xsl:for-each-group>
  </xsl:if>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:clark-name" as="xs:string">
  <xsl:param name="node" as="node()"/>
  <xsl:choose>
    <xsl:when test="$node/self::attribute()">
      <xsl:sequence select="f:clark-name($node/parent::*, string($node))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:clark-name($node, string($node))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:clark-name" as="xs:string">
  <xsl:param name="node" as="node()"/>
  <xsl:param name="name" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="contains($name, ':')">
      <xsl:variable name="prefix" select="substring-before($name, ':')"/>
      <xsl:variable name="name" select="substring-after($name, ':')"/>
      <xsl:variable name="ns" select="namespace-uri-for-prefix($prefix, $node)"/>
      <xsl:sequence select="'{' || $ns || '}' || $name"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="'{}' || $name"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>

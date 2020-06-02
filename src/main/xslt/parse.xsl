<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://nwalsh.com/ns/xslt/analysis"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:p="xpath-31"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://nwalsh.com/ns/xslt/analysis"
                default-mode="m:parse"
                exclude-result-prefixes="a f m p xs"
                version="3.0">

<?xsltexplorer-skip-import?>
<xsl:import href="xpath-31.xslt"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xsl:stylesheet|xsl:transform">
  <xsl:param name="href" as="xs:string?" select="()"/>
  <xsl:param name="extra-attributes" as="attribute()*" select="()"/>

  <stylesheet id="{f:encode-for-id(f:unique-id(.))}">
    <xsl:copy-of select="namespace::*[local-name(.) != '']"/>
    <xsl:attribute name="xml:base" select="resolve-uri(base-uri(.))"/>
    <xsl:if test="$href">
      <xsl:attribute name="href" select="$href"/>
    </xsl:if>
    <xsl:sequence select="if (exists($extra-attributes))
                          then $extra-attributes
                          else f:source-location(.)"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*"/>
  </stylesheet>
</xsl:template>

<xsl:template match="xsl:import">
  <xsl:variable name="pi"
                select="preceding-sibling::node()[not(self::text())][1]"/>
  <xsl:if test="not($pi/self::processing-instruction('xsltexplorer-skip-import'))">
    <xsl:message select="'Importing', @href/string(), '…'"/>
    <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))/*">
      <xsl:with-param name="href" select="@href/string()"/>
      <xsl:with-param name="extra-attributes" as="attribute()+">
        <xsl:sequence select="f:source-location(.)"/>
        <xsl:attribute name="transclusion" select="'import'"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

<xsl:template match="xsl:include">
  <xsl:variable name="pi"
                select="preceding-sibling::node()[not(self::text())][1]"/>
  <xsl:if test="not(preceding-sibling
                    ::processing-instruction('xsltexplorer-skip-include'))">
    <xsl:message select="'Including', @href/string(), '…'"/>
    <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))/*">
      <xsl:with-param name="href" select="@href/string()"/>
      <xsl:with-param name="extra-attributes" as="attribute()+">
        <xsl:sequence select="f:source-location(.)"/>
        <xsl:attribute name="transclusion" select="'include'"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
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

  <xsl:variable name="display-mode" as="xs:string?">
    <xsl:choose>
      <xsl:when test="@mode">
        <xsl:sequence select="@mode/string()"/>
      </xsl:when>
      <xsl:when test="ancestor::xsl:stylesheet[1]/@default-mode">
        <xsl:sequence select="ancestor::xsl:stylesheet[1]/@default-mode/string()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <template id="{f:encode-for-id(f:unique-id(.))}">
    <xsl:if test="@name">
      <xsl:attribute name="display-name" select="@name"/>
      <xsl:attribute name="name" select="f:clark-name(@name)"/>
    </xsl:if>
    <xsl:copy-of select="@priority,@as"/>
    <xsl:if test="exists($mode)">
      <xsl:attribute name="mode" select="$mode"/>
      <xsl:attribute name="display-mode" select="$display-mode"/>
    </xsl:if>
    <xsl:if test="exists($match)">
      <xsl:attribute name="match" select="string-join($match,'|')"/>
    </xsl:if>
    <xsl:sequence select="f:source-location(.)"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </template>
</xsl:template>

<xsl:template match="xsl:function">
  <xsl:message use-when="false()" select="'xsl:function', @name/string()"/>

  <function id="{f:encode-for-id(f:unique-id(.)||'#'||count(xsl:param))}"
            noarity-id="{f:clark-name(@name)}"
            name="{f:clark-name(@name)}#{count(xsl:param)}"
            display-name="{@name}#{count(xsl:param)}">
    <xsl:sequence select="f:source-location(.)"/>
    <xsl:copy-of select="@as"/>
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

  <variable id="{f:encode-for-id(f:unique-id(.))}"
            class="{local-name(.)}">
    <xsl:copy-of select="namespace::*[local-name(.) != '']"/>
    <xsl:attribute name="display-name" select="@name"/>
    <xsl:attribute name="name" select="f:clark-name(@name)"/>
    <xsl:copy-of select="@static,@as"/>
    <xsl:sequence select="f:source-location(.)"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </variable>
</xsl:template>

<xsl:template match="xsl:call-template">
  <xsl:message use-when="false()" select="node-name(.), @name/string()"/>

  <call-template ref="{f:clark-name(@name)}">
    <xsl:copy-of select="@name"/>
    <xsl:sequence select="f:source-location(.)"/>
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
    <xsl:sequence select="f:source-location(.)"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </apply-templates>
</xsl:template>

<xsl:template match="element()">
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="@select[namespace-uri(parent::*)
                             ='http://www.w3.org/1999/XSL/Transform']
                     |xsl:if/@test
                     |xsl:when/@test
                     |xsl:evaluate/@context-item
                     |xsl:evaluate/@xpath
                     |xsl:template/@match
                     |xsl:group-by/@group-by">
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

<!-- ============================================================ -->

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

<xsl:function name="f:unique-id" as="xs:string">
  <xsl:param name="ref" as="element()"/>

  <xsl:variable name="prefix"
                select="if ($ref/self::xsl:stylesheet)
                        then ''
                        else f:unique-id($ref/ancestor::xsl:stylesheet[1]) || '-'"/>

  <xsl:choose>
    <xsl:when test="$ref/self::xsl:stylesheet">
      <xsl:sequence select="'S-' || f:checksum(base-uri($ref))"/>
    </xsl:when>
    <xsl:when test="$ref/@name">
      <xsl:sequence select="$prefix || f:clark-name($ref/@name)"/>
    </xsl:when>
    <xsl:when test="$ref/self::xsl:template">
      <xsl:sequence select="$prefix || 't-' || (count($ref/preceding::xsl:template)+1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$prefix || generate-id($ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:encode-for-id" as="xs:string">
  <xsl:param name="name" as="xs:string"/>

  <xsl:variable name="id" select="replace($name, '\{https?:/+', '')"/>
  <xsl:variable name="id" select="translate($id, '{}/#', '...,')"/>

  <xsl:sequence select="$id"/>
</xsl:function>

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

<xsl:function name="f:source-location" as="attribute()*">
  <xsl:param name="context" as="node()"/>

  <xsl:if xmlns:saxon="http://saxon.sf.net/"
          use-when="function-available('saxon:line-number')"
          test="saxon:line-number($context) gt 0">
    <xsl:attribute name="line-number" select="saxon:line-number($context)"/>
    <xsl:if use-when="function-available('saxon:column-number')"
            test="saxon:column-number($context) gt 0">
      <xsl:attribute name="column-number" select="saxon:column-number($context)"/>
    </xsl:if>
  </xsl:if>
</xsl:function>

<!-- ============================================================ -->
<!-- From: https://stackoverflow.com/questions/6753343/using-xsl-to-make-a-hash-of-xml-file -->

<xsl:function name="f:checksum" as="xs:string">
  <xsl:param name="str" as="xs:string"/>

  <xsl:variable name="filename"
                select="if (($xspec-tests = ('1', 'yes', 'true'))
                            and contains($str, 'src/test/resources/'))
                        then substring-after($str, 'src/test/resources')
                        else $str"/>

  <xsl:variable name="codepoints" select="string-to-codepoints($filename)"/>
  <xsl:variable name="checksum"
                select="f:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
  <!-- FIX ME: turn this into hex -->
  <xsl:sequence select="string($checksum)"/>
</xsl:function>

<xsl:function name="f:fletcher16">
  <xsl:param name="str" as="xs:integer*"/>
  <xsl:param name="len" as="xs:integer" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:param name="sum1" as="xs:integer" />
  <xsl:param name="sum2" as="xs:integer"/>
  <xsl:choose>
    <xsl:when test="$index gt $len">
      <xsl:sequence select="$sum2 * 256 + $sum1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="newSum1" as="xs:integer"
                    select="($sum1 + $str[$index]) mod 255"/>
      <xsl:sequence select="f:fletcher16($str, $len, $index + 1, $newSum1,
                                         ($sum2 + $newSum1) mod 255)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>

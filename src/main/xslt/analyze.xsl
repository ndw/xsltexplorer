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
                default-mode="m:analyze"
                exclude-result-prefixes="a f fp h m t xs"
                version="3.0">

<xsl:key name="fnoarity" match="a:function" use="@noarity-id"/>
<xsl:key name="id" match="*" use="@id"/>
<xsl:key name="xref" match="*" use="@xref"/>

<xsl:template match="/">
  <summary>
    <xsl:attribute name="xml:base" select="base-uri(/*)"/>
    <xsl:attribute name="imports"
                   select="count(/a:stylesheet//a:stylesheet[@transclusion='import'])"/>
    <xsl:attribute name="includes"
                   select="count(/a:stylesheet//a:stylesheet[@transclusion='include'])"/>
    <xsl:attribute name="variables"
                   select="count(//a:variable[parent::a:stylesheet and @class='variable'])"/>
    <xsl:attribute name="params"
                   select="count(//a:variable[parent::a:stylesheet and @class='param'])"/>
    <xsl:attribute name="templates"
                   select="count(//a:template[parent::a:stylesheet])"/>
    <xsl:attribute name="functions"
                   select="count(//a:function[parent::a:stylesheet])"/>
    <xsl:apply-templates/>
  </summary>
</xsl:template>

<xsl:template match="a:stylesheet">
  <xsl:variable name="stylesheet" select="."/>
  <xsl:variable name="depth" select="count(ancestor::a:stylesheet)+1"/>

  <stylesheet>
    <xsl:copy-of select="@id,@xml:base,@depth,@href,@transclusion"/>

    <xsl:variable name="imports" select="a:stylesheet[@transclusion='import']"/>
    <xsl:variable name="includes" select="a:stylesheet[@transclusion='include']"/>
    <xsl:variable name="vars" select="a:variable[@class='variable']"/>
    <xsl:variable name="params" select="a:variable[@class='param']"/>
    <xsl:variable name="templates" select="a:template"/>
    <xsl:variable name="functions" select="a:function"/>

    <xsl:attribute name="imports" select="count($imports)"/>
    <xsl:attribute name="includes" select="count($includes)"/>
    <xsl:attribute name="variables" select="count($vars)"/>
    <xsl:attribute name="params" select="count($params)"/>
    <xsl:attribute name="templates" select="count($templates)"/>
    <xsl:attribute name="functions" select="count($functions)"/>

    <xsl:variable name="vp-unused" as="element(a:variable)*"
                  select="a:variable[empty(key('xref', @id))]"/>

    <xsl:variable name="vp-shadows"
                  select="a:variable[f:variable(., @name/string())]"/>

    <xsl:variable name="vp-elsewhere" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:variable name="used-in"
                      select="key('xref', @id, root($stylesheet))
                                /ancestor::a:stylesheet[not(@transclusion='include')][1]
                              union ()"/>
        <xsl:if test="count($used-in) = 1 and exists($used-in except parent::*)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <variables>
      <xsl:for-each select="$vp-unused[@class='variable']">
        <unused><xsl:sequence select="f:generate-id(.)"/></unused>
      </xsl:for-each>
      <xsl:for-each select="$vp-shadows[@class='variable']">
        <shadows><xsl:sequence select="f:generate-id(.)"/></shadows>
      </xsl:for-each>
      <xsl:for-each select="$vp-elsewhere[@class='variable']">
        <elsewhere><xsl:sequence select="f:generate-id(.)"/></elsewhere>
      </xsl:for-each>
    </variables>

    <params>
      <xsl:for-each select="$vp-unused[@class='param']">
        <unused><xsl:sequence select="f:generate-id(.)"/></unused>
      </xsl:for-each>
      <xsl:for-each select="$vp-shadows[@class='param']">
        <shadows><xsl:sequence select="f:generate-id(.)"/></shadows>
      </xsl:for-each>
      <xsl:for-each select="$vp-elsewhere[@class='param']">
        <elsewhere><xsl:sequence select="f:generate-id(.)"/></elsewhere>
      </xsl:for-each>
    </params>

    <xsl:variable name="templates-unused" as="element(a:template)*">
      <xsl:for-each select="a:template[@name]">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="used-in" as="element()*">
          <xsl:for-each select="key('xref', @id, root($stylesheet))">
            <!-- recursion doesn't count as use -->
            <xsl:if test="not($this intersect ancestor::*)">
              <xsl:sequence select="."/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="empty($used-in)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="templates-shadow"
                  select="a:template[@name and f:template-shadows(., @name/string())]"/>

    <xsl:variable name="templates-elsewhere" as="element(a:template)*">
      <xsl:for-each select="a:template[@name]">
        <xsl:variable name="used-by"
                      select="(key('xref', @id)
                              /ancestor::*[parent::a:stylesheet[not(@transclusion='include')]][1])
                              union ()"/>
        <xsl:variable name="used-by-modules"
                      select="$used-by/parent::* union ()"/>
        <xsl:if test="count($used-by-modules) = 1
                      and not(parent::* is $used-by-modules)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <templates>
      <xsl:for-each select="$templates-unused">
        <unused><xsl:sequence select="f:generate-id(.)"/></unused>
      </xsl:for-each>
      <xsl:for-each select="$templates-shadow">
        <shadows><xsl:sequence select="f:generate-id(.)"/></shadows>
      </xsl:for-each>
      <xsl:for-each select="$templates-elsewhere">
        <elsewhere><xsl:sequence select="f:generate-id(.)"/></elsewhere>
      </xsl:for-each>
    </templates>

    <xsl:variable name="functions-shadow"
                  select="a:function[@name and f:function-shadows(., @name/string())]"/>

    <functions>
      <xsl:variable name="functions-unused" as="element(a:function)*">
        <xsl:for-each select="a:function">
          <xsl:variable name="this" select="."/>
          <xsl:variable name="used-in" as="element()*">
            <xsl:for-each select="key('xref', @id, root($stylesheet))">
              <!-- recursion doesn't count as use -->
              <xsl:if test="not($this intersect ancestor::*)">
                <xsl:sequence select="."/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="empty($used-in)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="functions-elsewhere" as="element(a:function)*">
        <xsl:for-each select="a:function">
          <xsl:variable name="used-in"
                        select="key('xref', @id, root($stylesheet))
                                    /ancestor::a:stylesheet[not(@transclusion='include')][1]
                                union ()"/>
          <xsl:if test="count($used-in) = 1 and exists($used-in except parent::*)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:for-each select="$functions-unused">
        <unused><xsl:sequence select="f:generate-id(.)"/></unused>
      </xsl:for-each>
      <xsl:for-each select="$functions-shadow">
        <shadows><xsl:sequence select="f:generate-id(.)"/></shadows>
      </xsl:for-each>
      <xsl:for-each select="$functions-elsewhere">
        <elsewhere><xsl:sequence select="f:generate-id(.)"/></elsewhere>
      </xsl:for-each>
    </functions>

    <xsl:apply-templates select="a:variable|a:template|a:function|a:stylesheet"/>
  </stylesheet>
</xsl:template>

<xsl:template match="a:function">
  <xsl:variable name="used-by" as="element()*">
    <xsl:for-each select="key('xref', @id)">
      <xsl:sequence
          select="ancestor::*[parent::a:stylesheet[not(@transclusion='include')]][1]"/>
    </xsl:for-each>
  </xsl:variable>

  <!-- remove dups -->
  <xsl:variable name="used-by" select="$used-by union ()"/>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="shadows"
                select="f:function-shadows(., @name/string())"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="local-name(.)"/>
    <xsl:sequence select="if (empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($shadows) then 'shadows' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <function id="{f:generate-id(.)}"
            class="{string-join($classes, ' ')}"
            recursive="{exists(. intersect $used-by)}"
            elsewhere="{$used-only-elsewhere}">
    <xsl:copy-of select="@name,@display-name,@id,@as,@line-number,@column-number"/>
    <xsl:copy-of select="a:param" copy-namespaces="no"/>

    <xsl:for-each select="$shadows">
      <shadow><xsl:sequence select="f:generate-id(.)"/></shadow>
    </xsl:for-each>

    <xsl:for-each select="key('fnoarity', @noarity-id) except $shadows">
      <no-arity><xsl:sequence select="f:generate-id(.)"/></no-arity>
    </xsl:for-each>

    <xsl:for-each select="f:variables-referenced(.)">
      <variable><xsl:sequence select="f:generate-id(.)"/></variable>
    </xsl:for-each>

    <xsl:for-each select="$used-by/self::a:function except .">
      <function><xsl:sequence select="f:generate-id(.)"/></function>
    </xsl:for-each>

    <xsl:for-each select="f:template-calls(.)">
      <template><xsl:sequence select="f:generate-id(.)"/></template>
    </xsl:for-each>

    <xsl:for-each select="$used-by">
      <used-by><xsl:sequence select="f:generate-id(.)"/></used-by>
    </xsl:for-each>

    <xsl:for-each select="$used-by-modules">
      <used-by-module><xsl:sequence select="f:generate-id(.)"/></used-by-module>
    </xsl:for-each>
  </function>
</xsl:template>

<xsl:template match="a:variable">
  <xsl:variable name="this" select="."/>
  <xsl:variable name="id" select="@id/string()"/>

  <xsl:variable name="used-by" as="element()*">
    <xsl:for-each select="key('xref', @id)">
      <xsl:sequence
          select="ancestor::*[parent::a:stylesheet[not(@transclusion='include')]][1]"/>
    </xsl:for-each>
  </xsl:variable>

  <!-- remove dups -->
  <xsl:variable name="used-by" select="$used-by union ()"/>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="shadows" select="f:variable(., @name/string())"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="@class/string()"/>
    <xsl:sequence select="if ($shadows) then 'shadows' else ()"/>
    <xsl:sequence select="if (empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <variable id="{f:generate-id(.)}"
            class="{string-join($classes, ' ')}"
            type="{@class}"
            elsewhere="{$used-only-elsewhere}">
    <xsl:copy-of select="@static,@name,@line-number,@column-number,@display-name,@as"/>

    <xsl:for-each select="$shadows">
      <shadow><xsl:sequence select="f:generate-id(.)"/></shadow>
    </xsl:for-each>

    <xsl:for-each select="f:variables-referenced(.)">
      <variable><xsl:sequence select="f:generate-id(.)"/></variable>
    </xsl:for-each>

    <xsl:for-each select="f:function-calls(.)">
      <function><xsl:sequence select="f:generate-id(.)"/></function>
    </xsl:for-each>

    <xsl:for-each select="f:template-calls(.)">
      <template><xsl:sequence select="f:generate-id(.)"/></template>
    </xsl:for-each>

    <xsl:for-each select="$used-by">
      <used-by class="{local-name(.)}"><xsl:sequence select="f:generate-id(.)"/></used-by>
    </xsl:for-each>

    <xsl:for-each select="$used-by-modules">
      <used-by-module><xsl:sequence select="f:generate-id(.)"/></used-by-module>
    </xsl:for-each>
  </variable>
</xsl:template>

<xsl:template match="a:template">
  <xsl:variable name="this" select="."/>

  <xsl:variable name="used-by" as="element()*">
    <xsl:if test="@name">
      <xsl:sequence
          select="(key('xref', @id)/ancestor::*
                     [parent::a:stylesheet[not(@transclusion='include')]][1])
                   union ()"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="shadows"
                select="if (@name) then f:template-shadows(., @name/string()) else ()"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="local-name(.)"/>
    <xsl:sequence select="if ($shadows) then 'shadows' else ()"/>
    <xsl:sequence select="if (@name and empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <template id="{f:generate-id(.)}"
            class="{string-join($classes, ' ')}"
            recursive="{exists(. intersect $used-by)}"
            elsewhere="{$used-only-elsewhere}">
    <xsl:copy-of select="@name,@display-name,@match,@as,@mode,@display-mode,
                         @priority,@line-number,@column-number"/>

    <xsl:for-each select="$shadows">
      <shadow><xsl:sequence select="f:generate-id(.)"/></shadow>
    </xsl:for-each>

    <xsl:for-each select="f:variables-referenced(.)">
      <variable><xsl:sequence select="f:generate-id(.)"/></variable>
    </xsl:for-each>

    <xsl:for-each select="f:function-calls(.)">
      <function><xsl:sequence select="f:generate-id(.)"/></function>
    </xsl:for-each>

    <xsl:for-each select="f:template-calls(.) except .">
      <template><xsl:sequence select="f:generate-id(.)"/></template>
    </xsl:for-each>

    <xsl:for-each select="$used-by">
      <used-by><xsl:sequence select="f:generate-id(.)"/></used-by>
    </xsl:for-each>

    <xsl:for-each select="$used-by-modules">
      <used-by-module><xsl:sequence select="f:generate-id(.)"/></used-by-module>
    </xsl:for-each>
  </template>
</xsl:template>

<xsl:function name="f:variables-referenced" as="element(a:variable)*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="($node//a:variable-ref ! key('id', @xref))[parent::a:stylesheet] union ()"/>
</xsl:function>

<xsl:function name="f:function-calls" as="element(a:function)*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="($node//a:function-call ! key('id', @xref))[parent::a:stylesheet] union ()"/>
</xsl:function>

<xsl:function name="f:template-calls" as="element(a:template)*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="($node//a:call-template ! key('id', @xref))[parent::a:stylesheet] union ()"/>
</xsl:function>

<xsl:function name="f:generate-id" as="xs:string">
  <xsl:param name="node" as="element()"/>
  <xsl:if test="not($node/@id)">
    <xsl:message terminate="yes" select="'No id?', $node"/>
  </xsl:if>
  <xsl:sequence select="$node/@id/string()"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:variable" as="element(a:variable)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:variable[@name=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:variable[@name=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:sequence select="($context/preceding::a:stylesheet/a:variable[@name=$ref])[last()]"/>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:variable($context/parent::*, $ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:template-shadows" as="element(a:template)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:template[@name=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:template[@name=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:sequence
          select="($context/preceding::a:stylesheet/a:template[@name=$ref])[last()]"/>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:template-shadows($context/parent::*, $ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:function-shadows" as="element(a:function)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:function[@name=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:function[@name=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:sequence
          select="($context/preceding::a:stylesheet/a:function[@name=$ref])[last()]"/>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:function-shadows($context/parent::*, $ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>

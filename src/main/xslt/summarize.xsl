<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://nwalsh.com/ns/xslt/analysis"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:fp="http://nwalsh.com/ns/xslt/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:t="http://nwalsh.com/ns/xslt/templates"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:summarize"
                exclude-result-prefixes="a f fp h m t xs"
                version="3.0">

<xsl:param name="css" select="'css/xsltexplorer.css'"/>
<xsl:param name="js" select="'js/xsltexplorer.js'"/>
<xsl:param name="title"
           select="$TITLE || ': ' || tokenize(base-uri(/*), '/')[last()]"/>

<xsl:key name="vars" match="a:stylesheet/a:variable" use="@id"/>
<xsl:key name="vrefs" match="a:variable-ref" use="@ref"/>
<xsl:key name="functions" match="a:function" use="@id"/>
<xsl:key name="fnoarity" match="a:function" use="@noarity-id"/>
<xsl:key name="fcalls" match="a:function-call" use="@ref"/>
<xsl:key name="templates" match="a:template" use="@id"/>
<xsl:key name="trefs" match="a:call-template" use="@ref"/>

<xsl:variable name="Z" select="xs:dayTimeDuration('PT0H')"/>

<xsl:template match="/">
  <html>
    <head>
      <title>
        <xsl:sequence select="$title"/>
      </title>
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <link href="https://fonts.googleapis.com/css?family=B612+Mono" rel="stylesheet" />
      <link href="https://fonts.googleapis.com/css?family=Noto+Sans" rel="stylesheet" />
      <link href="https://fonts.googleapis.com/css?family=Noto+Serif" rel="stylesheet" />
      <link rel="stylesheet" href="{$css}"/>
      <link rel="schema.dc" href="http://purl.org/dc/elements/1.1/"/>
      <meta name="dc.modified"
            content="{format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), $Z),
                                      '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')}"/>
      <meta name="generator" content="{$TITLE} {$VERSION} / {$VERHASH}"/>
      <link href="css/prism.css" rel="stylesheet" />
      <script src="js/prism.js"></script>
    </head>
    <body>
      <main>
        <xsl:apply-templates/>
      </main>
    </body>
    <script src="{$js}"/>
  </html>
</xsl:template>

<xsl:template match="a:stylesheet">
  <xsl:variable name="stylesheet" select="."/>

  <xsl:variable name="depth" select="count(ancestor::a:stylesheet)+1"/>
  <xsl:variable name="hsize" select="min(($depth,4))"/>

  <div class="{local-name(.)}" id="{f:generate-id(.)}">
    <xsl:element name="h{$hsize}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:choose>
        <xsl:when test="empty(parent::*)">
          <xsl:sequence select="$title"/>
          <xsl:message select="'Summarizing …'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="tokenize(resolve-uri(@href, base-uri(/*)), '/')[last()]"/>
          <xsl:message select="'Summarizing', @href/string(), '…'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:variable name="imports" select="if (parent::*)
                                         then ./a:stylesheet
                                         else .//a:stylesheet"/>
    <xsl:variable name="vars" select=".//a:variable[parent::a:stylesheet
                                                    and @class='variable']"/>
    <xsl:variable name="params" select=".//a:variable[parent::a:stylesheet
                                                      and @class='param']"/>
    <xsl:variable name="templates" select=".//a:template[parent::a:stylesheet]"/>
    <xsl:variable name="functions" select=".//a:function[parent::a:stylesheet]"/>

    <xsl:variable name="vp-unused" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="used-by" as="element()*">
          <xsl:for-each select="key('vrefs', @id)">
            <xsl:variable name="var" select="f:variable(., @ref)"/>
            <xsl:if test="exists($var) and $var is $this">
              <xsl:sequence select="."/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="empty($used-by)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="vp-shadows"
                  select="a:variable[f:variable(., @id/string())]"/>

    <xsl:variable name="vp-elsewhere" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:variable name="used-in"
                      select="key('vrefs', @id, root($stylesheet))/parent::a:stylesheet
                              union ()"/>
        <xsl:if test="count($used-in) = 1 and exists($used-in except parent::*)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="variable-notes" as="element(h:span)*">
      <xsl:variable name="v-unused" select="$vp-unused[@class='variable']"/>
      <xsl:variable name="v-shadows" select="$vp-shadows[@class='variable']"/>
      <xsl:variable name="v-elsewhere" select="$vp-elsewhere[@class='variable']"/>
      <xsl:if test="$v-unused">
        <span class="variable unused">
          <xsl:sequence select="count($v-unused) || ' unused'"/>
        </span>
      </xsl:if>
      <xsl:if test="$v-shadows">
        <span class="variable shadows">
          <xsl:sequence select="count($v-shadows) || ' shadows'"/>
        </span>
      </xsl:if>
      <xsl:if test="$v-elsewhere">
        <span class="variable elsewhere">
          <xsl:sequence select="count($v-elsewhere) || ' used only in other modules'"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="param-notes" as="element(h:span)*">
      <xsl:variable name="p-unused" select="$vp-unused[@class='param']"/>
      <xsl:variable name="p-shadows" select="$vp-shadows[@class='param']"/>
      <xsl:variable name="p-elsewhere" select="$vp-elsewhere[@class='param']"/>

      <xsl:if test="$p-unused">
        <span class="param unused">
          <xsl:sequence select="count($p-unused) || ' unused'"/>
        </span>
      </xsl:if>
      <xsl:if test="$p-shadows">
        <span class="param shadows">
          <xsl:sequence select="count($p-shadows) || ' shadows'"/>
        </span>
      </xsl:if>
      <xsl:if test="$p-elsewhere">
        <span class="param elsewhere">
          <xsl:sequence select="count($p-elsewhere) || ' used only in other modules'"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="template-notes" as="element(h:span)*">
      <xsl:variable name="templates-unused" as="element(a:template)*">
        <xsl:for-each select="a:template[@name]">
          <xsl:variable name="this" select="."/>
          <xsl:variable name="used-in" as="element()*">
            <xsl:for-each select="key('trefs', @id, root($stylesheet))">
              <xsl:variable name="t" select="f:template(., @ref/string())"/>
              <xsl:if test="exists($t) and $t is $this">
                <xsl:sequence select="$this"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="empty($used-in)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="template-shadows"
                    select="a:template[@name and f:template-shadows(., @id/string())]"/>

      <xsl:variable name="elsewhere-templates" as="element(a:template)*">
        <xsl:for-each select="a:template[@name]">
          <xsl:variable name="this" select="."/>
          <xsl:variable name="used-in" as="element()*">
            <xsl:for-each select="key('trefs', @id, root($stylesheet))">
              <xsl:variable name="t" select="f:template(., @ref/string())"/>
              <xsl:if test="exists($t) and $t is $this">
                <xsl:sequence select="$this/ancestor::a:stylesheet[1]"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="count($used-in) = 1 and exists($used-in except parent::*)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:if test="$templates-unused">
        <span class="template unused">
          <xsl:sequence select="count($templates-unused) || ' unused'"/>
        </span>
      </xsl:if>
      <xsl:if test="$template-shadows">
        <span class="template shadows">
          <xsl:sequence select="count($template-shadows) || ' shadows'"/>
        </span>
      </xsl:if>
      <xsl:if test="$elsewhere-templates">
        <span class="template elsewhere">
          <xsl:sequence select="count($elsewhere-templates) || ' used only in other modules'"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="function-notes" as="element(h:span)*">
      <xsl:variable name="functions-unused"
                    select="a:function[empty(key('fcalls', @id, root($stylesheet)))]"/>
      <xsl:variable name="elsewhere-functions" as="element(a:function)*">
        <xsl:for-each select="a:function">
          <xsl:variable name="used-in"
                        select="key('fcalls', @id, root($stylesheet))/ancestor::a:stylesheet[1]
                                union ()"/>
          <xsl:if test="count($used-in) = 1 and exists($used-in except parent::*)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="$functions-unused">
        <span class="function unused">
          <xsl:sequence select="count($functions-unused) || ' unused'"/>
        </span>
      </xsl:if>
      <!-- FIXME: shadows -->
      <xsl:if test="$elsewhere-functions">
        <span class="function elsewhere">
          <xsl:sequence select="count($elsewhere-functions) || ' used only in other modules'"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="summary" as="element()*">
      <xsl:if test="$imports">
        <span>
          <xsl:sequence select="count($imports) || ' imports'"/>
        </span>
      </xsl:if>

      <xsl:if test="$templates">
        <span>
          <xsl:sequence select="count($templates) || ' templates'"/>
          <xsl:sequence select="f:notes($template-notes)"/>
        </span>
      </xsl:if>

      <xsl:if test="$functions">
        <span>
          <xsl:sequence select="count($functions), 'functions'"/>
          <xsl:sequence select="f:notes($function-notes)"/>
        </span>
      </xsl:if>

      <xsl:if test="$vars">
        <span>
          <xsl:sequence select="count($vars), 'variables'"/>
          <xsl:sequence select="f:notes($variable-notes)"/>
        </span>
      </xsl:if>
      <xsl:if test="$params">
        <span a-type="param">
          <xsl:sequence select="count($params), 'parameters'"/>
          <xsl:sequence select="f:notes($param-notes)"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:if test="exists($summary)">
      <p>
        <xsl:for-each select="$summary">
          <xsl:if test="position() gt 1">, </xsl:if>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </p>
    </xsl:if>

    <xsl:if test="not(parent::*) and a:stylesheet">
      <div class="toc">
        <span class="closed">Table of Imports</span>
        <xsl:apply-templates select="." mode="m:toc"/>
      </div>

      <xsl:variable name="list" select="//a:template[@name]"/>
      <xsl:if test="$list">
        <div class="lot">
          <span class="closed">List of Templates</span>
          <dl class="columns">
            <xsl:for-each select="$list">
              <xsl:sort select="@id"/>
              <dt>
                <xsl:apply-templates select="." mode="m:reference"/>
              </dt>
            </xsl:for-each>
          </dl>
        </div>
      </xsl:if>            

      <xsl:variable name="list" select="//a:function"/>
      <xsl:if test="$list">
        <div class="lof">
          <span class="closed">List of Functions</span>
          <dl class="columns">
            <xsl:for-each select="$list">
              <xsl:sort select="@id"/>
              <dt>
                <xsl:apply-templates select="." mode="m:reference"/>
              </dt>
            </xsl:for-each>
          </dl>
        </div>
      </xsl:if>            
    </xsl:if>

    <xsl:apply-templates select="a:stylesheet"/>

    <div class="instructions">
      <div class="title closed">Instructions</div>
      <div class="body">
        <xsl:apply-templates select="a:* except a:stylesheet"/>
      </div>
    </div>

    <xsl:if test="string($source-listings) = ('1','true','yes')">
      <div class="source-code">
        <div class="title closed">Source code</div>
        <div class="body">
          <div>
            <xsl:if test="@uri">
              <xsl:try>
                <xsl:variable name="code" select="unparsed-text(@uri)"/>
                <table>
                  <tr>
                    <td valign="top" align="right">
                      <pre class="fake-prism">
                        <xsl:for-each select="tokenize($code,'&#10;')">
                          <span id="line-{generate-id($stylesheet)}-{position()}">
                            <xsl:choose>
                              <xsl:when test="position() eq 1 or (position() mod 5 = 0)">
                                <xsl:sequence select="position()"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <span class="lno">
                                  <xsl:sequence select="position()"/>
                                </span>
                              </xsl:otherwise>
                            </xsl:choose>
                          </span>
                          <xsl:text>&#10;</xsl:text>
                        </xsl:for-each>
                      </pre>
                    </td>
                    <td valign="top">
                      <pre>
                        <code class="language-xml">
                          <xsl:sequence select="$code"/>
                        </code>
                      </pre>
                    </td>
                  </tr>
                </table>
                <xsl:catch>
                  <xsl:sequence select="()"/>
                </xsl:catch>
              </xsl:try>
            </xsl:if>
          </div>
        </div>
      </div>
    </xsl:if>

    <xsl:if test="not(parent::*)">
      <xsl:variable name="now" select="adjust-dateTime-to-timezone(current-dateTime(), $Z)"/>
      <div class="details">
        <p>
          <xsl:text>Generated by </xsl:text>
          <xsl:sequence select="$TITLE"/>
          <xsl:text> version </xsl:text>
          <span title="git hash: {$VERHASH}">
            <xsl:sequence select="$VERSION"/>
          </span>
          <xsl:text> at </xsl:text>
          <xsl:sequence select="format-dateTime($now, '[H01]:[m01]')"/>
          <xsl:text> on </xsl:text>
          <xsl:sequence select="format-dateTime($now, '[D01] [MNn,*-3] [Y0001]')"/>
          <xsl:text>.</xsl:text>
        </p>
        <p>
          <xsl:text>Source: </xsl:text>
          <xsl:sequence select="@uri/string()"/>
        </p>
      </div>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="a:function">
  <xsl:variable name="used-by" as="element()*">
    <xsl:for-each select="key('fcalls', @id)">
      <xsl:sequence select="ancestor::*[parent::a:stylesheet][1]"/>
    </xsl:for-each>
  </xsl:variable>

  <!-- remove dups -->
  <xsl:variable name="used-by" select="$used-by union ()"/>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="fdefs" select="key('fnoarity', @noarity-id)"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="'instruction'"/>
    <xsl:sequence select="local-name(.)"/>
    <xsl:sequence select="if (empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <div id="{f:generate-id(.)}"
       class="{string-join($classes, ' ')}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:text>Function </xsl:text>
      <xsl:sequence select="substring-before(@name/string(), '#')"/>
      <xsl:if test="count($fdefs) gt 1">
        <xsl:sequence select="'#' || substring-after(@name/string(), '#')"/>
      </xsl:if>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="a:param">
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:text>$</xsl:text>
        <xsl:value-of select="@name/string()"/>
        <xsl:if test="@as">
          <xsl:text> as </xsl:text>
          <xsl:value-of select="@as/string()"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>)</xsl:text>

      <xsl:if test="@as">
        <xsl:sequence select="' as ' || @as"/>
      </xsl:if>

      <xsl:if test=". intersect $used-by">
        <xsl:text> </xsl:text>
        <span class="recursive" title="Recursive function">♻</span>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:function-calls">
        <xsl:with-param name="calls" select="$used-by/self::a:function except ."/>
      </xsl:call-template>
      <xsl:call-template name="t:template-calls"/>

      <div class="used-by">
        <xsl:choose>
          <xsl:when test="$used-by">
            <span class="marker"></span>
            <xsl:text>Used by: </xsl:text>
            <xsl:sequence select="f:reference-list($used-by)"/>
          </xsl:when>
          <xsl:otherwise>
            <span class="marker">☞</span>
            <span class="unused">Unused</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>

      <xsl:if test="$used-by-modules except parent::*">
        <div class="used-in">
          <span class="marker" title="Only used in one other module">
            <xsl:if test="$used-only-elsewhere">☝</xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:for-each select="$used-by-modules">
            <xsl:if test="position() gt 1">, </xsl:if>
            <a href="#{f:generate-id(.)}">
              <xsl:sequence select="@href/string()"/>
            </a>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<xsl:template match="a:variable">
  <xsl:variable name="this" select="."/>
  <xsl:variable name="id" select="@id/string()"/>

  <xsl:variable name="used-by" as="element()*">
    <xsl:for-each select="key('vrefs', @id)">
      <xsl:variable name="var" select="f:variable(., @ref)"/>
      <xsl:if test="exists($var) and $var is $this">
        <xsl:sequence select="ancestor::*[parent::a:stylesheet][1]"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- remove dups -->
  <xsl:variable name="used-by" select="$used-by union ()"/>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="shadows" select="f:variable(., @id/string())"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="'instruction'"/>
    <xsl:sequence select="@class/string()"/>
    <xsl:sequence select="if ($shadows) then 'shadows' else ()"/>
    <xsl:sequence select="if (empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <div id="{f:generate-id(.)}"
       class="{string-join($classes, ' ')}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:sequence
          select="if (@class = 'param') then 'Param ' else 'Variable '"/>
      <xsl:sequence select="'$'||@name/string()"/>
      <xsl:if test="@static = 'yes'">
        <xsl:text> [static]</xsl:text>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:if test="$shadows">
        <div class="shadows">
          <span class="marker">⚠</span>
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="f:variable(., @id/string())" mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:function-calls"/>
      <xsl:call-template name="t:template-calls"/>

      <div class="used-by">
        <xsl:choose>
          <xsl:when test="$used-by">
            <span class="marker"></span>
            <xsl:text>Used by: </xsl:text>
            <xsl:sequence select="f:reference-list($used-by)"/>
          </xsl:when>
          <xsl:otherwise>
            <span class="marker">☞</span>
            <span class="unused">Unused</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>

      <xsl:if test="$used-by-modules">
        <div class="used-in">
          <span class="marker" title="Only used in one other module">
            <xsl:if test="$used-only-elsewhere">☝</xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:for-each select="$used-by-modules">
            <xsl:if test="position() gt 1">, </xsl:if>
            <a href="#{f:generate-id(.)}">
              <xsl:sequence select="@href/string()"/>
            </a>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<xsl:template match="a:template">
  <xsl:variable name="this" select="."/>

  <xsl:variable name="used-by" as="element()*">
    <xsl:if test="@name">
      <xsl:for-each select="key('trefs', @id)">
        <xsl:variable name="t" select="f:template(., @ref/string())"/>
        <xsl:if test="exists($t) and $t is $this">
          <xsl:sequence select="$this"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <!-- remove dups -->
  <xsl:variable name="used-by" select="$used-by union ()"/>

  <xsl:variable name="used-by-modules"
                select="$used-by/parent::* union ()"/>

  <xsl:variable name="used-only-elsewhere"
                select="count($used-by-modules) = 1
                        and not(parent::* is $used-by-modules)"/>

  <xsl:variable name="shadows"
                select="if (@name) then f:template-shadows(., @id/string()) else ()"/>

  <xsl:variable name="classes" as="xs:string+">
    <xsl:sequence select="'instruction'"/>
    <xsl:sequence select="local-name(.)"/>
    <xsl:sequence select="if ($shadows) then 'shadows' else ()"/>
    <xsl:sequence select="if (@name and empty($used-by)) then 'unused' else ()"/>
    <xsl:sequence select="if ($used-only-elsewhere) then 'elsewhere' else ()"/>
  </xsl:variable>

  <div id="{f:generate-id(.)}"
       class="{string-join($classes, ' ')}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:text>Template </xsl:text>
      <xsl:choose>
        <xsl:when test="@name">
          <xsl:sequence select="@name/string()"/>
        </xsl:when>
        <xsl:when test="@match and string-length(@match) gt 30">
          <xsl:sequence select="'match ≅ ' || substring(@match, 1, 30) || '…'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'match ≅ ' || @match/string()"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="@as">
        <xsl:sequence select="' as ' || @as"/>
      </xsl:if>

      <xsl:if test=". intersect $used-by">
        <xsl:text> </xsl:text>
        <span class="recursive" title="Recursive template">♻</span>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:if test="$shadows">
        <div class="shadows">
          <span class="marker">⚠</span>
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="f:template-shadows(., @id/string())"
                               mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:function-calls"/>
      <xsl:call-template name="t:template-calls">
        <xsl:with-param name="calls" select="$used-by/self::a:template except ."/>
      </xsl:call-template>

      <xsl:if test="@name">
        <div class="used-by">
          <xsl:choose>
            <xsl:when test="$used-by">
              <span class="marker"></span>
              <xsl:text>Used by: </xsl:text>
              <xsl:sequence select="f:reference-list($used-by)"/>
            </xsl:when>
            <xsl:otherwise>
              <span class="marker">☞</span>
              <span class="unused">Unused</span>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:if>

      <xsl:if test="$used-by-modules">
        <div class="used-in">
          <span class="marker" title="Only used in one other module">
            <xsl:if test="$used-only-elsewhere">☝</xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:for-each select="$used-by-modules">
            <xsl:if test="position() gt 1">, </xsl:if>
            <a href="#{f:generate-id(.)}">
              <xsl:sequence select="@href/string()"/>
            </a>
          </xsl:for-each>
        </div>
      </xsl:if>

      <xsl:if test="@mode">
        <div class="mode">
          <xsl:text>Mode: </xsl:text>
          <code>
            <xsl:value-of select="@mode/string()"/>
          </code>
        </div>
      </xsl:if>

      <xsl:if test="@priority">
        <div class="priority">
          <xsl:text>Priority: </xsl:text>
          <code>
            <xsl:value-of select="@priority/string()"/>
          </code>
        </div>
      </xsl:if>

      <xsl:if test="@match">
        <div class="matches">
          <xsl:text>Matches: </xsl:text>
          <xsl:for-each select="tokenize(@match,'\|')">
            <xsl:if test="position() gt 1">, </xsl:if>
            <code>
              <xsl:value-of select="."/>
            </code>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:variables-referenced" as="element(a:variable)*">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="vars"
                select="$node//a:variable-ref ! key('vars', @ref)"/>

  <xsl:variable name="vars"
                select="$vars ! f:variable($node, @id)"/>

  <xsl:sequence select="$vars union ()"/> 
</xsl:function>

<xsl:template name="t:variables-referenced">
  <!-- I only care about references to "global" variables -->
  <xsl:variable name="vars"
                select="f:variables-referenced(.)[parent::a:stylesheet]"/>

  <xsl:if test="$vars">
    <div class="uses">
      <xsl:text>Uses: </xsl:text>
      <xsl:for-each select="$vars">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="." mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:function name="f:function-calls" as="element(a:function)*">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="funcs"
                select="$node//a:function-call ! key('functions', @ref)"/>

  <xsl:sequence select="$funcs union ()"/>
</xsl:function>

<xsl:template name="t:function-calls">
  <xsl:param name="calls" select="f:function-calls(.)"/>

  <xsl:if test="$calls">
    <div class="calls">
      <xsl:text>Calls: </xsl:text>
      <xsl:for-each select="$calls">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="." mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:function name="f:template-calls" as="element(a:template)*">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="temps"
                select="$node//a:call-template ! key('templates', @ref)"/>

  <xsl:sequence select="$temps union ()"/>
</xsl:function>

<xsl:template name="t:template-calls">
  <xsl:param name="calls" select="f:template-calls(.)"/>

  <xsl:if test="$calls">
    <div class="calls">
      <xsl:text>Calls: </xsl:text>
      <xsl:for-each select="$calls">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="." mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:reference-list">
  <xsl:param name="refs" as="element()+"/>

  <xsl:for-each select="$refs">
    <xsl:sort select="@name"/>
    <xsl:if test="position() gt 1">, </xsl:if>
    <xsl:apply-templates select="." mode="m:reference"/>
  </xsl:for-each>
</xsl:function>

<xsl:template match="*" mode="m:reference">
  <a href="#{f:generate-id(.)}" class="error">
    <xsl:text>???</xsl:text>
    <xsl:sequence select="local-name(.)"/>
  </a>
</xsl:template>

<xsl:template match="a:variable" mode="m:reference">
  <a href="#{f:generate-id(.)}">
    <xsl:sequence select="'$'||@name/string()"/>
  </a>
</xsl:template>

<xsl:template match="a:function" mode="m:reference">
  <xsl:variable name="fdefs"
                select="key('fnoarity', @noarity-id)"/>

  <a href="#{f:generate-id(.)}">
    <xsl:sequence select="substring-before(@name/string(), '#')"/>
    <xsl:if test="count($fdefs) gt 1">
      <xsl:sequence select="'#' || substring-after(@name/string(), '#')"/>
    </xsl:if>
    <xsl:text>()</xsl:text>
  </a>
</xsl:template>

<xsl:template match="a:template" mode="m:reference">
  <a href="#{f:generate-id(.)}">
    <xsl:choose>
      <xsl:when test="@name">
        <xsl:sequence select="@name/string()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>template</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="a:stylesheet" mode="m:toc">
  <xsl:if test="a:stylesheet">
    <ul>
      <xsl:for-each select="a:stylesheet">
        <li>
          <a href="#{f:generate-id(.)}">
            <xsl:sequence select="@href/string()"/>
          </a>
          <xsl:apply-templates select="." mode="m:toc"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:variable" as="element(a:variable)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:variable[@id=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:variable[@id=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:sequence select="($context/preceding::a:stylesheet/a:variable[@id=$ref])[last()]"/>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:variable($context/parent::*, $ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:template" as="element(a:template)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>
  <xsl:sequence select="fp:template($context, $ref, false())"/>
</xsl:function>

<xsl:function name="f:template-shadows" as="element(a:template)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>
  <xsl:sequence select="fp:template($context, $ref, true())"/>
</xsl:function>

<xsl:function name="fp:template" as="element(a:template)?">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="ref" as="xs:string"/>
  <xsl:param name="only-shadows" as="xs:boolean"/>

  <xsl:choose>
    <xsl:when test="$context/preceding-sibling::a:template[@id=$ref]">
      <xsl:sequence select="$context/preceding-sibling::a:template[@id=$ref][1]"/>
    </xsl:when>
    <xsl:when test="$context/self::a:stylesheet">
      <xsl:choose>
        <xsl:when test="$context/preceding::a:stylesheet/a:template[@id=$ref]">
          <xsl:sequence
              select="($context/preceding::a:stylesheet/a:template[@id=$ref])[last()]"/>
        </xsl:when>
        <xsl:when test="not($only-shadows)">
          <xsl:sequence
              select="(root($context)//a:stylesheet/a:template[@id=$ref])[last()]"/>
         </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:template($context/parent::*, $ref, $only-shadows)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->
<xsl:function name="f:line-link" as="element(h:span)?">
  <xsl:param name="node" as="element()"/>

  <span class="link">
    <xsl:if test="string($source-listings) = ('1','true','yes')
                  and $node/@a:line-number">
      <xsl:attribute name="title" select="'Line ' || $node/@a:line-number/string()"/>
      <a href="#line-{generate-id($node/ancestor::a:stylesheet[1])}-{$node/@a:line-number}"
         class="goto-lno">
        <xsl:text>§</xsl:text>
      </a>
    </xsl:if>
  </span>
</xsl:function>

<xsl:function name="f:notes">
  <xsl:param name="notes" as="element(h:span)*"/>
  <xsl:if test="$notes">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="$notes">
      <xsl:if test="position() gt 1">, </xsl:if>
      <xsl:sequence select="."/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:function>

<xsl:function name="f:generate-id" as="xs:string">
  <xsl:param name="ref" as="element()"/>

  <xsl:choose>
    <xsl:when test="$ref/self::a:stylesheet">
      <xsl:variable name="root" select="base-uri(root($ref)/*)"/>
      <!-- FIXME: this doesn't work
      <xsl:message select="$root"/>
      <xsl:message select="$ref/@uri/string()"/>
      -->
      <xsl:variable name="id"
                    select="if (starts-with($ref/@uri, $root))
                            then substring-after($ref/@uri, $root)
                            else replace($ref/@uri, '^.*?:/+', '')"/>
      <xsl:variable name="id" select="translate($id, './#}{', '___-')"/>
      <xsl:sequence select="substring(local-name($ref), 1, 1) || '-' || $id"/>
    </xsl:when>
    <xsl:when test="$ref/@id">
      <xsl:variable name="id" select="replace($ref/@id, '^.*?:/+', '')"/>
      <xsl:variable name="id" select="translate($id, './#}{', '___-')"/>
      <xsl:sequence select="substring(local-name($ref), 1, 1) || '-' || $id"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="generate-id($ref)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>

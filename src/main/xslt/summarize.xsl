<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:a="http://nwalsh.com/ns/xslt/analysis"
                xmlns:f="http://nwalsh.com/ns/xslt/functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://nwalsh.com/ns/xslt/modes"
                xmlns:t="http://nwalsh.com/ns/xslt/templates"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:summarize"
                exclude-result-prefixes="a f h m t xs"
                version="3.0">

<xsl:param name="css" select="'css/xsltexplorer.css'"/>
<xsl:param name="js" select="'js/xsltexplorer.js'"/>
<xsl:param name="title"
           select="'XSLT Explorer: ' || tokenize(base-uri(/*), '/')[last()]"/>

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
      <link href="https://fonts.googleapis.com/css?family=B612+Mono" rel="stylesheet" />
      <link href="https://fonts.googleapis.com/css?family=Noto+Sans" rel="stylesheet" />
      <link href="https://fonts.googleapis.com/css?family=Noto+Serif" rel="stylesheet" />
      <link rel="stylesheet" href="{$css}"/>
      <link rel="schema.dc" href="http://purl.org/dc/elements/1.1/"/>
      <meta name="dc.modified"
            content="{format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), $Z),
                                      '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')}"/>
      <meta name="generator" content="{$TITLE} {$VERSION} / {$VERHASH}"/>
      <script src="https://kit.fontawesome.com/27862f3f23.js" crossorigin="anonymous"/>
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

  <div class="{local-name(.)}" id="{f:generate-id(.)}">
    <xsl:variable name="depth" select="count(ancestor::a:stylesheet)+1"/>
    <xsl:element name="h{min(($depth,4))}"
                 namespace="http://www.w3.org/1999/xhtml">
      <xsl:if test="parent::a:stylesheet">
        <xsl:attribute name="class" select="'module-title closed'"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="empty(parent::*)">
          <xsl:sequence select="$title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="tokenize(resolve-uri(@href, base-uri(/*)), '/')[last()]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:if test="not(parent::*)">
      <xsl:variable name="now" select="adjust-dateTime-to-timezone(current-dateTime(), $Z)"/>
      <p>
        <xsl:text>Created at </xsl:text>
        <xsl:sequence select="format-dateTime($now, '[H01]:[m01]')"/>
        <xsl:text> on </xsl:text>
        <xsl:sequence select="format-dateTime($now, '[D01] [MNn,*-3] [Y0001]')"/>
        <xsl:text>.</xsl:text>
      </p>
    </xsl:if>

    <xsl:variable name="imports"
                  select="if (parent::*)
                          then ./a:stylesheet
                          else .//a:stylesheet"/>
    <xsl:variable name="vars"
                  select="descendant-or-self::a:stylesheet/a:variable[@class='variable']"/>
    <xsl:variable name="params"
                  select="descendant-or-self::a:stylesheet/a:variable[@class='param']"/>
    <xsl:variable name="templates"
                  select="descendant-or-self::a:stylesheet/a:template"/>
    <xsl:variable name="functions"
                  select="descendant-or-self::a:stylesheet/a:function"/>

    <xsl:variable name="unused-variables" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:if test="empty(key('vrefs', @id, root($stylesheet)))">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="shadow-variables" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:if test="f:variable(., @id/string())">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="variables-only-used-elsewhere" as="element(a:variable)*">
      <xsl:for-each select="a:variable">
        <xsl:variable name="usedby"
                      select="key('vrefs', @id, root($stylesheet))"/>
        <xsl:variable name="usedin"
                      select="f:used-in(., $usedby)"/>
        <xsl:if test="count($usedin) = 1 and exists($usedin except parent::*)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="var-notes" as="element(h:span)*">
      <xsl:if test="$unused-variables[@class = 'variable']">
        <span class="unused-variables unused">
          <xsl:sequence select="count($unused-variables[@class = 'variable']),
                                'unused'"/>
        </span>
      </xsl:if>
      <xsl:if test="$shadow-variables[@class = 'variable']">
        <span class="shadow-variables shadow">
          <xsl:sequence select="count($shadow-variables[@class = 'variable']),
                                'shadowing'"/>
        </span>
      </xsl:if>
      <xsl:if test="$variables-only-used-elsewhere[@class = 'variable']">
        <span class="onlyused-variables onlyused">
          <xsl:sequence
              select="count($variables-only-used-elsewhere[@class = 'variable']),
                     'used in only one other module'"/>
        </span>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="unused-templates" as="element(a:template)*">
      <xsl:for-each select="a:template[@name]">
        <xsl:if test="empty(key('trefs', @id, root($stylesheet)))">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="unused-functions" as="element(a:function)*">
      <xsl:for-each select="a:function">
        <xsl:if test="empty(key('fcalls', @id, root($stylesheet)))">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="functions-only-used-elsewhere" as="element(a:function)*">
      <xsl:for-each select="a:function">
        <xsl:variable name="callers"
                      select="key('fcalls', @id, root($stylesheet))"/>
        <xsl:variable name="usedin"
                      select="f:used-in(., $callers)"/>
        <xsl:if test="count($usedin) = 1 and exists($usedin except parent::*)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>


    <xsl:variable name="summary" as="element()*">
      <xsl:if test="$imports">
        <span a-type="stylesheet">
          <xsl:sequence select="count($imports), 'imports'"/>
        </span>
      </xsl:if>
      <xsl:if test="$templates">
        <span a-type="template">
          <xsl:sequence select="count($templates), 'templates'"/>
          <xsl:if test="$unused-templates">
            <xsl:text> (</xsl:text>
            <span class="unused-templates unused">
              <xsl:sequence select="count($unused-templates), 'unused'"/>
            </span>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="$functions">
        <span a-type="function">
          <xsl:sequence select="count($functions), 'functions'"/>
          <xsl:if test="$unused-functions or $functions-only-used-elsewhere">
            <xsl:text> (</xsl:text>
            <xsl:if test="$unused-functions">
              <span class="unused-functions unused">
                <xsl:sequence select="count($unused-functions), 'unused'"/>
              </span>
            </xsl:if>
            <xsl:if test="$functions-only-used-elsewhere">
              <xsl:if test="$unused-functions">, </xsl:if>
              <span class="onlyused-functions onlyused">
                <xsl:sequence select="count($functions-only-used-elsewhere), 'used in only one other module'"/>
              </span>
            </xsl:if>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="$vars">
        <span a-type="variable">
          <xsl:sequence select="count($vars), 'variables'"/>
          <xsl:if test="$var-notes">
            <xsl:text> (</xsl:text>
            <xsl:for-each select="$var-notes">
              <xsl:if test="position() gt 1">, </xsl:if>
              <xsl:sequence select="."/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="$params">
        <span a-type="param">
          <xsl:sequence select="count($params), 'parameters'"/>
          <xsl:if test="$unused-variables[@class = 'param']
                        or $shadow-variables[@class = 'param']">
            <xsl:text> (</xsl:text>
            <xsl:if test="$unused-variables[@class = 'param']">
              <span class="unused-params unused">
                <xsl:sequence select="count($unused-variables[@class = 'param']),
                                      'unused'"/>
              </span>
            </xsl:if>
            <xsl:if test="$shadow-variables[@class = 'param']">
              <xsl:if test="$unused-variables[@class = 'param']">, </xsl:if>
              <span class="shadow-params shadow">
                <xsl:sequence select="count($shadow-variables[@class = 'param']),
                                      'shadowing'"/>
              </span>
            </xsl:if>
            <xsl:text>)</xsl:text>
          </xsl:if>
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
        <span class="closed">Table of Contents</span>
        <xsl:apply-templates select="." mode="m:toc"/>
      </div>
    </xsl:if>

    <xsl:apply-templates select="a:stylesheet"/>

    <div class="instructions{if (parent::*) then () else ' forceshow'}">
      <xsl:apply-templates select="a:* except a:stylesheet"/>
    </div>
  </div>
</xsl:template>

<xsl:template match="a:function">
  <xsl:variable name="fdefs"
                select="key('fnoarity', @noarity-id)"/>

  <xsl:variable name="calls" select="f:calls-functions(.)"/>

  <xsl:variable name="callers" as="element()*"
                select="key('fcalls', @id)/ancestor::*[parent::a:stylesheet][1]"/>
  <xsl:variable name="caller-ids" select="($callers except .) ! f:generate-id(.)"/>

  <xsl:variable name="usedin" select="f:used-in(., $callers)"/>
  <xsl:variable name="onlyin"
                select="count($usedin) = 1 and exists($usedin except parent::*)"/>

  <div class="{local-name(.)}{
              if (empty($callers)) then ' not-used' else ()
              }{
              if ($onlyin) then ' only-used' else ()
              }"
       id="{f:generate-id(.)}">
    <div class="title">
      <xsl:text>Function </xsl:text>
      <xsl:sequence select="substring-before(@name/string(), '#')"/>
      <xsl:if test="count($fdefs) gt 1">
        <sup><xsl:sequence select="substring-after(@name/string(), '#')"/></sup>
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

      <xsl:if test="$calls = .">
        <xsl:text> </xsl:text>
        <span class="recursive" title="Recursive function">
          <i class="fa fa-sync"/>
        </span>
      </xsl:if>
    </div>

    <div class="body">
      <xsl:call-template name="t:uses"/>
      <xsl:call-template name="t:calls-functions">
        <xsl:with-param name="calls" select="$calls except ."/>
      </xsl:call-template>
      <xsl:call-template name="t:calls-templates"/>

      <xsl:choose>
        <xsl:when test="$callers">
          <xsl:text>Used by: </xsl:text>
          <xsl:for-each select="distinct-values($caller-ids)">
            <xsl:variable name="id" select="."/>
            <xsl:if test="position() gt 1">, </xsl:if>
            <xsl:apply-templates
                select="$callers[f:generate-id(.) = $id][1]" mode="m:reference"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <div class="usedby unused">
            <xsl:text>Unused</xsl:text>
          </div>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$usedin except parent::*">
        <div class="usedin{if ($onlyin) then ' onlyused' else ()}">
          <xsl:text>Used in: </xsl:text>
          <xsl:for-each select="$usedin except parent::*">
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
  <xsl:variable name="id" select="@id/string()"/>

  <xsl:variable name="this" select="."/>
  <xsl:variable name="usedby" as="element()*">
    <xsl:for-each select="key('vrefs', @id)">
      <xsl:variable name="var" select="f:variable(., @ref)"/>
      <xsl:if test="exists($var) and $var is $this">
        <xsl:sequence select="ancestor::*[parent::a:stylesheet][1]"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="usedby-ids" select="$usedby ! f:generate-id(.)"/>

  <xsl:variable name="usedby" as="element()*">
    <xsl:for-each select="distinct-values($usedby-ids)">
      <xsl:variable name="id" select="."/>
      <xsl:sequence select="$usedby[f:generate-id(.) = $id][1]"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="usedin" select="f:used-in(., $usedby)"/>
  <xsl:variable name="onlyin"
                select="count($usedin) = 1 and exists($usedin except parent::*)"/>

  <div class="{if (@class) then @class/string() else local-name(.)
              } {if (empty($usedby)) then 'not-used' else ()
              } {if (f:variable(., @id/string())) then 'shadow' else ()
              } {if ($onlyin) then 'only-used' else ()}"
       id="{f:generate-id(.)}">
    <div class="title">
      <xsl:sequence select="if (@class = 'param')
                            then 'Param '
                            else 'Variable '"/>
      <xsl:sequence select="'$'||@name/string()"/>
      <xsl:if test="@static = 'yes'">
        <xsl:text> [static]</xsl:text>
      </xsl:if>
    </div>

    <div class="body">
      <xsl:if test="f:variable(., @id/string())">
        <div class="shadows">
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="f:variable(., @id/string())" mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:uses"/>
      <xsl:call-template name="t:calls-functions"/>
      <xsl:call-template name="t:calls-templates"/>

      <xsl:choose>
        <xsl:when test="$usedby">
          <div class="usedby">
            <xsl:text>Used by: </xsl:text>
            <xsl:for-each select="$usedby">
              <xsl:if test="position() gt 1">, </xsl:if>
              <xsl:apply-templates select="." mode="m:reference"/>
            </xsl:for-each>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="usedby unused">
            <xsl:text>Unused</xsl:text>
          </div>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:variable name="usedin" select="f:used-in(., $usedby)"/>
      <xsl:if test="$usedin">
        <div class="usedin">
          <xsl:text>Used in: </xsl:text>
          <xsl:for-each select="$usedin">
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
  <xsl:variable name="refs" select="if (@name) then key('trefs', @id) else ()"/>
  <xsl:variable name="callers"
                select="$refs/ancestor::*[parent::a:stylesheet][1]"/>
  <xsl:variable name="caller-ids"
                select="distinct-values($callers ! generate-id(.))"/>

  <div class="{local-name(.)}{
              if (@name and empty($caller-ids)) then ' not-used' else ()}"
       id="{f:generate-id(.)}">
    <div class="title">
      <xsl:text>Template </xsl:text>
      <xsl:sequence select="@name/string()"/>
    </div>

    <div class="body">
      <xsl:call-template name="t:uses"/>
      <xsl:call-template name="t:calls-functions"/>
      <xsl:call-template name="t:calls-templates"/>

      <xsl:if test="@name">
        <xsl:choose>
          <xsl:when test="exists($caller-ids)">
            <xsl:text>Used by: </xsl:text>
            <xsl:for-each select="$caller-ids">
              <xsl:variable name="id" select="."/>
              <xsl:variable name="caller" select="($callers[generate-id(.) = $id])[1]"/>
              <xsl:if test="position() gt 1">, </xsl:if>
              <xsl:apply-templates select="$caller" mode="m:reference"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <div class="usedby unused">
              <xsl:text>Unused</xsl:text>
            </div>
          </xsl:otherwise>
        </xsl:choose>
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

<xsl:function name="f:uses" as="element(a:variable-ref)*">
  <xsl:param name="node" as="element()"/>

  <xsl:for-each select="$node//a:variable-ref">
    <xsl:sequence select="if (key('vars', @ref))
                          then .
                          else ()"/>
  </xsl:for-each>
</xsl:function>

<xsl:template name="t:uses">
  <xsl:variable name="uses" select="f:uses(.)"/>
  <xsl:variable name="vars" as="element(a:variable)*">
    <xsl:for-each select="$uses">
      <xsl:variable name="var" select="f:variable(., @ref)"/>
      <xsl:if test="$var/parent::a:stylesheet">
        <xsl:sequence select="$var"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="$vars">
    <div class="uses">
      <xsl:text>Uses: </xsl:text>
      <xsl:for-each select="$vars">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <a href="#{f:generate-id(.)}">
          <xsl:sequence select="'$'||@name/string()"/>
        </a>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:function name="f:calls-functions" as="element(a:function)*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="$node//a:function-call ! key('functions', @ref)"/>
</xsl:function>

<xsl:template name="t:calls-functions">
  <xsl:param name="calls" select="f:calls-functions(.)"/>

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

<xsl:function name="f:calls-templates" as="element(a:call-template)*">
  <xsl:param name="node" as="element()"/>
  <xsl:variable name="calls" select="$node//a:call-template"/>
  <xsl:for-each select="distinct-values($calls/@ref/string())">
    <xsl:variable name="id" select="."/>
    <xsl:sequence select="$calls[@ref = $id][1]"/>
  </xsl:for-each>
</xsl:function>

<xsl:template name="t:calls-templates">
  <xsl:variable name="calls" select="f:calls-templates(.)"/>

  <xsl:if test="$calls">
    <div class="calls">
      <xsl:text>Calls: </xsl:text>
      <xsl:for-each select="$calls">
        <xsl:sort select="@name"/>
        <xsl:variable name="def" select="key('templates', @ref)"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="$def[1]" mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

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
      <sup><xsl:sequence select="substring-after(@name/string(), '#')"/></sup>
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

<xsl:function name="f:variable" as="element()?">
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

<xsl:function name="f:used-in" as="element()*">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="nodes" as="element()*"/>

  <xsl:variable name="context"
                select="$context/ancestor::a:stylesheet[1]"/>

<!--
  <xsl:variable name="stylesheets" as="element(a:stylesheet)*">
    <xsl:for-each select="$nodes">
      <xsl:variable name="ss" select="ancestor::a:stylesheet[1]"/>
      <xsl:if test="not($ss is $context)">
        <xsl:sequence select="$ss"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
-->

  <xsl:variable name="stylesheets" as="element(a:stylesheet)*"
                select="$nodes/ancestor::a:stylesheet[1]"/>

  <xsl:for-each select="distinct-values($stylesheets ! generate-id(.))">
    <xsl:variable name="id" select="."/>
    <xsl:sequence select="($stylesheets[generate-id(.) = $id])[1]"/>
  </xsl:for-each>
</xsl:function>

<!-- ============================================================ -->

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

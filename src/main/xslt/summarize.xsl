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
<xsl:param name="prismcss" select="'css/prism.css'"/>
<xsl:param name="prismjs" select="'js/prism.js'"/>

<xsl:param name="title" select="()"/>

<xsl:variable name="Z" select="xs:dayTimeDuration('PT0H')"/>

<xsl:template match="a:summary">
  <html>
    <head>
      <title>
        <xsl:sequence select="if (exists($title))
                              then $title
                              else $TITLE
                                   || ': '
                                   || tokenize(base-uri(/*), '/')[last()]"/>
      </title>
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <link rel="shortcut icon" href="https://xslt.xmlexplorer.com/img/icon64.png"
            type="image/png" />
      <link rel="stylesheet" href="{$prismcss}"/>
      <link rel="stylesheet" href="{$css}"/>
      <link rel="schema.dc" href="http://purl.org/dc/elements/1.1/"/>
      <meta name="dc.modified"
            content="{format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), $Z),
                                      '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')}"/>
      <meta name="generator" content="{$TITLE} {$VERSION} / {$VERHASH}"/>
      <script src="{$prismjs}"></script>
    </head>
    <body>
      <main>
        <h1>
          <a href="https://xslt.xmlexplorer.com/">
            <img class="logo" src="https://xslt.xmlexplorer.com/img/logo256.png"/>
          </a>
          <xsl:sequence select="if (exists($title))
                                then $title
                                else $TITLE
                                     || ': '
                                     || tokenize(base-uri(/*), '/')[last()]"/>
        </h1>

        <xsl:variable name="details" as="element(h:span)*">
          <xsl:sequence select="@imports ! f:summary-count(./string(), 'import')"/>
          <xsl:sequence select="@includes ! f:summary-count(./string(), 'include')"/>
          <xsl:sequence select="@templates ! f:summary-count(./string(), 'template')"/>
          <xsl:sequence select="@functions ! f:summary-count(./string(), 'function')"/>
          <xsl:sequence select="@variables ! f:summary-count(./string(), 'variable')"/>
          <xsl:sequence select="@params ! f:summary-count(./string(), 'param')"/>
          <xsl:sequence select="@fixmes ! f:summary-count(./string(), 'FIXME: comment')"/>
        </xsl:variable>

        <xsl:if test="$details">
          <p>
            <xsl:for-each select="$details">
              <xsl:if test="position() gt 1">, </xsl:if>
              <!-- strip off the spans so they aren't visible to CSS/JS -->
              <xsl:sequence select="node()"/>
            </xsl:for-each>
          </p>
        </xsl:if>

        <xsl:if test="a:stylesheet/a:stylesheet">
          <div class="toc">
            <span class="closed">List of Imports</span>
            <xsl:apply-templates select="a:stylesheet" mode="m:toc"/>
          </div>
        </xsl:if>

        <xsl:variable name="list" select="//a:stylesheet/a:template[@name]"/>
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

        <xsl:variable name="list" select="//a:stylesheet/a:function"/>
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

        <xsl:apply-templates/>
      </main>
      <footer>
        <xsl:variable name="now" select="adjust-dateTime-to-timezone(current-dateTime(), $Z)"/>
        <p>
          <xsl:text>Generated by </xsl:text>
          <a href="https://xslt.xmlexplorer.com/">
            <xsl:sequence select="$TITLE"/>
          </a>
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
          <xsl:sequence select="@xml:base/string()"/>
        </p>
      </footer>
    </body>
    <script src="{$js}"/>
  </html>
</xsl:template>

<xsl:template match="a:stylesheet">
  <xsl:variable name="stylesheet" select="."/>

  <xsl:variable name="hsize" select="min((count(ancestor::a:stylesheet)+1,4))"/>

  <div class="{local-name(.)}" id="{@id}">
    <xsl:element name="h{$hsize}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:value-of select="tokenize(@xml:base, '/')[last()]"/>
      <xsl:message select="'Summarizing', @href/string(), '…'"/>
    </xsl:element>

    <xsl:variable name="summary" as="element(h:span)*">
      <xsl:sequence select="f:summary-count(@imports, 'import')"/>
      <xsl:sequence select="f:summary-count(@includes, 'include')"/>
    </xsl:variable>

    <xsl:if test="exists($summary)">
      <p>
        <xsl:for-each select="$summary">
          <xsl:if test="position() gt 1">, </xsl:if>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </p>
    </xsl:if>

    <xsl:apply-templates select="a:stylesheet"/>

    <xsl:variable name="summary" as="element(h:span)*">
      <xsl:if test="@templates ne '0'">
        <span>
          <xsl:sequence select="f:summary-count(@templates, 'template')"/>
          <xsl:sequence select="f:summary-details(a:templates)"/>
        </span>
      </xsl:if>          
      <xsl:if test="@functions ne '0'">
        <span>
          <xsl:sequence select="f:summary-count(@functions, 'function')"/>
          <xsl:sequence select="f:summary-details(a:functions)"/>
        </span>
      </xsl:if>          
      <xsl:if test="@variables ne '0'">
        <span>
          <xsl:sequence select="f:summary-count(@variables, 'variable')"/>
          <xsl:sequence select="f:summary-details(a:variables)"/>
        </span>
      </xsl:if>          
      <xsl:if test="@params ne '0'">
        <span>
          <xsl:sequence select="f:summary-count(@params, 'param')"/>
          <xsl:sequence select="f:summary-details(a:params)"/>
        </span>
      </xsl:if>          
      <xsl:if test="@fixmes ne '0'">
        <span>
          <xsl:sequence select="f:summary-count(@fixmes, 'FIXME: comment')"/>
          <xsl:sequence select="f:summary-details(a:comments)"/>
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

    <div class="instructions">
      <div class="title closed">Instructions</div>
      <div class="body">
        <xsl:apply-templates select="a:* except (a:stylesheet|a:variables|a:functions
                                                 |a:templates|a:params
                                                 |a:comments|a:comment)"/>
      </div>
    </div>

    <xsl:if test=".//a:comment except .//a:stylesheet//a:comment">
      <div class="instructions">
        <div class="title closed">FIXME: comments</div>
        <div class="body">
          <xsl:apply-templates select=".//a:comment except .//a:stylesheet//a:comment"/>
        </div>
      </div>
    </xsl:if>

    <xsl:if test="string($source-listings) = ('1','true','yes')">
      <div class="source-code">
        <div class="title closed">Source code</div>
        <div class="body">
          <div>
            <xsl:try>
              <xsl:variable name="code" select="unparsed-text(@xml:base)"/>
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
                <xsl:message select="'Failed to load source:', @xml:base"/>
                <xsl:sequence select="()"/>
              </xsl:catch>
            </xsl:try>
          </div>
        </div>
      </div>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="a:function">
  <div id="{@id}"
       class="instruction {@class}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:text>Function </xsl:text>
      <xsl:choose>
        <xsl:when test="count(a:no-arity) gt 1">
          <xsl:sequence select="@display-name/string()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="substring-before(@display-name/string(), '#')"/>
        </xsl:otherwise>
      </xsl:choose>
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

      <xsl:if test="@recursive = 'true'">
        <xsl:text> </xsl:text>
        <span class="recursive" title="Recursive function">♻</span>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:if test="a:shadow">
        <div class="shadows">
          <span class="marker">⚠</span>
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="key('id', a:shadow)" mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:functions-called"/>
      <xsl:call-template name="t:templates-called"/>

      <div class="used-by">
        <xsl:choose>
          <xsl:when test="a:used-by">
            <span class="marker">
              <xsl:if test="count(a:used-by) = 1 and a:used-by/string() = @id/string()">
                <span class="marker">☞</span>
              </xsl:if>
            </span>
            <xsl:text>Used by: </xsl:text>
            <xsl:sequence select="f:reference-list(a:used-by)"/>
          </xsl:when>
          <xsl:otherwise>
            <span class="marker">☞</span>
            <span class="unused">Unused</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>

      <xsl:if test="a:used-by-module">
        <div class="used-in">
          <span class="marker">
            <xsl:if test="@elsewhere = 'true'">
              <xsl:attribute name="title" select="'Only used in one other module'"/>
              <xsl:text>☝</xsl:text>
            </xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:sequence select="f:reference-list(a:used-by-module)"/>
        </div>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<xsl:template match="a:variable">
  <div id="{@id}"
       class="instruction {@class}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:sequence
          select="if (@type = 'param') then 'Param ' else 'Variable '"/>
      <code>
        <xsl:sequence select="'$'||@display-name/string()"/>
      </code>
      <xsl:if test="@as">
        <xsl:text> as </xsl:text>
        <code>
          <xsl:sequence select="@as/string()"/>
        </code>
      </xsl:if>
      <xsl:if test="@static = 'yes'">
        <xsl:text> [static]</xsl:text>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:if test="a:shadow">
        <div class="shadows">
          <span class="marker">⚠</span>
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="key('id', a:shadow)" mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:functions-called"/>
      <xsl:call-template name="t:templates-called"/>

      <div class="used-by">
        <xsl:choose>
          <xsl:when test="a:used-by">
            <span class="marker"></span>
            <xsl:text>Used by: </xsl:text>
            <xsl:sequence select="f:reference-list(a:used-by)"/>
          </xsl:when>
          <xsl:otherwise>
            <span class="marker">☞</span>
            <span class="unused">Unused</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>

      <xsl:if test="a:used-by-module">
        <div class="used-in">
          <span class="marker">
            <xsl:if test="@elsewhere = 'true'">
              <xsl:attribute name="title" select="'Only used in one other module'"/>
              <xsl:text>☝</xsl:text>
            </xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:sequence select="f:reference-list(a:used-by-module)"/>
        </div>
      </xsl:if>
    </div>
  </div>
</xsl:template>

<xsl:template match="a:template">
  <div id="{@id}"
       class="instruction {@class}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:text>Template</xsl:text>

      <xsl:if test="@name">
        <xsl:sequence select="' ' || @display-name/string()"/>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="@match and string-length(@match) gt 30">
          <xsl:sequence select="' match ≅ ' || substring(@match, 1, 30) || '…'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="' match ≅ ' || @match/string()"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="@as">
        <xsl:sequence select="' as ' || @as"/>
      </xsl:if>

      <xsl:if test="@recursive = 'true'">
        <xsl:text> </xsl:text>
        <span class="recursive" title="Recursive template">♻</span>
      </xsl:if>
    </div>

    <div class="props">
      <xsl:if test="a:shadow">
        <div class="shadows">
          <span class="marker">⚠</span>
          <xsl:text>Shadows: </xsl:text>
          <xsl:apply-templates select="key('id', a:shadow)" mode="m:reference"/>
        </div>
      </xsl:if>

      <xsl:call-template name="t:variables-referenced"/>
      <xsl:call-template name="t:functions-called"/>
      <xsl:call-template name="t:templates-called"/>

      <xsl:if test="@name">
        <div class="used-by">
          <xsl:choose>
            <xsl:when test="a:used-by">
              <span class="marker">
                <xsl:if test="count(a:used-by) = 1 and a:used-by/string() = @id/string()">
                  <span class="marker">☞</span>
                </xsl:if>
              </span>
              <xsl:text>Used by: </xsl:text>
              <xsl:sequence select="f:reference-list(a:used-by)"/>
            </xsl:when>
            <xsl:otherwise>
              <span class="marker">☞</span>
              <span class="unused">
                <xsl:text>Unused</xsl:text>
                <xsl:if test="@match">
                  <xsl:text> (by name)</xsl:text>
                </xsl:if>
              </span>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:if>

      <xsl:if test="a:used-by-module">
        <div class="used-in">
          <span class="marker">
            <xsl:if test="@elsewhere = 'true'">
              <xsl:attribute name="title" select="'Only used in one other module'"/>
              <xsl:text>☝</xsl:text>
            </xsl:if>
          </span>
          <xsl:text>Used in: </xsl:text>
          <xsl:sequence select="f:reference-list(a:used-by-module)"/>
        </div>
      </xsl:if>

      <xsl:if test="@mode">
        <div class="mode">
          <xsl:text>Mode: </xsl:text>
          <code>
            <xsl:value-of select="@display-mode/string()"/>
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

<xsl:template match="a:comment">
  <div id="{@id}"
       class="instruction {@class}">
    <div class="title">
      <xsl:sequence select="f:line-link(.)"/>
      <xsl:text>Comment</xsl:text>
    </div>

    <div class="props">
      <xsl:sequence select="string(.)"/>
    </div>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:variables-referenced">
  <xsl:if test="a:variable">
    <div class="uses">
      <xsl:text>Uses: </xsl:text>
      <xsl:for-each select="a:variable ! key('id', .)">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="." mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template name="t:functions-called">
  <xsl:if test="a:function">
    <div class="calls">
      <xsl:text>Calls: </xsl:text>
      <xsl:for-each select="a:function ! key('id', .)">
        <xsl:sort select="@name"/>
        <xsl:if test="position() gt 1">, </xsl:if>
        <xsl:apply-templates select="." mode="m:reference"/>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template name="t:templates-called">
  <xsl:if test="a:template">
    <div class="calls">
      <xsl:text>Calls: </xsl:text>
      <xsl:for-each select="a:template ! key('id', .)">
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

  <xsl:for-each select="$refs ! key('id', .)">
    <xsl:sort select="@name"/>
    <xsl:if test="position() gt 1">, </xsl:if>
    <xsl:apply-templates select="." mode="m:reference"/>
  </xsl:for-each>
</xsl:function>

<xsl:template match="*" mode="m:reference">
  <a href="#{@id}" class="error">
    <xsl:text>???</xsl:text>
    <xsl:sequence select="local-name(.)"/>
  </a>
</xsl:template>

<xsl:template match="a:stylesheet" mode="m:reference">
  <a href="#{@id}">
    <xsl:sequence select="if (@href)
                          then string(@href)
                          else '«root»'"/>
  </a>
</xsl:template>

<xsl:template match="a:variable" mode="m:reference">
  <a href="#{@id}">
    <xsl:sequence select="'$'||@display-name/string()"/>
  </a>
</xsl:template>

<xsl:template match="a:function" mode="m:reference">
  <xsl:variable name="fdefs"
                select="key('fnoarity', @noarity-id)"/>

  <a href="#{@id}">
    <xsl:choose>
      <xsl:when test="count($fdefs) gt 1">
        <xsl:sequence select="@display-name/string()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="substring-before(@display-name/string(), '#')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>()</xsl:text>
  </a>
</xsl:template>

<xsl:template match="a:template" mode="m:reference">
  <a href="#{@id}">
    <xsl:choose>
      <xsl:when test="@name">
        <xsl:sequence select="@display-name/string()"/>
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
          <a href="#{@id}">
            <xsl:sequence select="@href/string()"/>
          </a>
          <xsl:apply-templates select="." mode="m:toc"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->
<xsl:function name="f:line-link" as="element(h:span)?">
  <xsl:param name="node" as="element()"/>

  <span class="link">
    <xsl:if test="string($source-listings) = ('1','true','yes')
                  and $node/@line-number">
      <xsl:attribute name="title" select="'Line ' || $node/@line-number/string()"/>
      <a href="#line-{generate-id($node/ancestor::a:stylesheet[1])}-{$node/@line-number}"
         class="goto-lno">
        <xsl:text>§</xsl:text>
      </a>
    </xsl:if>
  </span>
</xsl:function>

<xsl:function name="f:summary-count" as="element(h:span)?">
  <xsl:param name="count" as="xs:string"/>
  <xsl:param name="label" as="xs:string"/>

  <xsl:if test="$count ne '0'">
    <span class="{$label} all">
      <xsl:choose>
        <xsl:when test="$count = '1'">
          <xsl:sequence select="$count || ' ' || $label"/>
        </xsl:when>
        <xsl:when test="not($count castable as xs:integer)">
          <xsl:sequence select="$count || ' ' || $label"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$count || ' ' || $label || 's'"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:if>
</xsl:function>

<xsl:function name="f:summary-details">
  <xsl:param name="detail" as="element()"/>

  <!-- hack -->
  <xsl:variable name="class" select="local-name($detail)"/>
  <xsl:variable name="class" select="substring($class, 1, string-length($class) - 1)"/>

  <xsl:variable name="detail" as="element(h:span)*">
    <xsl:if test="$detail/a:unused">
      <span class="{$class} unused">
        <xsl:sequence select="count($detail/a:unused) || ' unused'"/>
      </span>
    </xsl:if>
    <xsl:if test="$detail/a:shadows">
      <span class="{$class} shadows">
        <xsl:sequence select="count($detail/a:shadows) || ' shadow'"/>
      </span>
    </xsl:if>
    <xsl:if test="$detail/a:elsewhere">
      <span class="{$class} elsewhere">
        <xsl:sequence select="count($detail/a:elsewhere) || ' used only in one other module'"/>
      </span>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="exists($detail)">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="$detail">
      <xsl:if test="position() gt 1">, </xsl:if>
      <xsl:sequence select="."/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>

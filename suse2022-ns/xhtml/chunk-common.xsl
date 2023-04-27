<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Create structure of chunked contents

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, 2013, Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t d">

  <xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/chunk-common.xsl"/>


  <xsl:template
    match="d:appendix|d:article|d:book|d:bibliography|d:chapter|d:part|d:preface|d:glossary|d:sect1|d:section|d:set|d:refentry|d:index"
    mode="breadcrumbs">
    <xsl:param name="class" select="''"/>

    <xsl:variable name="title.candidate">
      <xsl:apply-templates select="." mode="titleabbrev.markup"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$title.candidate != ''">
          <xsl:value-of select="$title.candidate"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name(.)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a class="crumb">
      <xsl:choose>
        <xsl:when test="$class='book-link'">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($root.filename, $html.ext)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="."/>
              <xsl:with-param name="context" select="."/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="string($title)"/>
    </a>
  </xsl:template>


  <xsl:template name="breadcrumbs.navigation">
    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
        <div class="growth-inhibitor">
          <xsl:call-template name="generate.breadcrumbs.back"/>
          <xsl:for-each select="ancestor-or-self::*">
            <xsl:choose>
              <xsl:when test="$rootid != '' and descendant::*[@xml:id = string($rootid)]"/>
              <xsl:when test="not(ancestor::*) or @xml:id = string($rootid)">
                <xsl:apply-templates select="." mode="breadcrumbs">
                  <xsl:with-param name="class">book-link</xsl:with-param>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
                <xsl:apply-templates select="." mode="breadcrumbs"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </div>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="bottom.navigation">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:param name="nav.context"/>
    <xsl:variable name="needs.navig">
      <xsl:call-template name="is.node.in.navig">
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="prev" select="$prev"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isnext">
      <xsl:call-template name="is.next.node.in.navig">
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isprev">
      <xsl:call-template name="is.prev.node.in.navig">
        <xsl:with-param name="prev" select="$prev"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
     We use two node sets and calculate the set difference
     with the following, general XPath expression:

      setdiff = $node-set1[count(.|$node-set2) != count($node-set2)]

     $node-set1 contains the ancestors of all nodes, starting with the
     current node (but the current node is NOT included in the set)

     $node-set2 contains the ancestors of all nodes starting from the
     node which points to the $rootid parameter

     For example:
     node-set1: {/, set, book, chapter}
     node-set2: {/, set, }
     setdiff:   {        book, chapter}
  -->
    <xsl:variable name="ancestorrootnode"
      select="key('id', $rootid)/ancestor::*"/>
    <xsl:variable name="setdiff"
      select="ancestor::*[count(. | $ancestorrootnode)
                                != count($ancestorrootnode)]"/>
    <xsl:if test="$generate.bottom.navigation != 0 and $needs.navig = 'true' and not(self::d:set)">
      <nav class="bottom-pagination">
        <div>
          <xsl:if test="count($prev) > 0 and $isprev = 'true'">
            <a class="pagination-link prev">
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="object" select="$prev"/>
                </xsl:call-template>
              </xsl:attribute>
              <span class="pagination-relation">
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'previouspage'"/>
                </xsl:call-template>
              </span>
              <span class="pagination-label">
                <xsl:apply-templates select="$prev" mode="page-bottom.label"/>
                <xsl:apply-templates select="$prev" mode="titleabbrev.markup"/>
              </span>
            </a>
          </xsl:if>
          <xsl:text> </xsl:text>
        </div>
        <div>
          <xsl:if test="count($next) > 0 and $isnext = 'true'">
            <a class="pagination-link next">
              <xsl:attribute name="href">
                <xsl:call-template name="href.target">
                  <xsl:with-param name="object" select="$next"/>
                </xsl:call-template>
              </xsl:attribute>
              <span class="pagination-relation">
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'nextpage'"/>
                </xsl:call-template>
              </span>
              <span class="pagination-label">
                <xsl:apply-templates select="$next" mode="page-bottom.label"/>
                <xsl:apply-templates select="$next" mode="titleabbrev.markup"/>
              </span>
            </a>
          </xsl:if>
          <xsl:text> </xsl:text>
        </div>
      </nav>
    </xsl:if>
  </xsl:template>


  <xsl:template match="d:chapter|d:appendix|d:part" mode="page-bottom.label">
    <xsl:variable name="template">
      <xsl:call-template name="gentext.template">
        <xsl:with-param name="context" select="'xref-number'"/>
        <xsl:with-param name="name" select="local-name()"/>
      </xsl:call-template>
    </xsl:variable>

    <span class="title-number">
      <xsl:call-template name="substitute-markup">
        <xsl:with-param name="template" select="$template"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="*" mode="page-bottom.label"/>


  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>

    <xsl:call-template name="chunk-element-content-html">
      <xsl:with-param name="content" select="$content"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="chunk-element-content-html">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content"/>

    <xsl:variable name="lang-scope" select="ancestor-or-self::*[@xml:lang][1]"/>
    <xsl:variable name="lang-attr">
      <xsl:call-template name="get-lang-for-ssi" />
    </xsl:variable>

    <xsl:call-template name="user.preroot"/>

    <html>
      <xsl:attribute name="lang">
        <xsl:choose>
          <xsl:when test="$rootid">
            <xsl:call-template name="l10n.language">
              <xsl:with-param name="target" select="key('id', $rootid)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="l10n.language">
              <xsl:with-param name="target" select="/*[1]"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="root.attributes" />
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev" />
        <xsl:with-param name="next" select="$next" />
      </xsl:call-template>

      <body>
        <xsl:call-template name="body.attributes" />
        <xsl:call-template name="outerelement.class.attribute" />
        <xsl:if test="$include.suse.header">
          <xsl:variable name="candidate.suse.header.body">
            <xsl:call-template name="string.subst">
              <xsl:with-param name="string" select="$include.ssi.body" />
              <xsl:with-param name="target" select="$placeholder.ssi.language" />
              <xsl:with-param name="replacement" select="$lang-attr" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:text>&#10;</xsl:text>
          <xsl:comment>#include virtual="<xsl:value-of select="$candidate.suse.header.body" />"</xsl:comment>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:call-template name="bypass">
          <xsl:with-param name="format" select="'chunk'" />
        </xsl:call-template>

        <xsl:call-template name="user.header.content" />

        <xsl:call-template name="breadcrumbs.navigation" />

        <main id="_content">

          <xsl:call-template name="side.toc.overall" />
          <button id="_open-side-toc-overall">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'TableofContents'" />
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </button>

          <article class="documentation">

            <button id="_unfold-side-toc-page">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'onthispage'" />
              </xsl:call-template>
            </button>
            <xsl:copy-of select="$content" />

            <xsl:call-template name="bottom.navigation">
              <xsl:with-param name="prev" select="$prev" />
              <xsl:with-param name="next" select="$next" />
              <xsl:with-param name="nav.context" select="$nav.context" />
            </xsl:call-template>

          </article>

          <xsl:call-template name="side.toc.page" />

        </main>

        <xsl:call-template name="user.footer.content" />

      </body>
    </html>
  </xsl:template>


  <xsl:template name="side.toc.overall">
    <xsl:if test="$generate.side.toc != 0">
      <xsl:variable name="needs-document-overview">
        <xsl:if test="(/d:set or /d:book[d:article]) and not($rootid) or
                      //*[@xml:id = $rootid][self::d:set or self::d:book[d:article]]">1</xsl:if>
      </xsl:variable>

      <nav id="_side-toc-overall">
        <xsl:attribute name="class">
          <xsl:text>side-toc</xsl:text>
          <xsl:if test="self::d:set">
            <xsl:text> document-overview-visible disable-document-overview-button</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:if test="$needs-document-overview = 1">
          <button id="_open-document-overview">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'moredocuments'"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </button>
        </xsl:if>
        <div class="side-title">
          <xsl:apply-templates select="(ancestor-or-self::d:set|ancestor-or-self::d:book | ancestor-or-self::d:article)[last()]" mode="titleabbrev.markup"/>
        </div>
        <!-- For articles, the content here would the same as the "on this
        page" content, so skip that, even though that (also) looks horrible. -->
        <xsl:if test="not(self::d:article)">
          <xsl:call-template name="side.toc.overall.inner">
            <xsl:with-param name="node" select="((ancestor-or-self::d:book | ancestor-or-self::d:article)|key('id', $rootid))[last()]"/>
            <xsl:with-param name="page-context" select="."/>
          </xsl:call-template>
        </xsl:if>
        <!-- Generate an overview of all books/articles in the current set/book -->
        <xsl:if test="$needs-document-overview = 1">
          <div id="_document-overview">
            <xsl:call-template name="side.toc.overall.doc-overview.inner">
              <xsl:with-param name="node" select="(/*|key('id', $rootid))[last()]"/>
            </xsl:call-template>
          </div>
        </xsl:if>

        <xsl:text> </xsl:text>
      </nav>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>

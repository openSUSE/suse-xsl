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

  <!-- ===================================================== -->
  <xsl:template
    match="d:appendix|d:article|d:book|d:bibliography|d:chapter|d:part|d:preface|d:glossary|d:sect1|d:set|d:refentry|d:index"
                mode="breadcrumbs">
    <xsl:param name="class">crumb</xsl:param>
    <xsl:param name="context">header</xsl:param>

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

    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$class='book-link'">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($root.filename, $html.ext)"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="string($title)"/>
          </xsl:attribute>
          <span class="book-icon">
            <xsl:choose>
              <xsl:when test="$overview-page = ''">
                <xsl:attribute name="class">book-icon</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">book-icon lower-level</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="string($title)"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="."/>
              <xsl:with-param name="context" select="."/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="$class = 'single-crumb'">
            <span class="single-contents-icon"> </span>
          </xsl:if>
          <xsl:if test="$context = 'fixed-header'">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">showcontentsoverview</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">admonseparator</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:value-of select="string($title)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="breadcrumbs.navigation">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="context">header</xsl:param>
    <xsl:param name="debug"/>

    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
        <xsl:call-template name="generate.breadcrumbs.back"/>
        <xsl:choose>
          <xsl:when test="$rootelementname != 'article'">
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
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="breadcrumbs">
              <xsl:with-param name="class">single-crumb</xsl:with-param>
              <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="create.header.buttons.nav">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:if test="not(self::d:set|self::d:article)">
      <div class="button">
        <xsl:call-template name="header.navigation">
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev" select="$prev"/>
        </xsl:call-template>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="header.navigation">
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
  <xsl:variable name="ancestorrootnode" select="key('id', $rootid)/ancestor::*"/>
  <xsl:variable name="setdiff" select="ancestor::*[count(. | $ancestorrootnode)
                                != count($ancestorrootnode)]"/>
  <xsl:if test="$needs.navig">
       <xsl:choose>
         <xsl:when test="count($prev) > 0 and $isprev = 'true'">
           <a accesskey="p" class="tool-spacer">
             <xsl:attribute name="title">
               <xsl:apply-templates select="$prev"
                 mode="object.title.markup"/>
             </xsl:attribute>
             <xsl:attribute name="href">
               <xsl:call-template name="href.target">
                 <xsl:with-param name="object" select="$prev"/>
               </xsl:call-template>
             </xsl:attribute>
             <span class="prev-icon">←</span>
           </a>
         </xsl:when>
         <xsl:otherwise>
           <span class="tool-spacer">
             <span class="prev-icon">←</span>
           </span>
         </xsl:otherwise>
       </xsl:choose>
       <xsl:choose>
         <xsl:when test="count($next) > 0 and $isnext = 'true'">
           <a accesskey="n" class="tool-spacer">
             <xsl:attribute name="title">
               <xsl:apply-templates select="$next"
                 mode="object.title.markup"/>
             </xsl:attribute>
             <xsl:attribute name="href">
               <xsl:call-template name="href.target">
                 <xsl:with-param name="object" select="$next"/>
               </xsl:call-template>
             </xsl:attribute>
             <span class="next-icon">→</span>
           </a>
         </xsl:when>
         <xsl:otherwise>
           <span class="tool-spacer">
             <span class="next-icon">→</span>
           </span>
         </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
  </xsl:template>


  <!-- ===================================================== -->
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
      <div id="_bottom-navigation">
        <xsl:if test="count($next) > 0 and $isnext = 'true'">
          <a class="nav-link">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="$next"/>
              </xsl:call-template>
            </xsl:attribute>
            <span class="next-icon">→</span>
            <span class="nav-label">
              <xsl:apply-templates select="$next" mode="page-bottom.label"/>
              <xsl:apply-templates select="$next" mode="titleabbrev.markup"/>
            </span>
          </a>
        </xsl:if>
        <xsl:if test="count($prev) > 0 and $isprev = 'true'">
          <a class="nav-link">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="$prev"/>
              </xsl:call-template>
            </xsl:attribute>
            <span class="prev-icon">←</span>
            <span class="nav-label">
              <xsl:apply-templates select="$prev" mode="page-bottom.label"/>
              <xsl:apply-templates select="$prev" mode="titleabbrev.markup"/>
            </span>
          </a>
      </xsl:if>
      </div>
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

  <!-- ===================================================== -->
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

    <xsl:variable name="lang">
      <xsl:apply-templates select="(ancestor-or-self::*/@xml:lang)[last()]" mode="html.lang.attribute"/>
    </xsl:variable>

    <xsl:call-template name="user.preroot"/>

    <html lang="{$lang}">
      <xsl:call-template name="root.attributes"/>
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>

      <body>
        <xsl:call-template name="body.attributes"/>
        <xsl:call-template name="outerelement.class.attribute"/>
        <xsl:call-template name="bypass">
          <xsl:with-param name="format" select="'chunk'"/>
        </xsl:call-template>

        <xsl:call-template name="user.header.content"/>

        <main id="_content">
          <xsl:call-template name="outerelement.class.attribute">
            <xsl:with-param name="node" select="'id-content'"/>
          </xsl:call-template>

          <xsl:call-template name="side.toc.overall"/>

          <article class="documentation">
            <xsl:copy-of select="$content"/>

            <nav class="page-bottom">
              <xsl:call-template name="bottom.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="nav.context" select="$nav.context"/>
              </xsl:call-template>
            </nav>

          </article>

          <aside id="_side-toc-page" class="side-toc">
            <xsl:if test="not(self::d:part or self::d:book or self::d:set)
                          and (./d:section or ./d:sect1 or ./d:sect2 or ./d:sect3 or
                               ./d:sect4 or ./d:sect5 or
                               ./d:refsect1 or ./d:refsect2 or ./d:refsect3 or
                               ./d:topic or ./d:simplesect)">
              <div class="side-title">
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'onthispage'"/>
                </xsl:call-template>
              </div>
              <xsl:variable name="toc.params">
                <xsl:call-template name="find.path.params">
                  <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
                </xsl:call-template>
              </xsl:variable>

              <xsl:call-template name="make.lots">
                <xsl:with-param name="toc.params" select="$toc.params"/>
                <xsl:with-param name="toc">
                  <xsl:call-template name="component.toc"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>

            <xsl:call-template name="share.and.print">
              <xsl:with-param name="prev" select="$prev"/>
              <xsl:with-param name="next" select="$next"/>
              <xsl:with-param name="nav.context" select="$nav.context"/>
            </xsl:call-template>

            <xsl:text> </xsl:text>
          </aside>

        </main>

        <xsl:call-template name="user.footer.content"/>

      </body>
    </html>
  </xsl:template>


  <xsl:template name="user.header.content">
    <xsl:choose>
     <xsl:when test="$include.ssi.header != ''">
       <xsl:comment>#include virtual="<xsl:value-of select="$include.ssi.header"/>"</xsl:comment>
     </xsl:when>
     <xsl:when test="$generate.header != 0">
      <!-- FIXME suse22: this is too much (real) header code, should all be ssi'd -->
       <header id="_mainnav">
         <xsl:call-template name="create.header.logo"/>
         <div id="utilitynav">
           <div id="searchbox">
             <form id="searchform" accept-charset="utf-8" action="/search.html" method="get">
               <input class="search-text" autocomplete="off" type="text" size="10" name="q" title="Search" placeholder="Search term" dir="ltr" spellcheck="false" />
               <button type="submit" class="search-submit">Search</button>
             </form>
           </div>
           <div class="utilitynav-container">
             <div id="utilitynav-customer">
               <a href="https://scc.suse.com/">
                 <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
                   <xsl:comment>Font Awesome Free 5.15.3 by @fontawesome, https://fontawesome.com - CC BY 4.0</xsl:comment>
                   <path d="M358.182 179.361c-19.493-24.768-52.679-31.945-79.872-19.098-15.127-15.687-36.182-22.487-56.595-19.629V67c0-36.944-29.736-67-66.286-67S89.143 30.056 89.143 67v161.129c-19.909-7.41-43.272-5.094-62.083 8.872-29.355 21.795-35.793 63.333-14.55 93.152l109.699 154.001C134.632 501.59 154.741 512 176 512h178.286c30.802 0 57.574-21.5 64.557-51.797l27.429-118.999A67.873 67.873 0 0 0 448 326v-84c0-46.844-46.625-79.273-89.818-62.639zM80.985 279.697l27.126 38.079c8.995 12.626 29.031 6.287 29.031-9.283V67c0-25.12 36.571-25.16 36.571 0v175c0 8.836 7.163 16 16 16h6.857c8.837 0 16-7.164 16-16v-35c0-25.12 36.571-25.16 36.571 0v35c0 8.836 7.163 16 16 16H272c8.837 0 16-7.164 16-16v-21c0-25.12 36.571-25.16 36.571 0v21c0 8.836 7.163 16 16 16h6.857c8.837 0 16-7.164 16-16 0-25.121 36.571-25.16 36.571 0v84c0 1.488-.169 2.977-.502 4.423l-27.43 119.001c-1.978 8.582-9.29 14.576-17.782 14.576H176c-5.769 0-11.263-2.878-14.697-7.697l-109.712-154c-14.406-20.223 14.994-42.818 29.394-22.606zM176.143 400v-96c0-8.837 6.268-16 14-16h6c7.732 0 14 7.163 14 16v96c0 8.837-6.268 16-14 16h-6c-7.733 0-14-7.163-14-16zm75.428 0v-96c0-8.837 6.268-16 14-16h6c7.732 0 14 7.163 14 16v96c0 8.837-6.268 16-14 16h-6c-7.732 0-14-7.163-14-16zM327 400v-96c0-8.837 6.268-16 14-16h6c7.732 0 14 7.163 14 16v96c0 8.837-6.268 16-14 16h-6c-7.732 0-14-7.163-14-16z"/>
                 </svg>
                 Customer Center
               </a>
             </div>
             <div id="utilitynav-contact">
               <a href="https://www.suse.com/contact/">
                 <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="weighted">
                   <xsl:comment>Font Awesome Free 5.15.3 by @fontawesome, https://fontawesome.com - CC BY 4.0</xsl:comment>
                   <path d="M464 64H48C21.49 64 0 85.49 0 112v288c0 26.51 21.49 48 48 48h416c26.51 0 48-21.49 48-48V112c0-26.51-21.49-48-48-48zm0 48v40.805c-22.422 18.259-58.168 46.651-134.587 106.49-16.841 13.247-50.201 45.072-73.413 44.701-23.208.375-56.579-31.459-73.413-44.701C106.18 199.465 70.425 171.067 48 152.805V112h416zM48 400V214.398c22.914 18.251 55.409 43.862 104.938 82.646 21.857 17.205 60.134 55.186 103.062 54.955 42.717.231 80.509-37.199 103.053-54.947 49.528-38.783 82.032-64.401 104.947-82.653V400H48z"/>
                 </svg>
                 Contact
               </a>
             </div>
             <div id="utilitynav-language">
               <div class="menu-item">
                 <span id="language-name">
                   English
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" class="weighted right">
                     <xsl:comment>Font Awesome Free 5.15.3 by @fontawesome, https://fontawesome.com - CC BY 4.0</xsl:comment>
                     <path d="M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z"/>
                   </svg>
                 </span>
               </div>
             </div>
             <div id="utilitynav-search">
               <div class="menu-item" style="cursor: pointer;">
                 <span>
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                    <xsl:comment>Font Awesome Free 5.15.3 by @fontawesome, https://fontawesome.com - CC BY 4.0</xsl:comment>
                     <path d="M505 442.7L405.3 343c-4.5-4.5-10.6-7-17-7H372c27.6-35.3 44-79.7 44-128C416 93.1 322.9 0 208 0S0 93.1 0 208s93.1 208 208 208c48.3 0 92.7-16.4 128-44v16.3c0 6.4 2.5 12.5 7 17l99.7 99.7c9.4 9.4 24.6 9.4 33.9 0l28.3-28.3c9.4-9.4 9.4-24.6.1-34zM208 336c-70.7 0-128-57.2-128-128 0-70.7 57.2-128 128-128 70.7 0 128 57.2 128 128 0 70.7-57.2 128-128 128z"/>
                     </svg>
                     Search
                   </span>
                 </div>
               </div>
             </div>
         </div>
         <div id="menu">
           <div class="category enabled"><a href="/">Supported documentation</a></div>
           <div class="category enabled hidden-xs"><a href="https://www.suse.com/releasenotes/">Release notes</a></div>
           <div class="category enabled hidden-xs"><a href="https://www.suse.com/support/kb/">Knowledgebase</a></div>
           <div class="category enabled"><a class="c-btn--round" href="https://www.suse.com/">SUSE homepage</a></div>
         </div>
         <div class="header-end-line">
           <div class="header-end-line-persimmon"><xsl:text> </xsl:text></div>
           <div class="header-end-line-green"><xsl:text> </xsl:text></div>
           <div class="header-end-line-waterhole-blue"><xsl:text> </xsl:text></div>
           <div class="header-end-line-mint"><xsl:text> </xsl:text></div>
         </div>
       </header>
       <!-- <xsl:call-template name="breadcrumbs.navigation">
         <!-/-<xsl:with-param name="prev" select="$prev"/>
         <xsl:with-param name="next" select="$next"/>-/->
       </xsl:call-template> -->
     </xsl:when>
     <xsl:otherwise/>
   </xsl:choose>
  </xsl:template>

  <xsl:template name="user.footer.content">
    <xsl:choose>
      <xsl:when test="$include.ssi.footer != ''">
        <xsl:comment>#include virtual="<xsl:value-of select="$include.ssi.footer"/>"</xsl:comment>
      </xsl:when>
      <xsl:when test="$generate.footer = 1">
        <!-- FIXME suse22 real footer! -->
        <footer id="_footer">
          <div class="footer-start-line"></div>
          <div class="l-flex l-flex--justify-start u-margin-bottom-medium">
            <img class="logo" src="/docserv/res/lightheaded/suse-white-logo-green.svg" alt="" />
            <div class="foot-nav">
              <ul class="l-flex l-flex--justify-start">
                <li><a href="https://www.suse.com/company/careers/">Careers</a></li>
                <li><a href="https://www.suse.com/company/legal/">Legal</a></li>
                <li class="en-us-only"><a href="https://www.suse.com/media/agreement/suse_anti_slavery_statement.pdf">Anti-slavery statement</a></li>
                <li><a href="https://www.suse.com/company/about/">About</a></li>
                <li><a href="https://www.suse.com/company/subscribe/">Communication preferences</a></li>
                <li><a href="https://www.suse.com/contact/">Contact</a></li>
              </ul>
            </div>
            <div class="social">
              <ul class="l-flex l-flex--justify-start">
                <li><a href="https://www.facebook.com/SUSEWorldwide"><img src="/docserv/res/lightheaded/fn-fbook-ico-white.png" alt="footer-social-facebook"/></a></li>
                <li><a href="https://www.twitter.com/SUSE"><img src="/docserv/res/lightheaded/fn-twitter-ico-white.png" width="30" alt="footer-social-twitter"/></a></li>
                <li><a href="https://www.linkedin.com/company/suse"><img src="/docserv/res/lightheaded/fn-link-ico-white.png" alt="footer-social-linkedin"/></a></li>
              </ul>
            </div>
            </div>
            <div class="divider"></div>
            <div class="copy">
              <span class="copy__rights">© SUSE 2022</span>
              <a href="https://www.suse.com/company/policies/privacy/">Privacy</a>
            </div>
        </footer>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>





  <xsl:template name="side.toc.overall">
    <xsl:if test="$generate.side.toc != 0">
      <nav id="_side-toc-overall" class="side-toc">
        <xsl:call-template name="side.toc.overall.inner">
          <xsl:with-param name="node" select="((ancestor-or-self::d:book | ancestor-or-self::d:article)|key('id', $rootid))[last()]"/>
          <xsl:with-param name="page-context" select="."/>
        </xsl:call-template>
      </nav>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

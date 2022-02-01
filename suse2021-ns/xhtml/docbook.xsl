<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into single XHTML file

   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Input:
     DocBook 4/5 document

   Output:
     Single XHTML file

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>,
               Stefan Knorr <sknorr@suse.de>
   Copyright:  2012-2018 Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl date d">

  <xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml5/docbook.xsl"/>

  <xsl:include href="../VERSION.xsl"/>

  <xsl:include href="../common/dates-revisions.xsl"/>
  <xsl:include href="../common/labels.xsl"/>
  <xsl:include href="../common/titles.xsl"/>
  <xsl:include href="../common/navigation.xsl"/>
  <xsl:include href="../common/string-replace.xsl"/>
  <xsl:include href="../common/arch-string.xsl"/>
  <xsl:include href="../common/xref.xsl"/>
  <xsl:include href="../common/trim-verbatim.xsl"/>
  <xsl:include href="../common/converter-string.xsl"/>
  <xsl:include href="../common/screen-length.xsl"/>
  <xsl:include href="../common/utility.xsl"/>

  <xsl:include href="param.xsl"/>
  <xsl:include href="create-permalink.xsl"/>

  <xsl:include href="autotoc.xsl"/>
  <xsl:include href="autobubbletoc.xsl"/>
  <xsl:include href="lists.xsl"/>
  <xsl:include href="callout.xsl"/>
  <xsl:include href="verbatim.xsl"/>
  <xsl:include href="component.xsl"/>
  <xsl:include href="glossary.xsl"/>
  <xsl:include href="formal.xsl"/>
  <xsl:include href="sections.xsl"/>
  <xsl:include href="division.xsl"/>
  <xsl:include href="inline.xsl"/>
  <xsl:include href="xref.xsl"/>
  <xsl:include href="html.xsl"/>
  <xsl:include href="admon.xsl"/>
  <xsl:include href="graphics.xsl"/>
  <xsl:include href="block.xsl"/>
  <xsl:include href="qandaset.xsl"/>
  <xsl:include href="titlepage.xsl"/>
  <xsl:include href="titlepage.templates.xsl"/>

  <xsl:include href="tracker.meta.xsl"/>


<!-- Actual templates start here -->

  <xsl:template name="clearme">
    <xsl:param name="wrapper">div</xsl:param>
    <xsl:element name="{$wrapper}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">clearme</xsl:attribute>
    </xsl:element>
  </xsl:template>

 <!-- Adapt head.contents to...
 + generate more useful page titles ("Chapter x. Chapter Name" -> "Chapter Name | Book Name")
 + remove the inline styles for draft mode, so they can be substituted by styles
   in the real stylesheet
 -->
<xsl:template name="head.content">
  <xsl:param name="node" select="."/>
  <xsl:param name="product-name">
    <xsl:call-template name="product.name"/>
  </xsl:param>
  <xsl:param name="product-number">
    <xsl:call-template name="product.number"/>
  </xsl:param>
  <xsl:param name="product">
    <xsl:call-template name="version.info"/>
  </xsl:param>
  <xsl:param name="product-short">
    <xsl:call-template name="version.info">
      <xsl:with-param name="prefer-abbreviation" select="1"/>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="structure.title.candidate">
    <xsl:choose>
      <xsl:when test="self::d:book or self::d:article or self::d:set">
        <xsl:apply-templates select="d:title | d:info/d:title[last()]" mode="title.markup.textonly"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="((ancestor::d:book | ancestor::d:article)[last()]/d:title |
                                      (ancestor::d:book | ancestor::d:article)[last()]/d:info/d:title)[last()]"
           mode="title.markup.textonly"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="structure.title">
    <xsl:choose>
      <xsl:when test="$structure.title.candidate != ''">
        <xsl:value-of select="$structure.title.candidate"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="self::d:book or self::d:article or self::d:set">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="local-name(.)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="ancestor::d:article">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'article'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'book'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="substructure.title.short">
    <xsl:if test="not(self::d:book or self::d:article or self::d:set)">
      <xsl:choose>
        <xsl:when test="d:info/d:title | d:title | d:refmeta/d:refentrytitle">
          <xsl:apply-templates select="(d:info/d:title | d:title | d:refmeta/d:refentrytitle)[last()]" mode="title.markup.textonly"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name(.)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:param>
  <xsl:param name="substructure.title.long">
    <xsl:if test="not(self::d:book or self::d:article or self::d:set)">
       <xsl:apply-templates select="." mode="object.title.markup"/>
    </xsl:if>
  </xsl:param>

  <xsl:param name="title">
    <xsl:if test="$substructure.title.short != ''">
      <xsl:value-of select="concat($substructure.title.short, $head.content.title.separator)"/>
    </xsl:if>

    <xsl:value-of select="$structure.title"/>

    <xsl:if test="$product != ''">
      <xsl:value-of select="concat($head.content.title.separator, $product)"/>
    </xsl:if>
  </xsl:param>

  <xsl:variable name="meta.description.base">
    <xsl:choose>
      <xsl:when test="d:info/d:abstract or d:info/d:highlights">
        <xsl:for-each select="(d:info[1]/d:abstract[1]|d:info[1]/d:highlights[1])[1]/*">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:if test="position() &lt; last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- Except for the lack of markup here, this code is very similar to
        that in autotoc.xsl. Unify later if possible. -->
        <xsl:choose>
          <!-- For single-html books/articles, it is important that we skip
          the legalnotice. "© SUSE 20XX" is not a good page description
          usually. -->
          <xsl:when test="self::d:book">
            <xsl:apply-templates select="(*[self::d:preface or self::d:chapter or self::d:sect1 or self::d:section]/d:para |
                                          *[self::d:preface or self::d:chapter or self::d:sect1 or self::d:section]/d:simpara)[1]"/>
          </xsl:when>
          <xsl:when test="self::d:article">
            <xsl:apply-templates select="(*[self::d:sect1 or self::d:section]/d:para |
                                          *[self::d:sect1 or self::d:section]/d:simpara)[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="(descendant::d:para | descendant::d:simpara)[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="search.description">
    <xsl:call-template name="ellipsize.text">
      <xsl:with-param name="input" select="$meta.description.base"/>
      <xsl:with-param name="ellipsize.after" select="$search.description.length"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="socialmedia.description">
    <xsl:call-template name="ellipsize.text">
      <xsl:with-param name="input" select="$meta.description.base"/>
      <xsl:with-param name="ellipsize.after" select="$socialmedia.description.length"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="meta.title.base">
    <!-- FIXME: localize punctuation -->
    <xsl:choose>
      <xsl:when test="$substructure.title.short != ''">
        <xsl:value-of select="$substructure.title.short"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$structure.title"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$product-short != ''">
      <xsl:text> | </xsl:text>
      <xsl:value-of select="$product-short"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="search.title">
    <xsl:call-template name="ellipsize.text">
      <xsl:with-param name="input" select="$meta.title.base"/>
      <xsl:with-param name="ellipsize.after" select="$search.title.length"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="socialmedia.title">
    <xsl:call-template name="ellipsize.text">
      <xsl:with-param name="input" select="$meta.title.base"/>
      <xsl:with-param name="ellipsize.after" select="$socialmedia.title.length"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="socialmedia.preview">
    <xsl:choose>
      <!-- We ignore:
           * inlinemediaobjects, because they are likely very small
           * SVGs, because they don't work (according to the Contentking) -->
      <!-- We reimplement ends-with() https://stackoverflow.com/questions/40934644 -->
      <xsl:when
        test="(descendant::d:figure/descendant::d:imagedata/@fileref
              |descendant::d:informalfigure/descendant::d:imagedata/@fileref)[not(
               substring(translate(., 'SVG', 'svg'), string-length(.) - 5) = '.svg')][1]">
        <xsl:value-of
          select="concat($canonical-url-base, '/', $img.src.path,
                  (descendant::d:figure/descendant::d:imagedata/@fileref
                  |descendant::d:informalfigure/descendant::d:imagedata/@fileref)[not(
                    substring(translate(., 'SVG', 'svg'), string-length(.) - 5) = '.svg')][1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($canonical-url-base, '/', $socialmedia.preview.default)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <meta charset="UTF-8"/>

  <meta name="viewport"
    content="width=device-width, initial-scale=1.0, user-scalable=yes"/>

  <title><xsl:value-of select="$title"/></title>

  <xsl:if test="$html.base != ''">
    <base href="{$html.base}"/>
  </xsl:if>

  <!-- Insert links to CSS files or insert literal style elements -->
  <xsl:call-template name="generate.css"/>

  <xsl:if test="$html.stylesheet != ''">
    <xsl:call-template name="output.html.stylesheets">
      <xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="$html.script != ''">
    <xsl:call-template name="output.html.scripts">
      <xsl:with-param name="scripts" select="normalize-space($html.script)"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="$link.mailto.url != ''">
    <link rev="made" href="{$link.mailto.url}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <meta name="title" content="{$search.title}"/>
  <xsl:text>&#10;</xsl:text>
  <meta name="description" content="{$search.description}"/>
  <xsl:text>&#10;</xsl:text>

  <xsl:if test="$product-name != ''">
    <meta name="product-name" content="{$product-name}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:if test="$product-number != ''">
    <meta name="product-number" content="{$product-number}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <meta name="book-title" content="{$structure.title}"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="$substructure.title.long != ''">
    <meta name="chapter-title" content="{$substructure.title.long}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="$use.tracker.meta != 0">
    <xsl:call-template name="create.bugtracker.information"/>
  </xsl:if>

  <xsl:apply-templates select="." mode="head.keywords.content"/>

  <xsl:if test="$canonical-url-base != ''">
    <xsl:variable name="ischunk">
      <xsl:call-template name="chunk"/>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$ischunk = 1">
          <xsl:apply-templates mode="chunk-filename" select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($root.filename,$html.ext)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="canonical.url">
      <xsl:value-of select="concat($canonical-url-base,'/',$filename)"/>
    </xsl:variable>

    <link rel="canonical" href="{$canonical.url}"/>
    <xsl:text>&#10;</xsl:text>
    <!-- These Open Graph and Twitter Cards properties need a canonical URL -->
    <meta property="og:url" content="{$canonical.url}"/>
    <xsl:text>&#10;</xsl:text>
    <meta property="og:image" content="{concat($canonical-url-base,'/',$socialmedia.preview)}"/>
    <xsl:text>&#10;</xsl:text>
    <meta name="twitter:image" content="{concat($canonical-url-base,'/',$socialmedia.preview)}"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:call-template name="meta-generator"/>
  </xsl:if>

  <!-- The following properties "work" without a canonical URL being defined
  (but both the Open Graph and Twitter Cards implementations are incomplete
  without the above tags, better than nothing though). -->
  <meta property="og:title" content="{$socialmedia.title}"/>
  <xsl:text>&#10;</xsl:text>
  <meta property="og:description" content="{$socialmedia.description}"/>
  <xsl:text>&#10;</xsl:text>
  <meta property="og:type" content="{$opengraph.type}"/>
  <xsl:text>&#10;</xsl:text>

  <meta name="twitter:card" content="{$twittercards.type}"/>
  <xsl:text>&#10;</xsl:text>
  <meta name="twitter:title" content="{$socialmedia.title}"/>
  <xsl:text>&#10;</xsl:text>
  <meta name="twitter:description" content="{$socialmedia.description}"/>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="string-length($twittercards.twitter.account) &gt; 0">
    <meta name="twitter:site" content="{$twittercards.twitter.account}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>


  <xsl:template name="ellipsize.text">
    <xsl:param name="input" select="''"/>
    <xsl:param name="ellipsize.after" select="150"/>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($input)) &gt; $ellipsize.after">
        <xsl:value-of select="substring(normalize-space($input),1,$ellipsize.after - 1)"/>
        <xsl:value-of select="'…'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($input)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="meta-generator">
    <xsl:element name="meta">
      <xsl:attribute name="name">generator</xsl:attribute>
      <xsl:attribute name="content">
        <xsl:call-template name="converter-string"/>
        <xsl:if test="$is.chunk != 0">
          <xsl:text> - chunked</xsl:text>
        </xsl:if>
      </xsl:attribute>
    </xsl:element>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="d:refentry" mode="titleabbrev.markup">
    <xsl:value-of select="d:refmeta/d:refentrytitle[text()]"/>
  </xsl:template>

  <xsl:template match="d:appendix|d:article|d:book|d:bibliography|d:chapter|d:part|d:preface|d:glossary|d:sect1|d:set|d:refentry"
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
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="."/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="accesskey">
          <xsl:text>c</xsl:text>
      </xsl:attribute>
      <span class="single-contents-icon"> </span>
      <xsl:if test="$context = 'fixed-header'">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">showcontentsoverview</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">admonseparator</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:value-of select="string($title)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="breadcrumbs.navigation">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="context">header</xsl:param>
    <xsl:param name="debug"/>

    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs inactive">
        <xsl:if test="$context = 'header'">
          <xsl:call-template name="generate.breadcrumbs.back"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="breadcrumbs">
          <xsl:with-param name="class">single-crumb</xsl:with-param>
          <xsl:with-param name="context" select="$context"/>
        </xsl:apply-templates>
        <xsl:if test="$context = 'header'">
          <div class="bubble-corner active-contents"> </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generate.breadcrumbs.back">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$overview-page-title != 0">
          <xsl:value-of select="$overview-page-title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$overview-page"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$overview-page != ''">
      <a class="overview-link" href="{$overview-page}" title="{$title}">
        <span class="overview-icon"><xsl:value-of select="$title"/></span>
      </a>
      <span><xsl:copy-of select="$daps.breadcrumbs.sep"/></span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="create.header.logo">
    <xsl:if test="$generate.logo != 0">
      <xsl:choose>
        <xsl:when test="$homepage != ''">
          <a href="{$homepage}">
            <img src="{$daps.header.logo}" alt="{$daps.header.logo.alt}" class="logo"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <img src="{$daps.header.logo}" alt="{$daps.header.logo.alt}" class="logo"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="create.header.buttons">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>

    <div class="buttons">
      <a class="top-button button" href="#">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">totopofpage</xsl:with-param>
        </xsl:call-template>
      </a>
      <xsl:call-template name="create.header.buttons.nav">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
      <xsl:call-template name="clearme"/>
    </div>
  </xsl:template>

  <xsl:template name="create.header.buttons.nav">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <!-- This is a stub, intentionally.
         The version in chunk-common does something, though. -->
  </xsl:template>

  <xsl:template name="share.and.print">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:param name="nav.context"/>

    <xsl:if test="$generate.share.and.print != 0">
      <xsl:if test="$generate.sharelinks != 0">
        <div class="side-title">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">sharethispage</xsl:with-param>
          </xsl:call-template>
        </div>
        <ul class="share">
          <li class="_share-fb bottom-button">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviafacebook</xsl:with-param>
            </xsl:call-template>
          </li>
          <li class="_share-in bottom-button">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">sharevialinkedin</xsl:with-param>
            </xsl:call-template>
          </li>
          <li class="_share-tw bottom-button">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviatwitter</xsl:with-param>
            </xsl:call-template>
          </li>
          <li class="_share-mail bottom-button">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">shareviaemail</xsl:with-param>
            </xsl:call-template>
          </li>
        </ul>
      </xsl:if>
      <div class="print">
        <span class="_print-button bottom-button">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">printthispage</xsl:with-param>
          </xsl:call-template>
        </span>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="outerelement.class.attribute">
    <!-- To accommodate for ActiveDoc's needs, add this to both body and
         #_content.-->
    <xsl:param name="node" select="'body'"/>

    <xsl:attribute name="class">
      <xsl:if test="($draft.mode = 'yes' or
                    ($draft.mode = 'maybe' and
                    ancestor-or-self::*[@status][1]/@status = 'draft'))
                    and $draft.watermark.image != ''"
        >draft </xsl:if><xsl:if test="$node = 'body'"><xsl:if test="$is.chunk = 0"
        >single </xsl:if><xsl:if test="$generate.footer = 0">nofooter </xsl:if
        >offline js-off</xsl:if></xsl:attribute>
  </xsl:template>

  <xsl:template name="bypass"/> <!-- fixme later -->
  <!--<xsl:template name="bypass">
    <!-/- Bypass blocks help disabled, e.g. blind users navigate more quickly.
    Hard-to-parse W3C spec: https://www.w3.org/TR/WCAG20/#navigation-mechanisms-skip -/->
    <xsl:param name="format" select="'single'"/>
    <xsl:if test="not($optimize.plain.text = 1)">
      <div class="bypass-block">
        <a href="#_content">
          <xsl:call-template name="gentext.template">
            <xsl:with-param name="context" select="'bypass-block'"/>
            <xsl:with-param name="name" select="'bypass-to-content'"/>
          </xsl:call-template>
        </a>
        <xsl:if test="$format = 'chunk'">
          <!-/- Going to #_bottom-navigation is an admittedly quirky choice but
          the other two places in which we have this kind of page nav
          (regular header and fixed header) do not assign an ID to it. -/->
          <a href="#_bottom-navigation">
            <xsl:call-template name="gentext.template">
              <xsl:with-param name="context" select="'bypass-block'"/>
              <xsl:with-param name="name" select="'bypass-to-nav'"/>
            </xsl:call-template>
          </a>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>-->


<xsl:template match="*" mode="process.root">
  <xsl:param name="prev"/>
  <xsl:param name="next"/>
  <xsl:param name="nav.context"/>
  <xsl:param name="content">
    <xsl:apply-imports/>
  </xsl:param>
  <xsl:variable name="doc" select="self::*"/>
  <xsl:variable name="lang">
    <xsl:apply-templates select="(ancestor-or-self::*/@xml:lang)[last()]" mode="html.lang.attribute"/>
  </xsl:variable>

  <xsl:call-template name="user.preroot"/>
  <xsl:call-template name="root.messages"/>

  <html lang="{$lang}">
    <xsl:call-template name="root.attributes"/>
    <head>
      <xsl:call-template name="system.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="user.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
    </head>
    <body>
      <xsl:call-template name="body.attributes"/>
      <xsl:call-template name="outerelement.class.attribute"/>
      <xsl:call-template name="bypass"/>
      <div id="_outer-wrap">
        <div id="_white-bg">
          <div id="_header">
            <xsl:call-template name="create.header.logo"/>
            <xsl:call-template name="breadcrumbs.navigation">
              <xsl:with-param name="prev" select="$prev"/>
              <xsl:with-param name="next" select="$next"/>
            </xsl:call-template>
            <xsl:call-template name="clearme"/>
          </div>
        </div>

        <xsl:call-template name="user.header.content"/>
        <div id="_toc-bubble-wrap"></div>
        <div id="_content">
          <xsl:call-template name="outerelement.class.attribute">
            <xsl:with-param name="node" select="'id-content'"/>
          </xsl:call-template>
          <div class="documentation">

          <xsl:apply-templates select="."/>

          </div>
          <div class="page-bottom">
            <xsl:call-template name="share.and.print">
              <xsl:with-param name="prev" select="$prev"/>
              <xsl:with-param name="next" select="$next"/>
              <xsl:with-param name="nav.context" select="$nav.context"/>
            </xsl:call-template>
          </div>
        </div>
        <xsl:if test="$add.suse.footer = 1">
          <div id="_inward"></div>
        </xsl:if>
      </div>

      <xsl:if test="$generate.footer = 1">
        <div id="_footer-wrap">
          <xsl:call-template name="user.footer.content"/>
        </div>
      </xsl:if>
    </body>
  </html>
</xsl:template>

  <xsl:template name="user.head.content">
    <xsl:param name="node" select="."/>

    <xsl:text>&#10;</xsl:text>

    <xsl:if test="$build.for.web = 1">
      <script type="text/javascript">
<xsl:text disable-output-escaping="yes">
<![CDATA[
if ( window.location.protocol.toLowerCase() != 'file:' ) {
  document.write('<link rel="stylesheet" type="text/css" href="https://documentation.suse.com/docserv/res/fonts/poppins/poppins.css"></link>');
};
]]>
</xsl:text>
      </script>
      <noscript>
        <link rel="stylesheet" type="text/css" href="https://documentation.suse.com/docserv/res/fonts/poppins/poppins.css"></link>
      </noscript>
    </xsl:if>
    <xsl:if test="$daps.header.js.library != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.library"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$daps.header.js.custom != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.custom"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$enable.source.highlighting = 1">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.highlight"/>
      </xsl:call-template>
      <script>
<xsl:text disable-output-escaping="yes">
<![CDATA[
$(document).ready(function() {
  $('.verbatim-wrap.highlight').each(function(i, block) {
    hljs.highlightBlock(block);
  });
});
hljs.configure({
  useBR: false
});
]]>
</xsl:text>
      </script>
    </xsl:if>
    <xsl:if test="$enable.source.highlighting != 1">
      <!-- Provide a fake highlight.js, because our script is waiting for
      such an Object to appear before adding copy-code buttons into screens.
      -->
      <script>
<xsl:text disable-output-escaping="yes">
<![CDATA[
var hljs = new Object;
]]>
</xsl:text>
      </script>
    </xsl:if>
    <xsl:if test="$external.js != ''">
      <xsl:call-template name="make.multi.script.link">
        <xsl:with-param name="input" select="$external.js"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$external.js.onlineonly != ''">
      <xsl:call-template name="make.multi.script.link.onlineonly">
        <xsl:with-param name="input" select="$external.js.onlineonly"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make.multi.script.link">
    <xsl:param name="input" select="''"/>
    <xsl:variable name="input-sanitized" select="concat(normalize-space($input),' ')"/>
    <xsl:if test="string-length($input) &gt; 1">
      <xsl:variable name="this" select="substring-before($input-sanitized,' ')"/>
      <xsl:variable name="next" select="substring-after($input-sanitized,' ')"/>
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$this"/>
      </xsl:call-template>
      <xsl:call-template name="make.multi.script.link">
        <xsl:with-param name="input" select="$next"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make.multi.script.link.onlineonly">
    <xsl:param name="input" select="''"/>
    <xsl:param name="count" select="1"/>
    <xsl:variable name="input-sanitized" select="concat(normalize-space($input),' ')"/>
    <xsl:if test="string-length($input) &gt; 1">
      <xsl:variable name="this" select="substring-before($input-sanitized,' ')"/>
      <xsl:variable name="next" select="substring-after($input-sanitized,' ')"/>
      <xsl:variable name="varname" select="concat('externalScript', $count)"/>
      <script type="text/javascript">
if (window.location.protocol.toLowerCase() != 'file:') {
  var <xsl:value-of select="$varname"/> = document.createElement("script");
  <xsl:value-of select="$varname"/>.src = "<xsl:value-of select="$this"/>";
  document.head.appendChild(<xsl:value-of select="$varname"/>);
}
      </script>
      <xsl:call-template name="make.multi.script.link.onlineonly">
        <xsl:with-param name="input" select="$next"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="user.footer.content">
    <div id="_footer">
      <p>©
        <xsl:if test="function-available('date:year')">
          <xsl:value-of select="date:year()"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        SUSE</p>
      <xsl:if test="$generate.footer.links != 0">
        <ul>
          <li>
            <a href="https://jobs.suse.com/" target="_top">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">susecareers</xsl:with-param>
              </xsl:call-template>
            </a>
          </li>
          <li>
            <a href="https://www.suse.com/company/legal/" target="_top">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">suselegal</xsl:with-param>
              </xsl:call-template>
            </a>
          </li>
          <li>
            <a href="https://www.suse.com/company/about/" target="_top">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">suseabout</xsl:with-param>
              </xsl:call-template>
            </a>
          </li>
          <li>
            <a href="https://www.suse.com/contact/"
              target="_top">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">susecontact</xsl:with-param>
              </xsl:call-template>
            </a>
          </li>
        </ul>
      </xsl:if>
    </div>
  </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into single XHTML file

   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Input:
     DocBook 5 document

   Output:
     Single XHTML file

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>,
               Stefan Knorr <sknorr@suse.de>
   Copyright:  2012-2022 Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:dm="urn:x-suse:ns:docmanager"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl date d dm">

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
  <xsl:include href="sidetoc.xsl"/>
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
  <xsl:include href="meta.xsl"/>
  <xsl:include href="json-ld.xsl"/>

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

    <xsl:if test="$product-short != ''">
      <xsl:value-of select="concat($head.content.title.separator, $product-short)"/>
    </xsl:if>

  </xsl:param>

  <xsl:variable name="meta.description.base">
    <xsl:choose>
      <xsl:when test="d:info/d:meta[@name='description']">
        <xsl:value-of select="normalize-space(d:info/d:meta[@name='description'][1])"/>
      </xsl:when>
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
          <xsl:when test="self::d:book[(self::d:preface | self::d:chapter | self::d:topic)/d:para]">
            <xsl:apply-templates select="(*[self::d:preface or self::d:chapter or self::d:topic]/d:para |
                                          *[self::d:preface or self::d:chapter or self::d:topic]/d:simpara)[1]"/>
          </xsl:when>
          <xsl:when test="self::d:book | self::d:appendix | self::d:chapter | self::d:part | self::d:glossary | self::d:preface">
            <xsl:value-of select="normalize-space(string((d:title|d:info/d:title)[last()]))"/>
          </xsl:when>
          <xsl:when test="self::d:article">
            <xsl:apply-templates select="(*[self::d:sect1 or self::d:section]/d:para |
                                          *[self::d:sect1 or self::d:section]/d:simpara)[1]"/>
          </xsl:when>
          <xsl:when test="self::d:revhistory">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'RevHistory'" />
            </xsl:call-template>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="(d:title[normalize-space(.) != ''] | d:revision[1]/d:revdescription/d:para[1])[last()]"/>
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
  <xsl:variable name="metanodes" select="$node/ancestor-or-self::*/d:info/d:meta"/>

  <title><xsl:value-of select="$title"/></title>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/>

  <xsl:if test="$html.base != ''">
    <xsl:call-template name="head.content.base">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
  </xsl:if>

  <!-- Insert links to CSS files or insert literal style elements -->
  <xsl:call-template name="generate.css"/>

  <xsl:if test="$html.stylesheet != ''">
    <xsl:call-template name="output.html.stylesheets">
      <xsl:with-param name="stylesheets" select="normalize-space($html.stylesheet)"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="$include.html.dublincore">
    <xsl:variable name="candidate-modified">
      <xsl:choose>
        <!-- Select the nearest first revision date from the ancestor axis -->
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="normalize-space(($node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date)[last()])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="candidate-published">
      <xsl:choose>
        <!-- Select the nearest last revision date from the ancestor axis -->
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:revhistory/d:revision[last()]/d:date">
          <xsl:value-of select="normalize-space(($node/ancestor-or-self::*/d:info/d:revhistory/d:revision[last()]/d:date)[last()])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- For Dublin Core metadata -->
    <link rel="schema.dc"      href="http://purl.org/dc/elements/1.1/" />
    <link rel="schema.dcterms" href="http://purl.org/dc/terms/" />
    <xsl:text>&#10;</xsl:text>
    <meta name="dcterms.modified" content="{$candidate-modified}" />
    <meta name="dcterms.created" content="{$candidate-published}" />
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

  <xsl:call-template name="create.bugtracker.information"/>

  <xsl:apply-templates select="." mode="head.keywords.content"/>
  <meta name="publisher" content="SUSE"/>

  <xsl:apply-templates select="($metanodes[@name='category'])[last()]" mode="meta"/>
  <xsl:apply-templates select="($metanodes[@name='updated'])[last()]" mode="meta"/>
  <xsl:apply-templates select="($metanodes[@name='maintainer'])[last()]" mode="meta"/>

  <xsl:call-template name="social-media-opengraph">
    <xsl:with-param name="socialmedia.title" select="$socialmedia.title"/>
    <xsl:with-param name="socialmedia.description" select="$socialmedia.description"/>
  </xsl:call-template>

  <xsl:call-template name="social-media-twitter">
    <xsl:with-param name="socialmedia.title" select="$socialmedia.title"/>
    <xsl:with-param name="socialmedia.description" select="$socialmedia.description"/>
  </xsl:call-template>

  <xsl:call-template name="generate-json-ld">
    <xsl:with-param name="node" select="$node"/>
  </xsl:call-template>

  <xsl:if test="number($generate.qualtrics.div) != 0 and $qualtrics-feedback.js != ''">
      <xsl:comment>BEGIN QUALTRICS WEBSITE FEEDBACK SNIPPET</xsl:comment>
      <script type='text/javascript' src="{$qualtrics-feedback.js}"/>
      <div id="{$qualtrics.div.id}">
        <xsl:comment>DO NOT REMOVE-CONTENTS PLACED HERE</xsl:comment>
      </div>
      <xsl:comment>END WEBSITE FEEDBACK SNIPPET</xsl:comment>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>


  <xsl:template name="ellipsize.text">
    <xsl:param name="input" select="''"/>
    <xsl:param name="ellipsize.after" select="150"/>
    <xsl:variable name="input-ns" select="normalize-space($input)"/>

    <xsl:choose>
      <xsl:when test="string-length($input-ns) &gt; $ellipsize.after">
        <xsl:value-of select="substring($input-ns, 1, $ellipsize.after - 1)"/>
        <xsl:text>…</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input-ns"/>
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

  <xsl:template match="d:appendix|d:article|d:book|d:bibliography|d:chapter|d:part|d:preface|d:glossary|d:sect1|d:section|d:set|d:refentry"
                mode="breadcrumbs">

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
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="."/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="string($title)"/>
    </a>
  </xsl:template>

  <xsl:template name="breadcrumbs.navigation">

    <xsl:if test="$generate.breadcrumbs != 0">
      <div class="crumbs">
        <div class="growth-inhibitor">
          <xsl:call-template name="generate.breadcrumbs.back"/>
          <xsl:apply-templates select="." mode="breadcrumbs"/>
        </div>
        <xsl:call-template name="doc-survey"/>
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
      <a class="crumb overview-link" href="{$overview-page}" title="{$title}">
        <xsl:value-of select="$title"/>
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


  <xsl:template name="share.and.print">
    <xsl:if test="$generate.share.and.print != 0">
      <div class="side-title">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">sharethispage</xsl:with-param>
        </xsl:call-template>
      </div>
      <ul class="share">
        <xsl:if test="$generate.socialmedia != 0">
        <li>
          <a id="_share-fb" href="#">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">shareviafacebook</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </a>
        </li>
        <li>
          <a id="_share-in" href="#">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">sharevialinkedin</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </a>
        </li>
        <li>
          <a id="_share-tw" href="#">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">shareviatwitter</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </a>
        </li>
        </xsl:if>
        <li>
          <a id="_share-mail" href="#">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">shareviaemail</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </a>
        </li>
        <li>
          <!-- Why yes, of course there's a rationale for this being the
          fifth "share" button - it's the "share on paper" button. More
          seriously, it looked really lost there, standing alone. It would
          probably make more sense to just put it out of its misery and let
          the browser menu handle this function than separate it out again. -->
          <a id="_print-button" href="#">
            <xsl:attribute name="title">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key">printthispage</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text> </xsl:text>
          </a>
        </li>
      </ul>
    </xsl:if>
  </xsl:template>


  <xsl:template name="give.feedback">
    <xsl:if test="$generate.give.feedback = 1 or $force.generate.give.feedback = 1">
      <xsl:variable name="meta-bugtracker" select="ancestor-or-self::*/d:info/d:meta[@name='bugtracker']/d:phrase[@role='editurl']"/>
      <xsl:variable name="editurl" select="ancestor-or-self::*/d:info/dm:docmanager/dm:editurl[1]"/>
      <xsl:variable name="xmlbase" select="ancestor-or-self::*[@xml:base][1]/@xml:base"/>
      <xsl:variable name="url-candidate" select="($meta-bugtracker | $editurl)[last()]"/>

      <xsl:variable name="valid-for-editurl">
        <xsl:if test="($draft.mode = 'yes' or $show.edit.link = 1) and $url-candidate != '' and $xmlbase != ''">1</xsl:if>
      </xsl:variable>

      <xsl:if test="$valid-for-editurl = 1 or $force.generate.give.feedback = 1">
        <div class="side-title">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'givefeedback'"/>
          </xsl:call-template>
        </div>
        <ul class="feedback" id="_give-feedback">
          <!-- Placeholder item that can be filled via JS as necessary-->
          <xsl:if test="$force.generate.give.feedback = 1">
            <li id="_feedback-placeholder">
              <xsl:text> </xsl:text>
            </li>
          </xsl:if>
          <!-- add here a "global" report bug -->
          <xsl:if test="$valid-for-editurl = 1">
            <li>
              <a id="_feedback-editurl" href="{$url-candidate}{$xmlbase}" rel="nofollow" target="_blank">
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'editsource'"/>
                </xsl:call-template>
              </a>
            </li>
          </xsl:if>
        </ul>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template name="qualtrics.rating">
    <xsl:if test="number($generate.qualtrics.div) != 0 and  $qualtrics.id != ''">
      <div id="{$qualtrics.id}"></div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="doc-survey">
    <xsl:if test="$doc.survey != 0">
      <div class="docsurvey-wrapper">
        <a class="survey-link" href="{$doc.survey.url}">Documentation survey</a>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generate.sourcelink">
    <xsl:param name="node" select="."/>
    <xsl:variable name="meta-bugtracker" select="$node/ancestor-or-self::*/d:info/d:meta[@name='bugtracker']/d:phrase[@role='editurl']"/>
    <xsl:variable name="editurl" select="$node/ancestor-or-self::*/d:info/dm:docmanager/dm:editurl[1]"/>
    <xsl:variable name="xmlbase" select="$node/ancestor-or-self::*[@xml:base][1]/@xml:base"/>
    <xsl:variable name="url-candidate" select="($meta-bugtracker | $editurl)[last()]"/>

    <xsl:if test="($draft.mode = 'yes' or $show.edit.link = 1) and $url-candidate != '' and $xmlbase != ''">
      <xsl:value-of select="concat($url-candidate, $xmlbase)"/>
    </xsl:if>
  </xsl:template>


  <xsl:template name="generate.meta.reportbug">
    <xsl:param name="node" select="."/>
    <xsl:variable name="url">
      <xsl:call-template name="generate.sourcelink">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$url != ''">
      <meta name="edit-url" content="{$url}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="outerelement.class.attribute">
    <xsl:param name="node" select="'body'"/>

    <xsl:attribute name="class">
      <xsl:if test="($draft.mode = 'yes' or
                    ($draft.mode = 'maybe' and
                    ancestor-or-self::*[@status][1]/@status = 'draft'))
                    and $draft.watermark.image != ''"
        >draft </xsl:if><xsl:if test="$node = 'body'"><xsl:if test="$is.chunk = 0"
        >single </xsl:if><xsl:if test="$generate.footer = 0">nofooter </xsl:if
        ><xsl:if test="$show.language-switcher = 0">disable-language-switcher </xsl:if
        ><xsl:choose><xsl:when test="$is.chunk = 1">wide </xsl:when
        ><xsl:otherwise>normal </xsl:otherwise></xsl:choose
        >offline js-off</xsl:if></xsl:attribute>
  </xsl:template>

  <xsl:template name="bypass">
    <!-- Bypass blocks help disabled, e.g. blind users navigate more quickly.
    Hard-to-parse W3C spec: https://www.w3.org/TR/WCAG20/#navigation-mechanisms-skip -->
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
          <!-- Going to #_bottom-navigation is an admittedly quirky choice but
          the other two places in which we have this kind of page nav
          (regular header and fixed header) do not assign an ID to it. -->
          <a href="#_bottom-pagination">
            <xsl:call-template name="gentext.template">
              <xsl:with-param name="context" select="'bypass-block'"/>
              <xsl:with-param name="name" select="'bypass-to-nav'"/>
            </xsl:call-template>
          </a>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="generate.title.icons">
    <!--<xsl:message>generate.title.icons</xsl:message>-->
    <xsl:variable name="source-link">
      <xsl:call-template name="generate.sourcelink"/>
    </xsl:variable>
    <xsl:variable name="editurl" select="ancestor-or-self::*/d:info/dm:docmanager/dm:editurl[1]"/>

    <xsl:if test="$title.icons != 0">
    <div class="icons">
      <a target="_blank" class="icon-reportbug">
        <xsl:attribute name="title">
           <xsl:call-template name="gentext">
             <xsl:with-param name="key">reportbug</xsl:with-param>
           </xsl:call-template>
        </xsl:attribute>
        <xsl:text>&#xa0;</xsl:text>
      </a>

     <!--
       We only want to build the source link for English, not for
       other languages.
     -->
     <xsl:if test="$source-link != ''">
      <a target="_blank" class="icon-editsource" href="{$source-link}">
        <xsl:attribute name="title">
           <xsl:call-template name="gentext">
            <xsl:with-param name="key">editsource</xsl:with-param>
           </xsl:call-template>
        </xsl:attribute>
        <xsl:text>&#xa0;</xsl:text>
      </a>
     </xsl:if>
    </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="handle-json-ld">
    <xsl:choose>
      <xsl:when test="$rootid != '' and $dcfilename != ''">
          <xsl:call-template name="generate-json-ld-external">
            <xsl:with-param name="node" select="key('id', $rootid)" />
            <xsl:with-param name="first" select="1"/>
          </xsl:call-template>
        </xsl:when>
      <xsl:when test="$dcfilename != ''">
        <xsl:call-template name="generate-json-ld-external">
          <xsl:with-param name="node" select="*[1]" />
          <xsl:with-param name="first" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">WARN</xsl:with-param>
          <xsl:with-param name="context-desc">
            <xsl:text>JSON-LD</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>The parameter $dcfilename is unset. Cannot create the external JSON file.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- SUSE Header -->
  <xsl:template name="suse-header-header">
    <xsl:call-template name="log.message">
      <xsl:with-param name="level">hint</xsl:with-param>
      <xsl:with-param name="context-desc">SUSE-Header</xsl:with-param>
      <xsl:with-param name="message">
        <xsl:text>Enabled SUSE Header head</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:comment>SUSE Header head</xsl:comment>
    <script type="module">
     import { defineCustomElements, setAssetPath } from <xsl:value-of select='concat("&apos;", $suse.header.import.url, "&apos;")'/>;
     defineCustomElements();
     setAssetPath(<xsl:value-of select="concat('&quot;', $suse.header.assets.url, '&quot;')"/>);
   </script>
   <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="suse-header-body">
    <xsl:variable name="languages">{
      "en": { "label": "English", "url": "https://documentation.suse.com/en-us/" },
      "de": { "label": "Deutsch", "url": "https://documentation.suse.com/de-de/" },
      "fr": { "label": "Français", "url": "https://documentation.suse.com/fr-fr/" },
      "es": { "label": "Español", "url": "https://documentation.suse.com/es-es/" },
      "zh_CN": { "label": "中文", "url": "https://documentation.suse.com/zh-cn/" },
      "pt_BR": { "label": "Português Brasileiro", "url": "https://documentation.suse.com/pt-br/" }
     }</xsl:variable>
    <xsl:call-template name="log.message">
      <xsl:with-param name="level">hint</xsl:with-param>
      <xsl:with-param name="context-desc">SUSE-Header</xsl:with-param>
      <xsl:with-param name="message">
        <xsl:text>Enabled SUSE Header body (shared-header)</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <shared-header language="en" languages='{translate($languages, "&#10;", "")}'>
      <xsl:text>&#x20;</xsl:text>
    </shared-header>
  </xsl:template>


  <xsl:template name="language-switcher">
    <xsl:call-template name="log.message">
        <xsl:with-param name="level">hint</xsl:with-param>
        <xsl:with-param name="context-desc">LangSwitcher</xsl:with-param>
        <xsl:with-param name="message">
          <xsl:text>Enabled language switcher JS code</xsl:text>
        </xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    <!-- <script> needs to be with start- and end-tag -->
    <script type="text/javascript" src="{$daps.header.js.languageswitcher}">
      <xsl:text> </xsl:text>
    </script>
  </xsl:template>

  <!-- ############################################################## -->
  <!-- This template is called when creating single HTML -->
  <xsl:template match="/">
    <xsl:apply-imports/>
    <xsl:if test="$is.chunk = 0">
      <xsl:call-template name="handle-json-ld"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="process.root">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>
    <xsl:variable name="doc" select="self::*"/>
    <xsl:variable name="lang-attr">
      <xsl:call-template name="get-lang-for-ssi"/>
    </xsl:variable>
    <xsl:variable name="node" select="(key('id', $rootid) | /*[1])[last()]"/>
    <xsl:variable name="candidate.lang">
      <xsl:call-template name="l10n.language">
        <xsl:with-param name="target" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="user.preroot"/>

    <html lang="{$candidate.lang}" xml:lang="{$candidate.lang}">
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

        <xsl:if test="boolean($include.suse.header)">
          <xsl:call-template name="suse-header-header" />
        </xsl:if>

        <xsl:if test="$show.language-switcher = 0">
          <script type="text/javascript" src="{$daps.hide.js.languageswitcher}">
            <xsl:text> </xsl:text>
          </script>
        </xsl:if>
      </head>

      <body>
        <xsl:call-template name="body.attributes"/>
        <xsl:call-template name="outerelement.class.attribute"/>

        <xsl:choose>
          <xsl:when test="boolean($include.suse.header)">
            <xsl:call-template name="suse-header-body" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="bypass" />
            <xsl:call-template name="user.header.content" />
          </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="breadcrumbs.navigation"/>

        <main id="_content">
          <!-- fake a sidebar, for single HTML, we only ever use the sidebar on
          the right -->
          <nav class="side-toc placebo" id="_side-toc-overall"><xsl:text> </xsl:text></nav>

          <article class="documentation">

            <button id="_unfold-side-toc-page">
              <xsl:call-template name="gentext">
                <xsl:with-param name="key" select="'onthispage'"/>
              </xsl:call-template>
            </button>
            <xsl:apply-templates select="."/>

          </article>

          <xsl:call-template name="side.toc.page"/>

        </main>

        <xsl:call-template name="user.footer.content"/>

        <xsl:if test="$show.language-switcher = 1">
          <xsl:call-template name="language-switcher" />
        </xsl:if>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="user.head.content">
    <xsl:param name="node" select="."/>

    <xsl:if test="$build.for.web = 1">
      <!-- CORS issue: "https://www.suse.com/assets/css/google-fonts-suse.css?avs=1733925891" -->
      <link type="text/css" rel="preload" as="style" onload="this.rel='stylesheet'"
        href="https://documentation.suse.com/docserv/res/fonts/suse/suse.css" />
    </xsl:if>
<!--     <xsl:if test="$daps.header.js.library != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.library"/>
      </xsl:call-template>
    </xsl:if> -->
    <xsl:if test="$daps.header.js.custom != ''">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.custom"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$enable.source.highlighting = 1">
      <xsl:call-template name="make.script.link">
        <xsl:with-param name="script.filename" select="$daps.header.js.highlight"/>
      </xsl:call-template>
      <script>hljs.highlightAll();</script>
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
    <xsl:call-template name="generate.meta.reportbug"/>
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


  <xsl:template name="user.header.content">
    <xsl:variable name="lang-attr">
      <xsl:call-template name="get-lang-for-ssi"/>
    </xsl:variable>

    <header id="_mainnav">
      <div class="growth-inhibitor">
        <xsl:call-template name="create.header.logo" />
      </div>
    </header>
  </xsl:template>

  <xsl:template name="user.footer.content">
    <footer id="_footer">
      <div class="growth-inhibitor">
        <div class="copy">
          <span class="copy__rights">© SUSE <xsl:if
              test="function-available('date:year')">
              <xsl:text> </xsl:text>
              <xsl:value-of select="date:year()" />
            </xsl:if>
          </span>
        </div>
      </div>
    </footer>
  </xsl:template>


  <xsl:template name="side.toc.page">
    <aside id="_side-toc-page" class="side-toc">
      <!-- FIXME suse22: Does not work correctly for single-page sets & books
      (but does work for articles). So just disable it in that case for now and
      focus on chunked HTML ... -->
      <xsl:if test="$is.chunk != 0 or self::d:article">
        <xsl:if test="(not(self::d:part or self::d:book or self::d:set) or $is.chunk = 0)
                      and (./d:section or ./d:sect1 or ./d:sect2 or ./d:sect3 or
                           ./d:sect4 or ./d:sect5 or
                           ./d:refsect1 or ./d:refsect2 or ./d:refsect3 or
                           ./d:topic or ./d:simplesect or
                           ./d:book or ./d:article or ./d:chapter or ./d:preface or
                           ./d:appendix or ./d:part)">
          <xsl:variable name="toc.params">
            <xsl:call-template name="find.path.params">
              <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
            </xsl:call-template>
          </xsl:variable>
          <div class="side-title">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'onthispage'"/>
            </xsl:call-template>
          </div>

          <xsl:call-template name="make.lots">
            <xsl:with-param name="toc.params" select="$toc.params"/>
            <xsl:with-param name="toc">
              <xsl:call-template name="component.toc"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>

      <xsl:call-template name="give.feedback"/>
      <xsl:call-template name="share.and.print"/>
      <xsl:call-template name="qualtrics.rating"/>
      <xsl:text> </xsl:text>
    </aside>
    <xsl:call-template name="doc-survey"/>
  </xsl:template>

</xsl:stylesheet>

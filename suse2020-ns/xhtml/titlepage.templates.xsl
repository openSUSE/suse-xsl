<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Create customized title pages for book and article

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
  xmlns:dm="urn:x-suse:ns:docmanager"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="dm d">

  <xsl:template name="product.name">
    <xsl:choose>
      <xsl:when test="*/d:productname[not(@role='abbrev')]">
        <!-- One can use role="abbrev" to additionally store a short version
             of the productname. This is helpful to make the best of the space
             available in the living column titles of the FO version.
             In our case, we'd rather have the long version, though. Dito for
             the productnumber below. -->
        <xsl:apply-templates select="(*/d:productname[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:when test="*/d:productname">
        <xsl:apply-templates select="(*/d:productname)[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productname[not(@role='abbrev')]">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productname[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productname)[last()]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="product.number">
    <xsl:choose>
      <xsl:when test="*/d:productnumber[not(@role='abbrev')]">
        <!-- See comment in product.name... -->
        <xsl:apply-templates select="(*/d:productnumber[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:when test="*/d:productnumber">
        <xsl:apply-templates select="(*/d:productnumber)[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productnumber[not(@role='abbrev')]">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productnumber[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productnumber)[last()]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="version.info">
    <xsl:param name="prefaced" select="0"/>
    <xsl:variable name="product-name">
      <xsl:call-template name="product.name"/>
    </xsl:variable>
    <xsl:variable name="product-number">
      <xsl:call-template name="product.number"/>
    </xsl:variable>

    <xsl:if test="$prefaced = 1 and ($product-name != '' or $product-number != '')">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">version.info</xsl:with-param>
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:copy-of select="$product-name"/>
    <xsl:if test="$product-name != '' and $product-number != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:copy-of select="$product-number"/>
  </xsl:template>

  <xsl:template name="vcs.url">
   <xsl:variable name="dm" select="*/dm:docmanager"/>
   <xsl:variable name="url" select="$dm/dm:vcs/dm:url"/>
   <xsl:if test="$dm and $url">
    <xsl:variable name="vcs.text">
     <xsl:choose>
      <xsl:when test="contains($url, 'github.com')">GitHub</xsl:when>
      <xsl:when test="contains($url, 'gitlab')">GitLab</xsl:when>
      <xsl:when test="contains($url, 'svn')">SVN</xsl:when>
      <xsl:otherwise>VCS URL</xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <div class="vcsurl">
     <p><span class="vcshead">Source XML:</span>&#xa0;<a target="_blank" href="{$url}"><xsl:value-of select="$vcs.text"/></a></p>
    </div>
   </xsl:if>
  </xsl:template>

  <xsl:template name="version.info.page-top">
    <xsl:variable name="info-text">
      <xsl:call-template name="version.info">
        <xsl:with-param name="prefaced" select="1"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$generate.version.info != 0 and $info-text != '' and
                  ($is.chunk = 1 or
                  (local-name(.) = 'article' or local-name(.) = 'book'))">
      <div class="version-info"><xsl:copy-of select="$info-text"/></div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="version.info.headline">
    <xsl:variable name="info-text">
      <xsl:call-template name="version.info">
        <xsl:with-param name="prefaced" select="0"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$generate.version.info != 0 and $info-text != ''">
      <h6 class="version-info"><xsl:copy-of select="$info-text"/></h6>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add.authorgroup">
    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <div>
        <span class="imprint-label">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">
              <xsl:choose>
                <xsl:when test="count(d:author|d:corpauthor) > 1">Authors</xsl:when>
                <xsl:otherwise>Author</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:text>: </xsl:text>
        </span>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list"
            select="d:author|d:corpauthor"/>
        </xsl:call-template>
      </div>
      <xsl:if test="d:othercredit|d:editor">
        <xsl:call-template name="add.othercredit"/>
      </xsl:if>
    </div>
  </xsl:template>

<xsl:template name="add.othercredit">
  <div>
    <xsl:call-template name="generate.class.attribute"/>
    <span class="imprint-label">
       <xsl:call-template name="gentext">
         <xsl:with-param name="key">
            <xsl:choose>
              <xsl:when test="count((../d:othercredit)|(../d:editor)) > 1"
                >Contributors</xsl:when>
              <xsl:otherwise>Contributor</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      <xsl:text>: </xsl:text>
    </span>
    <xsl:call-template name="person.name.list">
      <xsl:with-param name="person.list"
        select="(../d:othercredit)|(../d:editor)"/>
    </xsl:call-template>
  </div>
</xsl:template>


  <!-- ===================================================== -->
  <xsl:template name="part.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="preface.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="appendix.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="glossary.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="reference.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="chapter.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>
  <xsl:template name="bibliography.titlepage.before.recto">
    <xsl:call-template name="version.info.page-top"/>
  </xsl:template>


  <!-- ===================================================== -->
  <!-- article titlepage templates -->
  <xsl:template match="d:authorgroup" mode="article.titlepage.recto.auto.mode">
    <xsl:call-template name="add.authorgroup"/>
  </xsl:template>

  <xsl:template match="d:othercredit|d:editor" mode="article.titlepage.recto.auto.mode">
    <xsl:if test=". = ((../d:othercredit)|(../d:editor))[1]">
      <xsl:call-template name="add.othercredit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:author" mode="article.titlepage.recto.auto.mode">
    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <span class="imprint-label">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Author</xsl:with-param>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      </span>
      <xsl:call-template name="person.name"/>
    </div>
  </xsl:template>

  <xsl:template match="d:abstract" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template name="article.titlepage.before.recto">
    <xsl:call-template name="version.info.headline"/>
  </xsl:template>

  <xsl:template name="article.titlepage.recto">
        <xsl:choose>
            <xsl:when test="d:articleinfo/d:title">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:title"/>
            </xsl:when>
            <xsl:when test="d:artheader/d:title">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:title"/>
            </xsl:when>
            <xsl:when test="d:info/d:title">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:title"/>
            </xsl:when>
            <xsl:when test="d:title">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="fallback.title"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="d:articleinfo/d:subtitle">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:subtitle"/>
            </xsl:when>
            <xsl:when test="d:artheader/d:subtitle">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:subtitle"/>
            </xsl:when>
            <xsl:when test="d:info/d:subtitle">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:subtitle"/>
            </xsl:when>
            <xsl:when test="d:subtitle">
                <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:subtitle"/>
            </xsl:when>
        </xsl:choose>

        <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:abstract"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:abstract"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:abstract"/>
        <!-- Moved authors and authorgroups here: -->
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:author"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:author"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:author"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:othercredit"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:editor"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:editor"/>

        <xsl:call-template name="date.and.revision"/>
        <xsl:call-template name="vcs.url"/>

        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:copyright"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:copyright"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
  </xsl:template>

  <xsl:template name="article.titlepage.separator">
    <!-- Don't insert a horizontal rule after article titles. -->
  </xsl:template>

  <!-- ===================================================== -->
  <!-- set titlepage templates -->

  <xsl:template name="set.titlepage.separator"/>

  <xsl:template name="set.titlepage.before.recto">
    <xsl:call-template name="version.info.headline"/>
  </xsl:template>

<xsl:template name="set.titlepage.recto">
  <xsl:choose>
    <xsl:when test="d:setinfo/d:title">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:title"/>
    </xsl:when>
    <xsl:when test="d:info/d:title">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:title"/>
    </xsl:when>
    <xsl:when test="d:title">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:title"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="fallback.title"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="d:setinfo/d:subtitle">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:subtitle"/>
    </xsl:when>
    <xsl:when test="d:info/d:subtitle">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:subtitle"/>
    </xsl:when>
    <xsl:when test="d:subtitle">
      <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:subtitle"/>
    </xsl:when>
  </xsl:choose>

  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:corpauthor"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:authorgroup"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:author"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:author"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:othercredit"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:othercredit"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:releaseinfo"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:releaseinfo"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:copyright"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:legalnotice"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:legalnotice"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:pubdate"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:pubdate"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:revision"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:revision"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:revhistory"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:revhistory"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:setinfo/d:abstract"/>
  <xsl:apply-templates mode="set.titlepage.recto.auto.mode" select="d:info/d:abstract"/>
</xsl:template>
  <!-- ===================================================== -->
  <!-- book titlepage templates -->

  <xsl:template name="book.titlepage.separator"/>

  <xsl:template name="book.titlepage.before.recto">
    <xsl:call-template name="version.info.headline"/>
  </xsl:template>

  <xsl:template name="book.titlepage.recto">
        <xsl:choose>
            <xsl:when test="d:bookinfo/d:title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:title"/>
            </xsl:when>
            <xsl:when test="d:info/d:title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:title"/>
            </xsl:when>
            <xsl:when test="d:title">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="fallback.title"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="d:bookinfo/d:subtitle">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:subtitle"/>
            </xsl:when>
            <xsl:when test="d:info/d:subtitle">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:subtitle"/>
            </xsl:when>
            <xsl:when test="d:subtitle">
                <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:subtitle"/>
            </xsl:when>
        </xsl:choose>
        <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:abstract"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:abstract"/>

        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:corpauthor"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:authorgroup"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:author"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:author"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:othercredit"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:othercredit"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:editor"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:editor"/>

        <xsl:call-template name="date.and.revision"/>
        <xsl:call-template name="vcs.url"/>

        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:bibliosource"/>

        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:copyright"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
  </xsl:template>

  <xsl:template match="d:authorgroup" mode="book.titlepage.recto.auto.mode">
    <xsl:call-template name="add.authorgroup"/>
  </xsl:template>


  <xsl:template match="d:othercredit|d:editor" mode="book.titlepage.recto.auto.mode">
    <xsl:if test=". = ((../d:othercredit)|(../d:editor))[1]">
      <xsl:call-template name="add.othercredit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:author" mode="book.titlepage.recto.auto.mode">
    <div>
      <span class="imprint-label">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Author</xsl:with-param>
      </xsl:call-template>
      <xsl:text>: </xsl:text>
      </span>
      <xsl:call-template name="person.name"/>
    </div>
  </xsl:template>

  <xsl:template match="d:abstract" mode="book.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

<xsl:template name="date.and.revision">
    <div class="date">
      <xsl:call-template name="date.and.revision.inner"/>
    </div>
</xsl:template>

<xsl:template name="imprint.label">
  <xsl:param name="label" select="'PubDate'"/>

  <span class="imprint-label">
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="$label"/>
    </xsl:call-template>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'admonseparator'"/>
    </xsl:call-template>
  </span>
</xsl:template>

<xsl:template name="fallback.title">
  <div>
    <h1 class="title">
      <span class="name">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="local-name(.)"/>
        </xsl:call-template>
      </span>
    </h1>
  </div>
</xsl:template>

</xsl:stylesheet>

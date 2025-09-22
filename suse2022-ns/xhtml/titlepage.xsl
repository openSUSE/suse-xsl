<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Add permalink to titlepage template

  Output:
     Creates <h1> headline.

   Author(s):   Stefan Knorr <sknorr@suse.de>
   Copyright:   2012, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d"
  >


<xsl:template match="d:book/d:title|d:article/d:title|d:set/d:title" mode="titlepage.mode">
  <xsl:variable name="id">
    <xsl:choose>
      <!-- if title is in an *info wrapper, get the grandparent -->
      <xsl:when test="parent::d:info">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="../.."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="title-container">
  <h1>
    <xsl:apply-templates select="." mode="common.html.attributes"/>
    <xsl:choose>
      <xsl:when test="$generate.id.attributes = 0">
        <a id="{$id}"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$show.revisionflag != 0 and @revisionflag">
    <span class="{@revisionflag}">
      <xsl:apply-templates mode="titlepage.mode"/>
    </span>
      </xsl:when>
      <xsl:otherwise>
    <xsl:apply-templates mode="titlepage.mode"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:call-template name="create.permalink">
      <xsl:with-param name="object" select=".."/>
    </xsl:call-template>
  </h1>
  <xsl:call-template name="generate.title.icons"/>
  </div>
</xsl:template>

<!-- ============================================================== -->
<!-- revhistory handling -->
<xsl:template match="d:revhistory" mode="titlepage.mode">
    <xsl:variable name="revhistory.text">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'RevHistory'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="empty.title">
      <d:title>
        <xsl:value-of select="$revhistory.text"/>
        <xsl:if test="$revision.add.div.title">
          <xsl:text>: </xsl:text>
          <xsl:choose>
            <xsl:when test="$rootid">
              <xsl:value-of
                select="(key('id', $rootid)/d:title | key('id', $rootid)/d:info/d:title)[1]"
               />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="(/*/d:title | /*/d:info/d:title)[1]" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </d:title>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="d:title | d:info/d:title">
          <xsl:apply-templates select="(d:title | d:info/d:title)[1]"
            mode="titlepage.mode" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="exsl:node-set($empty.title)/*"
            mode="titlepage.mode" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="contents">
      <div>
        <xsl:apply-templates select="." mode="common.html.attributes" />
        <xsl:call-template name="id.attribute" />

        <xsl:copy-of select="$title" />
        <xsl:choose>
          <xsl:when test="$revision.limit != '' and number($revision.limit) > 2">
            <xsl:apply-templates select="d:revision[position() &lt;= $revision.limit]" mode="titlepage.mode" >
              <xsl:sort order="descending" select="number(translate(d:date, '-', ''))"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="d:revision" mode="titlepage.mode" >
              <xsl:sort order="descending" select="number(translate(d:date, '-', ''))"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$generate.revhistory.link != 0">

        <!-- Compute name of revhistory file -->
        <xsl:variable name="file">
          <xsl:call-template name="ln.or.rh.filename">
            <xsl:with-param name="is.ln" select="false()" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="filename">
          <xsl:call-template name="make-relative-filename">
            <xsl:with-param name="base.dir" select="$chunk.base.dir" />
            <xsl:with-param name="base.name" select="$file" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="lang-scope" select="ancestor-or-self::*[@xml:lang][1]"/>
        <xsl:variable name="candidate.lang">
          <xsl:call-template name="l10n.language">
            <xsl:with-param name="target" select="$lang-scope"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="str.title" select="string($title)"/>

        <!-- Create the link to the revhistory page -->
        <div class="titlepage-revhistory">
          <a aria-label="{$str.title}" hreflang="{$candidate.lang}"
             href="{$file}" target="_blank"><xsl:copy-of select="$str.title" /></a>
        </div>

        <xsl:call-template name="write.chunk">
          <xsl:with-param name="filename" select="$filename" />
          <xsl:with-param name="quiet" select="$chunk.quietly" />
          <xsl:with-param name="content">
            <xsl:call-template name="user.preroot" />
            <html lang="{$candidate.lang}" xml:lang="{$candidate.lang}">
              <head>
                <xsl:call-template name="system.head.content" />
                <xsl:call-template name="head.content">
                  <xsl:with-param name="title">
                    <xsl:value-of select="$title" />
                    <xsl:if test="../../d:title">
                      <xsl:value-of select="concat(' (', ../../d:title, ')')" />
                    </xsl:if>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="user.head.content" />
              </head>
              <body>
                <xsl:call-template name="body.attributes" />
                <xsl:copy-of select="$contents" />
              </body>
            </html>
            <xsl:text>
</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$contents" />
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template match="d:revhistory/d:revision" mode="titlepage.mode">
  <xsl:variable name="revnumber" select="d:revnumber"/>
  <xsl:variable name="revauthor" select="d:authorinitials|d:author"/>
  <xsl:variable name="revremark" select="d:revremark|d:revdescription"/>

  <section>
    <xsl:apply-templates select="." mode="common.html.attributes"/>
    <xsl:call-template name="id.attribute" />

    <h2>
      <span class="revision date"><xsl:apply-templates select="d:date" mode="titlepage.mode"/></span>
      <xsl:if test="$revnumber">
        <span class="revision sep"> | </span>
          <span>
            <xsl:apply-templates select="$revnumber[1]" mode="titlepage.mode" />
          </span>
      </xsl:if>
    </h2>

    <xsl:if test="$revauthor">
      <p>
        <xsl:for-each select="$revauthor">
            <xsl:apply-templates select="." mode="titlepage.mode"/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
      </p>
    </xsl:if>

    <xsl:apply-templates select="*[not(self::d:date or
                                       self::d:revnumber or
                                       self::d:author or
                                       self::d:authorinitials)]" mode="titlepage.mode"/>
  </section>
</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     The title page for articles



   Authors:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2022 Thomas Schraitle
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">

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
        </span>
        <xsl:for-each select="d:author">
          <xsl:apply-templates select="." mode="article.titlepage.recto.auto.mode">
            <xsl:with-param name="withlabel" select="0"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </div>
    </div>
    <xsl:if test="d:othercredit|d:editor">
      <xsl:call-template name="add.othercredit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="add.othercredit">
    <div class="othercredit">
      <xsl:call-template name="generate.class.attribute"/>
      <span class="imprint-label">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">
            <xsl:choose>
              <xsl:when test="count(d:othercredit|d:editor) > 1"
                >Contributors</xsl:when>
              <xsl:otherwise>Contributor</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </span>
      <xsl:for-each select="d:editor|d:othercredit">
        <xsl:apply-templates select="." mode="article.titlepage.recto.auto.mode">
          <xsl:with-param name="withlabel" select="0"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="d:author[d:personname]|d:editor[d:personname]|d:othercredit[d:personname]" mode="article.titlepage.recto.auto.mode">
    <xsl:param name="withlabel" select="1"/>
    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <xsl:if test="$withlabel != 0">
        <span class="imprint-label">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">Author</xsl:with-param>
          </xsl:call-template>
        </span>
      </xsl:if>

      <xsl:call-template name="person.name">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>

      <xsl:if test="d:affiliation">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="d:affiliation/d:jobtitle" mode="article.titlepage.recto.auto.mode"/>
        <xsl:apply-templates select="d:affiliation/d:orgname" mode="article.titlepage.recto.auto.mode"/>
      </xsl:if>
    </div>
  </xsl:template>


  <xsl:template match="d:author[d:orgname]|d:editor[d:orgname]|d:othercredit[d:orgname]" mode="article.titlepage.recto.auto.mode">
    <xsl:param name="withlabel" select="1"/>
    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <xsl:apply-templates select="d:orgname"/>
      <xsl:if test="d:affiliation">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="d:affiliation/d:jobtitle" mode="article.titlepage.recto.auto.mode"/>
        <xsl:apply-templates select="d:affiliation/d:orgname" mode="article.titlepage.recto.auto.mode"/>
      </xsl:if>
      <!-- In case we want e-mail addresses: -->
      <!--<xsl:apply-templates select="d:email" mode="article.titlepage.recto.auto.mode"/>-->
    </div>
  </xsl:template>


  <xsl:template match="d:affiliation/d:jobtitle"  mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="d:affiliation/d:orgname"  mode="article.titlepage.recto.auto.mode">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="d:cover" mode="article.titlepage.recto.auto.mode">
    <div class="cover">
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <xsl:template name="_article.titlepage.before.recto">

<!--    <xsl:call-template name="version.info.page-top"/>-->
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

    <div class="series-category">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='series']"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='category']"/>
    </div>

    <!-- Moved authors and authorgroups here: -->
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:othercredit"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:othercredit"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:editor"/>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:cover"/>

    <div class="platforms">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='platform']"/>
    </div>

    <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:abstract"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:abstract"/>

    <xsl:call-template name="date.and.revision"/>
    <xsl:call-template name="vcs.url"/>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:copyright"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
  </xsl:template>

  <xsl:template match="d:meta" name="meta">
    <xsl:param name="class" select="@name"/><!-- default -->
    <xsl:param name="element">div</xsl:param>
    <xsl:element name="{$element}">
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:meta[@name='series']" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="d:meta[@name='category']" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="d:meta[@name='platform']" mode="article.titlepage.recto.auto.mode">
    <div>
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="@name"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
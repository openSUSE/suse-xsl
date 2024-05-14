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
          <xsl:apply-templates select="." mode="authorgroup">
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
        <xsl:apply-templates select="." mode="authorgroup">
          <xsl:with-param name="withlabel" select="0"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="d:info/d:abstract" mode="article.titlepage.recto.auto.mode">
    <div class="abstract">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"/>
    </div>
  </xsl:template>
  <xsl:template match="d:info/d:abstract/d:title" mode="article.titlepage.recto.auto.mode">
    <div class="title">
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="d:abstract/d:*" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="d:author[d:personname]|d:editor[d:personname]|d:othercredit[d:personname]"  mode="authorgroup">
    <xsl:param name="withlabel" select="1"/>
<!--<xsl:message>d:<xsl:value-of select="local-name(.)"/>[d:personname]</xsl:message>  -->

    <div>
      <xsl:call-template name="generate.class.attribute"/>
      <xsl:if test="$withlabel != 0">
        <span class="imprint-label">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">Author</xsl:with-param>
          </xsl:call-template>
        </span>
        <xsl:text>: </xsl:text>
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


  <xsl:template match="d:author[d:orgname]|d:editor[d:orgname]|d:othercredit[d:orgname]" mode="authorgroup">
    <xsl:param name="withlabel" select="1"/>
<!--    <xsl:message>d:<xsl:value-of select="local-name(.)"/>[d:orgname]</xsl:message>-->

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


  <xsl:template match="d:info/d:date" mode="article.titlepage.recto.auto.mode">
    <div class="date">
      <span class="imprint-label">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">Date</xsl:with-param>
        </xsl:call-template>
      </span>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="." mode="titlepage.mode"/>
    </div>
  </xsl:template>


  <xsl:template match="d:info/d:author[1]" mode="article.titlepage.recto.auto.mode">
    <xsl:variable name="rtf.authorgroup">
      <d:authorgroup>
        <xsl:copy-of select=". | following-sibling::d:author"/>
        <xsl:copy-of select="preceding-sibling::d:editor"/>
        <xsl:copy-of select="following-sibling::d:editor"/>
        <xsl:copy-of select="preceding-sibling::d:othercredit"/>
        <xsl:copy-of select="following-sibling::d:othercredit"/>
      </d:authorgroup>
    </xsl:variable>
    <xsl:variable name="authorgroup" select="exsl:node-set($rtf.authorgroup)"/>

    <!--<xsl:message>author[1] mode="article.titlepage.recto.auto.mode"
      content of authorgroup = <xsl:value-of select="count($authorgroup/*/*)"/>
      following-sibling::d:author=<xsl:value-of select="count(following-sibling::d:author)"/>

      following-sibling::d:editor=<xsl:value-of select="count(following-sibling::d:editor)"/>
      preceding-sibling::d:editor=<xsl:value-of select="count(preceding-sibling::d:editor)"/>
      following-sibling::d:othercredit=<xsl:value-of select="count(following-sibling::d:othercredit)"/>
      preceding-sibling::d:othercredit=<xsl:value-of select="count(preceding-sibling::d:othercredit)"/>
    </xsl:message>-->

    <!-- Delegate all collected nodes to the authorgroup template -->
    <xsl:apply-templates select="$authorgroup" mode="article.titlepage.recto.auto.mode"/>
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
    <div class="series"><xsl:value-of select="$json-ld-seriesname"/></div>
  </xsl:template>


  <xsl:template match="d:meta[@name='category' or @name='type']" mode="article.titlepage.recto.auto.mode">
    <div class="category">
      <xsl:for-each select="*">
        <p class="{local-name()}"><xsl:apply-templates/></p>
      </xsl:for-each>
    </div>
  </xsl:template>


  <xsl:template match="d:meta[@name='platform']" mode="article.titlepage.recto.auto.mode">
    <div>
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="@name"/>
      </xsl:call-template>
      <xsl:apply-templates mode="titlepage.mode"/>
    </div>
  </xsl:template>


  <xsl:template name="add.series.name">
    <xsl:choose>
      <xsl:when test="$json-ld-seriesname != ''">
        <div class="series"><xsl:value-of select="$json-ld-seriesname"/></div>
      </xsl:when>
      <xsl:when test="d:info/d:meta[@name='series']">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='series']"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- XHTML titlepage -->
  <xsl:template name="article.titlepage.recto">
    <!-- TITLE -->
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

    <!-- SUBTITLE -->
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
      <xsl:comment/>
      <xsl:call-template name="add.series.name"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='category' or @name='type']"/>
    </div>

    <!-- Moved authors and authorgroups here: -->
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <!-- We match only the first author and group every author, editor, and othercredit -->
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:author[1]"/>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:cover"/>

    <div class="platforms">
      <xsl:comment/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='platform']"/>
    </div>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:date"/>

    <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:abstract"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:abstract"/>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:copyright"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
  </xsl:template>

</xsl:stylesheet>

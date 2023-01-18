<?xml version="1.0" encoding="UTF-8"?>
<!--

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template match="d:cover" mode="book.titlepage.recto.auto.mode">
    <div class="cover">
      <xsl:apply-templates select="*"/>
    </div>
  </xsl:template>

  <xsl:template match="d:meta[@name='series']" mode="book.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="d:meta[@name='category' or @name='type']" mode="book.titlepage.recto.auto.mode">
    <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="d:meta[@name='platform']" mode="book.titlepage.recto.auto.mode">
    <div>
      <xsl:call-template name="generate.class.attribute">
        <xsl:with-param name="class" select="@name"/>
      </xsl:call-template>
      <xsl:apply-templates mode="titlepage.mode"/>
    </div>
  </xsl:template>


  <xsl:template match="d:affiliation/d:jobtitle"  mode="book.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="d:affiliation/d:orgname"  mode="book.titlepage.recto.auto.mode">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  <xsl:template match="d:info/d:author[1]" mode="book.titlepage.recto.auto.mode">
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

    <xsl:message>author[1] mode="book.titlepage.recto.auto.mode"
      content of authorgroup = <xsl:value-of select="count($authorgroup/*/*)"/>
      following-sibling::d:author=<xsl:value-of select="count(following-sibling::d:author)"/>

      following-sibling::d:editor=<xsl:value-of select="count(following-sibling::d:editor)"/>
      preceding-sibling::d:editor=<xsl:value-of select="count(preceding-sibling::d:editor)"/>
      following-sibling::d:othercredit=<xsl:value-of select="count(following-sibling::d:othercredit)"/>
      preceding-sibling::d:othercredit=<xsl:value-of select="count(preceding-sibling::d:othercredit)"/>
    </xsl:message>

    <!-- Delegate all collected nodes to the authorgroup template -->
    <xsl:apply-templates select="$authorgroup" mode="book.titlepage.recto.auto.mode"/>
  </xsl:template>


  <xsl:template match="d:info/d:date" mode="book.titlepage.recto.auto.mode">
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

  <!-- XHTML book titlepage -->
  <xsl:template name="book.titlepage.recto">
    <xsl:message>book.titlepage.recto</xsl:message>
    <!-- TITLE -->
    <xsl:choose>
      <xsl:when test="d:bookinfo/d:title">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:bookinfo/d:title" />
      </xsl:when>
      <xsl:when test="d:info/d:title">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:info/d:title" />
      </xsl:when>
      <xsl:when test="d:title">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:title" />
      </xsl:when>
    </xsl:choose>

    <!-- SUBTITLE -->
    <xsl:choose>
      <xsl:when test="d:bookinfo/d:subtitle">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:bookinfo/d:subtitle" />
      </xsl:when>
      <xsl:when test="d:info/d:subtitle">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:info/d:subtitle" />
      </xsl:when>
      <xsl:when test="d:subtitle">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:subtitle" />
      </xsl:when>
    </xsl:choose>

    <div class="series-category">
      <xsl:comment/>
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:meta[@name='series']"/>
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:meta[@name='category' or @name='type']"/>
    </div>

    <!-- Moved authors and authorgroups here: -->
    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <!-- We match only the first author and group every author, editor, and othercredit -->
    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:author[1]"/>

    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:cover"/>

    <div class="platforms">
      <xsl:comment/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:meta[@name='platform']"/>
    </div>

    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:date"/>

    <!-- Legal notice removed from here, now positioned at the bottom of the page, see: division.xsl -->
    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:abstract"/>

    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:copyright"/>

  </xsl:template>

</xsl:stylesheet>
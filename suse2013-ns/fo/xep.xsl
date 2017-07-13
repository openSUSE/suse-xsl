<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl d">

  <xsl:template name="xep-document-information">
  <rx:meta-info>
    <xsl:variable name="authors"
                  select="(//d:author|//d:editor|//d:corpauthor|//d:authorgroup)[1]"/>
    <xsl:if test="$authors">
      <xsl:variable name="author">
        <xsl:choose>
          <xsl:when test="$authors[self::d:authorgroup]">
            <xsl:call-template name="person.name.list">
              <xsl:with-param name="person.list"
                        select="$authors/*[self::d:author|self::d:corpauthor|
                               self::d:othercredit|self::d:editor]"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$authors[self::d:corpauthor]">
            <xsl:value-of select="$authors"/>
          </xsl:when>
          <xsl:when test="$authors[d:orgname]">
            <xsl:value-of select="$authors/d:orgname"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="person.name">
              <xsl:with-param name="node" select="$authors"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="rx:meta-field">
        <xsl:attribute name="name">author</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:value-of select="normalize-space($author)"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:variable name="node"
      select="(/* | key('id', $rootid))[last()]"/>

    <xsl:variable name="title">
      <xsl:apply-templates select="$node[1]" mode="label.markup"/>
      <xsl:apply-templates select="$node[1]" mode="title.markup"/>
      <xsl:variable name="productname">
          <xsl:value-of select="$node[1]/*/d:productname[1]"/>
      </xsl:variable>
      <xsl:variable name="productnumber">
         <xsl:value-of select="$node[1]/*/d:productnumber[1]"/>
      </xsl:variable>
      <xsl:if test="$productname != ''">
        <!-- Checking for productname only is not an oversight - if there is
             no name, we likely don't want to display the version either. -->
         <xsl:text> - </xsl:text>
         <xsl:value-of select="$productname"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="$productnumber"/>
      </xsl:if>
    </xsl:variable>

    <xsl:element name="rx:meta-field">
      <xsl:attribute name="name">creator</xsl:attribute>
      <xsl:attribute name="value">
        <xsl:value-of select="$pdf-creator"/>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="rx:meta-field">
      <xsl:attribute name="name">title</xsl:attribute>
      <xsl:attribute name="value">
        <xsl:value-of select="normalize-space($title)"/>
      </xsl:attribute>
    </xsl:element>

    <xsl:if test="//d:keyword">
      <xsl:element name="rx:meta-field">
        <xsl:attribute name="name">keywords</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:for-each select="//d:keyword">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <xsl:if test="//d:subjectterm">
      <xsl:element name="rx:meta-field">
        <xsl:attribute name="name">subject</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:for-each select="//d:subjectterm">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
  </rx:meta-info>
</xsl:template>

  <xsl:template match="d:set|d:book|d:article" mode="xep.outline">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="bookmark-label">
      <xsl:apply-templates select="." mode="object.title.markup"/>
    </xsl:variable>
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table"
          select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$bookmark-label != ''">
        <rx:bookmark internal-destination="{$id}">
          <rx:bookmark-label>
            <xsl:value-of select="normalize-space($bookmark-label)"/>
          </rx:bookmark-label>
        </rx:bookmark>
      </xsl:if>

      <xsl:if test="contains($toc.params, 'toc')
                    and d:set|d:book|d:part|d:reference|d:section|d:sect1|d:refentry
                        |d:article|d:topic|d:bibliography|d:glossary|d:chapter
                        |d:appendix">
        <rx:bookmark internal-destination="toc...{$id}">
          <rx:bookmark-label>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
          </rx:bookmark-label>
        </rx:bookmark>
      </xsl:if>
      <xsl:apply-templates select="*" mode="xep.outline"/>
  </xsl:template>

</xsl:stylesheet>

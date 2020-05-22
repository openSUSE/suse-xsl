<?xml version='1.0'?>
<!--
  Purpose:
    Rework the structure of Tables of Contents in Parts.

  Author(s):  Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Thomas Schraitle, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet exclude-result-prefixes="d"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version='1.0'>

<xsl:template name="division.part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="nodes"
                select="$toc-context/d:part
                        |$toc-context/d:reference
                        |$toc-context/d:preface
                        |$toc-context/d:chapter
                        |$toc-context/d:appendix
                        |$toc-context/d:article
                        |$toc-context/d:topic
                        |$toc-context/d:bibliography
                        |$toc-context/d:glossary
                        |$toc-context/d:index"/>


  <xsl:apply-templates select="$nodes" mode="part.toc">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="d:reference" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>

</xsl:template>

<xsl:template match="d:preface|d:chapter|d:appendix|d:article" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="d:bibliography|d:glossary" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="toc.part.line">
    <xsl:with-param name="toc-context" select="$toc-context"/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="d:index" mode="part.toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:if test="* or $generate.index != 0">
    <xsl:call-template name="toc.part.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template name="toc.part.line">
  <xsl:param name="toc-context" select="NOTANODE"/>

  <xsl:variable name="line-height" select="concat($base-lineheight, 'em')"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">
    <xsl:apply-templates select="." mode="label.markup"/>
  </xsl:variable>

  <fo:list-item>
    <fo:list-item-label end-indent="label-end()">
      <fo:block text-align="end" width="&column;mm" font-family="{$title.fontset}"
        font-size="{&large; * $sans-fontsize-adjust}pt" line-height="{$line-height}">
        <fo:basic-link internal-destination="{$id}">
          <xsl:if test="$label != ''">
            <xsl:copy-of select="$label"/>
          </xsl:if>
        </fo:basic-link>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block line-height="{$line-height}" padding-after="{&gutter; div 2}mm">
        <fo:basic-link internal-destination="{$id}">
          <fo:inline keep-with-next.within-line="always"
            font-family="{$title.fontset}" font-size="{&large; * $sans-fontsize-adjust}pt">
            <xsl:apply-templates select="." mode="titleabbrev.markup"/>
          </fo:inline>
          <fo:leader leader-pattern="space" leader-length="&gutterfragment;mm"
            keep-with-next.within-line="always"/>
          <fo:inline keep-together.within-line="always" font-size="{&large; * $sans-fontsize-adjust}pt"
            xsl:use-attribute-sets="toc.pagenumber.properties" color="&mid-gray;">
            <fo:page-number-citation ref-id="{$id}"/>
          </fo:inline>
        </fo:basic-link>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<!-- =================================================================== -->
<xsl:param name="page.debug" select="0"/>

<xsl:template name="toc.label">
  <xsl:param name="node" select="."/>

  <fo:block text-align="start">
      <xsl:apply-templates select="$node" mode="label.markup"/>
  </fo:block>
</xsl:template>

<xsl:template name="toc.title">
    <xsl:param name="node" select="."/>
    <xsl:param name="wrapper.name">fo:block</xsl:param>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <xsl:element name="{$wrapper.name}">
      <fo:basic-link internal-destination="{$id}">
        <fo:inline hyphenate="false">
          <xsl:apply-templates select="$node" mode="titleabbrev.markup"/>
        </fo:inline>
        <fo:leader leader-pattern="space" leader-length="&gutterfragment;mm"
          keep-with-next.within-line="always"/>
        <fo:inline xsl:use-attribute-sets="toc.pagenumber.properties">
          <fo:page-number-citation ref-id="{$id}"/>
        </fo:inline>
      </fo:basic-link>
    </xsl:element>
</xsl:template>

<xsl:template name="toc.line">
    <xsl:param name="toc-context" select="NOTANODE"/>
    <xsl:apply-templates select="." mode="susetoc"/>
</xsl:template>

<xsl:template match="*" mode="susetoc">
    <xsl:call-template name="log.message">
      <xsl:with-param name="level">WARNING</xsl:with-param>
      <xsl:with-param name="context-desc">toc</xsl:with-param>
      <xsl:with-param name="context-desc-field-length" select="4"/>
      <xsl:with-param name="message">
        <xsl:text>Unknown TOC element </xsl:text>
        <xsl:value-of select="local-name()"/>
      </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="d:part" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>

    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>


    <fo:list-block xsl:use-attribute-sets="toc.level1.properties" relative-align="baseline"
       space-before="&columnfragment;mm"
       space-after="&gutterfragment;mm"
       keep-with-next.within-column="always"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
        <fo:list-item>
          <fo:list-item-label end-indent="label-end()">
            <fo:block  text-align-last="end">
              <fo:basic-link internal-destination="{$id}">
                <xsl:value-of select="$label"/>
              </fo:basic-link>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()"
            hyphenate="false">
            <xsl:copy-of select="$title"/>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
</xsl:template>

<xsl:template match="d:preface|d:book/d:glossary|d:book/d:index" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>

    <fo:block start-indent="{&column; + &gutter;}mm"
      space-before="&columnfragment;mm"
      xsl:use-attribute-sets="toc.level2.properties dark-green">
      <xsl:if test="not(following-sibling::d:part)">
        <xsl:attribute name="space-after">0.75em</xsl:attribute>
      </xsl:if>
        <xsl:copy-of select="$title"/>
    </fo:block>
</xsl:template>

<xsl:template match="d:chapter|d:appendix[ancestor::d:book]" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>

    <fo:list-block role="TOC.{local-name()}" relative-align="baseline"
       font-size="{&xx-large; * $sans-fontsize-adjust}pt"
       keep-with-next.within-column="always"
       xsl:use-attribute-sets="toc.level2.properties dark-green sans.bold.noreplacement"
       provisional-distance-between-starts="{&column; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm">
      <xsl:if test="preceding-sibling::d:chapter or
                    preceding-sibling::d:appendix">
        <xsl:attribute name="space-before">2* &gutterfragment;mm</xsl:attribute>
        <xsl:attribute name="space-after">&gutterfragment;mm</xsl:attribute>
      </xsl:if>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()" xsl:use-attribute-sets="dark-green">
          <fo:block text-align="end">
            <fo:basic-link internal-destination="{$id}">
              <xsl:value-of select="$label"/>
            </fo:basic-link>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block>
            <xsl:copy-of select="$title"/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
</xsl:template>

<xsl:template match="d:article/d:appendix|d:article/d:glossary|d:article/d:index" mode="susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>

    <fo:list-block role="TOC.{local-name()}" relative-align="baseline"
       keep-with-next.within-column="always"
       xsl:use-attribute-sets="toc.level3.properties"
       provisional-distance-between-starts="{&columnfragment; + &gutter;}mm"
       provisional-label-separation="{&gutter;}mm"
       space-after="0.75em">
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()">
          <fo:block text-align="end">
            <fo:basic-link internal-destination="{$id}">
              <xsl:value-of select="$label"/>
            </fo:basic-link>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block>
            <xsl:copy-of select="$title"/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
</xsl:template>

<xsl:template match="d:preface/d:sect1|d:appendix[@role='legal']/d:sect1/
                     d:preface/d:section|d:appendix[@role='legal']/d:section|d:sect2|
                     d:section/d:section"
  mode="susetoc"/>

<xsl:template match="d:sect1|d:refentry|d:section" mode="susetoc">
  <!-- Excludes sect1s when it appears in the appendixes etc. of articles,
       as we only want a one-level ToC in articles, and sect1 there would
       already be a second level. -->
  <xsl:if test="ancestor::d:book or parent::d:article">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:call-template name="toc.label"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="toc.title"/>
    </xsl:variable>
    <fo:list-block  role="TOC.{local-name()}"  xsl:use-attribute-sets="toc.level3.properties"
       relative-align="baseline">
     <xsl:choose>
        <xsl:when test="parent::d:article">
          <xsl:attribute name="provisional-distance-between-starts">
            <xsl:value-of select="concat(&columnfragment; + &gutter;, 'mm')"/>
          </xsl:attribute>
          <xsl:attribute name="provisional-label-separation">
            <xsl:value-of select="concat(&gutter;, 'mm')"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="provisional-distance-between-starts">
            <xsl:value-of select="concat(&column; + &gutter;, 'mm')"/>
          </xsl:attribute>
          <xsl:attribute name="provisional-label-separation">
            <xsl:value-of select="concat(&gutter;, 'mm')"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="(child::d:sect2 or child::d:section)
                        and not(ancestor::d:article or ancestor::*[@role='legal'])">
          <xsl:attribute name="space-after">0.1em</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="space-after">0.75em</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()"
          text-align="end">
          <fo:block text-align-last="end">
          <xsl:choose>
            <xsl:when test="self::d:sect1 or self::d:section">
              <fo:basic-link internal-destination="{$id}">
                <xsl:value-of select="$label"/>
              </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
              <!-- We need an empty block -->
              <fo:leader/>
            </xsl:otherwise>
          </xsl:choose>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()" text-align="start">
          <xsl:copy-of select="$title"/>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  </xsl:if>
</xsl:template>

<xsl:template match="d:sect2[1]|d:section[not(ancestor::d:section)]/d:section[1]" mode="susetoc">
    <xsl:if test="not(ancestor::d:article) and not(ancestor::*[@role='legal'])">
      <fo:block keep-with-previous.within-column="always" role="sect2"
        xsl:use-attribute-sets="toc.level4.properties"
        text-align="start" space-after="0.75em"
        start-indent="{&column; + &gutter;}mm">
        <xsl:apply-templates select="../d:sect2|../d:section" mode="inline.susetoc"/>
      </fo:block>
    </xsl:if>
</xsl:template>

<xsl:template match="d:sect2|d:section" mode="inline.susetoc">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
   <xsl:variable name="title">
     <xsl:call-template name="toc.title">
       <xsl:with-param name="wrapper.name">fo:inline</xsl:with-param>
     </xsl:call-template>
  </xsl:variable>

  <fo:inline>
    <fo:basic-link internal-destination="{$id}">
    <xsl:copy-of select="$title"/>
    <xsl:if test="following-sibling::d:sect2|following-sibling::d:section">
      <fo:leader keep-together.within-line="always"
        leader-pattern="space" leader-length="1.2 * &gutterfragment;mm"/>
      <fo:inline><xsl:text>&#x2022;</xsl:text></fo:inline>
      <fo:leader leader-pattern="space" leader-length="1.2 * &gutterfragment;mm"/>
    </xsl:if>
    </fo:basic-link>
  </fo:inline>
</xsl:template>

</xsl:stylesheet>

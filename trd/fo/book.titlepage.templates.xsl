<?xml version="1.0" encoding="UTF-8"?>
<!--

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

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="d exsl">


  <!-- Recto page -->
  <xsl:template name="book.titlepage.recto">
    <fo:table>
      <fo:table-column column-number="1" column-width="10%"/>
      <fo:table-column column-number="2" column-width="90%"/>
      <fo:table-body>
        <fo:table-cell text-align="start">
          <fo:block>
            <fo:instream-foreign-object
              content-width="{$titlepage.logo.width.article}"
              width="{$titlepage.logo.width}">
              <xsl:call-template name="logo-image" />
            </fo:instream-foreign-object>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell text-align="right" color="&c_jungle;">
          <fo:block font-size="&xxx-large;pt">
            <xsl:apply-templates select="d:info/d:meta[@name='series'][1]" mode="book.titlepage.recto.auto.mode"/>
          </fo:block>
          <fo:block font-size="&large;pt">
            <xsl:apply-templates select="d:info/d:meta[@name='category'][1]" mode="book.titlepage.recto.auto.mode"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>

    <!-- Title -->
    <fo:block space-before="3cm" hyphenate="false" text-align="left">
      <xsl:choose>
        <xsl:when test="d:info/d:title">
          <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:title" />
        </xsl:when>
        <xsl:when test="d:title">
          <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:title" />
        </xsl:when>
      </xsl:choose>
    </fo:block>
    <!-- Subtitle -->
    <fo:block space-before="0.75em" hyphenate="false" text-align="left">
      <xsl:choose>
        <xsl:when test="d:info/d:subtitle">
          <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:info/d:subtitle" />
        </xsl:when>
        <xsl:when test="d:subtitle">
          <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:subtitle" />
        </xsl:when>
      </xsl:choose>
    </fo:block>

    <!--  -->
    <!--<fo:block-container absolute-position="fixed" top="{$page.margin.top} + 6.75cm" left="0" right="{$page.width}"
      role="titlepage.logo">
      <fo:block>
        <fo:external-graphic content-width="100%" src="{$titlepage.logo.image}" />
      </fo:block>
    </fo:block-container>-->

    <fo:block margin-left="-2cm">
      <fo:external-graphic left="0" right="{$page.margin.outer}"
        content-width="100%" src="{$titlepage.logo.image}" />
    </fo:block>

    <!-- Platform specific -->
    <fo:block space-before="2em" text-align="right" font-size="&normal;pt">
      <xsl:apply-templates select="d:info/d:meta[@name='platform']" mode="book.titlepage.recto.auto.mode"/>
    </fo:block>

    <!-- Authors -->
    <fo:block space-before="4em" font-size="&normal;pt">
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
        select="d:info/d:authorgroup" />
      <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
        select="d:info/d:author[1]" />
    </fo:block>

    <!-- Cover Icons -->
    <fo:block-container absolute-position="absolute" top="{$page.height.portrait} * 0.78">
      <fo:block>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
          select="d:info/d:cover[d:mediaobject]" />
      </fo:block>
    </fo:block-container>
  </xsl:template>


  <xsl:template match="d:meta[@name='platform']" mode="book.titlepage.recto.auto.mode">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- ======== -->
  <xsl:template match="d:cover[d:mediaobject]" mode="book.titlepage.recto.auto.mode">
    <xsl:variable name="n" select="count(d:mediaobject)"/>
    <xsl:if test="count(d:mediaobject) > 5">
      <!-- We only allow max 5 icons -->
      <xsl:message terminate="yes">ERROR: There are more than 5 icons on the cover page.</xsl:message>
    </xsl:if>

    <fo:table role="cover">
      <fo:table-body>
        <!-- Cell no. 1 -->
        <fo:table-cell>
          <fo:block>
            <xsl:apply-templates select="d:mediaobject[last() -4]" mode="book.titlepage.recto.auto.mode"/>
          </fo:block>
        </fo:table-cell>
        <!-- Cell no. 2 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -3]" mode="book.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 3 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -2]" mode="book.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 4 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -1]" mode="book.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 5 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last()]" mode="book.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:template match="d:cover/d:mediaobject" mode="book.titlepage.recto.auto.mode">
    <xsl:param name="pos"/>
      <fo:block>
        <xsl:apply-templates select="."/>
      </fo:block>
  </xsl:template>

  <xsl:template match="d:meta[@name='series']" mode="book.titlepage.recto.auto.mode">
    <fo:block font-family="{$sans-stack}">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:authorgroup" mode="book.titlepage.recto.auto.mode">
    <fo:block text-align="outside" font-family="{$sans-stack}">
      <xsl:for-each select="d:author">
        <fo:block>
          <xsl:apply-templates select="." mode="authorgroup">
            <xsl:with-param name="withlabel" select="0" />
          </xsl:apply-templates>
        </fo:block>
        </xsl:for-each>

      <xsl:for-each select="d:editor|d:othercredit">
        <fo:block>
          <xsl:apply-templates select="." mode="authorgroup">
            <xsl:with-param name="withlabel" select="0" />
          </xsl:apply-templates>
        </fo:block>
      </xsl:for-each>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:author[1]" mode="book.titlepage.recto.auto.mode">
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
    <xsl:apply-templates select="$authorgroup" mode="book.titlepage.recto.auto.mode"/>
  </xsl:template>

  <xsl:template match="d:title" mode="book.titlepage.recto.auto.mode">
    <fo:block font-size="{&super-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.85}em"
      xsl:use-attribute-sets="book.titlepage.recto.style sans.bold.noreplacement"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:subtitle" mode="book.titlepage.recto.auto.mode">
    <fo:block font-size="{&xxx-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.85}em"
      text-align="left"
      xsl:use-attribute-sets="book.titlepage.recto.style"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
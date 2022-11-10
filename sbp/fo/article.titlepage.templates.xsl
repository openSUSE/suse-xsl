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
  xmlns:fo="http://www.w3.org/1999/XSL/Format">


  <!-- Recto page -->
  <xsl:template name="article.titlepage.recto">
    <fo:table>
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
            <xsl:apply-templates select="d:info/d:meta[@name='series'][1]" mode="article.titlepage.recto.auto.mode"/>
          </fo:block>
          <fo:block font-size="&large;pt">
            <xsl:apply-templates select="d:info/d:meta[@name='category'][1]" mode="article.titlepage.recto.auto.mode"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>
    <!-- Title -->
    <fo:block space-before="3cm">
      <xsl:choose>
        <xsl:when test="d:artheader/d:title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:artheader/d:title" />
        </xsl:when>
        <xsl:when test="d:info/d:title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:info/d:title" />
        </xsl:when>
        <xsl:when test="d:title">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:title" />
        </xsl:when>
      </xsl:choose>
    </fo:block>
    <!-- Subtitle -->
    <fo:block space-before="0.75em">
      <xsl:choose>
        <xsl:when test="d:artheader/d:subtitle">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:artheader/d:subtitle" />
        </xsl:when>
        <xsl:when test="d:info/d:subtitle">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:info/d:subtitle" />
        </xsl:when>
        <xsl:when test="d:subtitle">
          <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:subtitle" />
        </xsl:when>
      </xsl:choose>
    </fo:block>

    <!-- Tools -->
    <fo:block>
      <fo:external-graphic content-width="100%"
        src="{$styleroot}/images/sbp-tools-title.svg" />
    </fo:block>

    <!-- Platform specific -->
    <fo:block space-before="2em" text-align="right" font-size="&normal;pt">
      <xsl:apply-templates select="d:info/d:meta[@name='platform']" mode="article.titlepage.recto.auto.mode"/>
    </fo:block>

    <!-- Authors -->
    <fo:block space-before="4em" font-size="&normal;pt">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:articleinfo/d:corpauthor" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:info/d:corpauthor" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:articleinfo/d:authorgroup" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:info/d:authorgroup" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:articleinfo/d:author" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:info/d:author" />
    </fo:block>

    <fo:block-container absolute-position="absolute" top="{$page.height.portrait} * 0.78">
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
      select="d:info/d:cover[d:mediaobject]" />
    </fo:block-container>
  </xsl:template>

  <xsl:template name="article.titlepage.separator">
    <fo:block break-after="page"/>
  </xsl:template>

  <xsl:template match="d:meta">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:meta[@name='series']" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:meta[@name='category']" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:meta[@name='platform']" mode="article.titlepage.recto.auto.mode">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:cover[d:mediaobject]" mode="article.titlepage.recto.auto.mode">
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
            <xsl:apply-templates select="d:mediaobject[last() -4]" mode="article.titlepage.recto.auto.mode"/>
          </fo:block>
        </fo:table-cell>
        <!-- Cell no. 2 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -3]" mode="article.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 3 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -2]" mode="article.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 4 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last() -1]" mode="article.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
        <!-- Cell no. 5 -->
        <fo:table-cell>
          <fo:block><xsl:apply-templates select="d:mediaobject[last()]" mode="article.titlepage.recto.auto.mode"/></fo:block>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:template match="d:cover/d:mediaobject" mode="article.titlepage.recto.auto.mode">
    <xsl:param name="pos"/>
      <fo:block>
        <xsl:apply-templates select="."/>
      </fo:block>
  </xsl:template>


  <xsl:template match="d:title" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&super-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.85}em"
      xsl:use-attribute-sets="article.titlepage.recto.style sans.bold.noreplacement"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>


  <xsl:template match="d:authorgroup" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="outside">
      <xsl:for-each select="d:author">
        <fo:block>
          <xsl:apply-templates select="."
            mode="article.titlepage.recto.auto.mode">
            <xsl:with-param name="withlabel" select="0" />
          </xsl:apply-templates>
        </fo:block>
        </xsl:for-each>

      <xsl:for-each select="d:editor|d:othercredit">
        <fo:block>
          <xsl:apply-templates select="."
            mode="article.titlepage.recto.auto.mode">
            <xsl:with-param name="withlabel" select="0" />
          </xsl:apply-templates>
        </fo:block>
      </xsl:for-each>

    </fo:block>
  </xsl:template>


  <xsl:template match="d:author[d:personname]|d:editor[d:personname]|d:othercredit[d:personname]"
    mode="article.titlepage.recto.auto.mode">
    <xsl:call-template name="person.name">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:if test="d:affiliation">
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="d:affiliation/d:jobtitle"
        mode="article.titlepage.recto.auto.mode" />
      <xsl:apply-templates select="d:affiliation/d:orgname"
        mode="article.titlepage.recto.auto.mode" />
    </xsl:if>
  </xsl:template>


  <xsl:template match="d:author[d:orgname]|d:editor[d:orgname]|d:othercredit[d:orgname]" mode="article.titlepage.recto.auto.mode">
    <xsl:param name="withlabel" select="1"/>
    <fo:block>
      <xsl:apply-templates select="d:orgname"/>
      <xsl:if test="d:affiliation">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="d:affiliation/d:jobtitle" mode="article.titlepage.recto.auto.mode"/>
        <xsl:apply-templates select="d:affiliation/d:orgname" mode="article.titlepage.recto.auto.mode"/>
      </xsl:if>
      <!-- In case we want e-mail addresses: -->
      <!--<xsl:apply-templates select="d:email" mode="article.titlepage.recto.auto.mode"/>-->
    </fo:block>
  </xsl:template>


  <xsl:template match="d:affiliation/d:jobtitle"  mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="d:affiliation/d:orgname"  mode="article.titlepage.recto.auto.mode">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>


  <!-- Verso page -->
  <xsl:template name="article.titlepage.verso">
    <fo:block break-after="page"/>
    <fo:block space-after="2em">
      <xsl:choose>
          <xsl:when test="d:artheader/d:title">
            <xsl:apply-templates mode="article.titlepage.verso.mode"
              select="d:artheader/d:title" />
          </xsl:when>
          <xsl:when test="d:info/d:title">
            <xsl:apply-templates mode="article.titlepage.verso.mode"
              select="d:info/d:title" />
          </xsl:when>
          <xsl:when test="d:title">
            <xsl:apply-templates mode="article.titlepage.verso.mode"
              select="d:title" />
          </xsl:when>
        </xsl:choose>
      <fo:block space-before="0.75em">
        <xsl:choose>
          <xsl:when test="d:artheader/d:subtitle">
            <xsl:apply-templates mode="article.titlepage.recto.mode"
              select="d:artheader/d:subtitle" />
          </xsl:when>
          <xsl:when test="d:info/d:subtitle">
            <xsl:apply-templates mode="article.titlepage.recto.mode"
              select="d:info/d:subtitle" />
          </xsl:when>
          <xsl:when test="d:subtitle">
            <xsl:apply-templates mode="article.titlepage.recto.mode"
              select="d:subtitle" />
          </xsl:when>
        </xsl:choose>
      </fo:block>
    </fo:block>

    <xsl:apply-templates mode="article.titlepage.verso.mode" select="d:info/d:abstract"/>
  </xsl:template>

  <xsl:template match="d:title" mode="article.titlepage.verso.mode">
    <fo:block font-size="&large;" role="title-article.titlepage.verso.mode">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:subtitle" mode="article.titlepage.verso.mode">
    <fo:block font-size="&normal;" role="subtitle-article.titlepage.verso.mode">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
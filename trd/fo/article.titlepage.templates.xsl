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
  <xsl:template name="article.titlepage.recto">
    <fo:table table-layout="fixed">
      <fo:table-column column-number="1" column-width="20%"/>
      <fo:table-column column-number="2" /><!-- column-width="75%" -->

      <fo:table-body>
        <fo:table-cell text-align="start">
          <fo:block padding-top="0pt" margin-top="-10pt" margin-left="-10pt">
            <fo:instream-foreign-object
              content-width="{$titlepage.logo.width.article}"
              width="{$titlepage.logo.width}">
              <xsl:call-template name="logo-image" />
            </fo:instream-foreign-object>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell text-align="right" color="&c_jungle;">
          <fo:block font-size="&x-large;pt" hyphenate="false">
            <xsl:choose>
              <xsl:when test="$json-ld-seriesname != ''">
                <xsl:value-of select="$json-ld-seriesname"/>
              </xsl:when>
              <xsl:when test="d:info/d:meta[@name='series']">
                <xsl:apply-templates select="d:info/d:meta[@name='series'][1]" mode="article.titlepage.recto.auto.mode"/>
              </xsl:when>
            </xsl:choose>
          </fo:block>
          <fo:block font-size="&large;pt">
            <xsl:apply-templates select="d:info/d:meta[@name='type'][1]" mode="article.titlepage.recto.auto.mode"/>
          </fo:block>
        </fo:table-cell>
      </fo:table-body>
    </fo:table>
    
    <!-- product -->
    <fo:block space-before="3cm">
      <xsl:if test="d:info/d:productname">
        <fo:block role="productname">
          <xsl:apply-templates select="d:info/d:productname[1]" mode="article.titlepage.recto.auto.mode"/>
        </fo:block>
      </xsl:if>

    <!-- Title -->
    <fo:block hyphenate="false">
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
    </fo:block>

    <!-- Tools -->
    <fo:block>
      <fo:external-graphic content-width="100%" src="{$titlepage.logo.image}" />
    </fo:block>

    <!-- Platform specific -->
    <fo:block space-before="2em" text-align="right" font-size="&normal;pt">
      <xsl:apply-templates select="d:info/d:meta[@name='platform']" mode="article.titlepage.recto.auto.mode"/>
    </fo:block>

    <!-- Authors -->
    <fo:block space-before="4em" font-size="&normal;pt">
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:info/d:authorgroup" />
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
        select="d:info/d:author[1]" />
    </fo:block>

    <fo:block-container absolute-position="absolute" top="{$page.height.portrait} * 0.78">
      <fo:block>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
          select="d:info/d:cover[d:mediaobject]" />
      </fo:block>
    </fo:block-container>
  </xsl:template>

  <xsl:template name="article.titlepage.separator">
    <fo:block break-after="page"/>
  </xsl:template>


  <xsl:template match="d:info/d:productname" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="start" font-size="{&xx-large; * $sans-fontsize-adjust}pt" space-after="0.5em">
      <fo:inline background-color="&c_jungle;" color="white"
        padding="0.3em 0.3em 0.1em 0.3em">
        <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:meta">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:meta[@name='series']" mode="article.titlepage.recto.auto.mode">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:meta[@name='category' or @name='type']" mode="article.titlepage.recto.auto.mode">
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
      <fo:table-column column-number="1" column-width="20%"/>
      <fo:table-column column-number="2" column-width="20%"/>
      <fo:table-column column-number="3" column-width="20%"/>
      <fo:table-column column-number="4" column-width="20%"/>
      <fo:table-column column-number="5" column-width="20%"/>
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


  <xsl:template match="d:author[d:personname]|d:editor[d:personname]|d:othercredit[d:personname]"
    mode="authorgroup">
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


  <xsl:template match="d:author[d:orgname]|d:editor[d:orgname]|d:othercredit[d:orgname]" mode="authorgroup">
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

  <xsl:template match="d:author[1]" mode="article.titlepage.recto.auto.mode">
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

  <!-- Verso page -->
  <xsl:template name="article.titlepage.verso">
    <fo:block break-after="page"/>
    <fo:block space-after="2em" hyphenate="false" text-align="left">
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

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.verso.mode" select="d:info/d:date"/>
    </fo:block>

    <xsl:apply-templates mode="article.titlepage.verso.mode" select="d:info/d:abstract"/>
  </xsl:template>

  <xsl:template match="d:info/d:abstract" mode="article.titlepage.verso.mode">
    <fo:block space-before="2em">
      <xsl:apply-templates mode="article.titlepage.verso.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:info/d:abstract/d:title" mode="article.titlepage.verso.mode">
    <fo:block font-weight="bold">
      <xsl:apply-templates/>
    </fo:block>
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

  <xsl:template match="d:date" mode="article.titlepage.verso.mode">
    <fo:inline font-weight="bold">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">Date</xsl:with-param>
      </xsl:call-template>
    </fo:inline>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
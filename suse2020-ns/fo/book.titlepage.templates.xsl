<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle book's first page and imprint page

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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
                 version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <!--  Book ====================================================== -->
<xsl:template name="book.titlepage.recto">
  <xsl:variable name="height">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="unit">
    <xsl:call-template name="get.unit.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Geeko tail cover image -->
  <xsl:if test="$enable.secondary.branding = 1">
    <!-- FIXME: Review LTR/RTL situation...  -->
    <fo:block-container top="{(2 - &goldenratio;) * $height}{$unit}" left="0"
      text-align="right"
      absolute-position="fixed">
      <fo:block>
      <!-- Almost golden ratio... -->
        <fo:instream-foreign-object content-width="{$titlepage.background.width}"
          width="{$titlepage.background.width}">
          <xsl:call-template name="secondary-branding"/>
        </fo:instream-foreign-object>
      </fo:block>
    </fo:block-container>
  </xsl:if>

  <!-- Logo -->
  <fo:block-container top="{$page.margin.top}" absolute-position="fixed"
    left="{$page.margin.start - $titlepage.logo.overhang}mm">
    <xsl:choose>
      <xsl:when test="$writing.mode = 'lr'">
        <xsl:attribute name="right">
          <xsl:value-of select="$page.margin.start"/>mm
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="left">
          <xsl:value-of select="$page.margin.start - $titlepage.logo.overhang"/>mm
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <fo:block>
      <fo:instream-foreign-object content-width="{$titlepage.logo.width}"
        width="{$titlepage.logo.width}">
        <xsl:call-template name="logo-image"/>
      </fo:instream-foreign-object>
    </fo:block>
  </fo:block-container>

 <!-- Title and product -->
  <fo:block-container top="0" left="0" absolute-position="fixed"
    height="{$height * (2 - &goldenratio;)}{$unit}">
    <fo:block>
    <fo:table width="{(&column; * 7) + (&gutter; * 5)}mm" table-layout="fixed"
      block-progression-dimension="auto">
      <fo:table-column column-number="1" column-width="100%"/>

      <fo:table-body>
        <fo:table-row>
          <fo:table-cell display-align="after"
            height="{$height * (2 - &goldenratio;)}{$unit}" >
            <fo:table width="{(&column; * 7) + (&gutter; * 5)}mm"
              table-layout="fixed" block-progression-dimension="auto">
              <fo:table-column column-number="1" column-width="{&column;}mm"/>
              <fo:table-column column-number="2"
                column-width="{(&column; * 6) + (&gutter; * 5)}mm"/>
              <fo:table-body>
                <fo:table-row>
                  <fo:table-cell>
                    <fo:block> </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block padding-after="&gutterfragment;mm">
                      <xsl:choose>
                        <xsl:when test="d:bookinfo/d:title">
                          <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                            select="d:bookinfo/d:title"/>
                        </xsl:when>
                        <xsl:when test="d:info/d:title">
                          <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                            select="d:info/d:title"/>
                        </xsl:when>
                        <xsl:when test="d:title">
                          <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                            select="d:title"/>
                        </xsl:when>
                      </xsl:choose>
                      </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                  <fo:table-cell>
                    <xsl:attribute name="border-top"><xsl:value-of select="concat(&mediumline;,'mm solid ',$mid-green)"/></xsl:attribute>
                    <fo:block> </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                    <xsl:attribute name="border-top"><xsl:value-of select="concat(&mediumline;,'mm solid ',$mid-green)"/></xsl:attribute>
                    <fo:block padding-before="&columnfragment;mm">
                      <!-- We use the full productname here: -->
                      <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
                        select="d:bookinfo/d:productname[not(@role='abbrev')]|d:info/d:productname[not(@role='abbrev')]"/>
                      </fo:block>
                    </fo:table-cell>
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
    </fo:block>
  </fo:block-container>

  <!-- XEP needs at least one block following the normal flow, else it won't
       create a page break. This is not elegant, but works. -->
  <fo:block><fo:leader/></fo:block>
</xsl:template>

<xsl:template match="d:title" mode="book.titlepage.recto.auto.mode">
  <fo:block text-align="start" line-height="1.2" hyphenate="false"
    xsl:use-attribute-sets="title.font title.name.color"
    font-size="{&ultra-large;}pt">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:subtitle" mode="book.titlepage.recto.auto.mode">
  <fo:block
    xsl:use-attribute-sets="title.font" font-size="{&super-large; * $sans-fontsize-adjust}pt"
    space-before="&gutterfragment;mm">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:productname[not(@role='abbrev')]"
  mode="book.titlepage.recto.auto.mode">
  <fo:block text-align="start" hyphenate="false"
    line-height="{$base-lineheight * 0.85}em"
    font-weight="normal" font-size="{&super-large; * $sans-fontsize-adjust}pt"
    space-after="&gutterfragment;mm"
    xsl:use-attribute-sets="title.font mid-green">
    <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="../d:productnumber[not(@role='abbrev')]"
      mode="book.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:legalnotice" mode="book.titlepage.verso.auto.mode">
  <fo:block
    xsl:use-attribute-sets="book.titlepage.verso.style" font-size="{&small; * $fontsize-adjust}pt">
    <xsl:apply-templates select="*" mode="book.titlepage.verso.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:legalnotice/d:para" mode="book.titlepage.verso.mode">
  <fo:block space-after="0.25em" space-before="0em">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- For their use in xrefs, many book titles have emphases
     around them. Now, for formatting reasons in cases where we are
     actually outside of an xref that pretty much is the wrong thing
     to do. In languages where italic text is replaced by gray text,
     this issue is especially glaring. -->
<xsl:template match="d:emphasis" mode="titlepage.mode">
  <xsl:apply-templates/>
</xsl:template>


<!-- ============================================================
      Imprint page
     ============================================================
-->
<xsl:template name="book.titlepage.verso">
  <xsl:variable name="height">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="page-height">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="margin-top">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.margin.top"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="margin-bottom">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$page.margin.bottom"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="margin-bottom-body">
    <xsl:call-template name="get.value.from.unit">
      <xsl:with-param name="string" select="$body.margin.bottom"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="table.height"
    select="$page-height - ($margin-top + $margin-bottom + $margin-bottom-body)"/>
  <xsl:variable name="unit">
    <xsl:call-template name="get.unit.from.unit">
      <xsl:with-param name="string" select="$page.height"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:table table-layout="fixed" block-progression-dimension="auto"
    height="{$table.height}{$unit}"
    width="{(6 * &column;) + (5 * &gutter;)}mm">
    <fo:table-column column-number="1" column-width="100%"/>
    <fo:table-body>
      <fo:table-row>
        <fo:table-cell height="{0.4 * $table.height}{$unit}">
          <xsl:apply-templates
            select="(d:bookinfo/d:title | d:info/d:title | d:title)[1]"
            mode="book.titlepage.verso.auto.mode"/>
          <xsl:apply-templates
            select="(d:bookinfo/d:productname | d:info/d:productname)[not(@role='abbrev')]"
            mode="book.titlepage.verso.auto.mode"/>

          <xsl:apply-templates
            select="(d:bookinfo/d:authorgroup | d:info/d:authorgroup)[1]"
            mode="book.titlepage.verso.auto.mode"/>
          <xsl:apply-templates
            select="(d:bookinfo/d:author | d:info/d:author)[1]"
            mode="book.titlepage.verso.auto.mode"/>

          <xsl:apply-templates
            select="(d:bookinfo/d:abstract | d:info/d:abstract)[1]"
            mode="book.titlepage.verso.auto.mode"/>
          <!-- Empty fo:block to fix openSUSE/suse-xsl#97 -->
          <fo:block/>
        </fo:table-cell>
      </fo:table-row>

      <!-- Everything else is in a second block of text at the bottom -->
      <fo:table-row>
        <fo:table-cell display-align="after" height="{0.6 * $table.height}{$unit}">

          <xsl:call-template name="date.and.revision"/>

          <xsl:apply-templates
            select="(d:bookinfo/d:corpauthor | d:info/d:corpauthor)[1]"
            mode="book.titlepage.verso.auto.mode"/>
          <xsl:apply-templates
            select="(d:bookinfo/d:othercredit | d:info/d:othercredit)[1]"
            mode="book.titlepage.verso.auto.mode"/>
          <xsl:apply-templates
            select="(d:bookinfo/d:editor | d:info/d:editor)[1]"
            mode="book.titlepage.verso.auto.mode"/>

          <xsl:call-template name="suse.imprint"/>

          <xsl:apply-templates
            select="(d:bookinfo/d:copyright | d:info/d:copyright)[1]"
            mode="book.titlepage.verso.auto.mode"/>

          <xsl:apply-templates
            select="(d:bookinfo/d:legalnotice | d:info/d:legalnotice)[1]"
            mode="book.titlepage.verso.auto.mode"/>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-body>
  </fo:table>
</xsl:template>

<xsl:template match="d:title" mode="book.titlepage.verso.auto.mode">
    <fo:block font-size="{&x-large; * $sans-fontsize-adjust}pt"
      xsl:use-attribute-sets="dark-green sans.bold.noreplacement title.font">
      <xsl:call-template name="book.verso.title"/>
    </fo:block>
</xsl:template>

<xsl:template match="d:productname[not(@role='abbrev')]" mode="book.titlepage.verso.auto.mode">
  <fo:block
   font-size="{&large; * $sans-fontsize-adjust}pt" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
    <xsl:text> </xsl:text>
    <xsl:if test="../d:productnumber">
      <!-- Use productnumber without role first, but fallback to
        productnumber with role
      -->
      <xsl:apply-templates mode="book.titlepage.verso.mode"
        select="(../d:productnumber[@role='abbrev'] |
                 ../d:productnumber[not(@role='abbrev')])[last()]" />
    </xsl:if>
  </fo:block>
</xsl:template>

<xsl:template match="d:authorgroup" mode="book.titlepage.verso.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="book.titlepage.verso.style title.font">
    <xsl:call-template name="verso.authorgroup"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:author" mode="book.titlepage.verso.auto.mode">
  <fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xsl:use-attribute-sets="book.titlepage.verso.style title.font">
    <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
  </fo:block>
</xsl:template>

<xsl:template match="d:editor" mode="book.titlepage.verso.auto.mode">
  <fo:block font-size="{&normal; * $sans-fontsize-adjust}pt">
    <xsl:apply-templates select="." mode="book.titlepage.verso.mode"/>
  </fo:block>
</xsl:template>

<xsl:template name="suse.imprint">
  <xsl:variable name="ulink.url">
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$suse.doc.url"/>
    </xsl:call-template>
  </xsl:variable>
  <fo:block xsl:use-attribute-sets="book.titlepage.verso.style"
    space-after="1.2em" space-before="1.2em">
    <fo:block line-height="{$line-height}"
      white-space-treatment="preserve"
      wrap-option="no-wrap"
      linefeed-treatment="preserve"
      white-space-collapse="false">
      <xsl:copy-of select="$company.address"/>
    </fo:block>
    <fo:block>
      <fo:basic-link external-destination="{$ulink.url}"
        xsl:use-attribute-sets="dark-green title.font">
        <xsl:value-of select="$suse.doc.url"/>
        <xsl:call-template name="image-after-link"/>
      </fo:basic-link>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template name="date.and.revision">
  <fo:block xsl:use-attribute-sets="book.titlepage.verso.style">
    <xsl:call-template name="date.and.revision.inner"/>
  </fo:block>
</xsl:template>

<xsl:template name="imprint.label">
  <xsl:param name="label" select="'PubDate'"/>

  <fo:inline>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="$label"/>
    </xsl:call-template>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'admonseparator'"/>
    </xsl:call-template>
  </fo:inline>
</xsl:template>

<xsl:template match="d:date/processing-instruction('dbtimestamp')" mode="book.titlepage.verso.mode">
  <xsl:call-template name="pi.dbtimestamp"/>
</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Remove blank pages from PDF output – we really don't need them if people
    are supposed to print books on their own.
    Output license [@role=legal] pages in multiple columns, to save space.

  Authors:    Stefan Knorr <sknorr@suse.de>,
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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl d">


<xsl:template name="product">
  <!--
     This XPath is needed to select an abbreviated version for the
     footer. For this reason, authors can add two productnames: one
     with a @role attribute, another without. The one with
     @role="abbrev" is used as an abbreviated productname.

     If there is no productnumber or productname with @role
     available, it falls back to the element without the @role.

  -->
  <xsl:variable name="productnumber"
    select="(ancestor-or-self::d:set/d:setinfo/d:productnumber|
             ancestor-or-self::d:book/d:bookinfo/d:productnumber|
             ancestor-or-self::d:article/d:articleinfo/d:productnumber|
             ancestor-or-self::d:set/d:info/d:productnumber|
             ancestor-or-self::d:book/d:info/d:productnumber|
             ancestor-or-self::d:article/d:info/d:productnumber)[last()]"/>

  <xsl:variable name="productname-long"
    select="(ancestor-or-self::d:set/d:setinfo/d:productname[not(@role='abbrev')]|
             ancestor-or-self::d:book/d:bookinfo/d:productname[not(@role='abbrev')]|
             ancestor-or-self::d:article/d:articleinfo/d:productname[not(@role='abbrev')]|
             ancestor-or-self::d:set/d:info/d:productname[not(@role='abbrev')]|
             ancestor-or-self::d:book/d:info/d:productname[not(@role='abbrev')]|
             ancestor-or-self::d:article/d:info/d:productname[not(@role='abbrev')])[last()]"/>

  <xsl:variable name="productname-abbreviation"
    select="(ancestor-or-self::d:set/d:setinfo/d:productname[@role='abbrev']|
             ancestor-or-self::d:book/d:bookinfo/d:productname[@role='abbrev']|
             ancestor-or-self::d:article/d:articleinfo/d:productname[@role='abbrev']|
             ancestor-or-self::d:set/d:info/d:productname[@role='abbrev']|
             ancestor-or-self::d:book/d:info/d:productname[@role='abbrev']|
             ancestor-or-self::d:article/d:info/d:productname[@role='abbrev'])[last()]"/>

  <xsl:choose>
    <xsl:when test="$productname-abbreviation">
      <xsl:apply-templates select="$productname-abbreviation" mode="footer"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$productname-long" mode="footer"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text> </xsl:text>
  <xsl:apply-templates select="$productnumber" mode="footer"/>
</xsl:template>

<xsl:template match="d:productname|d:productnumber" mode="footer">
  <xsl:variable name="content-candidate">
    <xsl:value-of select="."/>
  </xsl:variable>
  <xsl:variable name="content" select="normalize-space($content-candidate)"/>
  <!-- Hopefully, we will never need to cut off productnumbers.
       That could be ugly. -->
  <xsl:variable name="cutoff" select="20"/>

  <xsl:choose>
    <xsl:when test="string-length($content) &gt; $cutoff">
      <xsl:value-of select="substring($content, 1, ($cutoff - 3))"/>…
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.charseq"/>
      <!-- No @class added -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="header.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:if test="$debug.fo != 0">
  <fo:block margin-top="-5em" font-size="9pt" space-after="0em">
    <xsl:value-of select="$pageclass"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$sequence"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$position"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$gentext-key"/>
  </fo:block>

  <fo:block space-before=".25em" font-size="9pt">

    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$sequence = 'blank'">
        <!-- nothing -->
      </xsl:when>

      <xsl:when test="$position='left'">
        <!-- Same for odd, even, empty, and blank sequences -->
        <xsl:call-template name="draft.text"/>
        <xsl:call-template name="product"/>
      </xsl:when>

      <xsl:when test="($sequence='odd' or $sequence='even') and $position='center'">
        <xsl:if test="$pageclass != 'titlepage'">
          <xsl:choose>
            <xsl:when test="ancestor::d:book and ($double.sided != 0)">
              <fo:retrieve-marker retrieve-class-name="section.head.marker"
                retrieve-position="first-including-carryover"
                retrieve-boundary="page-sequence"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:when>

      <xsl:when test="$position='center'">
        <!-- nothing for empty and blank sequences -->
      </xsl:when>

      <xsl:when test="$position='right'">
        <!-- Same for odd, even, empty, and blank sequences -->
        <xsl:call-template name="draft.text"/>
      </xsl:when>

      <xsl:when test="$sequence = 'first'">
        <!-- nothing for first pages -->
      </xsl:when>

      <xsl:when test="$sequence = 'blank'">
        <!-- nothing for blank pages -->
      </xsl:when>
    </xsl:choose>
  </fo:block>
  </xsl:if>
</xsl:template>

<!-- We don't really need this... -->
<xsl:template name="footer.content.doublesided">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:call-template name="footer.content.singlesided">
    <xsl:with-param name="pageclass" select="''"/>
    <xsl:with-param name="sequence" select="''"/>
    <xsl:with-param name="position" select="''"/>
    <xsl:with-param name="gentext-key" select="''"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="footer.content.singlesided">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>
  <!-- pageclass can be front, body, back -->
  <!-- sequence can be odd, even, first, blank -->
  <!-- position can be left, center, right -->

  <xsl:choose>
    <xsl:when test="$pageclass = 'titlepage'"/> <!-- Nothing -->
    <xsl:when test="$position = 'left'">
      <fo:page-number/>
    </xsl:when>
    <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor::d:book">
            <fo:retrieve-marker
              retrieve-class-name="section.head.marker.short"
              retrieve-position="first-including-carryover"
              retrieve-boundary="page-sequence"/>
            <xsl:if test="(ancestor-or-self::d:set/d:setinfo/d:productname|
              ancestor-or-self::d:book/d:bookinfo/d:productname|
              ancestor-or-self::d:article/d:articleinfo/d:productname|
              ancestor-or-self::d:set/d:info/d:productname|
              ancestor-or-self::d:book/d:info/d:productname|
              ancestor-or-self::d:article/d:info/d:productname)">
              <!-- FIXME/UNHACKME: This causes some line break problems in
                   Arabic, so xsl:if this out for the moment. -->
              <xsl:if test="$writing.mode = 'lr'">
                <fo:inline>
                  <fo:leader leader-length="&columnfragment;mm"
                    leader-pattern="space"/>
                  <xsl:call-template name="product"/>
                </fo:inline>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="titleabbrev.markup"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <fo:block>
    <xsl:choose>
      <xsl:when test="$double.sided != 0">
        <xsl:call-template name="footer.content.doublesided">
          <xsl:with-param name="pageclass" select="$pageclass"/>
          <xsl:with-param name="position" select="$position"/>
          <xsl:with-param name="sequence" select="$sequence"/>
          <xsl:with-param name="gentext-key" select="$gentext-key"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="footer.content.singlesided">
          <xsl:with-param name="pageclass" select="$pageclass"/>
          <xsl:with-param name="position" select="$position"/>
          <xsl:with-param name="sequence" select="$sequence"/>
          <xsl:with-param name="gentext-key" select="$gentext-key"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>


<xsl:template name="footer.table.doublesided">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:variable name="column1">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">1</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
      <xsl:otherwise>3</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="column3">
    <xsl:choose>
      <xsl:when test="$double.sided = 0">3</xsl:when>
      <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="candidate">
    <fo:table xsl:use-attribute-sets="footer.table.properties"
       block-progression-dimension="auto">
      <xsl:call-template name="foot.sep.rule">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="$sequence"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>
      <fo:table-column column-number="1">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column1"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="2">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="2"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>
      <fo:table-column column-number="3">
        <xsl:attribute name="column-width">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:call-template name="header.footer.width">
            <xsl:with-param name="location">footer</xsl:with-param>
            <xsl:with-param name="position" select="$column3"/>
            <xsl:with-param name="pageclass" select="$pageclass"/>
            <xsl:with-param name="sequence" select="$sequence"/>
            <xsl:with-param name="gentext-key" select="$gentext-key"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:attribute>
      </fo:table-column>

      <fo:table-body>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
            <xsl:value-of select="$footer.table.height"/>
          </xsl:attribute>
          <fo:table-cell text-align="start" display-align="after"
            xsl:use-attribute-sets="sans.bold.noreplacement">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.start"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell display-align="after">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="text-align">
              <xsl:choose>
                <xsl:when test="$sequence='even'">start</xsl:when>
                <xsl:otherwise>end</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="'center'"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="end" display-align="after"
            xsl:use-attribute-sets="sans.bold.noreplacement">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.end"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <!-- Really output a footer? -->
  <xsl:choose>
    <!-- book titlepages have no footers at all -->
    <xsl:when test="$pageclass='titlepage' and $gentext-key='book'
                    and $sequence='first'"/>
    <xsl:when test="$sequence = 'blank' and $footers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="footer.table.singlesided">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <fo:table xsl:use-attribute-sets="footer.table.properties"
    block-progression-dimension="auto">
    <!-- Page number -->
    <fo:table-column column-number="1"
        column-width="{&column; + &gutter;}mm"/>
    <!-- Some titles -->
    <fo:table-column column-number="2"
        column-width="{(&column; * 5) + (&gutter; *4)}mm"/>

      <fo:table-body>
        <fo:table-row>
          <xsl:attribute name="block-progression-dimension.minimum">
            <xsl:value-of select="$footer.table.height"/>
          </xsl:attribute>
          <fo:table-cell text-align="start" display-align="after"
            xsl:use-attribute-sets="sans.bold.noreplacement">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.start"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell display-align="after" text-align="end">
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:call-template name="footer.content">
                <xsl:with-param name="pageclass" select="$pageclass"/>
                <xsl:with-param name="sequence" select="$sequence"/>
                <xsl:with-param name="position" select="$direction.align.end"/>
                <xsl:with-param name="gentext-key" select="$gentext-key"/>
              </xsl:call-template>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
  </fo:table>
</xsl:template>


<xsl:template name="footer.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

    <xsl:choose>
      <xsl:when test="$pageclass = 'index'">
        <xsl:attribute name="margin-{$direction.align.start}"
          >0pt</xsl:attribute>
      </xsl:when>
    </xsl:choose>

  <xsl:variable name="candidate">
    <xsl:choose>
      <xsl:when test="$double.sided != 0">
        <xsl:call-template name="footer.table.doublesided">
          <xsl:with-param name="pageclass" select="$pageclass"/>
          <xsl:with-param name="sequence" select="$sequence"/>
          <xsl:with-param name="gentext-key" select="$gentext-key"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="footer.table.singlesided">
          <xsl:with-param name="pageclass" select="$pageclass"/>
          <xsl:with-param name="sequence" select="$sequence"/>
          <xsl:with-param name="gentext-key" select="$gentext-key"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Really output a footer? -->
  <xsl:choose>
    <xsl:when test="$pageclass='titlepage' and $gentext-key='book'
                    and $sequence='first'">
      <!-- no, book titlepages have no footers at all -->
    </xsl:when>
    <xsl:when test="$sequence = 'blank' and $footers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="user.pagemasters">
  <!-- New page-master for License pages -->

    <fo:simple-page-master master-name="legal-first" page-width="{$page.width}"
      page-height="{$page.height}" margin-top="{$page.margin.top}"
      margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.inner"/>
        <xsl:if test="$fop.extensions != 0">
          <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
        margin-top="{$body.margin.top}" column-gap="&gutter;mm"
        column-count="2">
        <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$body.margin.inner"/>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$body.margin.outer"/>
        </xsl:attribute>
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-first"
                        extent="{$region.before.extent}"
                        precedence="{$region.before.precedence}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-first"
        extent="{$region.after.extent}" precedence="{$region.after.precedence}"
        display-align="after"/>
      <xsl:call-template name="region.inner">
        <xsl:with-param name="sequence">first</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="region.outer">
        <xsl:with-param name="sequence">first</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
    </fo:simple-page-master>

    <fo:simple-page-master master-name="legal-odd" page-width="{$page.width}"
      page-height="{$page.height}" margin-top="{$page.margin.top}"
      margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.inner"/>
        <xsl:if test="$fop.extensions != 0">
          <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
        margin-top="{$body.margin.top}" column-gap="&gutter;mm" column-count="2">
        <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$body.margin.inner"/>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$body.margin.outer"/>
        </xsl:attribute>
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-odd"
        extent="{$region.before.extent}" precedence="{$region.before.precedence}"
        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-odd"
        extent="{$region.after.extent}" precedence="{$region.after.precedence}"
        display-align="after"/>
      <xsl:call-template name="region.inner">
        <xsl:with-param name="sequence">odd</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="region.outer">
        <xsl:with-param name="sequence">odd</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
    </fo:simple-page-master>

    <fo:simple-page-master master-name="legal-even" page-width="{$page.width}"
      page-height="{$page.height}" margin-top="{$page.margin.top}"
      margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.outer"/>
        <xsl:if test="$fop.extensions != 0">
          <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
        margin-top="{$body.margin.top}" column-gap="&gutter;mm" column-count="2">
        <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$body.margin.outer"/>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$body.margin.inner"/>
        </xsl:attribute>
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-even"
        extent="{$region.before.extent}" precedence="{$region.before.precedence}"
        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-even"
        extent="{$region.after.extent}" precedence="{$region.after.precedence}"
        display-align="after"/>
      <xsl:call-template name="region.outer">
        <xsl:with-param name="sequence">even</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="region.inner">
        <xsl:with-param name="sequence">even</xsl:with-param>
        <xsl:with-param name="pageclass">legal</xsl:with-param>
      </xsl:call-template>
    </fo:simple-page-master>

    <xsl:if test="$draft.mode != 'no'">
      <fo:simple-page-master master-name="legal-first-draft" page-width="{$page.width}"
        page-height="{$page.height}" margin-top="{$page.margin.top}"
        margin-bottom="{$page.margin.bottom}">
        <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$page.margin.inner"/>
          <xsl:if test="$fop.extensions != 0">
            <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$page.margin.outer"/>
        </xsl:attribute>
        <fo:region-body margin-bottom="{$body.margin.bottom}"
          margin-top="{$body.margin.top}" column-gap="&gutter;mm"
          column-count="2">
          <xsl:if test="$draft.watermark.image != ''">
            <xsl:attribute name="background-image">
              <xsl:call-template name="fo-external-image">
                <xsl:with-param name="filename" select="$draft.watermark.image"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="background-attachment">fixed</xsl:attribute>
            <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
            <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
            <xsl:attribute name="background-position-vertical">center</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="margin-{$direction.align.start}">
            <xsl:value-of select="$body.margin.inner"/>
          </xsl:attribute>
          <xsl:attribute name="margin-{$direction.align.end}">
            <xsl:value-of select="$body.margin.outer"/>
          </xsl:attribute>
        </fo:region-body>
        <fo:region-before region-name="xsl-region-before-first"
                          extent="{$region.before.extent}"
                          precedence="{$region.before.precedence}"
                          display-align="before"/>
        <fo:region-after region-name="xsl-region-after-first"
          extent="{$region.after.extent}" precedence="{$region.after.precedence}"
          display-align="after"/>
        <xsl:call-template name="region.inner">
          <xsl:with-param name="sequence">first</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="region.outer">
          <xsl:with-param name="sequence">first</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="legal-odd-draft" page-width="{$page.width}"
        page-height="{$page.height}" margin-top="{$page.margin.top}"
        margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$page.margin.inner"/>
          <xsl:if test="$fop.extensions != 0">
            <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
            </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$page.margin.outer"/>
        </xsl:attribute>
        <fo:region-body margin-bottom="{$body.margin.bottom}"
          margin-top="{$body.margin.top}" column-gap="&gutter;mm" column-count="2">
          <xsl:if test="$draft.watermark.image != ''">
            <xsl:attribute name="background-image">
              <xsl:call-template name="fo-external-image">
                <xsl:with-param name="filename" select="$draft.watermark.image"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="background-attachment">fixed</xsl:attribute>
            <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
            <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
            <xsl:attribute name="background-position-vertical">center</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="margin-{$direction.align.start}">
            <xsl:value-of select="$body.margin.inner"/>
          </xsl:attribute>
          <xsl:attribute name="margin-{$direction.align.end}">
            <xsl:value-of select="$body.margin.outer"/>
          </xsl:attribute>
        </fo:region-body>
        <fo:region-before region-name="xsl-region-before-odd"
          extent="{$region.before.extent}" precedence="{$region.before.precedence}"
          display-align="before"/>
        <fo:region-after region-name="xsl-region-after-odd"
          extent="{$region.after.extent}" precedence="{$region.after.precedence}"
          display-align="after"/>
        <xsl:call-template name="region.inner">
          <xsl:with-param name="sequence">odd</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="region.outer">
          <xsl:with-param name="sequence">odd</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
      </fo:simple-page-master>

      <fo:simple-page-master master-name="legal-even-draft" page-width="{$page.width}"
        page-height="{$page.height}" margin-top="{$page.margin.top}"
        margin-bottom="{$page.margin.bottom}">
        <xsl:attribute name="margin-{$direction.align.start}">
          <xsl:value-of select="$page.margin.outer"/>
          <xsl:if test="$fop.extensions != 0">
            <xsl:value-of select="concat(' - (',$title.margin.left,')')"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="margin-{$direction.align.end}">
          <xsl:value-of select="$page.margin.inner"/>
        </xsl:attribute>
        <fo:region-body margin-bottom="{$body.margin.bottom}"
          margin-top="{$body.margin.top}" column-gap="&gutter;mm" column-count="2">
          <xsl:if test="$draft.watermark.image != ''">
            <xsl:attribute name="background-image">
              <xsl:call-template name="fo-external-image">
                <xsl:with-param name="filename" select="$draft.watermark.image"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="background-attachment">fixed</xsl:attribute>
            <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
            <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
            <xsl:attribute name="background-position-vertical">center</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="margin-{$direction.align.start}">
            <xsl:value-of select="$body.margin.outer"/>
          </xsl:attribute>
          <xsl:attribute name="margin-{$direction.align.end}">
            <xsl:value-of select="$body.margin.inner"/>
          </xsl:attribute>
        </fo:region-body>
        <fo:region-before region-name="xsl-region-before-even"
          extent="{$region.before.extent}" precedence="{$region.before.precedence}"
          display-align="before"/>
        <fo:region-after region-name="xsl-region-after-even"
          extent="{$region.after.extent}" precedence="{$region.after.precedence}"
          display-align="after"/>
        <xsl:call-template name="region.outer">
          <xsl:with-param name="sequence">even</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="region.inner">
          <xsl:with-param name="sequence">even</xsl:with-param>
          <xsl:with-param name="pageclass">legal</xsl:with-param>
        </xsl:call-template>
      </fo:simple-page-master>
    </xsl:if>

    <fo:page-sequence-master master-name="legal">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference master-reference="blank"
          blank-or-not-blank="blank"/>
        <fo:conditional-page-master-reference master-reference="legal-first"
          page-position="first"/>
        <fo:conditional-page-master-reference master-reference="legal-odd"
          odd-or-even="odd"/>
        <fo:conditional-page-master-reference
          odd-or-even="even">
          <xsl:attribute name="master-reference">
            <xsl:choose>
              <xsl:when test="$double.sided != 0">legal-even</xsl:when>
              <xsl:otherwise>legal-odd</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <xsl:if test="$draft.mode != 'no'">
      <fo:page-sequence-master master-name="legal-draft">
        <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference master-reference="blank-draft"
            blank-or-not-blank="blank"/>
          <fo:conditional-page-master-reference master-reference="legal-first-draft"
            page-position="first"/>
          <fo:conditional-page-master-reference master-reference="legal-odd-draft"
            odd-or-even="odd"/>
          <fo:conditional-page-master-reference
            odd-or-even="even">
            <xsl:attribute name="master-reference">
              <xsl:choose>
                <xsl:when test="$double.sided != 0">legal-even-draft</xsl:when>
                <xsl:otherwise>legal-odd-draft</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </fo:conditional-page-master-reference>
        </fo:repeatable-page-master-alternatives>
      </fo:page-sequence-master>
    </xsl:if>
</xsl:template>

<xsl:template name="select.user.pagemaster">
  <xsl:param name="element"/>
  <xsl:param name="pageclass"/>
  <xsl:param name="default-pagemaster"/>

  <xsl:choose>
    <xsl:when test="self::d:appendix[@role='legal']">
      <xsl:text>legal</xsl:text>
      <xsl:if test="$draft.mode = 'yes'">
        <xsl:text>-draft</xsl:text>
      </xsl:if>
      <xsl:if test="ancestor-or-self::*[@status][1]/@status = 'draft'">
        <xsl:text>-draft</xsl:text>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-pagemaster"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="create.region.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:variable name="title" select="(ancestor-or-self::d:set/d:title |
    ancestor-or-self::d:book/d:bookinfo/d:title |
    ancestor-or-self::d:book/d:title |
    ancestor-or-self::d:article/d:articleinfo/d:title |
    ancestor-or-self::d:article/d:title
    )[last()]"/>
  
  <xsl:call-template name="product"/>
  <xsl:text> * </xsl:text>
  <xsl:apply-templates select="$title" mode="title.markup"/>
</xsl:template>


  
<xsl:template name="outer.region.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>
  
  <xsl:variable name="title" select="(ancestor-or-self::d:set/d:title |
                         ancestor-or-self::d:book/d:bookinfo/d:title |
                         ancestor-or-self::d:book/d:title |
                         ancestor-or-self::d:article/d:articleinfo/d:title |
                         ancestor-or-self::d:article/d:title
                         )[last()]"/>

  <!-- pageclass can be front, body, back -->
  <!-- sequence can be odd, even, first, blank -->
  <!-- position can be left, center, right -->

  <!-- Customize to add side region content-->
  <fo:block xsl:use-attribute-sets="outer.region.content.properties"
     margin-top="2em">
    <xsl:if test="$draft.mode = 'yes'">
      <xsl:call-template name="create.region.content"/>
    </xsl:if>
  </fo:block>
</xsl:template>
</xsl:stylesheet>

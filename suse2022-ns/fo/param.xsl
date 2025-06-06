<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for XSL-FO.
    (Sorted against the list in "Part 2. FO Parameter Reference" in
    the DocBook XSL Stylesheets User Reference, see link below)

    See Also:
    * http://docbook.sourceforge.net/release/xsl-ns/current/doc/fo/index.html

  Author(s):  Stefan Knorr <sknorr@suse.de>
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

  <!-- FIXME suse22: Keep this disabled? Re-enable? -->
  <!-- Disable optional checks designed to give feedback to writers but which
  are not necessary for builds as such. This only makes sense for people who
  look at `daps -vv` output which no one seems to do. -->
  <xsl:param name="optimize.performance" select="1"/>


<!-- 1. Admonitions  ============================================ -->


<!-- 2. Callouts ================================================ -->


<!-- 3. ToC/LoT/Index Generation ================================ -->
<xsl:param name="autotoc.label.separator" select="' '"/>
<xsl:param name="generate.toc">
/article  toc,title
article   toc,title
book      toc,title
part      toc,title
reference toc,title
set       toc,title
</xsl:param>
<xsl:param name="toc.indent.width">0</xsl:param>


<!-- 4. Processor Extensions ==================================== -->


<!-- 5. Stylesheet Extensions =================================== -->


<!-- 6. Automatic labelling ===================================== -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>


<!-- 7. XSLT Processing  ======================================== -->


<!-- 8. Meta/*Info ============================================== -->


<!-- 9. Reference Pages ========================================= -->
<xsl:param name="refentry.generate.name" select="1"/>
<xsl:param name="refentry.generate.title" select="0"/>

<!-- 10. Tables ================================================= -->
<xsl:param name="default.table.width">100%</xsl:param>
<!-- FIXME: check c_fog_200 for grayscale compatibility -->
<xsl:param name="table.frame.border.color">&c_fog_200;</xsl:param>
<xsl:param name="table.frame.border.thickness">&thinline;mm</xsl:param>
<xsl:param name="table.cell.border.color">&c_fog_200;</xsl:param>
<xsl:param name="table.cell.border.thickness">&thinline;mm</xsl:param>
<xsl:attribute-set name="table.cell.padding">
  <xsl:attribute name="padding-start">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-end">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-top">1.5mm</xsl:attribute>
  <xsl:attribute name="padding-bottom">1.25mm</xsl:attribute>
    <!-- Smaller than padding-top, to compensate for the fact that descenders
         reserve some area at the bottom too. -->
</xsl:attribute-set>

<!-- 11. Linking ================================================ -->
<xsl:param name="generate.consistent.ids" select="1"/>

<!-- 12. Cross References ======================================= -->


<!-- 13. Lists ================================================== -->
<xsl:param name="variablelist.term.break.after" select="1"/>


<!-- 14. QAndASet =============================================== -->
<xsl:param name="qanda.inherit.numeration" select="1"/>
<xsl:param name="qanda.defaultlabel">global</xsl:param>

<!-- 15. Bibliography =========================================== -->


<!-- 16. Glossary =============================================== -->
<xsl:param name="glossary.as.blocks" select="1"/>
<xsl:param name="glosslist.as.blocks" select="1"/>
<xsl:param name="glossary.sort" select="1"/>


<!-- 17. Miscellaneous ========================================== -->
<xsl:param name="bookmarks.collapse" select="0"/>
<xsl:param name="variablelist.as.blocks" select="1"/>
<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
task before
</xsl:param>
<xsl:param name="shade.verbatim" select="1"/>

<!-- Don't do this - this leads to stray "-" characters with FOP 1.1. Ugh!
     To check if this still happens: Look at the output of
     "<screen>ls -l</screen>" "ls - -l"? -->
<!-- <xsl:param name="hyphenate.verbatim" select="'1'"/> -->

<xsl:param name="runinhead.default.title.end.punct">:</xsl:param>

<!-- 18. Graphics =============================================== -->


<!-- 19. Pagination and General Styles ========================== -->
<xsl:param name="paper.type" select="'A4'"/>
<xsl:param name="double.sided" select="0"/>
<xsl:param name="force.blank.pages" select="0"/>

<xsl:param name="page.margin.top" select="'19mm'"/>
<xsl:param name="body.margin.top" select="'0mm'"/>
<xsl:param name="page.margin.bottom" select="'18.9mm'"/>
<xsl:param name="body.margin.bottom" select="'30.5mm'"/>
<xsl:param name="page.margin.start" select="&column;"/>
<xsl:param name="page.margin.inner" select="concat($page.margin.start, 'mm')"/>
<xsl:param name="body.margin.inner" select="'0mm'"/>
<xsl:param name="page.margin.outer" select="concat($page.margin.start, 'mm')"/>
<xsl:param name="body.margin.outer" select="'0mm'"/>

<xsl:param name="header.rule" select="0"/>
<xsl:param name="footer.rule" select="0"/>
<xsl:param name="footer.column.widths"
  select="concat(&column; + &gutter;, ' ', 4 * &column; + 3 * &gutter;, ' ', &column; + &gutter;)"/>
  <!-- These are actual millimeters, even though this only needs to be a
       proportion. -->

<xsl:param name="body.start.indent" select="'0'"/>

<xsl:param name="draft.watermark.image"><xsl:value-of select="$styleroot"/>images/draft.svg</xsl:param>
<xsl:param name="line-height" select="concat($base-lineheight, 'em')"/>


<xsl:param name="alignment">
  <xsl:choose>
    <xsl:when test="$enable-text-justification = 'false'">start</xsl:when>
    <xsl:otherwise>justify</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<!-- 20. Font Families ========================================== -->

<xsl:param name="serif-stack">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'serif'"/>
    <xsl:with-param name="property.type" select="'font'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-stack">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans'"/>
    <xsl:with-param name="property.type" select="'font'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="mono-stack">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'mono'"/>
    <xsl:with-param name="property.type" select="'font'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="mono-xheight-adjust">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'mono-xheight-adjust'"/>
    <xsl:with-param name="property.type" select="'number'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-xheight-adjust">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans-xheight-adjust'"/>
    <xsl:with-param name="property.type" select="'number'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="fontsize-adjust">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'fontsize-adjust'"/>
    <xsl:with-param name="property.type" select="'number'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-fontsize-adjust" select="$fontsize-adjust * $sans-xheight-adjust"/>
<xsl:param name="mono-fontsize-adjust" select="$fontsize-adjust * $mono-xheight-adjust"/>

<xsl:param name="body.font.family" select="$serif-stack"/>
<!-- It is not helpful to set dingbat font family, as the symbol font is always
     included anyway -->
<xsl:param name="dingbat.font.family" select="''"/>
<xsl:param name="sans.font.family" select="$sans-stack"/>
<xsl:param name="title.font.family" select="$sans-stack"/>
<xsl:param name="monospace.font.family" select="$mono-stack"/>
<xsl:param name="symbol.font.family">&symbol;</xsl:param>

<xsl:param name="body.font.master" select="'&normal;'"/>
<xsl:param name="body.font.size">
  <xsl:value-of select="$body.font.master * $fontsize-adjust"/>pt
</xsl:param>
<xsl:param name="footnote.font.size"><xsl:value-of select="&small; * $sans-fontsize-adjust"/>pt</xsl:param>


<!-- 21. Property Sets ========================================== -->


<!-- 22. Profiling ============================================== -->


<!-- 23. Localization =========================================== -->
<xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<xsl:param name="document.language">
  <xsl:call-template name="l10n.language">
    <xsl:with-param name="target"
      select="(/* | key('id', $rootid))[last()]"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="writing.mode">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'writing-mode'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-bold">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-bold'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-serif-semibold">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-serif-semibold'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-sans-semibold">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-sans-semibold'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-mono-semibold">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-mono-semibold'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-italic">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-italic'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="base-lineheight">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'base-lineheight'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="mono-lineheight-adjust">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans-lineheight-adjust'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-lineheight-adjust">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans-lineheight-adjust'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="sans-cutoff-factor">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans-cutoff-factor'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="enable-text-justification">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-text-justification'"/>
  </xsl:call-template>
</xsl:param>

<!-- Callouts font basically hardcoded to be the default font (since these
are always just normal numbers). -->
<xsl:param name="callout-font-stack">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'sans'"/>
    <xsl:with-param name="property.language" select="'default'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="enable-callout-font-semibold">
  <xsl:call-template name="get.l10n.property">
    <xsl:with-param name="property" select="'enable-sans-semibold'"/>
    <xsl:with-param name="property.language" select="'default'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="callout-font-weight">
  <xsl:choose>
    <xsl:when test="$enable-callout-font-semibold">600</xsl:when>
    <xsl:otherwise>700</xsl:otherwise>
  </xsl:choose>
</xsl:param>


<!-- 24. EBNF =================================================== -->


<!-- 25. Prepress =============================================== -->


<!-- 26. Custom ================================================= -->

<!-- Creates borders or other things to debug FO code-->
<xsl:param name="debug.fo" select="0"/>

<!-- Saxon will fail if these parameters aren't declared. -->
<xsl:param name="format.print" select="0"/>

<!-- Include product information in footer -->
<xsl:param name="print.product" select="1"/>

<!-- Where to link for SUSE documentation -->
<xsl:param name="suse.doc.url">https://documentation.suse.com</xsl:param>

<!-- SUSE  -->
<xsl:param name="company.address"/>

<xsl:param name="enable.secondary.branding" select="0"/>

<xsl:param name="styleroot" select="'WARNING: styleroot unset!'"/>

<!-- Should navigation titles be displayed? 0=no, 1=yes
     For FO we don't need that, so setting it to 0
-->
<xsl:param name="navig.showtitles" select="0"/>

<!--  Output a warning, if chapter/@lang is different from book/@lang ?
      0=no, 1=yes
-->
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>

<!-- This simplifies LTR/RTL layout conversion in a few places -->
<xsl:param name="start-border">
  <xsl:choose>
    <xsl:when test="$writing.mode = 'rl'">right</xsl:when>
    <xsl:otherwise>left</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<!-- logo on book & article title page: display width -->

<xsl:param name="titlepage.logo.width"><xsl:value-of select="(2 * &column;) + (1 * &gutter;)"/>mm</xsl:param>
<xsl:param name="titlepage.logo.width.article"><xsl:value-of select="&column; + &gutter;"/>mm</xsl:param>


<!-- Background image for Book title page -->

<xsl:param name="titlepage.background.width"
  ><xsl:value-of select="(&column; * 5) + (&gutter; * 3)"/>mm</xsl:param>


<!-- Characters for the hyphenation algorithm:
          Contains characters hyhenated before or after other text
-->
<xsl:param name="ulink.hyphenate.before.chars"
   >.,%?&amp;#\~+{_-</xsl:param>
<xsl:param name="ulink.hyphenate.after.chars"
   >/:@=};</xsl:param>


<!-- Show arrows before and after a paragraph that applies only to a certain
     architecture? -->
<xsl:param name="para.use.arch" select="1"/>

<!-- Creator string for PDF -->
<xsl:param name="pdf-creator">
  <xsl:call-template name="converter-string"/>
</xsl:param>

<!-- Trim away empty lines from the beginning and end of screens -->
<xsl:param name="trim.verbatim" select="1"/>

</xsl:stylesheet>

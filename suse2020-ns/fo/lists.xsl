<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Unconditionally use a filled circle as the bullet before lists.

  Author(s):  Stefan Knorr <sknorr@suse.de>, Janina Setz <jsetz@suse.com>

  Copyright:  2013, 2016, Stefan Knorr, Janina Setz

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

<xsl:template name="itemizedlist.label.markup">
  <!-- We want nice large bullets like we get in the browser. None of the
       fonts we are currently using seem to provide anything fitting. (You can
       get close by using a larger font – this gives you a problem with line
       height, though, which must not be below 1em, it seems.) -->
  <fo:instream-foreign-object content-height="0.4em"
    alignment-baseline="alphabetic" alignment-adjust="0.175em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100" height="100">
      <svg:circle cx="50" cy="50" r="50" stroke="none" fill="{$dark-green}"/>
    </svg:svg>
  </fo:instream-foreign-object>
</xsl:template>


<xsl:template match="d:varlistentry" mode="vl.as.blocks">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <fo:block id="{$id}"
    xsl:use-attribute-sets="variablelist.term.properties list.item.spacing"
    keep-together.within-column="always"
    keep-with-next.within-column="always">
    <xsl:apply-templates select="d:term"/>
  </fo:block>

  <fo:block>
    <xsl:attribute name="margin-{$direction.align.start}">&columnfragment;mm
    </xsl:attribute>
    <xsl:apply-templates select="d:listitem"/>
  </fo:block>
</xsl:template>


<xsl:template match="d:itemizedlist">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:if test="d:title">
    <xsl:apply-templates select="d:title" mode="list.title.mode"/>
  </xsl:if>

  <!-- Preserve order of PIs and comments -->
  <xsl:apply-templates
      select="*[not(self::d:listitem
                or self::d:title
                or self::d:titleabbrev)]
              |comment()[not(preceding-sibling::d:listitem)]
              |processing-instruction()[not(preceding-sibling::d:listitem)]"/>

  <xsl:variable name="content">
    <xsl:apply-templates
          select="d:listitem
                 |comment()[preceding-sibling::d:listitem]
                 |processing-instruction()[preceding-sibling::d:listitem]"/>
  </xsl:variable>

  <!-- nested lists don't add extra list-block spacing -->
  <fo:list-block id="{$id}" xsl:use-attribute-sets="list.block.spacing list.block.properties">
   <xsl:if test="$keep.together != ''">
    <xsl:attribute name="keep-together.within-column">
     <xsl:value-of select="$keep.together"/>
    </xsl:attribute>
   </xsl:if>
   <xsl:copy-of select="$content"/>
  </fo:list-block>
</xsl:template>


<xsl:template match="d:orderedlist">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:if test="d:title">
    <xsl:apply-templates select="d:title" mode="list.title.mode"/>
  </xsl:if>

  <!-- Preserve order of PIs and comments -->
  <xsl:apply-templates
      select="*[not(self::d:listitem
                or self::d:title
                or self::d:titleabbrev)]
              |comment()[not(preceding-sibling::d:listitem)]
              |processing-instruction()[not(preceding-sibling::d:listitem)]"/>

  <xsl:variable name="content">
    <xsl:apply-templates
          select="d:listitem
                  |comment()[preceding-sibling::d:listitem]
                  |processing-instruction()[preceding-sibling::d:listitem]"/>
  </xsl:variable>

  <!-- nested lists don't add extra list-block spacing -->
  <xsl:choose>
    <xsl:when test="ancestor::d:listitem">
      <fo:list-block id="{$id}" xsl:use-attribute-sets="list.block.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:when>
    <xsl:otherwise>
      <fo:list-block id="{$id}"
        xsl:use-attribute-sets="list.block.spacing list.block.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column">
            <xsl:value-of select="$keep.together"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:list-block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

  <!-- Styling with a line on the left side +
  Handle step performance="optional": For the common case, where there is a
  para as the first item within step, we handle this in the para template
  further down. For the much less common case of "anything else" (e.g. a list
  as first element), we handle this directly in the step template.-->
<xsl:template match="d:procedure">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="param.placement"
                select="substring-after(normalize-space($formal.title.placement),
                                        concat(local-name(.), ' '))"/>

  <xsl:variable name="placement">
    <xsl:choose>
      <xsl:when test="contains($param.placement, ' ')">
        <xsl:value-of select="substring-before($param.placement, ' ')"/>
      </xsl:when>
      <xsl:when test="$param.placement = ''">before</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$param.placement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Preserve order of PIs and comments -->
  <xsl:variable name="preamble"
        select="*[not(self::d:step
                  or self::d:title
                  or self::d:titleabbrev)]
                |comment()[not(preceding-sibling::d:step)]
                |processing-instruction()[not(preceding-sibling::d:step)]"/>

  <xsl:variable name="steps"
                select="d:step
                        |comment()[preceding-sibling::d:step]
                        |processing-instruction()[preceding-sibling::d:step]"/>

  <fo:block id="{$id}" xsl:use-attribute-sets="list.block.properties list.block.spacing">
    <xsl:if test="./d:title and $placement = 'before'">
      <!-- n.b. gentext code tests for $formal.procedures and may make an "informal" -->
      <!-- heading even though we called formal.object.heading. odd but true. -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>

    <fo:block>
      <xsl:if test="not(ancestor::d:procedure)">
        <xsl:attribute name="border-{$start-border}">
          <xsl:text>&mediumline;mm solid </xsl:text>
          <xsl:choose>
            <xsl:when test="$format.print != 0">
              <xsl:text>&dark-gray;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>&dark-green;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>

        <xsl:attribute name="margin-{$start-border}"><xsl:value-of select="&mediumline; div 2"/>mm</xsl:attribute>
          <!-- This is seemingly illogical... but looks better with both FOP and
               XEP. -->
      </xsl:if>

      <xsl:if test="$preamble != ''">
        <fo:block>
          <xsl:attribute name="margin-{$start-border}">&columnfragment;mm</xsl:attribute>
          <xsl:apply-templates select="$preamble"/>
        </fo:block>
      </xsl:if>

      <fo:list-block
        xsl:use-attribute-sets="list.block.spacing list.block.properties">
        <xsl:apply-templates select="$steps"/>
      </fo:list-block>
    </fo:block>

    <xsl:if test="./d:title and $placement != 'before'">
      <!-- n.b. gentext code tests for $formal.procedures and may make an "informal" -->
      <!-- heading even though we called formal.object.heading. odd but true. -->
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
  </fo:block>
</xsl:template>


<xsl:template match="d:substeps">
  <fo:list-block xsl:use-attribute-sets="list.block.spacing list.block.properties">
    <xsl:apply-templates/>
  </fo:list-block>
</xsl:template>


<xsl:template match="d:procedure/d:step|d:substeps/d:step">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <fo:list-item xsl:use-attribute-sets="list.item.spacing">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <fo:list-item-label end-indent="label-end()"
      xsl:use-attribute-sets="orderedlist.label.properties">
      <fo:block id="{$id}">
        <!-- dwc: fix for one step procedures. Use a bullet if there's no step 2 -->
        <xsl:choose>
          <xsl:when test="count(../d:step) = 1">
            <xsl:call-template name="itemizedlist.label.markup"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="number">
              <xsl:with-param name="recursive" select="0"/>
            </xsl:apply-templates>.
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <fo:block>
        <xsl:if test="@performance='optional' and
                      *[1][local-name()!='para' and local-name()!='simpara']">
          <fo:inline color="&mid-gray;" xsl:use-attribute-sets="italicized">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'step.optional'"/>
            </xsl:call-template>
          </fo:inline>
        </xsl:if>
        <xsl:apply-templates/>
      </fo:block>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>

<!-- Special handling for arch attributes + Don't break after colons. -->
<xsl:template match="d:listitem/*[1][local-name()='para' or
                                   local-name()='simpara' or
                                   local-name()='formalpara']
                     |d:glossdef/*[1][local-name()='para' or
                                   local-name()='simpara' or
                                   local-name()='formalpara']
                     |d:step/*[1][local-name()='para' or
                                   local-name()='simpara' or
                                   local-name()='formalpara']
                     |d:callout/*[1][local-name()='para' or
                                   local-name()='simpara' or
                                   local-name()='formalpara']"
              priority="2">

  <fo:block xsl:use-attribute-sets="para.properties">
    <xsl:call-template name="no-break-after-colon"/>

    <xsl:call-template name="anchor"/>
    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows">
        <xsl:with-param name="arch-value" select="@arch"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="(self::d:para or self::d:simpara) and ../@performance='optional'">
      <fo:inline color="&mid-gray;" xsl:use-attribute-sets="italicized">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'step.optional'"/>
        </xsl:call-template>
      </fo:inline>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows"/>
    </xsl:if>
  </fo:block>
</xsl:template>
<!-- End template to remove -->

<xsl:template match="d:varlistentry/d:term" mode="xref-to">
  <fo:inline>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates>
          <xsl:with-param name="purpose" select="'xref'"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </fo:inline>
  <xsl:choose>
    <xsl:when test="not(following-sibling::d:term)"/> <!-- do nothing -->
    <xsl:otherwise>
      <!-- * if we have multiple terms in the same varlistentry, generate -->
      <!-- * a separator (", " by default) and/or an additional line -->
      <!-- * break after each one except the last -->
      <fo:inline><xsl:value-of select="$variablelist.term.separator"/></fo:inline>
      <xsl:if test="not($variablelist.term.break.after = '0')">
        <fo:block/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

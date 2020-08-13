<?xml version="1.0" encoding="ASCII"?>
<!--
    Purpose:
    Rework the structure of Q and A sections to include fewer tables.

    Author:     Stefan Knorr <sknorr@suse.de>
    Copyright:  2012, Stefan Knorr
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl d">


<xsl:template match="d:qandaset">
  <xsl:variable name="title" select="(d:blockinfo/d:title|d:info/d:title|d:title)[1]"/>
  <xsl:variable name="preamble" select="*[local-name(.) != 'title'
                                      and local-name(.) != 'titleabbrev'
                                      and local-name(.) != 'qandadiv'
                                      and local-name(.) != 'qandaentry']"/>
  <xsl:variable name="toc">
    <xsl:call-template name="pi.dbhtml_toc"/>
  </xsl:variable>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <div>
    <xsl:apply-templates select="." mode="common.html.attributes"/>
    <xsl:apply-templates select="$title"/>
    <xsl:if test="not($title)">
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="force" select="1"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="((contains($toc.params, 'toc') and $toc != '0') or $toc = '1')
            and not(ancestor::d:answer and not($qanda.nested.in.toc=0))">
      <xsl:call-template name="process.qanda.toc"/>
    </xsl:if>
    <xsl:apply-templates select="$preamble"/>
    <xsl:call-template name="process.qandaset"/>
  </div>
</xsl:template>


<xsl:template name="process.qandaset">
  <xsl:apply-templates select="d:qandaentry|d:qandadiv"/>
</xsl:template>

<xsl:template match="d:question/d:para[1]" priority="4">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:question/d:para">
  <br/><xsl:apply-templates/>
</xsl:template>

<xsl:template match="d:qandadiv">
  <xsl:variable name="preamble" select="*[local-name(.) != 'title'
                                      and local-name(.) != 'titleabbrev'
                                      and local-name(.) != 'qandadiv'
                                      and local-name(.) != 'qandaentry']"/>

  <xsl:if test="d:blockinfo/d:title|d:info/d:title|d:title">
    <div class="qandadiv-title-wrap">
        <xsl:apply-templates select="(d:blockinfo/d:title|d:info/d:title|d:title)[1]"/>
    </div>
  </xsl:if>

  <xsl:variable name="toc">
    <xsl:call-template name="pi.dbhtml_toc"/>
  </xsl:variable>

  <xsl:variable name="toc.params">
    <xsl:call-template name="find.path.params">
      <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="(contains($toc.params, 'toc') and $toc != '0') or $toc = '1'">
    <div class="toc">
        <xsl:call-template name="process.qanda.toc"/>
    </div>
  </xsl:if>
  <xsl:if test="$preamble">
    <div class="toc">
        <xsl:apply-templates select="$preamble"/>
    </div>
  </xsl:if>
  <div class="qandadiv">
    <xsl:apply-templates select="d:qandadiv|d:qandaentry"/>
  </div>
</xsl:template>


<xsl:template match="d:qandaentry">
  <div class="free-id">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
  </div>
  <dl class="qandaentry">

    <xsl:apply-templates/>
  </dl>
</xsl:template>


<xsl:template match="d:question">
  <dt class="question">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:variable name="label.content">
      <xsl:apply-templates select="." mode="qanda.label"/>
    </xsl:variable>
    <strong><xsl:value-of select="$label.content"/></strong>
    <xsl:apply-templates select="*[local-name(.) != 'label']"/>
  </dt>
</xsl:template>


<xsl:template match="d:answer">
  <dd class="answer">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="*[local-name(.) != 'label' and local-name(.) != 'qandaentry']"/>
  </dd>
</xsl:template>

<!-- ======================================================================= -->

<xsl:template match="d:qandaset/d:blockinfo/d:title|
                     d:qandaset/d:info/d:title|
                     d:qandaset/d:title">
  <xsl:variable name="qalevel">
    <xsl:call-template name="qanda.section.level"/>
  </xsl:variable>
  <xsl:element name="h{string(number($qalevel)+1)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="." mode="class.attribute"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="d:qandadiv/d:blockinfo/d:title|
                     d:qandadiv/d:info/d:title|
                     d:qandadiv/d:title">
  <xsl:variable name="qalevel">
    <xsl:call-template name="qandadiv.section.level"/>
  </xsl:variable>

  <xsl:element name="h{string(number($qalevel)+1)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class">qandadiv-title</xsl:attribute>
    <xsl:call-template name="id.attribute">
      <xsl:with-param name="node" select=".."/>
      <xsl:with-param name="force" select="1"/>
    </xsl:call-template>
    <xsl:apply-templates select="parent::d:qandadiv" mode="label.markup"/>
    <xsl:if test="$qandadiv.autolabel != 0">
      <xsl:apply-templates select="." mode="intralabel.punctuation"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- ======================================================================= -->

<xsl:template name="process.qanda.toc">
  <ul>
    <xsl:if test="local-name(.) = 'qandaset'">
      <xsl:attribute name="class">qanda-toc</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="d:qandadiv" mode="qandatoc.mode"/>
    <xsl:apply-templates select="d:qandaset|d:qandaentry" mode="qandatoc.mode"/>
  </ul>
</xsl:template>

<xsl:template match="d:qandadiv" mode="qandatoc.mode">
  <li><xsl:apply-templates select="d:title" mode="qandatoc.mode"/>
      <xsl:call-template name="process.qanda.toc"/>
  </li>
</xsl:template>

<xsl:template match="d:question" mode="qandatoc.mode">
  <xsl:variable name="firstch">
    <!-- Use a titleabbrev or title if available -->
    <xsl:choose>
      <xsl:when test="../d:blockinfo/d:titleabbrev">
        <xsl:apply-templates select="../d:blockinfo/d:titleabbrev[1]/node()"/>
      </xsl:when>
      <xsl:when test="../d:blockinfo/d:title">
        <xsl:apply-templates select="../d:blockinfo/d:title[1]/node()"/>
      </xsl:when>
      <xsl:when test="../d:info/d:titleabbrev">
        <xsl:apply-templates select="../d:info/d:titleabbrev[1]/node()"/>
      </xsl:when>
      <xsl:when test="../d:titleabbrev">
        <xsl:apply-templates select="../d:titleabbrev[1]/node()"/>
      </xsl:when>
      <xsl:when test="../d:info/d:title">
        <xsl:apply-templates select="../d:info/d:title[1]/node()"/>
      </xsl:when>
      <xsl:when test="../d:title">
        <xsl:apply-templates select="../d:title[1]/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="(*[local-name(.)!='label'])[1]/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()]/@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <li>
    <xsl:apply-templates select="." mode="label.markup"/>
    <xsl:if test="contains($deflabel,'number') and not(d:label)">
      <xsl:apply-templates select="." mode="intralabel.punctuation"/>
    </xsl:if>
    <xsl:text> </xsl:text>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="$firstch"/>
    </a>
    <!-- * include nested qandaset/qandaentry in TOC if user wants it -->
    <xsl:if test="not($qanda.nested.in.toc = 0)">
      <xsl:apply-templates select="following-sibling::d:answer" mode="qandatoc.mode"/>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="d:answer" mode="qandatoc.mode">
  <xsl:if test="descendant::d:question">
    <ul>
      <li>
        <xsl:call-template name="process.qanda.toc"/>
      </li>
    </ul>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>

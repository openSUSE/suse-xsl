<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook's block elements

  Author:     Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2012, 2013, Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns:la="urn:x-suse:xslt:layout"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t d la">

  <xsl:template match="d:para[@arch]">
    <xsl:variable name="arch">
      <xsl:call-template name="readable.arch.string">
        <xsl:with-param name="input" select="@arch"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="paragraph">
    <xsl:with-param name="class">
      <xsl:if test="@role and $para.propagates.style != 0">
        <xsl:value-of select="@role"/>
      </xsl:if>
    </xsl:with-param>
    <xsl:with-param name="content">
      <xsl:if test="position() = 1 and parent::d:listitem">
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select="parent::d:listitem"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
    </xsl:with-param>
    <xsl:with-param name="arch">
      <xsl:if test="$para.use.arch != 0">
        <xsl:value-of select="$arch"/>
      </xsl:if>
    </xsl:with-param>
  </xsl:call-template>
  </xsl:template>

<!-- Same as upstream version, but can also handle paragraphs with an
     architecture assigned to them. -->
  <xsl:template name="paragraph">
    <xsl:param name="node" select="."/>
    <xsl:param name="class" select="''"/>
    <xsl:param name="content"/>
    <xsl:param name="arch"/>

    <xsl:variable name="text-color">
      <xsl:choose>
        <xsl:when test="processing-instruction('dbsuse')">
          <xsl:call-template name="get-suse-color">
            <xsl:with-param name="value">
              <xsl:call-template name="pi-attribute">
                <xsl:with-param name="pis"
                  select="processing-instruction('dbsuse')" />
                <xsl:with-param name="attribute">color</xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="starts-with(@role, 'color:')">
          <!-- <xsl:message>d:phrase color="<xsl:value-of select="substring-after(., 'color:')"/>"</xsl:message>-->
          <xsl:call-template name="get-suse-color">
            <xsl:with-param name="value" select="substring-after(@role, 'color:')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="p">
      <p>
        <xsl:call-template name="id.attribute"/>
        <xsl:if test="$text-color != ''">
          <xsl:attribute name="style">
            <xsl:value-of select="concat('color:', $text-color, ';')"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$class != ''">
            <xsl:call-template name="common.html.attributes">
              <xsl:with-param name="class" select="$class"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="common.html.attributes">
              <xsl:with-param name="class" select="''"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="$arch != ''">
          <strong class="arch-arrow-start">
            <xsl:value-of select="$arch"/>
          </strong>
        </xsl:if>

        <xsl:copy-of select="$content"/>

        <xsl:if test="$arch != ''">
          <strong class="arch-arrow-end"><xsl:text> </xsl:text></strong>
        </xsl:if>
      </p>
    </xsl:variable>
    

    <xsl:choose>
      <xsl:when test="$html.cleanup != 0">
        <xsl:call-template name="unwrap.p">
          <xsl:with-param name="p" select="$p"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$p"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:formalpara/d:title|d:formalpara/d:info/d:title">
  <xsl:variable name="titleStr">
      <xsl:apply-templates/>
  </xsl:variable>
  <xsl:variable name="ns-titleStr" select="normalize-space($titleStr)"/>
  <xsl:variable name="lastChar">
    <xsl:if test="$ns-titleStr != ''">
      <xsl:value-of select="substring($ns-titleStr, string-length($ns-titleStr), 1)"/>
    </xsl:if>
  </xsl:variable>

  <span class="formalpara-title">
   <xsl:copy-of select="$titleStr"/>
    <xsl:if test="$lastChar != '' and not(contains($runinhead.title.end.punct, $lastChar))">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">runinhead.default.title.end.punct</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="d:formalpara/d:title/node()[last()][self::text()]">
 <xsl:call-template name="trim-verbatim-whitespace-end">
  <xsl:with-param name="input" select="."/>
 </xsl:call-template>
</xsl:template>

<xsl:template match="d:para[normalize-space(.)='' and not(*)]"/>

</xsl:stylesheet>

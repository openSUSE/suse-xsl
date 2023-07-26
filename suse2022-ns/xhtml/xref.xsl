<?xml version="1.0"?>
<!--
  Purpose:
     Make the anchor template dysfunctional.

   See Also:
     * http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Author(s): Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
    <xsl:param name="conditional" select="1"/>

    <xsl:if test="local-name($node) = 'figure'">
      <xsl:attribute name="id">
        <xsl:call-template name="object.id">
          <xsl:with-param name="object" select="$node"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:question" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="verbose" select="1"/>
    <xsl:variable name="teaser">
      <xsl:apply-templates select="d:para[1]" mode="question"/>
    </xsl:variable>
    <xsl:variable name="teaser-length">
      <xsl:value-of select="string-length(normalize-space($teaser))"/>
    </xsl:variable>
    <xsl:variable name="punctuation">
      <xsl:if test="$teaser-length &gt; 100">
        <xsl:choose>
          <xsl:when test="substring-before(substring($teaser,99,$teaser-length),'?')
            != ''">..?</xsl:when>
          <xsl:otherwise>…</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <em>
      <xsl:choose>
        <xsl:when test="$teaser-length &gt; 100">
            <xsl:value-of select="substring(normalize-space($teaser),1,100)"/>
            <xsl:value-of select="$punctuation"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="d:para[1]" mode="question"/>
        </xsl:otherwise>
      </xsl:choose>
    </em>
  </xsl:template>

  <xsl:template match="d:question/d:para[1]" mode="question">
    <!-- We don't want a block here: we just process the next
         child inside a para
    -->
    <xsl:apply-templates mode="question"/>
  </xsl:template>

  <xsl:template match="*" mode="qanda">
    <!-- Fallback to default mode -->
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="d:footnote" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="verbose" select="1"/>
    <xsl:variable name="href">
      <xsl:text>ftn.</xsl:text>
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="."/>
      </xsl:call-template>
    </xsl:variable>

    <a href="{$href}">
      <sup>[<xsl:apply-templates select="." mode="footnote.number"/>]</sup>
    </a>
  </xsl:template>

<xsl:template match="d:xref" name="xref">
  <xsl:variable name="context" select="."/>
  <xsl:variable name="target" select="key('id', @linkend)[1]"/>
  <xsl:variable name="xref.in.samebook">
    <xsl:call-template name="is.xref.within.rootid">
      <xsl:with-param name="target" select="$target"/>
    </xsl:call-template>
  </xsl:variable>

 <!--
    The xref resolution is a bit tricky. We need to distinguish these cases:

    1. if $rootid = '' -> use original code
    2. if $rootid != '' and rootid points to the root node -> use original code
    3. if we point to another book AND we have an @xrefstyle -> output the
       same text content as the original xref template but remove the link
    4. otherwise -> reference into another book
 -->

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

  <xsl:choose>
    <xsl:when test="$xref.in.samebook != 0">
      <!--
        Normal xrefs
        No need to do anything special.
        Fall back to the usual template.
      -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="$xref.in.samebook = 0 and @xrefstyle">
      <!--
        Intra xrefs with @xrefstyle
        We delegate it to the original stylesheet and just extract the content,
        but without the surrounding <a> element
      -->
      <xsl:variable name="rtf">
       <xsl:apply-imports/>
      </xsl:variable>
      <xsl:variable name="node" select="exsl:node-set($rtf)/*"/>

      <span class="intraxref">
        <xsl:copy-of select="$node/node()"/>
      </span>
    </xsl:when>

   <xsl:otherwise>
      <!--
        Intra xrefs
        Our XPath discovered that the node points to something outside
        of our $rootid node.
      -->
      <!-- A reference into another book -->
      <xsl:variable name="this.ancestor" select="ancestor-or-self::*[@xml:id=$rootid]"/>
      <xsl:variable name="target.chapandapp" select="
          ($target/ancestor-or-self::d:chapter[@xml:lang != '']
          | $target/ancestor-or-self::d:appendix[@xml:lang != '']
          )[1]"/>

      <xsl:if test="$warn.xrefs.into.diff.lang != 0 and
                    $target.chapandapp/@xml:lang != $this.ancestor/@xml:lang">
        <xsl:call-template name="log.message">
           <xsl:with-param name="level" select="'warn'"/>
           <xsl:with-param name="context-desc" select="'intra-xref'"/>
           <xsl:with-param name="message">
             <xsl:text>The xref with linkend=</xsl:text>
             <xsl:value-of select="@linkend"/>
             <xsl:text> points at a target with a different language than the main document, xml:id=</xsl:text>
             <xsl:value-of select="$target.chapandapp/@xml:id"/>
             <xsl:text>.</xsl:text>
           </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <span class="intraxref">
        <xsl:call-template name="create.linkto.other.book">
          <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

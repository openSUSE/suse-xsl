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
    <xsl:variable name="interpunction">
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
            <xsl:value-of select="$interpunction"/>
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

  <xsl:template match="d:ulink" name="ulink">
    <xsl:param name="url" select="@url"/>
    <xsl:variable name="link-text">
      <xsl:apply-templates mode="no.anchor.mode"/>
    </xsl:variable>
    <xsl:variable name="flat-link-text">
      <xsl:value-of select="$link-text"/>
    </xsl:variable>

    <a>
      <xsl:apply-templates select="." mode="common.html.attributes"/>
      <xsl:if test="@id or @xml:id">
        <xsl:choose>
          <xsl:when test="$generate.id.attributes = 0">
            <xsl:attribute name="name">
              <xsl:value-of select="(@id|@xml:id)[1]"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="id">
              <xsl:value-of select="(@id|@xml:id)[1]"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:attribute name="href"><xsl:value-of select="$url"/></xsl:attribute>
      <xsl:if test="$ulink.target != ''">
        <xsl:attribute name="target">
          <xsl:value-of select="$ulink.target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <!-- Don't just test for the existence of child nodes: The author may
             have added a space between start and end tag and it would throw us
             off. -->
        <xsl:when test="normalize-space($flat-link-text) = ''">
          <xsl:value-of select="$url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$link-text"/>
          <span class="ulink-url"> (<xsl:value-of select="$url"/>)</span>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>


<xsl:template match="d:xref" name="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="($target/ancestor-or-self::d:article|$target/ancestor-or-self::d:book)[1]"/>
  <xsl:variable name="this.book" select="(ancestor-or-self::d:article|ancestor-or-self::d:book)[1]"/>
  <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[1]"/>
  <xsl:variable name="xref.in.samebook">
    <xsl:call-template name="is.xref.in.samebook">
      <xsl:with-param name="target" select="$target"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

 <!--
    The xref resolution is a bit tricky. We need to distinguish these cases:

    1. if $rootid = '' -> use original code
    2. if $rootid != '' and rootid points to the root node -> use original code
    3. if (1) or (2) does not apply -> reference into another book
    4. if we point to another book AND we have an @xrefstyle -> output the
       same text content as the original xref template but remove the link
 -->
 <xsl:choose>
  <xsl:when test="$rootid = ''">
   <xsl:apply-imports/>
  </xsl:when>
  <xsl:when test="$rootid != '' and $xref.in.samebook != 0">
   <xsl:apply-imports/>
  </xsl:when>
  <!-- If we point to another book AND we have an xrefstyle present,
       skip creating intra-xrefs and use the default, but without
       a clickable text.
    -->
  <xsl:when test="$xref.in.samebook = 0 and @xrefstyle">
   <xsl:variable name="rtf">
    <xsl:apply-imports/>
   </xsl:variable>
   <xsl:variable name="node" select="exsl:node-set($rtf)/*"/>

   <span class="intraxref">
    <xsl:copy-of select="$node/node()"/>
   </span>
  </xsl:when>
  <xsl:when test="$xref.in.samebook != 0 or
                  /d:set/@id=$rootid or
                  /d:article/@id=$rootid">
   <!-- An xref that stays inside the current book or when $rootid
         pointing to the root element, then use the defaults -->
   <xsl:apply-imports/>
  </xsl:when>
  <xsl:otherwise>
   <!-- A reference into another book -->
   <xsl:variable name="target.chapandapp"
    select="($target/ancestor-or-self::d:chapter[@lang!='']
            | $target/ancestor-or-self::d:appendix[@lang!='']
            | $target/ancestor-or-self::d:chapter[@xml:lang!='']
            | $target/ancestor-or-self::d:appendix[@xml:lang!=''])[1]"/>

   <xsl:if test="$warn.xrefs.into.diff.lang != 0 and
    $target.chapandapp/@lang != $this.book/@lang">
    <xsl:message>WARNING: The xref '<xsl:value-of
     select="@linkend"/>' points to a chapter (id='<xsl:value-of
      select="$target.chapandapp/@id"/>') with a different language than the main book.</xsl:message>
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

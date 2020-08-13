<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Add an arrow after outward links to highlight them.

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
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xlink='http://www.w3.org/1999/xlink'
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="xlink exsl d">


<xsl:template match="d:ulink|d:link" name="ulink">
  <xsl:param name="url" select="(@url|@xlink:href)[last()]"/>

  <xsl:variable name="ulink.url">
    <xsl:call-template name="fo-external-image">
      <xsl:with-param name="filename" select="$url"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="hyphenated-url">
    <xsl:call-template name="hyphenate-url">
      <xsl:with-param name="url" select="$url"/>
    </xsl:call-template>
  </xsl:variable>

  <fo:basic-link xsl:use-attribute-sets="xref.properties"
                 external-destination="{$ulink.url}">
    <xsl:choose>
      <xsl:when test="count(child::node()) = 0 or
                      normalize-space(.) = $url or
                      (count(child::*) = 0 and
                       normalize-space(string(.)) = '')">
        <fo:inline hyphenate="false">
          <xsl:value-of select="$hyphenated-url"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>

        <xsl:if test="$ulink.show != 0">
        <!-- Display the URL for this hyperlink only if it is non-empty,
             and the value of its content is not a URL that is the same as
             URL it links to, and if ulink.show is non-zero. -->
          <fo:inline hyphenate="false">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$hyphenated-url"/>
            <xsl:text>)</xsl:text>
          </fo:inline>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="image-after-link"/>
  </fo:basic-link>
</xsl:template>


<xsl:template name="image-after-link">
  <xsl:variable name="fill" select="$dark-green"/>

  <fo:leader leader-pattern="space" leader-length="0.2em"/>
  <fo:instream-foreign-object content-height="0.65em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="100"
      height="100">
      <svg:g>
        <xsl:if test="$writing.mode = 'rl'">
          <xsl:attribute name="transform">matrix(-1,0,0,1,100,0)</xsl:attribute>
        </xsl:if>
        <svg:rect width="54" height="54" x="0" y="46" fill-opacity="0.4"
          fill="{$fill}"/>
        <svg:path d="M 27,0 27,16 72.7,16 17,71.75 28.25,83 84,27.3 84,73 l 16,0 0,-73 z"
          fill="{$fill}"/>
      </svg:g>
    </svg:svg>
  </fo:instream-foreign-object>
  <fo:leader leader-pattern="space" leader-length="0.2em"/>
</xsl:template>

<xsl:template match="d:chapter|d:appendix" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'xref'">
      <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
        <xsl:copy-of select="$title"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="insert.olink.docname.markup">
  <xsl:param name="docname" select="''"/>

  <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
    <xsl:value-of select="$docname"/>
  </fo:inline>
</xsl:template>

<xsl:template name="title.xref">
  <xsl:param name="target" select="."/>
  <xsl:choose>
    <xsl:when test="local-name($target) = 'figure'
                    or local-name($target) = 'example'
                    or local-name($target) = 'equation'
                    or local-name($target) = 'table'
                    or local-name($target) = 'dedication'
                    or local-name($target) = 'acknowledgements'
                    or local-name($target) = 'preface'
                    or local-name($target) = 'bibliography'
                    or local-name($target) = 'glossary'
                    or local-name($target) = 'index'
                    or local-name($target) = 'setindex'
                    or local-name($target) = 'colophon'">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:apply-templates select="$target" mode="title.markup"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <fo:inline xsl:use-attribute-sets="italicized.noreplacement">
        <xsl:apply-templates select="$target" mode="title.markup"/>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="create.xref.with.xrefstyle.to.another.book">
 <xsl:variable name="rtf">
     <xsl:apply-imports/>
 </xsl:variable>
 <xsl:variable name="node" select="exsl:node-set($rtf)/*"/>

  <fo:inline xsl:use-attribute-sets="xref.basic.properties">
    <xsl:copy-of select="$node/*"/>
  </fo:inline>
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

  <xsl:choose>
    <!-- If we point to another book AND we have an xrefstyle present,
         output the same text content as the original xref template but
         remove the link.
    -->
    <xsl:when test="$xref.in.samebook = 0 and @xrefstyle">
      <xsl:variable name="rtf">
        <xsl:apply-imports/>
      </xsl:variable>
      <xsl:variable name="node" select="exsl:node-set($rtf)/*"/>

      <fo:inline xsl:use-attribute-sets="xref.basic.properties">
         <xsl:copy-of select="$node/node()"/>
      </fo:inline>
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

      <fo:inline xsl:use-attribute-sets="xref.basic.properties">
        <xsl:call-template name="create.linkto.other.book">
          <xsl:with-param name="target" select="$target"/>
          <xsl:with-param name="lang" select="$lang"/>
        </xsl:call-template>
      </fo:inline>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

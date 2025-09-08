<?xml version="1.0"?>
<!--
  Purpose:
     Override original id.attribute template, so we can have a special parameter
     to force an ID.

   See Also:
     * http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Author(s): Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, Stefan Knorr

-->

<xsl:stylesheet exclude-result-prefixes="d"
                 version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns="http://www.w3.org/1999/xhtml">


  <xsl:template name="id.attribute">
    <xsl:param name="node" select="."/>
    <xsl:param name="conditional" select="1"/>
    <xsl:param name="force" select="0"/>

    <xsl:choose>
      <!-- No id attributes when this param is zero -->
      <xsl:when test="$generate.id.attributes = 0 and $force != 1"/>
      <xsl:when test="($force = 1 or $conditional = 0 or $node/@xml:id)
          and not($node/self::d:figure)">
        <xsl:attribute name="id">
          <xsl:call-template name="object.id">
            <xsl:with-param name="object" select="$node"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="./d:title or ./d:info/d:title">
          <xsl:variable name="trouble">&quot;&apos;&amp;&lt;&gt;</xsl:variable>
          <xsl:variable name="title-candidate"
            select='normalize-space(translate((./d:title|./d:info/d:title)[1], $trouble, ""))'/>
          <!-- we use @data-id-title for updating the report bug link via
          Javascript later -->
          <xsl:attribute name="data-id-title">
            <xsl:value-of select="$title-candidate"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


<!-- Add a space in between <script> </script>, HTML parsers hate
self-closing <script/> tags! -->
<xsl:template name="make.script.link">
  <xsl:param name="script.filename" select="''"/>

  <xsl:variable name="src">
    <xsl:call-template name="relative.path.link">
      <xsl:with-param name="target.pathname" select="$script.filename"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="string-length($script.filename) != 0">
    <script>
      <xsl:attribute name="src">
        <xsl:value-of select="$src"/>
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:value-of select="$html.script.type"/>
      </xsl:attribute>
      <xsl:call-template name="other.script.attributes">
        <xsl:with-param name="script.filename" select="$script.filename"/>
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </script>
  </xsl:if>
</xsl:template>


  <xsl:template name="create-lang-attribute">
    <xsl:param name="lang" />

    <!-- match the attribute name to the output type -->
    <xsl:choose>
      <xsl:when test="$lang and $stylesheet.result.type = 'html'">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$lang and $stylesheet.result.type = 'xhtml'">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

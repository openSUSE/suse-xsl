<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Splitting formal-wise titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template match="d:example">
    <xsl:choose>
      <xsl:when test="d:glosslist|d:bibliolist|d:itemizedlist|d:orderedlist|
                      d:segmentedlist|d:simplelist|d:variablelist|d:programlistingco|
                      d:screenco|d:screenshot|d:cmdsynopsis|d:funcsynopsis|
                      d:classsynopsis|d:fieldsynopsis|d:constructorsynopsis|
                      d:destructorsynopsis|d:methodsynopsis|d:formalpara|d:para|
                      d:simpara|d:address|d:blockquote|d:graphicco|d:mediaobjectco|
                      d:indexterm|d:beginpage">
        <div class="complex-example">
          <xsl:apply-imports/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template
    match="d:procedure|d:example|d:table|d:figure|d:glosslist|d:variablelist|d:itemizedlist|d:orderedlist"
    mode="object.label.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-label')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:procedure|d:example|d:table|d:figure|d:glosslist|d:variablelist|d:itemizedlist|d:orderedlist"
    mode="object.title.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-title')"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="create.formal.title">
    <xsl:param name="node" select="."/>
    <xsl:variable name="label.template">
      <xsl:apply-templates select="$node" mode="object.label.template"/>
    </xsl:variable>

    <span class="title-number-name">
    <xsl:if test="$label.template != ''">
      <span class="title-number">
        <xsl:call-template name="substitute-markup">
          <xsl:with-param name="template" select="$label.template"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </span>
    </xsl:if>
    <span class="title-name">
      <xsl:apply-templates select="$node" mode="title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
    </span>
    </span>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="formal.object.heading">
    <xsl:param name="object" select="."/>
    <xsl:param name="title">
      <xsl:call-template name="create.formal.title">
        <xsl:with-param name="node" select="$object"/>
      </xsl:call-template>
    </xsl:param>

    <xsl:choose>
      <!-- Avoids outputting the (ugly/obvious) label "Abstract"
           before abstracts/highlights:
      -->
      <xsl:when test="local-name($object) = 'abstract'"/>
      <xsl:when test="local-name($object) = 'highlights'"/>
      <xsl:otherwise>
        <div class="title-container">
          <div class="{concat(local-name(),'-title-wrap')}">
            <div class="{concat(local-name(), '-title')}">
              <!-- Do NOT create an id here; parent contains one already -->
              <xsl:copy-of select="$title" />
              <xsl:call-template name="create.permalink">
                <xsl:with-param name="object" select="$object" />
              </xsl:call-template>
            </div>
          </div>
          <xsl:call-template name="generate.title.icons" />
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

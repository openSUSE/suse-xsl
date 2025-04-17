<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Check, if navigation nodes needs to be created in regards to
     $rootid

   Named Templates:
    * is.next.node.in.navig(next=NODE)
      Returns boolean, if the next node is inside the descendants of
      $rootid node and needs to be included in navigation.

    * is.prev.node.in.navig(prev=NODE)
      Returns boolean, if the previous node is inside the descendants of
      $rootid node and needs to be included in navigation.

    * is.node.in.rootid.node(next=NODE, prev=NODE)
      Returns boolean, if the previous, next, up and home link is inside
      the descendants of $rootid node

    * is.xref.within.rootid(target=NODE)
      Returns boolean, if the <xref/>'s target node is inside the
      current book (returns 1) or not (returns 0)

   Author:    Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012-2021

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t d">


  <!-- ===================================================== -->
  <xsl:template name="is.next.node.in.navig">
    <xsl:param name="next"/>
    <xsl:param name="debug" select="false()" />

    <xsl:variable name="next.book"    select="$next/ancestor-or-self::d:book" />
    <xsl:variable name="next.article" select="$next/ancestor-or-self::d:article" />
    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:if test="boolean($debug)">
      <xsl:message>is.next.node.in.navig:
        Element:  <xsl:value-of select="local-name(.)"/>
        next:     <xsl:value-of select="local-name($next)"/>
        rootid:   <xsl:value-of select="concat(local-name($rootid.node), '/', $rootid)"/>
        next.book:    <xsl:value-of select="$next.book/d:title"/>
        next.article: <xsl:value-of select="$next.article/d:title"/>
      </xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="generate-id($rootid.node) = generate-id($next.article)"
        >1</xsl:when>
      <xsl:when test="generate-id($rootid.node) = generate-id($next.book)"
        >1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="is.prev.node.in.navig">
    <xsl:param name="prev"/>
    <xsl:param name="debug" select="false()" />

    <xsl:variable name="prev.book"    select="$prev/ancestor-or-self::d:book"/>
    <xsl:variable name="prev.article" select="$prev/ancestor-or-self::d:article" />

    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:if test="boolean($debug)">
      <xsl:message>is.prev.node.in.navig:
        Element:  <xsl:value-of select="local-name(.)"/>
        prev:     <xsl:value-of select="local-name($prev)"/>
        rootid:   <xsl:value-of select="$rootid"/>
        prev.book:    <xsl:value-of select="$prev.book/d:title"/>
        prev.article: <xsl:value-of select="$prev.article/d:title"/>
      </xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="generate-id($rootid.node) = generate-id($prev.article)"
        >1</xsl:when>
      <xsl:when test="generate-id($rootid.node) = generate-id($prev.book)"
        >1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="is.node.in.navig">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="debug"/>

    <!-- The next.book, prev.book, and this.book variables contains the
       ancestor or self nodes for book or article, but only one node.
     -->
    <xsl:variable name="next.book"
      select="($next/ancestor-or-self::d:book |
      $next/ancestor-or-self::d:article)[last()]"/>
    <xsl:variable name="prev.book"
      select="($prev/ancestor-or-self::d:book |
      $prev/ancestor-or-self::d:article)[last()]"/>
    <xsl:variable name="this.book"
      select="(ancestor-or-self::d:book|ancestor-or-self::d:article)[last()]"/>
    <!-- Compare the current "book" ID (be it really a book or an article)
       with the "next" or "previous" book or article ID
     -->
    <xsl:variable name="isnext">
      <!-- select="generate-id($this.book) = generate-id($next.book)" -->
      <xsl:call-template name="is.next.node.in.navig">
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isprev">
      <!-- select="generate-id($this.book) = generate-id($prev.book)" -->
      <xsl:call-template name="is.prev.node.in.navig">
        <xsl:with-param name="prev" select="$prev"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    <xsl:if test="$debug">
      <xsl:message>
        Element:  <xsl:value-of select="local-name(.)"/>
        prev:     <xsl:value-of select="local-name($prev)"/>
        next:     <xsl:value-of select="local-name($next)"/>
        rootid:   <xsl:value-of select="$rootid"/>
        isnext:   <xsl:value-of select="$isnext"/>
        isprev:   <xsl:value-of select="$isprev"/>
      </xsl:message>
    </xsl:if>
    <!-- Return our result: -->
    <xsl:value-of select="((count($prev) &gt; 0 and $isprev) or
                           (count($next) &gt; 0 and $isnext)) and
                          $navig.showtitles != 0"/>
  </xsl:template>

  <!-- ===================================================== -->
  <xsl:template name="is.xref.within.rootid">
    <xsl:param name="target" select="NOT_A_NODE"/>
    <xsl:variable name="context" select="."/>
    <xsl:variable name="this.ancestor" select="(ancestor-or-self::*[@xml:id=$rootid] | /*)[last()]"/>
    <xsl:variable name="target.in.ancestor" select="$this.ancestor//*[@xml:id=$context/@linkend]"/>
    <!-- Alternative, but not similar way:
         $target/ancestor-or-self::*[@xml:id=$rootid] = $this.ancestor
    -->
    <xsl:value-of select="count($target.in.ancestor)"/>
  </xsl:template>

  <xsl:template name="is.node.within.rootid">
    <xsl:param name="node" select="NOT_A_NODE" />
<!--    <xsl:param name="this" select="." />-->
    <xsl:param name="debug" select="true()" />
    <xsl:param name="this.rootid" select="$rootid" />
    <!--  -->
    <!--<xsl:variable name="this.ancestor"
      select="($this/ancestor-or-self::d:article | $this/ancestor-or-self::d:book)[last()]"/>-->
    <xsl:variable name="other.ancestor"
      select="($node/ancestor-or-self::d:article | $node/ancestor-or-self::d:book)[last()]"/>
    <xsl:variable name="rootid.node" select="key('id', $this.rootid)"/>
    <!--  -->
    <xsl:variable name="result">
      <xsl:choose>
      <xsl:when test="$this.rootid = ''">
        <!-- If no $rootid is set, we don't need to handle prev/next differently.
             All nodes are equally good.
        -->
        <xsl:value-of select="1"/>
      </xsl:when>
      <!--<xsl:when test="count($rootid.node | $other.ancestor) = 1">
        <xsl:value-of select="true()"/>
      </xsl:when>-->
      <xsl:when test="local-name($rootid.node) = 'article' and local-name($other.ancestor) = 'article'">
        <xsl:value-of select="count($rootid.node | $other.ancestor) -1"/><!--  -->
      </xsl:when>
      <xsl:otherwise>
        <!--
          As long as we have more than one node, we have two distinct nodes,
          pointing to different elements.
        -->
        <xsl:value-of select="count($rootid.node | $other.ancestor) -1"/> <!--  &lt;= 1 -->
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>

    <xsl:if test="boolean($debug)">
      <xsl:message>is.node.within.rootid:
      this.rootid:    <xsl:value-of select="$this.rootid"/>
      rootid.node:    <xsl:value-of select="concat(name($rootid.node), '/', $rootid.node/@xml:id )"/>
      <!--this.ancestor:  <xsl:value-of select="$this.ancestor/@xml:id"/>-->
      other.ancestor: <xsl:value-of select="concat(name($other.ancestor), '/', $other.ancestor/@xml:id)"/>
      union:          <xsl:value-of select="count($rootid.node | $other.ancestor)"/>
      => result:      <xsl:value-of select="$result"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="$result"/>
  </xsl:template>

</xsl:stylesheet>

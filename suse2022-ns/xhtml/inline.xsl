<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Process inline elements

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle


-->

<!DOCTYPE xsl:stylesheet [
  <!ENTITY ascii.uc "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
  <!ENTITY ascii.lc "abcdefghijklmnopqrstuvwxy">
  <!ENTITY ru.uc "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ">
  <!ENTITY ru.lc "абвгдежзийклмнопрстуфхцчшщъыьэюя">
  <!ENTITY lat1.uc "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ">
  <!ENTITY lat1.lc "àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ">
  <!ENTITY lat-ext-a.uc "ĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĸĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŸŹŻŽŒ">
  <!ENTITY lat-ext-a.lc "āăąćĉċčďđēĕėęěĝğġģĥħĩīĭįıĳĵķĸĺļľŀłńņňŋōŏőœŕŗřśŝşšţťŧũūŭůűųŵŷÿźżžœ">

  <!ENTITY uppercase "'&ascii.uc;&lat1.uc;&lat-ext-a.uc;&ru.uc;'">
  <!ENTITY lowercase "'&ascii.lc;&lat1.lc;&lat-ext-a.lc;&ru.lc;'">
]>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:la="urn:x-suse:xslt:layout"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d la">


  <xsl:template name="inline.sansseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <span class="{local-name(.)}">
      <xsl:call-template name="generate.html.title"/>
      <xsl:if test="@dir">
        <xsl:attribute name="dir">
          <xsl:value-of select="@dir"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
      <xsl:call-template name="apply-annotations"/>
    </span>
  </xsl:template>

  <xsl:template match="d:prompt" mode="common.html.attributes">
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="@role">prompt <xsl:value-of select="@role"/></xsl:when>
        <xsl:otherwise>prompt user</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:apply-templates select="." mode="class.attribute">
      <xsl:with-param name="class" select="$class"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="d:email">
    <xsl:if test="not($email.delimiters.enabled = 0)">
      <xsl:text>&lt;</xsl:text>
    </xsl:if>
    <a>
      <xsl:apply-templates select="." mode="common.html.attributes"/>
      <xsl:call-template name="id.attribute"/>
      <xsl:attribute name="href">
        <xsl:text>mailto:</xsl:text>
        <xsl:value-of select="."/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
    <xsl:if test="not($email.delimiters.enabled = 0)">
      <xsl:text>&gt;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:keycap">
    <!-- See also Ticket#84 -->
    <xsl:choose>
      <xsl:when test="@function">
        <xsl:call-template name="inline.sansseq">
          <xsl:with-param name="content">
            <xsl:call-template name="gentext.template">
              <xsl:with-param name="context" select="'keycap'"/>
              <xsl:with-param name="name" select="@function"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inline.sansseq"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:keycombo">
    <xsl:variable name="action" select="@action"/>
    <xsl:for-each select="*">
      <xsl:if test="position()&gt;1">
        <span class="key-connector">–</span>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="d:function/d:parameter" priority="2">
    <xsl:call-template name="inline.italicseq"/>
    <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:parameter">
    <xsl:call-template name="inline.italicseq"/>
  </xsl:template>

  <xsl:template match="d:function/d:replaceable" priority="2">
    <xsl:call-template name="inline.italicseq"/>
    <xsl:if test="following-sibling::*">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:replaceable" priority="1">
    <xsl:call-template name="inline.italicseq"/>
  </xsl:template>

  <xsl:template match="d:command">
    <xsl:call-template name="inline.monoseq"/>
  </xsl:template>

  <xsl:template match="d:phrase[contains(@role, 'color:')]">
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
          <xsl:call-template name="get-suse-color">
            <xsl:with-param name="value" select="substring-after(@role, 'color:')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <span>
      <xsl:if test="$text-color != ''">
        <xsl:attribute name="style">
          <xsl:value-of select="concat('color:', $text-color, ';')" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

 <xsl:template match="d:phrase[contains(@role, 'style:')]" name="phrase-style">
   <xsl:variable name="stylecandidate" select="substring-after(@role, 'style:')"/>
   <xsl:variable name="style" select="$stylecandidate"/>

   <xsl:choose>
     <xsl:when test="$style = 'uppercase'">
       <xsl:value-of select="translate(text(), &lowercase;, &uppercase;)"/>
       <xsl:apply-templates select="*"/>
     </xsl:when>
     <xsl:when test="$style = 'lowercase'">
       <xsl:value-of select="translate(text(), &uppercase;, &lowercase;)"/>
       <xsl:apply-templates select="*"/>
     </xsl:when>
     <!-- Just capitalize the first character; leave anything else unmodified -->
     <xsl:when test="$style = 'sentencecase'">
       <xsl:variable name="firstchar" select="substring(translate(text()[1], '&#10; ', ''), 1, 1)"/>
       <xsl:variable name="rest" select="substring-after(text(), $firstchar)"/>

       <xsl:choose>
         <!-- Only text, no other elements -->
         <xsl:when test="$firstchar != '' and count(*)=0">
<!--           <xsl:message>### phrase Case 1: "<xsl:value-of select="$firstchar"/>"</xsl:message>-->
           <xsl:value-of select="concat(translate($firstchar, &lowercase;, &uppercase;), $rest)"/>
         </xsl:when>

         <!-- No text before first child element -->
         <xsl:when test="$firstchar = '' and count(*)>0">
<!--           <xsl:message>### phrase Case 2</xsl:message>-->
           <xsl:apply-templates select="*[1]" mode="phrase-sentencecase"/>
         </xsl:when>

         <!-- Text with child element(s) -->
         <xsl:when test="$firstchar != '' and count(*)>0">
<!--           <xsl:message>### phrase Case 3: "<xsl:value-of select="concat($firstchar, $rest)"/>"</xsl:message>-->
           <xsl:value-of select="concat(translate($firstchar, &lowercase;, &uppercase;), $rest)"/>
           <xsl:apply-templates/>
         </xsl:when>

         <xsl:otherwise></xsl:otherwise>
       </xsl:choose>
     </xsl:when>
     <!--<xsl:when test="$style = 'titlecase'">
       <xsl:apply-templates select="*"/>
     </xsl:when>-->
     <xsl:otherwise>
       <!-- We don't have any match, so just don't change anything -->
       <xsl:apply-templates/>
     </xsl:otherwise>
   </xsl:choose>
 </xsl:template>


  <xsl:template match="d:*" mode="phrase-sentencecase">
    <xsl:apply-templates select="."/>
  </xsl:template>


  <xsl:template match="d:phrase" mode="phrase-sentencecase">
    <xsl:variable name="node">
      <xsl:apply-templates select="."/>
      <xsl:apply-templates select="parent::*/*[position() >1]"/>
    </xsl:variable>
    <xsl:variable name="rtf" select="exsl:node-set($node)"/>
    <xsl:variable name="firstchar" select="substring(translate(text(), '&#10; ', ''), 1, 1)"/>
    <xsl:variable name="rest" select="substring-after(text(), $firstchar)"/>

<!--    <xsl:message> * * * <xsl:value-of select="concat(local-name(.), ': ', count($rtf))"/>: "<xsl:value-of select="concat(translate($firstchar, &lowercase;, &uppercase;), $rest)"/>"</xsl:message>-->

    <xsl:choose>
      <xsl:when test="$firstchar != '' and count(*)=0">
        <xsl:value-of select="concat(translate($firstchar, &lowercase;, &uppercase;), $rest)"/>
      </xsl:when>

      <xsl:when test="$firstchar = '' and count(*)>0">
        <xsl:apply-templates select="*[1]" mode="phrase-sentencecase"/>
      </xsl:when>

      <xsl:when test="$firstchar != '' and count(*)>0">
        <xsl:value-of select="concat(translate($firstchar, &lowercase;, &uppercase;), $rest)"/>
        <xsl:apply-templates/>
      </xsl:when>
    </xsl:choose>

  </xsl:template>


  <xsl:template match="d:productname">
    <xsl:call-template name="inline.charseq"/>
    <!-- We don't want to process @class attribute here -->
  </xsl:template>


  <!-- Support for AsciiDoc's [%hardbreaks] option -->
  <xsl:template match="processing-instruction('asciidoc-br')">
    <br/>
  </xsl:template>

</xsl:stylesheet>

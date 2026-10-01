<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Returns the number only of an element, if it has one. Normally, this
    is done by the original stylesheets, however, some has to be
    explicitly added.

  Author(s):    Thomas Schraitle <toms@opensuse.org>

  Copyright:    2013, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl">

  <xsl:template match="refsect1/title|refnamediv" mode="label.markup"/>

  <xsl:template match="task" mode="label.markup">
   <xsl:variable name="pchap"
                 select="ancestor::chapter
                         |ancestor::appendix
                         |ancestor::article[ancestor::book]"/>
   <xsl:variable name="prefix">
     <xsl:if test="count($pchap) &gt; 0">
       <xsl:apply-templates select="$pchap" mode="label.markup"/>
     </xsl:if>
   </xsl:variable>
   <xsl:choose>
    <xsl:when test="@label"><xsl:value-of select="@label"/></xsl:when>
    <xsl:otherwise>
     <xsl:choose>
      <xsl:when test="count($pchap)>0">
       <xsl:if test="$prefix != ''">
             <xsl:apply-templates select="$pchap" mode="label.markup"/>
             <xsl:apply-templates select="$pchap" mode="intralabel.punctuation">
               <xsl:with-param name="object" select="."/>
             </xsl:apply-templates>
           </xsl:if>
           <xsl:number count="task[title|blockinfo/title|info/title]" format="1" 
                       from="chapter|appendix" level="any"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:number count="task[title|blockinfo/title|info/title]" format="1" 
                   from="book|article" level="any"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
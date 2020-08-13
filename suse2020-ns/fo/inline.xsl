<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Adapt inline monospaced font, so its x-height is about as tall as that of
    the serif font (Charis SIL), we use for the body text.

    You might notice the pattern of using fo:leaders for distancing inline
    elements from each other instead of simply using paddings/margins: that is
    because FOP (at least v1.1) seems to apply margins and paddings only after
    laying out the text. Therefore, any element that a margin is applied to may
    be pushed behind the text. We do not approve.

  Author(s):  Stefan Knorr <sknorr@suse.de>,
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
  <!--<!ENTITY % common.entities SYSTEM "http://docbook.sourceforge.net/release/xsl-ns/current/common/entities.ent">-->
  <!--%common.entities;-->
  <!-- Needed to define it here as the parent::variablelist is missing :-( -->

  <!ENTITY comment.block.parents "parent::d:answer|parent::d:appendix|parent::d:article|parent::d:bibliodiv|
                                parent::d:bibliography|parent::d:blockquote|parent::d:caution|parent::d:chapter|
                                parent::d:glossary|parent::d:glossdiv|parent::d:important|parent::d:index|
                                parent::d:indexdiv|parent::d:listitem|parent::d:note|parent::d:orderedlist|
                                parent::d:variablelist|
                                parent::d:partintro|parent::d:preface|parent::d:procedure|parent::d:qandadiv|
                                parent::d:qandaset|parent::d:question|parent::d:refentry|parent::d:refnamediv|
                                parent::d:refsect1|parent::d:refsect2|parent::d:refsect3|parent::d:refsection|
                                parent::d:refsynopsisdiv|parent::d:sect1|parent::d:sect2|parent::d:sect3|parent::d:sect4|
                                parent::d:sect5|parent::d:section|parent::d:setindex|parent::d:sidebar|
                                parent::d:simplesect|parent::d:taskprerequisites|parent::d:taskrelated|
                                parent::d:tasksummary|parent::d:warning|parent::d:topic">
]>
<xsl:stylesheet exclude-result-prefixes="d"
                 version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg">


<xsl:template name="inline.text">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates mode="mono-ancestor"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:param name="before" select="''"/>
  <xsl:param name="after" select="''"/>
  <xsl:variable name="mono-verbatim-ancestor">
    <xsl:if test="$mode = 'mono-ancestor' or ancestor::d:screen or
                  ancestor::d:programlisting or ancestor::d:synopsis">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="lighter-formatting">
    <xsl:if test="$mono-verbatim-ancestor = 1 or
                  ancestor::d:title[not(parent::d:formalpara)]">1</xsl:if>
  </xsl:variable>

  <fo:inline>
   <xsl:if test="$lighter-formatting != 1">
    <xsl:attribute name="border-bottom">&thinline;mm solid &mid-gray;</xsl:attribute>
    <xsl:attribute name="padding-bottom">0.1em</xsl:attribute>
   </xsl:if>
   <xsl:choose>
    <xsl:when test="$mono-verbatim-ancestor = 1"/> <!-- do nothing -->
    <xsl:when test="not(ancestor::d:title[not(parent::d:formalpara)] or
     ancestor::d:term)">
     <xsl:attribute name="font-size"><xsl:value-of select="$mono-xheight-adjust"/>em</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
     <xsl:attribute name="font-size"><xsl:value-of select="$mono-xheight-adjust div $sans-xheight-adjust"/>em</xsl:attribute>
    </xsl:otherwise>
   </xsl:choose>

   <xsl:if test="$lighter-formatting != 1">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
   </xsl:if>
   <xsl:call-template name="anchor"/>
   <xsl:if test="@dir">
    <xsl:attribute name="direction">
     <xsl:choose>
      <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
      <xsl:otherwise>rtl</xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>
   </xsl:if>
   <xsl:if test="$before != ''">
    <xsl:value-of select="$before"/>
   </xsl:if>
   <xsl:copy-of select="$content"/>
   <xsl:if test="$after != ''">
    <xsl:value-of select="$after"/>
   </xsl:if>
   <xsl:if test="$lighter-formatting != 1">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
   </xsl:if>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.monoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates mode="mono-ancestor"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:param name="before" select="''"/>
  <xsl:param name="after" select="''"/>
  <xsl:variable name="mono-verbatim-ancestor">
    <xsl:if test="$mode = 'mono-ancestor' or ancestor::d:screen or
                  ancestor::d:programlisting or ancestor::d:synopsis">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="lighter-formatting">
    <xsl:if test="$mono-verbatim-ancestor = 1 or
                  ancestor::d:title[not(parent::d:formalpara)]">1</xsl:if>
  </xsl:variable>

  <fo:inline xsl:use-attribute-sets="monospace.properties" font-weight="normal"
    font-style="normal">
    <xsl:call-template name="inline.text">
     <xsl:with-param name="mode" select="$mode"/>
     <xsl:with-param name="after" select="$after"/>
     <xsl:with-param name="before" select="$before"/>
     <xsl:with-param name="content" select="$content"/>
     <xsl:with-param name="purpose" select="$purpose"/>
    </xsl:call-template>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.boldmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates mode="mono-ancestor"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:param name="before" select="''"/>
  <xsl:param name="after" select="''"/>
   <xsl:param name="textcolor" select="'inherit'"/>
  <xsl:variable name="mono-verbatim-ancestor">
    <xsl:if test="$mode = 'mono-ancestor' or ancestor::d:screen or
                  ancestor::d:programlisting or ancestor::d:synopsis">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="lighter-formatting">
    <xsl:if test="$mono-verbatim-ancestor = 1 or
                  ancestor::d:title[not(parent::d:formalpara)]">1</xsl:if>
  </xsl:variable>

  <fo:inline xsl:use-attribute-sets="monospace.properties mono.bold"
    font-style="normal" color="{$textcolor}">
    <xsl:call-template name="inline.text">
     <xsl:with-param name="mode" select="$mode"/>
     <xsl:with-param name="after" select="$after"/>
     <xsl:with-param name="before" select="$before"/>
     <xsl:with-param name="content" select="$content"/>
     <xsl:with-param name="purpose" select="$purpose"/>
    </xsl:call-template>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates mode="mono-ancestor"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:param name="before" select="''"/>
  <xsl:param name="after" select="''"/>
  <xsl:variable name="mono-verbatim-ancestor">
    <xsl:if test="$mode = 'mono-ancestor' or ancestor::d:screen or
                  ancestor::d:programlisting or ancestor::d:synopsis">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="lighter-formatting">
    <xsl:if test="$mono-verbatim-ancestor = 1 or
                  ancestor::d:title[not(parent::d:formalpara)]">1</xsl:if>
  </xsl:variable>

  <fo:inline xsl:use-attribute-sets="monospace.properties italicized"
    font-weight="normal">
   <xsl:call-template name="inline.text">
    <xsl:with-param name="mode" select="$mode"/>
    <xsl:with-param name="after" select="$after"/>
    <xsl:with-param name="before" select="$before"/>
    <xsl:with-param name="content" select="$content"/>
    <xsl:with-param name="purpose" select="$purpose"/>
   </xsl:call-template>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline xsl:use-attribute-sets="serif.bold">
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:param name="purpose" select="'none'"/>

  <fo:inline xsl:use-attribute-sets="italicized">
    <xsl:choose>
      <xsl:when test="(ancestor::d:title/parent::d:set or
                       ancestor::d:title/parent::d:setinfo/parent::d:set or
                       ancestor::d:title/parent::d:info/parent::d:set or
                       ancestor::d:title/parent::d:book or
                       ancestor::d:title/parent::d:bookinfo/parent::d:book or
                       ancestor::d:title/parent::d:info/parent::d:book or
                       ancestor::d:title/parent::d:article or
                       ancestor::d:title/parent::d:articleinfo/parent::d:article or
                       ancestor::d:title/parent::d:info/parent::d:article) and
                      not($purpose='xref')">
        <xsl:attribute name="font-style">normal</xsl:attribute>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<!-- No mode -->
<xsl:template match="d:command|d:userinput">
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:param name="commandcolor" >
   <xsl:choose>
    <xsl:when test="self::d:command and ancestor::d:screen">
     <xsl:value-of select="$dark-green"/>
    </xsl:when>
    <xsl:otherwise>inherit</xsl:otherwise>
   </xsl:choose>
  </xsl:param>

  <xsl:call-template name="inline.boldmonoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="$mode"/>
    <xsl:with-param name="textcolor" select="$commandcolor"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:classname|d:exceptionname|d:interfacename|d:methodname
                    |d:computeroutput|d:constant|d:envar|d:filename|d:function|d:literal
                    |d:code|d:option|d:parameter|d:prompt|d:systemitem|d:varname|d:email|d:uri
                    |d:cmdsynopsis/d:command|d:package">
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>

  <xsl:call-template name="inline.monoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="$mode"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:sgmltag|d:tag" name="sgmltag">
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>
  <xsl:variable name="class">
    <xsl:if test="@class">
      <xsl:value-of select="@class"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="before">
    <xsl:choose>
      <xsl:when test="$class='endtag'">&lt;/</xsl:when>
      <xsl:when test="$class='genentity'">&amp;</xsl:when>
      <xsl:when test="$class='numcharref'">&amp;#</xsl:when>
      <xsl:when test="$class='paramentity'">%</xsl:when>
      <xsl:when test="$class='pi' or $class='xmlpi'">&lt;?</xsl:when>
      <xsl:when test="$class='starttag' or $class='emptytag'">&lt;</xsl:when>
      <xsl:when test="$class='sgmlcomment' or $class='comment'">&lt;!--</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="after">
    <xsl:choose>
      <xsl:when test="$class='endtag' or $class='starttag' or
                      $class='pi'">&gt;</xsl:when>
      <xsl:when test="$class='genentity' or $class='numcharref' or
                      $class='paramentity'">;</xsl:when>
      <xsl:when test="$class='xmlpi'">?&gt;</xsl:when>
      <xsl:when test="$class='emptytag'">/&gt;</xsl:when>
      <xsl:when test="$class='sgmlcomment' or $class='comment'">--&gt;</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="inline.monoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="$mode"/>
    <xsl:with-param name="before" select="$before"/>
    <xsl:with-param name="after" select="$after"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:replaceable|d:structfield">
  <xsl:param name="purpose" select="'none'"/>
  <xsl:param name="mode" select="'normal'"/>

  <xsl:call-template name="inline.italicmonoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="$mode"/>
  </xsl:call-template>
</xsl:template>


<!-- Mode: mono-ancestor -->
<xsl:template match="d:command|d:userinput" mode="mono-ancestor">
 <xsl:param name="purpose" select="'none'"/>
   <xsl:param name="commandcolor" >
   <xsl:choose>
    <xsl:when test="self::d:command and parent::d:screen">
     <xsl:value-of select="$dark-green"/>
    </xsl:when>
    <xsl:otherwise>inherit</xsl:otherwise>
   </xsl:choose>
  </xsl:param>
  <xsl:call-template name="inline.boldmonoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="'mono-ancestor'"/>
     <xsl:with-param name="textcolor" select="$commandcolor"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:classname|d:exceptionname|d:interfacename|d:methodname
                    |d:computeroutput|d:constant|d:envar|d:filename|d:function|d:literal
                    |d:code|d:option|d:parameter|d:prompt|d:systemitem|d:varname|d:email|d:uri
                    |d:cmdsynopsis/d:command|d:package"
  mode="mono-ancestor">
  <xsl:param name="purpose" select="'none'"/>

  <xsl:call-template name="inline.monoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="'mono-ancestor'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:sgmltag|d:tag" mode="mono-ancestor">
  <xsl:param name="purpose" select="'none'"/>

  <xsl:call-template name="sgmltag">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="'mono-ancestor'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:replaceable|d:structfield"
  mode="mono-ancestor">
  <xsl:param name="purpose" select="'none'"/>

  <xsl:call-template name="inline.italicmonoseq">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="mode" select="'mono-ancestor'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:emphasis" mode="mono-ancestor">
 <xsl:choose>
  <xsl:when test="@role='bold' or @role='strong'">
   <xsl:call-template name="inline.boldmonoseq">
    <xsl:with-param name="mode" select="'mono-ancestor'"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="inline.italicmonoseq">
   <xsl:with-param name="mode" select="'mono-ancestor'"/>
  </xsl:call-template>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="d:keycap">
  <xsl:variable name="cap">
    <xsl:choose>
      <xsl:when test="@function and normalize-space(.) = ''">
        <xsl:call-template name="gentext.template">
          <xsl:with-param name="context" select="'msgset'"/>
            <!-- This context is called "keycap" instead in the upcoming
                 upstream release – TODO: use "keycap" when we've switched to
                 1.77.2. -->
          <xsl:with-param name="name" select="@function"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="instream-font-size" select="70"/>
  <xsl:variable name="font-metrics-ratio" select="&mono-ratio;"/>
    <!-- Only use a monospaced font for the keycaps, else this metrics-ratio
         won't work out all that well – it is used both for determining the
         width of the key image being shown as well as centering the text on the
         image. -->
  <xsl:variable name="width">
    <xsl:value-of select="string-length(normalize-space($cap))*$instream-font-size*$font-metrics-ratio"/>
  </xsl:variable>

  <xsl:if test="not(parent::d:keycombo)">
    <xsl:if test="(preceding-sibling::*|preceding-sibling::text()) and
                  not(preceding-sibling::d:remark)">
      <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
  </xsl:if>

  <fo:instream-foreign-object content-height="1em" alignment-baseline="alphabetic"
    alignment-adjust="-0.2em">
    <svg:svg xmlns:svg="http://www.w3.org/2000/svg" height="100"
      width="{$width + 60}">
      <svg:defs>
        <svg:linearGradient id="svg-gr-recessed" x1="0.05" y1="0.05" x2=".95" y2=".95">
          <svg:stop stop-color="&light-gray;" stop-opacity="1" offset="0" />
          <svg:stop stop-color="&light-gray;" stop-opacity="1" offset="0.4" />
          <svg:stop stop-color="&mid-gray;" stop-opacity="1" offset="0.6" />
          <svg:stop stop-color="&mid-gray;" stop-opacity="1" offset="1" />
        </svg:linearGradient>
      </svg:defs>
      <svg:g>
        <xsl:if test="$writing.mode = 'rl'">
          <xsl:attribute name="transform">matrix(-1,0,0,1,<xsl:value-of select="$width + 60"/>,0)</xsl:attribute>
        </xsl:if>
        <svg:rect height="100" width="{$width + 60}" rx="10" ry="10" x="0" y="0"
          fill="url(#svg-gr-recessed)" fill-opacity="1" stroke="none"/>
      </svg:g>
      <svg:rect height="85" width="{$width + 45}" rx="7.5" ry="7.5" x="5" y="5"
        fill="&light-gray-old;" fill-opacity="1" stroke="none"/>
      <svg:text font-family="{$mono-stack}" text-anchor="middle"
        x="{($width div 2) + 25}" y="{$instream-font-size}" fill="&dark-gray;"
        font-size="{$instream-font-size}"><xsl:value-of select="$cap"/></svg:text>
    </svg:svg>
  </fo:instream-foreign-object>

  <xsl:if test="not(parent::d:keycombo)">
    <xsl:if test="(following-sibling::*|following-sibling::text()) and
                  not(following-sibling::d:remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
    </xsl:if>
  </xsl:if>

</xsl:template>

<xsl:template match="d:keycombo">
  <xsl:variable name="joinchar">–</xsl:variable>

  <xsl:if test="(preceding-sibling::*|preceding-sibling::text()) and
                not(preceding-sibling::d:remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
  </xsl:if>

  <xsl:for-each select="*">
    <xsl:if test="position()>1">
      <fo:inline space-start="-0.05em" space-end="0" color="#666">
        <xsl:value-of select="$joinchar"/>
      </fo:inline>
    </xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:for-each>

  <xsl:if test="(following-sibling::*|following-sibling::text()) and
                not(following-sibling::d:remark)">
    <fo:leader leader-pattern="space" leader-length="0.2em"/>
  </xsl:if>
</xsl:template>

<xsl:template match="d:guibutton|d:guiicon|d:guilabel|d:hardware|d:interface|
         d:interfacedefinition|d:keysym|d:keycode|d:mousebutton|d:property|d:returnvalue|
         d:structname|d:symbol|d:token|d:type">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="d:guimenu|d:guisubmenu">
  <xsl:call-template name="gentext.guimenu.startquote"/>
  <xsl:call-template name="inline.italicseq"/>
  <xsl:call-template name="gentext.guimenu.endquote"/>
</xsl:template>

<xsl:template match="d:package">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:prompt">
  <xsl:variable name="color">
    <xsl:choose>
      <xsl:when test="@role = 'rootprompt' and format.print = 0">&dark-blood;</xsl:when>
      <xsl:otherwise>&mid-gray;</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:inline color="{$color}">
    <xsl:call-template name="inline.monoseq"/>
  </fo:inline>
</xsl:template>

<!-- Avoid formatting overload (e.g. no need for green text that is also
     italic). This also avoids the ugly look that occurs when italics
     are replaced with gray text in CJK languages. -->
<xsl:template match="d:xref/d:citetitle">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="process.menuchoice">
  <xsl:param name="nodelist" select="d:guibutton|d:guiicon|d:guilabel|d:guimenu|d:guimenuitem|d:guisubmenu|d:interface"/><!-- not(shortcut) -->
  <xsl:param name="count" select="1"/>
  <xsl:param name="color">
    <xsl:choose>
      <!-- FIXME: This has the side effect of looking wrong in TOCs. suse-xsl#297 -->
      <xsl:when test="ancestor::d:title"><xsl:value-of select="$dark-green"/></xsl:when>
      <xsl:otherwise>&black;</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="height">
    <xsl:choose>
      <xsl:when test="ancestor::d:title or ancestor::d:term">0.55</xsl:when>
      <xsl:otherwise>0.47</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="$count>count($nodelist)"></xsl:when>
    <xsl:when test="$count=1">
      <xsl:apply-templates select="$nodelist[$count=position()]"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node" select="$nodelist[$count=position()]"/>
      <fo:leader leader-pattern="space" leader-length="0.3em"/>
      <fo:instream-foreign-object content-height="{$height}em">
        <svg:svg width="7" height="11">
          <svg:g>
            <xsl:if test="$writing.mode = 'rl'">
              <xsl:attribute name="transform">matrix(-1,0,0,1,7,0)</xsl:attribute>
            </xsl:if>
            <svg:path d="M 1.438,0 0,1.406 4.156,5.5 0,9.594 1.438,11 7,5.5 1.4375,0 z"
              fill="{$color}"/>
          </svg:g>
        </svg:svg>
      </fo:instream-foreign-object>
      <fo:leader leader-pattern="space" leader-length="0.3em"/>
      <xsl:apply-templates select="$node"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


  <!--
     Needed to fix a bug in the common/entities.ent for the
     DocBook stylesheets.
     Missing parent::variablelist in comment.block.parents
  -->
  <!-- Also needed for colorful remarks now... -->
  <xsl:template match="d:remark">
    <xsl:param name="wrapper">
      <xsl:choose>
        <xsl:when test="&comment.block.parents;">block</xsl:when>
        <xsl:otherwise>inline</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="$show.comments != 0">
    <xsl:element name="fo:{$wrapper}" use-attribute-sets="italicized.noreplacement">
      <xsl:choose>
        <xsl:when test="$format.print != 1">
          <xsl:attribute name="background-color">&tango-plum;</xsl:attribute>
          <xsl:attribute name="color">&white;</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="color">&mid-gray;</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="inline.charseq"/>
    </xsl:element>
  </xsl:if>
  </xsl:template>

</xsl:stylesheet>

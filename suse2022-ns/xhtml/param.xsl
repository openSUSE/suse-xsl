<?xml version="1.0"?>
<!--
  Purpose:
     Contains all parameters for (X)HTML
     (Sorted against the list in "Part 1. HTML Parameter Reference" in
      the DocBook XSL Stylesheets User Reference, see link below)

   See Also:
     * http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Author(s):     Thomas Schraitle <toms@opensuse.org>,
                  Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, 2013, Thomas Schraitle, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:saxon="http://icl.com/saxon"
  extension-element-prefixes="saxon"
  exclude-result-prefixes="saxon d"
  xmlns="http://www.w3.org/1999/xhtml">

<!-- x. Parameters for External Manipulation =================== -->
  <!-- Add a link to a product/company homepage to the logo -->
  <xsl:param name="homepage" select="''"/>
    <!-- Override with:
             -stringparam="homepage=https://www.example.com"
    -->

  <!-- Add a link back (up) to an external overview page. -->
  <xsl:param name="overview-page" select="''"/>
  <xsl:param name="overview-page-title" select="''"/>
    <!-- Override with:
             -stringparam="overview-page=https://www.example.com"
             -stringparam="overview-page-title='Back to Overview'"
    -->

  <!-- Base URL for <link rel=canonical> tags. No tags included if unset. -->
  <xsl:param name="canonical-url-base" select="''"/>
    <!-- Override with:
            -stringparam="canonical-url-base=https://www.example.com"
    -->

  <!-- Toggle the SUSE footer and SUSE e-mail button. Set to 0 if the
       documentation won't be available at a suse.com address.-->
  <xsl:param name="suse.content" select="1"/>
    <!-- Override with:
            -param="suse.content=0"
    -->

  <!-- Toggle inclusion of @font-face CSS. Set to 1 if you want to host
       the HTML on the internet or 0 if you are building for a locally
       installed package. -->
  <xsl:param name="build.for.web" select="1"/>
    <!-- Override with:
            -param="build.for.web=0"
    -->

  <!-- Whether to optimize for plain text output -->
  <xsl:param name="optimize.plain.text" select="0"/>
    <!-- Override with:
            -param="optimize.plain.text=1"
    -->

  <!-- Show "Edit Source" link always or only when draft mode is on.
       (dm:editurl needs to be defined in the document) -->
  <xsl:param name="show.edit.link" select="1"/>
    <!-- Override with:
            -param="show.edit.link=0"
    -->

  <!-- Include external JS, can take multiple space-separated paths. -->
  <xsl:param name="external.js" select="''"/>
    <!-- Override with:
            -stringparam="external.js='https://www.suse.com/path/to/file1.js /path/to/file2.js'"
    -->

  <!-- Include external JS, can take multiple space-separated paths, only loaded when page is not loaded from file: URL. -->
  <xsl:param name="external.js.onlineonly" select="''"/>
    <!-- Override with:
            -stringparam="external.js.onlineonly='https://www.suse.com/path/to/file1.js /path/to/file2.js'"
    -->

  <!-- FIXME suse22: Keep this disabled? Re-enable? -->
  <!-- Disable optional checks designed to give feedback to writers but which
  are not necessary for builds as such. This only makes sense for people who
  look at `daps -vv` output which no one seems to do. -->
  <xsl:param name="optimize.performance" select="1"/>

<!-- 0. DocBook XSL Parameter settings                              -->
<xsl:param name="html.ext">.html</xsl:param>

<!-- 1. Admonitions  ============================================ -->
  <!-- Use graphics in admonitions?  0=no, 1=yes -->
  <xsl:param name="admon.graphics" select="1"/>
  <!-- Path to admonition graphics -->
  <xsl:param name="admon.graphics.path">static/images/</xsl:param>
  <!-- Specifies the CSS style attribute that should be added to admonitions -->
  <xsl:param name="admon.style" select="''"/>


 <xsl:param name="chunker.output.method">
   <xsl:choose>
     <xsl:when test="contains(system-property('xsl:vendor'), 'SAXON')">saxon:xhtml</xsl:when>
     <xsl:otherwise>xml</xsl:otherwise>
   </xsl:choose>
 </xsl:param>

<!-- 2. Callouts ================================================ -->
<!-- These stylesheets don't allow using callout graphics/Unicode callouts. -->

<!-- 3. EBNF ==================================================== -->

<!-- 4. ToC/LoT/Index Generation ================================ -->
  <xsl:param name="toc.section.depth" select="1"/>
  <xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title
book      toc,title,figure,table,example,equation
chapter   toc,title
part      toc,title
preface   toc,title
qandaset  nop
reference toc,title
sect1     toc
sect2     toc
sect3     toc
sect4     toc
sect5     toc
section   toc
set       toc,title
</xsl:param>

<!-- 5. Stylesheet Extensions =================================== -->

<!-- 6. Automatic labeling ====================================== -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

<!-- 7. HTML ==================================================== -->
  <xsl:param name="css.decoration" select="0"/>
  <xsl:param name="docbook.css.link" select="0"/>

  <!-- To add e.g. brand specific additional stylesheets -->
  <xsl:param name="extra.css" select="''"/>
  <xsl:param name="docbook.css.source"/>
    <!-- Intentionally left empty – we already have a stylesheet, with this, we
         only override DocBook's default. -->

    <!-- The &#10;s introduce the necessary linebreak into this variable made up
         of variables... ugh. -->
  <xsl:param name="html.stylesheet">
<xsl:if test="$build.for.web != 1">static/css/fonts-onlylocal.css</xsl:if><xsl:text>&#10;</xsl:text>
<xsl:value-of select="$daps.header.css.standard"/><xsl:text>&#10;</xsl:text>
<xsl:value-of select="$extra.css"/>
</xsl:param>
  <xsl:param name="make.clean.html" select="1"/>
  <xsl:param name="make.valid.html" select="1"/>
  <xsl:param name="enable.source.highlighting" select="1"/>

  <xsl:param name="generate.id.attributes" select="1"/>

<!-- 8. XSLT Processing ========================================= -->
  <!-- Rule over footers? -->
  <xsl:param name="footer.rule" select="0"/>

<!-- 9. Meta/*Info and Titlepages =============================== -->
  <xsl:param name="generate.legalnotice.link" select="0"/>

<!-- 10. Reference Pages ======================================== -->

<!-- 11. Tables ================================================= -->

<!-- 12. QAndASet =============================================== -->
<xsl:param name="qanda.inherit.numeration" select="0"/>
<xsl:param name="qanda.defaultlabel">global</xsl:param>

<!-- 13. Linking ================================================ -->
<xsl:param name="ulink.target">_blank</xsl:param>
<xsl:param name="generate.consistent.ids" select="1"/>

<!-- 14. Cross References ======================================= -->

<!-- 15. Lists ================================================== -->

<!-- 16. Bibliography =========================================== -->

<!-- 17. Glossary =============================================== -->
<xsl:param name="glossary.sort" select="1"/>

<!-- 18. Miscellaneous ========================================== -->
  <xsl:param name="menuchoice.separator" select="'&#xa0;›&#xa0;'"/>
  <xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
task before
  </xsl:param>

  <xsl:param name="runinhead.default.title.end.punct">:</xsl:param>
  <!-- Also include:
    * Chinese colon U+FF1A (Fullwidth Colon)
  -->
  <xsl:param name="runinhead.title.end.punct">.!?:&#xff1a;</xsl:param>

  <!-- Should the content of programlisting|screen be syntactically highlighted? -->
  <xsl:param name="highlight.source" select="1" />


  <!-- From the DocBook XHTML stylesheet's "formal.xsl" -->
  <xsl:param name="formal.object.break.after">0</xsl:param>

<!-- 19. Annotations ============================================ -->

<!-- 20. Graphics =============================================== -->
  <xsl:param name="img.src.path">images/</xsl:param>
  <xsl:param name="make.graphic.viewport" select="0"/> <!-- Do not create tables around graphics. -->
  <xsl:param name="link.to.self.for.mediaobject" select="1"/> <!-- Create links to the image itself around images. -->


<!-- 21. Chunking =============================================== -->
  <!-- The base directory of chunks -->
  <xsl:param name="base.dir">./html/</xsl:param>

  <xsl:param name="chunk.fast" select="1"/>
  <!-- Depth to which sections should be chunked -->
  <xsl:param name="chunk.section.depth" select="0"/>
  <!-- Use ID value of chunk elements as the filename? -->
  <xsl:param name="use.id.as.filename" select="1"/>

  <!-- Use graphics in navigational headers and footers? -->
  <xsl:param name="navig.graphics" select="1"/>
  <!-- Path to navigational graphics -->
  <xsl:param name="navig.graphics.path">navig/</xsl:param>
  <!-- Extension for navigational graphics -->
  <xsl:param name="navig.graphics.extension" select="'.png'"/>
  <!-- Identifies the name of the root HTML file when chunking -->
  <xsl:param name="root.filename">index</xsl:param>


<!-- 27. Localization =========================================== -->
  <!-- Use customized language files -->
  <xsl:param name="local.l10n.xml" select="document('../common/l10n/l10n.xml')"/>

<!-- 28. SUSE specific parameters =============================== -->
  <xsl:param name="is.chunk" select="0"/>

  <xsl:param name="admon.graphics.prefix">icon-</xsl:param>
  <xsl:param name="admon.graphics.extension">.svg</xsl:param>

  <!-- Create an image tag for the logo? -->
  <xsl:param name="generate.logo">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="daps.header.logo">static/images/logo.svg</xsl:param>
  <xsl:param name="daps.header.logo.alt">Logo</xsl:param>
<!--   <xsl:param name="daps.header.js.library">static/js/jquery-1.12.4.min.js</xsl:param> -->
  <xsl:param name="daps.header.js.custom">static/js/script-purejs.js</xsl:param>
  <xsl:param name="daps.header.js.highlight">static/js/highlight.js</xsl:param>
  <xsl:param name="daps.header.css.standard">static/css/style.css</xsl:param>

  <!-- This list is intentionally quite strict (no aliases) to keep our documents
  consistent. -->
  <xsl:param name="highlight.supported.languages" select="'apache|bash|c++|css|diff|html|xml|http|ini|json|java|javascript|makefile|nginx|php|perl|python|ruby|sql|crmsh|dockerfile|lisp|yaml'"/>

  <xsl:param name="generate.header">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Create fixed header bar at the top?  -->
  <xsl:param name="generate.fixed.header">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="generate.toolbar">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="generate.bottom.navigation">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Create breadcrumbs navigation?  -->
  <xsl:param name="generate.breadcrumbs">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="breadcrumbs.prev">&#9664;<!--&#9668;--></xsl:param>
  <xsl:param name="breadcrumbs.next">&#9654;<!--&#9658;--></xsl:param>

  <!--  Side TOC options -->

  <!-- Create bubbletoc?  -->
  <xsl:param name="generate.side.toc">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="rootelementname">
    <xsl:choose>
      <xsl:when test="local-name(key('id', $rootid)) != ''">
        <xsl:value-of select="local-name(key('id', $rootid))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="local-name(/*)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="bubbletoc.section.depth">2</xsl:param>
  <xsl:param name="bubbletoc.max.depth">2</xsl:param>

  <xsl:param name="bubbletoc.max.depth.shallow">
    <xsl:choose>
      <xsl:when test="$rootelementname = 'article'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>


  <!-- Generate a footer with SUSE-specific content? -->
  <xsl:param name="generate.footer" select="$suse.content"/>

  <!-- Generate links in said footer? -->
  <xsl:param name="generate.footer.links">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Separator for chapter and book name in the XHTML output -->
  <xsl:param name="head.content.title.separator"> | </xsl:param>

  <!-- Create version information before title? -->
  <xsl:param name="generate.version.info" select="1"/>

  <!-- Add links to share page via social media and print via the sidebar. -->
  <xsl:param name="generate.share.and.print">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Should social media (Facebook, LinkedIn, Twitter) be generated? -->
  <xsl:param name="generate.socialmedia" select="0" />

  <!-- Allow generating "Give Feedback" section in sidebar. -->
  <xsl:param name="generate.give.feedback">0</xsl:param>
  <!-- Force generation of "Give Feedback" section, even if it may be empty in
  plain HTML -->
  <xsl:param name="force.generate.give.feedback" select="0"/>

  <xsl:param name="disable.language.switcher" select="0"/>

  <!-- Separator between breadcrumbs links: -->
  <xsl:param name="daps.breadcrumbs.sep">&#xa0;/&#xa0;</xsl:param>

  <!--  Create permalinks?-->
  <xsl:param name="generate.permalinks">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Should meta information be displayed below titles? yes=1|no=0 -->
  <xsl:param name="use.meta" select="0"/>

  <!-- Should the tracker meta information be processed? yes=1|no=0 -->
  <xsl:param name="use.tracker.meta">
    <xsl:choose>
      <xsl:when test="$optimize.plain.text = 1">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- Show arrows before and after a paragraph that applies only to a certain
       architecture? -->
  <xsl:param name="para.use.arch" select="1"/>

  <!-- Output a warning, if chapter/@xml:lang is different from book/@xml:lang ?
       0=no, 1=yes
  -->
<xsl:param name="warn.xrefs.into.diff.lang" select="1"/>

<xsl:param name="glossentry.show.acronym">yes</xsl:param>

  <!-- Wrap <img/> tags with a link (<a>), so you can click through to a big
       version of the image. -->
  <xsl:param name="wrap.img.with.a" select="1"/>

  <!-- Trim away empty lines from the beginning and end of screens -->
  <xsl:param name="trim.verbatim" select="1"/>

  <!-- The amount of characters allowed for descriptions on part pages.-->
  <xsl:param name="onpage.teaser.length" select="300"/>
  <!-- <meta> description tags used for search results pages, roughly as
  recommended by the Contentking -->
  <xsl:param name="search.title.length" select="55"/>
  <xsl:param name="search.description.length" select="150"/>
  <!-- Open Graph (og:)/Twitter Cards tags used for social-media preview -->
  <xsl:param name="socialmedia.title.length" select="55"/>
  <xsl:param name="socialmedia.description.length" select="60"/>
  <!-- Type of content to display in og:type tag, https://ogp.me/#types -->
  <xsl:param name="opengraph.type" select="'article'"/>
  <!-- How Twitter Cards should be displayed, as "summary" (uses smaller square
       image) or "summary_large_image" (uses full-width 2:1 image) -->
  <xsl:param name="twittercards.type" select="'summary'"/>
  <!-- Twitter account name to associate with the content via Twitter Card
       property twitter:site, e.g. '@SUSE'.
       There is no default here, someone might randomly use these
       stylesheets, having all result documents created with them associated
       with SUSE is suboptimal. -->
  <xsl:param name="twittercards.twitter.account" select="''"/>
  <!-- Default social media preview image, if no other image is available on the page
  static/images/social-media-preview-default.png
  -->
  <xsl:param name="socialmedia.preview.default">document.jpg</xsl:param>

  <!-- The path for the report bug link and edit source icons -->
  <xsl:param name="title.icons.path">static/images/</xsl:param>

  <!-- Should the report bug link and edit source icons be included? 0=no, 1=yes-->
  <xsl:param name="title.icons" select="1"/>


  <!-- Include HTML Dublin Core metadata? -->
  <xsl:param name="include.html.dublincore" select="1"/>

  <!-- Include header/footer via Server-Side Includes (SSI)? 0=no, 1=yes
  -->
  <xsl:param name="include.suse.header" select="0"/>

  <!-- When include.suse.header is set to 1, these are the paths for the SSIs
       to be added inside <head>, <body>, and <footer>.
       Use "{{#language#}}" to insert the language
  -->
  <xsl:param name="include.ssi.header">/docserv/fragments/suseparts/head_{{#language#}}.html</xsl:param>
  <xsl:param name="include.ssi.body">/docserv/fragments/suseparts/header_{{#language#}}.html</xsl:param>
  <xsl:param name="include.ssi.footer">/docserv/fragments/suseparts/footer_{{#language#}}.html</xsl:param>

  <!-- Should we generate a JSON-LD structure? 0=no, 1=yes -->
  <xsl:param name="generate.json-ld" select="1"/>
  <!-- Should we generate an external JSON-LD structure 0=no, 1=yes
       Only works when $generate.json-ld=1 was set
  -->
  <xsl:param name="generate.json-ld.external" select="0"/>
  <!-- Filename to the single stitch file that Docserv generates on startup -->
  <xsl:param name="stitchfile"/>
  <!-- The base.dir to store all external JSON files -->
  <xsl:param name="json-ld-base.dir" select="$base.dir"/>
  <!-- Should the individual authors be used? 0=no, 1=yes  -->
  <xsl:param name="json-ld-use-individual-authors" select="1"/>
  <!-- File extension -->
  <xsl:param name="json-ld.ext">.json</xsl:param>
  <!-- Timezone -->
  <xsl:param name="json-ld-date-timezone">T00:00+02:00</xsl:param>
  <xsl:param name="json-ld-fallback-author-name">SUSE Product &amp; Solution Documentation Team</xsl:param>
  <xsl:param name="json-ld-fallback-author-url">https://documentation.suse.com</xsl:param>
  <xsl:param name="json-ld-fallback-author-type">Corporation</xsl:param>
  <xsl:param name="json-ld-fallback-author-logo"
    >https://www.suse.com/assets/img/suse-white-logo-green.svg</xsl:param>
  <!-- The logo -->
  <xsl:param name="json-ld-image-url" select="$json-ld-fallback-author-logo" />
  <!-- By default, these are empty and are set by the SBP stylesheets -->
  <xsl:param name="json-ld-seriesname">Products &amp; Solutions</xsl:param>
  

  <!-- The DC file needs to be passed to find the structure in the Docserv config -->
  <xsl:param name="dcfilename"/>

  <xsl:variable name="placeholder.ssi.language">{{#language#}}</xsl:variable>

  <!-- The ID for the Qualtricks <div> -->
  <xsl:param name="generate.qualtrics.div" select="0"/>
  <xsl:param name="qualtrics.id">qualtrics_container</xsl:param>
  <xsl:param name="qualtrics.div.id">ZN_8qZUmklKYbBqAYe</xsl:param>
  <!-- The path to the Qualtrics JS file. By default, it's relative to the stylesheet.
       The content should be (correct the syntax HTML comment):

       <html xmlns="http://www.w3.org/1999/xhtml">
          <!- -BEGIN QUALTRICS WEBSITE FEEDBACK SNIPPET- ->
          <script type='text/javascript'><![CDATA[... add your content here ...]]></script>
          <div id='ZN_8qZUmklKYbBqAYe'><!- -DO NOT REMOVE-CONTENTS PLACED HERE- -></div>
          <!- -END WEBSITE FEEDBACK SNIPPET- ->
       </html>

       The root element is cut off (it can be any tagname, <html> is just an example).
       Anything below <html> is copied, including HTML comments and the <script>.
  -->
  <xsl:param name="qualtrics-feedback.js">static/js/qualtrics-feedback.js</xsl:param>

  <!-- Limit the revhistory list to X entries
       If it's empty, display all
  -->
  <xsl:param name="revision.limit"/>

  <!-- In case there is not revhistory/title, should the article/book title be included
       after the default "Revision History" string?
  -->
  <xsl:param name="revision.add.div.title" select="1"/>

  <!--
    $generate.revhistory = enable or disable revhistory generation
    valid values: 0 or 1
  -->
  <xsl:param name="generate.revhistory" select="1"/>

  <!-- Generates a separate file -->
  <xsl:param name="generate.revhistory.link" select="1"/>

  <!-- Should a button be generated on the right navigation? 0=no, 1=yes -->
  <xsl:param name="doc.survey" select="0"></xsl:param>

  <!-- The survey URL to be used. Change it accordingly -->
  <xsl:param name="doc.survey.url">https://suselinux.fra1.qualtrics.com/jfe/form/SV_bEiGZbUNzLD8Tcy</xsl:param>
</xsl:stylesheet>

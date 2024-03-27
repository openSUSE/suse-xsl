<!--

   Purpose:
     Provide metadata in the form of a JSON-LD

   Parameters:
     * $generate.json-ld (default 1): generate the structure (=1) or not (=0)

   Output:
     * Inside HTML <script type="application/ld+json"> tag containing JSON-LD
     * An external JSON file named after the DC file (without the "DC-" prefix,
       but with a ".json" suffix)

   Specification:
     * https://schema.org/TechArticle
     * https://confluence.suse.com/x/CYBGVg

   Example:
     From doc-modular, DC-sudo-configure-superuser-privileges:
     <script type="application/ld+json">
      {
        "@context": "http://schema.org",
        "@type": [
          "TechArticle"
        ],
        "image": "https://www.suse.com/assets/img/suse-white-logo-green.svg",
        "isPartOf": {
          "@type": "CreativeWorkSeries",
          "name": "Smart Docs"
        },
        "inLanguage": "en",
        "headline": "Configuring superuser privileges with sudo",
        "description": "Learn how to delegate superuser privileges with sudo.",
        "author": [
          {
            "@type": "Corporation",
            "name": "SUSE Product & Solution Documentation Team",
            "url": "https://www.suse.com/assets/img/suse-white-logo-green.svg"
          }
        ],
        "datePublished": "2024-02-15T00:00+02:00",
        "dateModified": "2024-02-16T00:00+02:00",
        "about": [
          {
            "@type": "Thing",
            "name": "Systems Management"
          },
          {
            "@type": "Thing",
            "name": "Configuration"
          },
          {
            "@type": "Thing",
            "name": "Security"
          }
        ],
        "mentions": [
          {
            "@type": "SoftwareApplication",
            "name": "Adaptable Linux Platform",
            "softwareVersion": "1",
            "applicationCategory": "Operating System",
            "operatingSystem": "Linux",
            "processorRequirements": "AMD64/Intel 64, IBM LinuxONE, Arm, POWER"
          }
        ],
        "sameAs": [
          "https://www.facebook.com/SUSEWorldwide/about",
          "https://www.youtube.com/channel/UCHTfqIzPKz4f_dri36lAQGA",
          "https://twitter.com/SUSE",
          "https://www.linkedin.com/company/suse"
        ],
        "publisher": {
          "@type": "Corporation",
          "name": "SUSE",
          "url": "https://documentation.suse.com",
          "logo": {
            "@type": "ImageObject",
            "url": "https://www.suse.com/assets/img/suse-white-logo-green.svg"
          }
        }
      }
     </script>

   HINT 1
     To create a JSON-LD structure for the HTML file, use generate.json-ld=1
     If you need an additional external JSON-LD file, use:
     * generate.json-ld=1
     * generate.json-ld.external=1
     * stitchfile="/tmp/docserv-stitch-....xml"
     * dcfilename="DC-..."

   HINT 2
     Validate the output with:
     * https://validator.schema.org
     * https://search.google.com/test/rich-results

   Authors:    Thomas Schraitle <toms@opensuse.org>, 2023-2024

-->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY ascii.uc "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
  <!ENTITY ascii.lc "abcdefghijklmnopqrstuvwxy">
  <!ENTITY lowercase "&ascii.lc;">
  <!ENTITY uppercase "&ascii.uc;">

]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="date exsl d">

  <xsl:variable name="stitchxml" select="document($stitchfile)/*"/>
  <xsl:key name="docserv-dcfiles" match="dc" use="."/>
  <xsl:key name="docserv-dcsubdelivfiles" match="subdeliverable" use="concat('DC-', .)"/>

  <xsl:template name="sanitize-date">
    <xsl:param name="date" select="."/>
    <xsl:variable name="length"  select="string-length($date)"/>
    <xsl:variable name="dashes" select="($length - string-length(translate($date, '-', ''))) = 2"/>
    <xsl:variable name="withcolon" select="contains($date, ':')" />
    <!-- Check if the (ISO?) date is in YYYY-MM or YYYY-M format and append
         "0" where necessary
    -->
    <xsl:choose>
      <!-- This is the case of a complete date: YYYYMMDDT00:00+02:00
           We return it unchanged
      -->
      <xsl:when test="$length = 22">
        <xsl:value-of select="$date"/>
      </xsl:when>
      <!-- We have a potential complete ISO date, return it unchanged -->
      <xsl:when test="$length = 10 and $dashes">
        <xsl:value-of select="concat($date, $json-ld-date-timezone)"/>
      </xsl:when>
      <!-- We have an incomplete date, probably YYYY-M-D -->
      <xsl:when test="$length = 8 and $dashes">
        <xsl:variable name="year" select="substring($date, 1, 4)"/>
        <xsl:variable name="month" select="concat('0', substring($date, 6, 2))"/>
        <xsl:variable name="day" select="concat('0', substring($date, 8, 2))"/>
        <xsl:value-of select="concat($year, '-', $month, '-', $day, $json-ld-date-timezone)"/>
      </xsl:when>
      <!-- We have an incomplete date, probably YYYY-MM so append the day -->
      <xsl:when test="$length = 7">
        <xsl:value-of select="concat(substring($date, 1, 7), '-01', $json-ld-date-timezone)"/>
      </xsl:when>
      <!-- We have an incomplete date, probably YYYY-M.  -->
      <xsl:when test="$length = 6">
        <xsl:variable name="year" select="substring($date, 1, 4)"/>
        <xsl:variable name="month" select="concat('0', substring($date, 6, 2))"/>
        <xsl:value-of select="concat($year, '-', $month, '-', '01', $json-ld-date-timezone)"/>
      </xsl:when>
      <!-- A potential ISO date with a timezone? Return it unchanged -->
      <xsl:when test="$length = 16 and $withcolon">
        <xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="$length = 14 and $withcolon">
        <xsl:variable name="year" select="substring($date, 1, 4)"/>
        <xsl:variable name="month" select="concat('0', substring($date, 6, 2))"/>
        <xsl:variable name="day" select="concat('0', substring($date, 8, 2))"/>
        <xsl:variable name="timezone" select="substring($date, 9)"/>
        <xsl:value-of select="concat($year, '-', $month, '-', $day, $timezone)"/>
      </xsl:when>
      <!-- Seems, we don't have a date. We can't guess anything useful, so output a warning -->
      <xsl:otherwise>
        <xsl:message>WARN: Cannot convert string '<xsl:value-of select="$date"/>'. Not a valid date!</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-basename">
    <xsl:param name="node" select="."/>
    <xsl:variable name="base">
      <xsl:choose>
          <xsl:when test="$node/@xml:base">
            <xsl:value-of select="substring-before($node/@xml:base, '.xml')" />
          </xsl:when>
          <xsl:when test="$node/@xml:id and $use.id.as.filename != 0">
            <xsl:value-of select="$node/@xml:id" />
          </xsl:when>
          <xsl:otherwise /><!-- TODO: What do we do here, if nothing works? -->
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$base"/>
  </xsl:template>

  <xsl:template name="get-dc-filename">
    <xsl:param name="node" select="."/>
    <xsl:variable name="base">
      <xsl:call-template name="get-basename">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$dcfilename != ''">
        <xsl:value-of select="$dcfilename"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('DC-', $base)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ========================================================== -->
  <xsl:template name="generate-json-ld-external">
    <xsl:param name="node" select="."/>
    <xsl:param name="first" select="0" />
    <xsl:variable name="base">
      <xsl:call-template name="get-basename">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:variable name="dcfile">
        <xsl:call-template name="get-dc-filename"/>
      </xsl:variable>
      <xsl:variable name="file" select="substring-after($dcfile, 'DC-')"/>
      <xsl:choose>
        <xsl:when test="$base != '' and $rootid != ''">
          <xsl:value-of select="concat($rootid, $json-ld.ext)"/>
        </xsl:when>
        <xsl:when test="$base != '' and $rootid = ''">
          <xsl:value-of select="concat($base, $json-ld.ext)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($file, $json-ld.ext)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="content">
      <xsl:call-template name="generate-json-content">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$generate.json-ld.external != 0 and $first = 1">
      <xsl:variable name="lang">
        <xsl:call-template name="l10n.language"/>
      </xsl:variable>
      <!--
        <xsl:message>Going to write external JSON-LD structure to "<xsl:value-of
        select="$filename"/>" for <xsl:value-of select="local-name($node)"/>
      Found <xsl:value-of select="count($stitchxml)"/> node(s) (=<xsl:value-of select="local-name($stitchxml)"/>).
      <xsl:if test="$dcfilename">Found DC filename "<xsl:value-of select="$dcfilename"/>"</xsl:if>
      json-ld-base.dir="<xsl:value-of select="$json-ld-base.dir"/>"
      filename="<xsl:value-of select="$filename"/>"
      </xsl:message>
      -->

      <!-- We take into account the language as well -->
      <xsl:call-template name="write.chunk">
        <xsl:with-param name="filename" select="concat($json-ld-base.dir, $lang, '-', $filename)"/>
        <xsl:with-param name="quiet" select="0"/>
        <xsl:with-param name="method">text</xsl:with-param>
        <xsl:with-param name="doctype-public"/>
        <xsl:with-param name="doctype-system"/>
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="generate-json-content">
    <xsl:param name="node"/>
    <xsl:text>{</xsl:text>
    "@context": "http://schema.org",
    "@type": ["TechArticle"],
    "image": "<xsl:value-of select="$json-ld-image-url"/>",
    <xsl:call-template name="json-ld-type">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-series">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-language">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-headline">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-description">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-keywords">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <!-- Later -->
    <!--<xsl:call-template name="json-ld-license">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    -->
    <xsl:call-template name="json-ld-authors-and-contributors">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-authors-and-contributors">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="type">editor</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="json-ld-authors-and-contributors">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="type">contributor</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="json-ld-techpartner">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-datePublished">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-dateModified">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-category">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-about"><!-- both task & webpages integrated into "about" property -->
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <!-- Belongs to type "SoftwareApplication" -->
    <xsl:call-template name="json-ld-software">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:call-template name="json-ld-releasenotes">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>

    <!-- This is the last entry. Don't add further additions due to the
         trailing comma missing.
    -->
    <xsl:call-template name="json-ld-publisher">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>
  </xsl:template>


  <xsl:template name="generate-json-ld">
    <xsl:param name="node" select="."/>
    <xsl:if test="$generate.json-ld != 0">
      <xsl:message>INFO: Going to generate JSON-LD... ("<xsl:value-of select="$stitchfile"/>") for context element <xsl:value-of select="local-name($node)"/></xsl:message>
      <script type="application/ld+json">
        <xsl:call-template name="generate-json-content">
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </script>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- ========================================================== -->
  <xsl:template name="json-ld-type">
    <xsl:param name="node" select="."/>
    <!-- We expect only _one_ type (relevant for TRD) -->
    <xsl:variable name="type" select="$node/d:info/d:meta[@name='type'][1]"/>
    <xsl:if test="$type">
    "additionalType": "<xsl:value-of select="normalize-space($type)"/>",
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-headline">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-headline">
      <xsl:choose>
        <xsl:when test="$node/d:info/d:meta[@name='title']">
          <xsl:value-of select="$node/d:info/d:meta[@name='title']"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:title">
          <xsl:value-of select="$node/d:info/d:title"/>
        </xsl:when>
        <xsl:when test="$node/d:title">
          <xsl:value-of select="$node/d:title"/>
        </xsl:when>
        <!--<xsl:when test="$node/ancestor-or-self::*/d:info/d:meta[@name='title']">
          <xsl:value-of select="($node/ancestor-or-self::*/d:info/d:meta[@name='title'])[last()]"/>
        </xsl:when>-->
        <!--<xsl:when test="$node/ancestor-or-self::*/d:info/d:title">
          <xsl:value-of select="($node/ancestor-or-self::*/d:info/d:title)[last()]"/>
        </xsl:when>-->
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="headline" select="normalize-space($candidate-headline)"/>

    "headline": "<xsl:value-of select="translate($headline, '&quot;', '')"/>",
  </xsl:template>

  <xsl:template name="json-ld-language">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-lang" select="($node/ancestor-or-self::*/@xml:lang)[last()]"/>
    <xsl:variable name="lang">
      <xsl:choose>
        <!-- Ensure we have lang-COUNTRY with country in uppercase -->
        <xsl:when test="contains($candidate-lang, '-')">
          <xsl:variable name="country" select="translate(substring-after($candidate-lang, '-'),
            '&lowercase;', '&uppercase;')"/>
          <xsl:value-of select="concat(substring-before($candidate-lang, '-'), '-', $country)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$candidate-lang"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$lang != ''">
    "inLanguage": "<xsl:value-of select="$lang"/>",
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-description">
    <xsl:param name="node" select="."/>
    <xsl:variable name="description">
      <xsl:choose>
        <xsl:when test="$node/d:info/d:meta[@name = 'description']">
          <xsl:value-of select="normalize-space($node/d:info/d:meta[@name = 'description'][1])"
          />
        </xsl:when>
        <xsl:when test="$node/d:info/d:meta[@name = 'social-descr']">
          <xsl:value-of select="normalize-space($node/d:info/d:meta[@name = 'social-descr'][1])"
          />
        </xsl:when>
        <xsl:when test="$node/d:info/d:meta[@name = 'title']">
          <xsl:value-of select="normalize-space($node/d:info/d:meta[@name = 'title'][1])"
          />
        </xsl:when>
        <xsl:when test="$node/d:info/d:abstract">
          <xsl:call-template name="ellipsize.text">
            <xsl:with-param name="input"
              select="($node/d:info/d:abstract/d:para[1] |
                       $node/d:info/d:abstract/d:variablelist[1]/d:varlistentry[1]/d:listitem/d:para[1])[last()]">
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <!-- Only for fallback, if all of the above fails -->
          <xsl:call-template name="ellipsize.text">
            <xsl:with-param name="input" select="($node/d:info/d:title | $node/d:title)[last()]"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

      <xsl:if test="$description != ''">
    "description": "<xsl:value-of select="translate($description, '&quot;', '')"/>",
      </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-keywords">
    <xsl:param name="node" select="."/>
    <xsl:variable name="keywords" select="$node/d:info/d:keywordset/d:keyword"/>
    <xsl:variable name="meta_keywords" select="$node/d:info/meta[@name='keyword']"/>

    <xsl:choose>
      <xsl:when test="($meta_keywords | $keywords)">
<!--        <xsl:value-of select="concat('    &quot;keywords:&quot;', ' [')"/>-->
        <xsl:text>    "keywords": [</xsl:text>
        <xsl:for-each select="$meta_keywords | $keywords">
          <xsl:value-of select="concat('&quot;', normalize-space(.), '&quot;')"/>
          <xsl:if test="position() != last()">,&#10;      </xsl:if>
        </xsl:for-each>
        <xsl:text>    ],</xsl:text>
      </xsl:when>
      <xsl:otherwise/><!-- Do nothing, if we don't find them -->
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-license">
    <xsl:param name="node" select="."/>

    <!-- "license": "URL",
         "copyrightNotice": "© 2023 ExampleTech Company. All rights reserved.",
         "copyrightYear": "2023",
    -->
  </xsl:template>

  <xsl:template name="json-ld-authors-and-contributors">
    <xsl:param name="node" select="."/>
    <!-- Only "author", "editor" and "contributor" is possible.
         WARNING: The value is not really checked
    -->
    <xsl:param name="type">author</xsl:param>
    <!--
       Implementation details:

       There are two possible sets:
       * Set A consists of separate elements like <author>, <editor>, <othercredit>, and <corpauthor>.
         They can appear in any combination or order.
       * Set B consists of <authorgroup> elements.

       Theoretically, writers can write any elements of both sets as they like. DocBook doesn't impose
       any restrictions.

       - We put everything from set A into a "$author" variable and wrap around an <authorgroup>
       - In XSLT 1.0, if we create temporary fragment trees (so called "result tree fragments") we need to
         convert them into "real" node trees with the extension function exsl:node-set().
         Yes, it's annoying. :-(
       - Everything else with <authorgroup> are stored in $authorgroup variable
       - Both node sets contain <authorgroup> elements. We can create a union node set with "|"
       - The <authorgroup> element only deals as a parent element, a wrapper for its content.
       - To see how many elements we have, we need the XPath expression "count($candidate-authors/*)"
         Keep in mind the "/*" at the end.
       - Depending on if we have one element or many, we deal accordingly. If we don't have any element
         at all, we fallback to the default author.
    -->
    <xsl:variable name="tmp-authors">
      <d:authorgroup>
        <xsl:choose>
          <xsl:when test="$type = 'contributor'">
            <xsl:copy-of select="$node/d:info/d:authorgroup/*[self::d:othercredit] |
                                 $node/d:info/d:othercredit"/>
          </xsl:when>
          <xsl:when test="$type = 'editor'">
            <xsl:copy-of select="$node/d:info/d:authorgroup/*[self::d:editor] |
                                 $node/d:info/d:editor"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$node/d:info/d:authorgroup/*[self::d:author] |
                                 $node/d:info/d:author"/>
          </xsl:otherwise>
        </xsl:choose>
      </d:authorgroup>
    </xsl:variable>
    <xsl:variable name="rtf-authors" select="exsl:node-set($tmp-authors)/*"/>

<!--    <xsl:message>INFO: json-ld-authors-and-authorgroups
     authors = <xsl:value-of select="count($authors)"/>
     rtf-authors = <xsl:value-of select="count($rtf-authors/*)"/>
     name(rtf-authors) = <xsl:value-of select="local-name($rtf-authors)"/>
     name(rtf-authors/*[1]) = <xsl:value-of select="local-name($rtf-authors/*[1])"/>
    </xsl:message>-->

    <xsl:choose>
      <!-- If we don't find any authors, create a default one -->
      <xsl:when test="$type = 'author' and count($rtf-authors/*) = 0">
    "author": [
      {
        "@type": "<xsl:value-of select="$json-ld-fallback-author-type"/>",
        "name": "<xsl:value-of select="$json-ld-fallback-author-name"/>",
        "url": "<xsl:value-of select="$json-ld-fallback-author-logo"/>"
      }
    ],
      </xsl:when>
      <xsl:when test="count($rtf-authors/*) > 0">
    "<xsl:value-of select="$type"/>": [
      <xsl:for-each select="$rtf-authors/*">
        <xsl:variable name="person">
          <xsl:choose>
            <xsl:when test="d:personname">
              <xsl:call-template name="person.name">
            <xsl:with-param name="node" select="."/>
          </xsl:call-template>
            </xsl:when>
            <xsl:when test="d:orgname">
              <xsl:value-of select="d:orgname"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="json-type">
          <xsl:choose>
            <xsl:when test="d:orgname">Corporation</xsl:when>
            <xsl:when test="d:personname">Person</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="uri" select="normalize-space(d:uri)"/>
        {
        "@type": "<xsl:value-of select="$json-type"/>",
        "name": "<xsl:value-of select="$person"/>"<xsl:if test="$uri">,
        "url": "<xsl:value-of select="normalize-space(d:uri)"/>"
        </xsl:if>
        <xsl:if test="not(d:orgname) and ./d:affiliation/d:orgname">,
          "affiliation": {
          "@type": "Corporation",
          "name": "<xsl:value-of select="./d:affiliation/d:orgname"/>"
          }
        </xsl:if>
        <!--, "role": "Writer"-->
        }<xsl:if test="position() != last()">,&#10;      </xsl:if>
      </xsl:for-each>
    ],
      </xsl:when>
      <!-- Do we need an xsl:otherwise? -->
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-datePublished">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-date">
      <xsl:choose>
        <!-- We look at different tags to extract some date information.
             Depending on which tag(s) are available.
             Sorted xsl:when from highest to lowest

             TODO: check format. It must be in ISO format.
        -->
        <xsl:when test="$node/d:info/d:meta[@name='published']">
          <xsl:value-of select="normalize-space(string($node/d:info/d:meta[@name='published']))"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="normalize-space(string($node/d:info/d:revhistory/d:revision[1]/d:date))"/>
        </xsl:when>
        <xsl:when test="normalize-space($node/d:info/d:pubdate) != ''">
          <xsl:value-of select="normalize-space(string($node/d:info/d:pubdate))"/>
        </xsl:when>
        <xsl:when test="normalize-space($node/d:info/d:date) != ''">
          <xsl:value-of select="normalize-space(string($node/d:info/d:date))"/>
        </xsl:when>
        <!-- Try to find a date from the ancestor nodes -->
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:meta[@name='published']">
          <xsl:value-of select="normalize-space(string($node/ancestor-or-self::*/d:info/d:meta[@name='published']))"/>
        </xsl:when>
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="normalize-space(string($node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date">
      <xsl:if test="$candidate-date != ''">
        <xsl:call-template name="sanitize-date">
          <xsl:with-param name="date" select="$candidate-date"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$date != ''">
    "datePublished": "<xsl:value-of select="$date"/>",
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Could not create "datePublished" property as no element was appropriate.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-dateModified">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-date">
      <xsl:choose>
        <xsl:when test="function-available('date:date-time') or
                        function-available('date:dateTime')">
          <xsl:call-template name="datetime.format">
            <xsl:with-param name="date" select="date:date-time()" />
            <xsl:with-param name="format">Y-m-d</xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="$json-ld-date-timezone"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date">
      <xsl:call-template name="sanitize-date">
        <xsl:with-param name="date" select="$candidate-date"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$date != ''">
    "dateModified": "<xsl:value-of select="normalize-space($date)"/>",
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Could not create "dateModified" entry as no extension was found.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-publisher">
    "sameAs": [
          "https://www.facebook.com/SUSEWorldwide/about",
          "https://www.youtube.com/channel/UCHTfqIzPKz4f_dri36lAQGA",
          "https://twitter.com/SUSE",
          "https://www.linkedin.com/company/suse"
    ],
    "publisher": {
      "@type": "Corporation",
      "name": "SUSE",
      "url": "https://documentation.suse.com",
      "logo": {
        "@type": "ImageObject",
        "url": "https://www.suse.com/assets/img/suse-white-logo-green.svg"
      }
    }
  </xsl:template>

  <xsl:template name="json-ld-category">
    <xsl:param name="node" select="."/>
    <!-- the @content can be removed if we don't use them anymore -->
    <xsl:variable name="categories" select="$node/d:info/d:meta[@name='category']/@content |
                                            $node/d:info/d:meta[@name='category']/*"/>

    <!-- WARNING: This may be not completely correct.
         According to schema.org, it can be only string, not a list.
    -->
    <xsl:if test="count($categories) > 0">
    "articleSection": [ <xsl:for-each select="$categories">
        "<xsl:value-of select="normalize-space(.)"/>"
        <xsl:if test="position() != last()">,&#10;      </xsl:if>
    </xsl:for-each>
    ],
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-techpartner">
    <xsl:param name="node" select="."/>
    <xsl:variable name="meta-techpartner" select="$node/d:info/d:meta[@name='techpartner']/d:phrase"/>
    <xsl:if test="$meta-techpartner">
    "affiliatedOrganization": [ <xsl:for-each select="$meta-techpartner">
      {
        "@type": "Organization",
        "name": "<xsl:value-of select="normalize-space(.)"/>"
      }<xsl:if test="position() != last()">,&#10;      </xsl:if>
    </xsl:for-each>
    ],
    </xsl:if>
  </xsl:template>

  <!-- The following templates access the Docserv config -->
  <xsl:template name="json-ld-series">
    <xsl:param name="node" select="."/>
    <xsl:variable name="meta-series" select="$node/d:info/d:meta[@name='series']"/>

    <xsl:if test="$meta-series != ''">
    "isPartOf": {
      "@type": "CreativeWorkSeries",
      "name": "<xsl:value-of select="normalize-space($meta-series)"/>"
    },
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-releasenotes">
    <xsl:param name="node" select="."/>
    <xsl:variable name="dcfile">
      <xsl:call-template name="get-dc-filename">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="docserv-dcfile"
      select="(key('docserv-dcfiles', $dcfile) | key('docserv-dcsubdelivfiles', $dcfile))[1]"/>
    <xsl:variable name="candidate-productid">
      <xsl:for-each select="$stitchxml">
        <xsl:value-of select="translate($docserv-dcfile/ancestor::product/@productid,
                                        '&lowercase;',
                                        '&uppercase;')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="productid">
      <xsl:choose>
        <!-- We need to adjust some values... -->
        <xsl:when test="$candidate-productid = 'SLES'">SUSE-SLES</xsl:when>
        <xsl:when test="$candidate-productid = 'SLED'">SUSE-SLED</xsl:when>
        <xsl:when test="$candidate-productid = 'SLE-MICRO'">SLE-Micro</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$candidate-productid"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="release">
      <xsl:for-each select="$stitchxml">
        <xsl:value-of select="$docserv-dcfile/ancestor::docset/@setid"/>
      </xsl:for-each>
    </xsl:variable>
    <!--
      Only add the releasenotes for SLES or SLED
      The releasenotes URL has this syntax (PRODUCT and RELEASE are placeholders):
      https://www.suse.com/releasenotes/x86_64/<PRODUCT>/<RELEASE>/
    -->
    <xsl:if test="$productid = 'sles' or $productid = 'sled'">
    "releaseNotes": "<xsl:value-of
      select="concat('https://www.suse.com/releasenotes/x86_64/',
                     $productid, '/', $release, '/')"/>",
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-about">
    <xsl:param name="node" select="."/>
    <xsl:variable name="tasks">
      <xsl:call-template name="json-ld-task">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="webpages">
      <xsl:call-template name="json-ld-webpages">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>

    "about": [
      <xsl:value-of select="$tasks"/>
      <xsl:if test="normalize-space($webpages) != ''">
          <xsl:if test="normalize-space($tasks) != ''">
            <xsl:text>,&#10;</xsl:text>
          </xsl:if>
        <xsl:value-of select="$webpages"/>
      </xsl:if>
    ],
  </xsl:template>

  <xsl:template name="json-ld-task">
    <xsl:param name="node" select="."/>
    <xsl:variable name="tasks" select="$node/d:info/d:meta[@name='task']/d:phrase"/>
    <xsl:if test="count($tasks) > 0">
      <xsl:for-each select="$tasks">{
        "@type": "Thing",
        "name": "<xsl:value-of select="normalize-space(.)"/>"
      }<xsl:if test="position() &lt; last()">
        <xsl:text>,&#10;      </xsl:text>
      </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-software">
    <xsl:param name="node" select="."/>
    <xsl:variable name="info-productnumber" select="normalize-space($node/d:info/d:productnumber)"/>
    <xsl:variable name="info-productname" select="normalize-space($node/d:info/d:productname)"/>
    <xsl:variable name="meta-productname" select="$node/d:info/d:meta[@name='productname']/d:productname"/>
    <xsl:variable name="tmp-productname-with-version">
      <xsl:if test="$info-productname">
        <productname xmlns="http://docbook.org/ns/docbook" version="{$info-productnumber}"
        ><xsl:value-of select="$info-productname"/></productname>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="productname-with-version" select="exsl:node-set($tmp-productname-with-version)/*"/>
    <xsl:variable name="productname" select="($productname-with-version | $meta-productname)"/>
    <xsl:variable name="archs" select="$node/d:info/d:meta[@name='architecture']/d:phrase"/>
    <xsl:variable name="candidate-arch">
      <xsl:for-each select="$archs">
        <xsl:value-of select="."/>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="$productname">
    "mentions": [
      <xsl:for-each select="$productname">
      { "@type": "SoftwareApplication",
        "name": "<xsl:value-of select="normalize-space(.)"/>",
        <xsl:if test="normalize-space(@version) != ''">"softwareVersion": "<xsl:value-of select="@version"/>",</xsl:if>
        "applicationCategory": "Operating System",
        "operatingSystem": "Linux"<xsl:if test="normalize-space($candidate-arch) != ''">,
        "processorRequirements": "<xsl:value-of select="$candidate-arch"/>"
        </xsl:if>
      }
      <xsl:if test="position() != last()">,&#10;      </xsl:if>
      </xsl:for-each>
    ],
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-webpages">
    <xsl:param name="node"/>
    <xsl:variable name="dcfile">
      <xsl:call-template name="get-dc-filename">
        <xsl:with-param name="node" select="$node"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="filepart" select="substring-after($dcfile, 'DC-')"/>
    <xsl:variable name="candidate-docsetid">
      <xsl:for-each select="$stitchxml">
        <xsl:value-of select="(key('docserv-dcfiles', $dcfile) |
                               key('docserv-dcsubdelivfiles', $dcfile))[1]/ancestor::docset/@setid"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="candidate-productid">
      <xsl:for-each select="$stitchxml">
        <xsl:value-of select="(key('docserv-dcfiles', $dcfile) |
                               key('docserv-dcsubdelivfiles', $dcfile))[1]/ancestor::product/@productid"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="candidate-lang">
      <xsl:for-each select="$stitchxml">
        <xsl:variable name="tmp" select="(key('docserv-dcfiles', $dcfile) |
                               key('docserv-dcsubdelivfiles', $dcfile))[1]/ancestor::language/@lang"/>
        <!-- We want the part before "-", for example "en-us" => "en" -->
        <xsl:value-of select="substring-before($tmp, '-')" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="candicate-format-node">
      <formats>
      <xsl:for-each select="$stitchxml">
        <xsl:for-each select="(key('docserv-dcfiles', $dcfile) |
                              key('docserv-dcsubdelivfiles', $dcfile))[1]/ancestor::deliverable/format/@*">
          <xsl:if test=". = '1' or . = 'yes' or . = 'true'">
            <format><xsl:value-of select="local-name(.)"/></format>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
      </formats>
    </xsl:variable>
    <xsl:variable name="format-node" select="exsl:node-set($candicate-format-node)/*/*"/>

<!--
    <xsl:message>JSON-LD json-ld-webpages
      dcfile=<xsl:value-of select="$dcfile"/>
      filepart=<xsl:value-of select="$filepart"/>
      docsetid=<xsl:value-of select="$candidate-docsetid"/>
      productid=<xsl:value-of select="$candidate-productid"/>
      format-node=<xsl:value-of select="count($format-node)"/>
    </xsl:message>
 -->

    <xsl:if test="count($format-node) = 0">
      <xsl:call-template name="log.message">
        <xsl:with-param name="level">error</xsl:with-param>
        <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
        <xsl:with-param name="message">
          <xsl:text>Could not create WebPage type for DC file </xsl:text>
          <xsl:value-of select="$dcfile"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:for-each select="$format-node">
        <xsl:variable name="attr" select="."/>
        <xsl:variable name="candidate-url" select="concat($json-ld-fallback-author-url, '/',
                                                $candidate-productid, '/',
                                                $candidate-docsetid, '/',
                                                $attr, '/', $filepart)"/>
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test=". = 'html' or . = 'single-html'">
              <xsl:value-of select="concat($candidate-url, '/')"/>
            </xsl:when>
            <xsl:when test=". = 'pdf'">
              <xsl:value-of select="concat($candidate-url, '_', $candidate-lang, '.pdf')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$candidate-url"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="encodingformat">
          <xsl:choose>
            <xsl:when test=". = 'html' or . = 'single-html'">text/html</xsl:when>
            <xsl:when test=". = 'pdf'">application/pdf</xsl:when>
          </xsl:choose>
        </xsl:variable>
        {
          "@type": "WebPage",
          "url": "<xsl:value-of select="$url"/>"<xsl:if test="$encodingformat != ''">,
          "encodingFormat": "<xsl:value-of select="$encodingformat"/>"</xsl:if>
        }<xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
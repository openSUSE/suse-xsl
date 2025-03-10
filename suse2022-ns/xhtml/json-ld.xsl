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

  <!--
    Validates a date

    Synopsis: validate-date(date: string) -> boolean
    $date should be in the format of YYYY-MM-DDTHH:MMZ, but only the YYYY-MM-DD is checked.
  -->
  <xsl:template name="validate-date">
    <xsl:param name="date"/>
    <!-- Extract year, month, and day parts -->
    <xsl:variable name="year" select="number(substring($date, 1, 4))"/>
    <xsl:variable name="month" select="number(substring($date, 6, 2))"/>
    <xsl:variable name="day" select="number(substring($date, 9, 2))"/>

    <xsl:choose>
      <!-- Check for NaN -->
      <xsl:when test="not($year = $year) or not($month = $month) or not($day = $day)">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring($date, 5, 1) = '-' and substring($date, 8, 1) = '-'">
            <xsl:choose>
              <xsl:when test="$month >= 1 and $month &lt;= 12">
                <!-- Additional checks for month-specific days -->
                <xsl:choose>
                  <xsl:when test="$month = 2 and $day &lt;= 29">
                    <xsl:choose>
                      <xsl:when test="$year mod 4 = 0 and ($year mod 100 != 0 or $year mod 400 = 0)">
                        <xsl:value-of select="true()" />
                      </xsl:when>
                      <xsl:when test="$year mod 4 != 0">
                        <xsl:value-of select="true()" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="false()" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:when test="$day >= 1 and $day &lt;= 31">
                    <xsl:value-of select="true()" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="false()" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="false()" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--
    Sanitize a date and convert it into YYYY-MM-DDTHH:MMZ

    Synopsis: sanitize-date(date: string) -> string

    $date can be any date in the format YYYY-M, YYYY-MM, YYYY-M-D, YYYY-MM-D, YYYY-M-DD, or YYYY-MM-DD
    If the date doesn't conform to any of these formats, an empty string is returned
  -->
  <xsl:template name="sanitize-date">
    <xsl:param name="date"/>

    <!-- We format the date with format-number. If there is a string which can't be converted,
         we get "NaN". This is a hint to reject the converted string and just return an empty
         string.
    -->
    <xsl:variable name="candidate-date">
      <xsl:choose>
        <!-- Check if the date is in the format YYYY-MM-DD -->
        <xsl:when test="string-length($date) = 10 and
                        substring($date, 5, 1) = '-' and substring($date, 8, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 2)"/>
          <xsl:variable name="day" select="substring($date, 9, 2)"/>
          <xsl:value-of select="concat(format-number($year, '#-'),
                                       format-number($month, '00-'),
                                       format-number($day, '00'),
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <!-- Check if the date is in the format YYYY-MM -->
        <xsl:when test="string-length($date) = 7 and substring($date, 5, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 2)"/>
          <xsl:value-of select="concat(format-number($year, '0000-'),
                                       format-number($month, '00-'), '01',
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <!-- Check if the date is in the format YYYY-M -->
        <xsl:when test="string-length($date) = 6 and substring($date, 5, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 1)"/>
          <xsl:value-of select="concat(format-number($year, '0000-'),
                                       format-number($month, '00-'), '01',
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <!-- Check if the date is in the format YYYY-M-D -->
        <xsl:when test="string-length($date) = 8 and
                        substring($date, 5, 1) = '-' and substring($date, 7, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 1)"/>
          <xsl:variable name="day" select="substring($date, 8, 1)"/>
          <xsl:value-of select="concat(format-number($year, '####-'),
                                       format-number($month, '00-'),
                                       format-number($day, '00'),
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <!-- Check if the date is in the format YYYY-MM-D -->
        <xsl:when test="string-length($date) = 9 and
                        substring($date, 5, 1) = '-' and substring($date, 8, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 2)"/>
          <xsl:variable name="day" select="substring($date, 9, 1)"/>
          <xsl:value-of select="concat(format-number($year, '####-'),
                                       format-number($month, '00-'),
                                       format-number($day, '00'),
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <!-- Check if the date is in the format YYYY-M-DD -->
        <xsl:when test="string-length($date) = 9 and
                        substring($date, 5, 1) = '-' and substring($date, 7, 1) = '-'">
          <xsl:variable name="year" select="substring($date, 1, 4)"/>
          <xsl:variable name="month" select="substring($date, 6, 1)"/>
          <xsl:variable name="day" select="substring($date, 8, 2)"/>
          <xsl:value-of select="concat(format-number($year, '####-'),
                                       format-number($month, '00-'),
                                       format-number($day, '00'),
                                       $json-ld-date-timezone)"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Return an empty string if the date does not match any of the specified formats -->
          <xsl:text/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <!-- Return an empty string if date is invalid (contains a "NaN") or empty -->
      <xsl:when test=" contains($candidate-date, 'NaN') or $candidate-date = ''">
        <xsl:text/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$candidate-date"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <!--
    Compare two dates lexicographically

    Synopsis: compare-dates(date1: string, date2: string) -> integer

    Result:
     -1, if date1 < date2
      0, if date1 == date2
      1, if date1 > date2

  -->
  <xsl:template name="compare-dates">
    <xsl:param name="date1"/>
    <xsl:param name="date2"/>

    <!-- Extract the date part and remove "-" -->
    <xsl:variable name="numericDate1" select="translate(substring-before($date1, 'T'), '-', '')"/>
    <xsl:variable name="numericDate2" select="translate(substring-before($date2, 'T'), '-', '')"/>

    <!-- Compare dates lexicographically -->
    <xsl:choose>
      <xsl:when test="$numericDate1 &lt; $numericDate2">-1</xsl:when>
      <xsl:when test="$numericDate1 = $numericDate2">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
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

<!--        <xsl:message>Going to write external JSON-LD structure to "<xsl:value-of
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
    <xsl:call-template name="json-ld-alternativeheadline">
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
    <xsl:call-template name="json-ld-dateModified-and-Published">
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
      <xsl:message>INFO: Going to generate JSON-LD... (stitchfile="<xsl:value-of select="$stitchfile"/>") for context element <xsl:value-of select="local-name($node)"/></xsl:message>
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


  <xsl:template name="json-ld-alternativeheadline">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-headline">
      <xsl:choose>
        <xsl:when test="$node/d:info/d:subtitle">
          <xsl:value-of select="$node/d:info/d:subtitle"/>
        </xsl:when>
        <xsl:when test="$node/d:subtitle">
          <xsl:value-of select="$node/d:subtitle"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="subtitle" select="normalize-space($candidate-headline)"/>

    <xsl:if test="$subtitle != ''">
      <xsl:text>  "alternativeHeadline": </xsl:text>
      <xsl:value-of select="concat('&quot;', $subtitle, '&quot;,')"/>
    </xsl:if>
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

  <xsl:template name="json-ld-dateModified-and-Published">
    <xsl:param name="node" select="."/>
    <xsl:variable name="candidate-modified">
      <xsl:choose>
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="normalize-space(($node/ancestor-or-self::*/d:info/d:revhistory/d:revision[1]/d:date)[last()])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="candidate-published">
      <xsl:choose>
        <xsl:when test="$node/ancestor-or-self::*/d:info/d:revhistory/d:revision[last()]/d:date">
          <xsl:value-of select="normalize-space(($node/ancestor-or-self::*/d:info/d:revhistory/d:revision[last()]/d:date)[last()])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date-modified">
      <xsl:if test="$candidate-modified != ''">
        <xsl:call-template name="sanitize-date">
          <xsl:with-param name="date" select="$candidate-modified"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="date-published">
      <xsl:if test="$candidate-published != ''">
        <xsl:call-template name="sanitize-date">
          <xsl:with-param name="date" select="$candidate-published"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="is-modified-valid">
      <xsl:choose>
        <xsl:when test="$date-modified != ''">
          <xsl:call-template name="validate-date">
            <xsl:with-param name="date" select="$date-modified"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="is-published-valid">
      <xsl:choose>
        <xsl:when test="$date-published != ''">
          <xsl:call-template name="validate-date">
            <xsl:with-param name="date" select="$date-published"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="compare">
      <xsl:choose>
        <xsl:when test="$is-published-valid = true() and $is-modified-valid = true()">
          <xsl:call-template name="compare-dates">
            <xsl:with-param name="date1" select="$date-published" />
            <xsl:with-param name="date2" select="$date-modified" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>100</xsl:otherwise><!-- In case some problem with one of the dates -->
      </xsl:choose>
    </xsl:variable>

<!--    <xsl:message>DEBUG:
      current element=<xsl:value-of select="local-name($node)"/>
      count = <xsl:value-of select="count($node/d:info/d:revhistory)"/>
      compare=<xsl:value-of select="$compare"/>
      candidate-modified="<xsl:value-of select="$candidate-modified"/>" / <xsl:value-of select="normalize-space($node/d:info/d:revhistory/d:revision[1]/d:date)"/>
    candidate-published="<xsl:value-of select="$candidate-published"/>"
    modified=<xsl:value-of select="$date-modified"/> => <xsl:value-of select="$is-modified-valid"/>
    published=<xsl:value-of select="$date-published"/> => <xsl:value-of select="$is-published-valid"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="$date-published"/> => <xsl:call-template name="validate-date">
        <xsl:with-param name="date" select="$date-modified"></xsl:with-param>
      </xsl:call-template>
    </xsl:message>
-->
    <!-- TODO: compare the two dates
      Condition: datePublished <= dateModified
    -->
    <xsl:choose>
      <xsl:when test="count($node/ancestor-or-self::*/d:info/d:revhistory) = 0">
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>No revhistory found in your document</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$compare &lt;= 0"/><!-- This is the expected outcome. Do nothing. -->
      <xsl:when test="$compare = 1">
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>In your revhistory, the first date </xsl:text>
            <xsl:value-of select="concat('(', $date-modified, ') ')"/>
            <xsl:text>is smaller than the last date </xsl:text>
            <xsl:value-of select="concat('(', $date-published, '). ')"/>
            <xsl:text>The revhistory's dates must be sorted from newest to oldest.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Number greater than 1 only occurs if there is an error in the metadata for dates -->
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">error</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Either the first and last entry in the revistory/revision/date contains an invalid date </xsl:text>
            <xsl:text>or no dates was found at all.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:choose>
      <xsl:when test="$date-modified != ''">
    "dateModified": "<xsl:value-of select="$date-modified"/>",
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Could not create "dateModified" property as no element was appropriate.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$date-published != ''">
    "datePublished": "<xsl:value-of select="$date-published"/>",
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
    <xsl:variable name="meta-series" select="$node/d:info/d:meta[@name='series'][1]"/>
    <xsl:variable name="candidate-series">
      <xsl:choose>
        <xsl:when test="$json-ld-seriesname != ''">
          <xsl:value-of select="$json-ld-seriesname"/>
        </xsl:when>
        <xsl:when test="$meta-series">
          <xsl:value-of select="$meta-series"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$candidate-series != ''">
     "isPartOf": {
      "@type": "CreativeWorkSeries",
      "name": "<xsl:value-of select="normalize-space($candidate-series)"/>"
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

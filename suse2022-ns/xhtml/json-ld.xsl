<!--

   Purpose:
     Provide metadata in the form of a JSON-LD

   Parameters:
     * $generate.json-ld (default 1): generate the structure (=1) or not (=0)

   Output:
     HTML <script type="application/ld+json"> tag containing JSON-LD

   Specification:
     https://schema.org/TechArticle

   Example:
     <script type="application/ld+json">
      {
        "@context": "https://schema.org/",
        "@type": "TechArticle",
        "name": "Getting Started with ExampleApp",
        "headline": "ExampleApp Documentation",
        "abstract": "A short abstract of ExampleApp",
        "description": "A comprehensive guide to get started with ExampleApp.",
        "author": {
          "@type": "Person",
          "name": "Tux Penguin",
          "role": "Writer"
        },
        "datePublished": "2023-07-24",
        "dateModified": "2023-07-25",
        "publisher": {
          "@type": "Organization",
          "name": "SUSE",
          "logo": {
            "@type": "ImageObject",
            "url": "https://www.suse.com/assets/img/suse-white-logo-green.svg"
          }
        }
      }
     </script>

   Authors:    Thomas Schraitle <toms@opensuse.org>,

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="date exsl d">

  <xsl:template name="json-group">
    <xsl:param name="key"/>
    <xsl:param name="type"/>
    <xsl:param name="indent"><xsl:text>&#10;    </xsl:text></xsl:param>
    <xsl:param name="body"/>
    <xsl:param name="comma" select="true()"/>

    <xsl:value-of select="concat($indent, '&quot;', $key, '&quot;: {')"/>
    <xsl:value-of select="$body"/>
    <xsl:value-of select="concat($indent, '}')"/>
    <xsl:if test="$comma">,</xsl:if>
  </xsl:template>


  <xsl:template name="generate-json-ld">
    <xsl:param name="node"/>
    <xsl:if test="$generate.json-ld != 0">
      <xsl:message>INFO: Going to generate JSON-LD...</xsl:message>
      <script type="application/ld+json">
{
    "@context": "http://schema.org",
    "@type": "TechArticle",<!--

    -->
        <xsl:call-template name="json-ld-headline"/>
        <xsl:call-template name="json-ld-abstract"/>
        <xsl:call-template name="json-ld-keywords"/>
        <xsl:call-template name="json-ld-authors"/>
        <xsl:call-template name="json-ld-authorgroup"/>
        <xsl:call-template name="json-ld-datePublished"/>
        <xsl:call-template name="json-ld-dateModified"/>
        <xsl:call-template name="json-ld-version"/>
        <xsl:call-template name="json-ld-publisher"/>
}
      </script>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-headline">
    <xsl:param name="node" select="."/>
    <xsl:variable name="headline" select="($node/d:info/d:meta[@name='title'] | $node/d:info/d:title | $node/d:title)[last()]"/>
    "headline": "<xsl:value-of select="normalize-space($headline)"/>",
  </xsl:template>

  <xsl:template name="json-ld-abstract">
    <xsl:param name="node" select="."/>
    <xsl:if test="$node/d:info/d:abstract">
      <xsl:variable name="abstract">
        <xsl:call-template name="ellipsize.text">
          <xsl:with-param name="input">
            <xsl:choose>
              <xsl:when test="$node/d:info/d:meta[@name = 'description']">
                <xsl:value-of select="normalize-space($node/d:info/d:meta[@name = 'description'][1])" />
              </xsl:when>
              <xsl:when test="$node/d:info/d:abstract or $node/d:info/d:highlights">
                <xsl:for-each select="($node/d:info[1]/d:abstract[1] | $node/d:info[1]/d:highlights[1])[1]/*">
                  <xsl:value-of select="normalize-space(.)" />
                  <xsl:if test="position() &lt; last()">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="$abstract != ''">
    "abstract": "<xsl:value-of select="$abstract"/>",
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-keywords">
    <xsl:param name="node" select="."/>
    <xsl:variable name="keywords" select="$node/d:info/d:keywordset"/>

    <xsl:if test="$keywords">
    "keywords": [
      <xsl:for-each select="$keywords/d:keyword">
        <xsl:value-of select="concat('&quot;', normalize-space(.), '&quot;')"/>
        <xsl:if test="position() != last()">,&#10;      </xsl:if>
      </xsl:for-each>
    ],
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-authors">
    <xsl:param name="node" select="."/>
    <xsl:choose>
      <xsl:when test="not($node/d:info/d:author)"/>
      <xsl:when test="count($node/d:info/d:author) = 1">
        <xsl:variable name="person">
          <xsl:call-template name="person.name">
            <xsl:with-param name="node" select="$node/d:info/d:author"/>
          </xsl:call-template>
        </xsl:variable>
    "author": {
      "@type": "Person",
      "name": "<xsl:value-of select="$person"/>",
      "role": "Writer"
    },
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="authors">
          <d:info>
            <d:authorgroup>
              <xsl:copy-of
                select="$node/d:info/d:author | $node/d:info/d:corpauthor | $node/d:info/d:othercredit | $node/d:info/d:editor"
               />
            </d:authorgroup>
          </d:info>
        </xsl:variable>
        <xsl:variable name="rtf-authors" select="exsl:node-set($authors)"/>
        <xsl:call-template name="json-ld-authorgroup">
          <xsl:with-param name="node" select="$rtf-authors"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-authorgroup">
    <xsl:param name="node" select="."/>
    <xsl:for-each select="$node/d:info/d:authorgroup">
    "author": [<xsl:call-template name="json-ld-person.name.list"/>
    ],
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="json-ld-version">
    <xsl:param name="node" select="."/>
    <xsl:variable name="version" select="($node/d:info/d:productnumber)"/>

    <xsl:if test="$version != ''">
    "version": "<xsl:value-of select="$version"/>",
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-person.name.list">
    <xsl:param name="node" select="."/>
    <xsl:param name="person.list"  select="$node/d:author|$node/d:corpauthor|$node/d:othercredit|$node/d:editor"/>
    <xsl:param name="person.count" select="count($person.list)"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count &gt; $person.count"></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="name">
          <xsl:call-template name="person.name">
            <xsl:with-param name="node" select="$person.list[position()=$count]"/>
          </xsl:call-template>
        </xsl:variable>
        {
          "@type": "Person",
          "name": "<xsl:value-of select="string($name)"/>",
          "role": "<xsl:choose>
<!--          <xsl:when test="local-name($person.list[position()=$count]) = 'author'">Writer</xsl:when>-->
          <xsl:when test="local-name($person.list[position()=$count]) = 'editor'">Editor</xsl:when>
          <xsl:when test="local-name($person.list[position()=$count]) = 'othercredit'">Contributor</xsl:when>
          <xsl:otherwise>Writer</xsl:otherwise>
        </xsl:choose>"
        }<xsl:if test="$count &lt; $person.count">,&#10;</xsl:if>
        <xsl:call-template name="json-ld-person.name.list">
          <xsl:with-param name="person.list" select="$person.list"/>
          <xsl:with-param name="person.count" select="$person.count"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-datePublished">
    <xsl:param name="node" select="."/>
    <xsl:variable name="date">
      <xsl:choose>
        <!-- We look at different tags to extract some date information.
             Depending on which tag(s) are available.

             TODO: check format. It must be in ISO format.
        -->
        <xsl:when test="$node/d:info/d:meta[@name='published']">
          <xsl:value-of select="string($node/d:info/d:meta[@name='published'])"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:pubdate">
          <xsl:value-of select="string($node/d:info/d:pubdate)"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:date">
          <xsl:value-of select="string($node/d:info/d:pubdate)"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="string($node/d:info/d:revhistory/d:revision[1]/d:date)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$date != ''">
    "datePublished": "<xsl:value-of select="normalize-space($date)"/>",
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Could not create "datePublished" entry as no element was appropriate.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-dateModified">
    <xsl:variable name="date">
    <xsl:choose>
      <xsl:when test="function-available('date:date-time') or
                      function-available('date:dateTime')">
        <xsl:call-template name="datetime.format">
          <xsl:with-param name="date" select="date:date-time()"/>
          <xsl:with-param name="format">Y-m-d</xsl:with-param><!-- ISO -->
      </xsl:call-template>
      </xsl:when>
    </xsl:choose>
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
    "publisher": {
      "@type": "Organization",
      "name": "SUSE",
      "logo": {
        "@type": "ImageObject",
        "url": "https://www.suse.com/assets/img/suse-white-logo-green.svg"
      }
    }
  </xsl:template>

</xsl:stylesheet>
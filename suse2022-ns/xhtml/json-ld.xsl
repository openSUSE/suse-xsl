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
        "description": "A comprehensive guide to get started with ExampleApp.",
        "author": {
          "@type": "Person",
          "name": "Tux Penguin",
          "role": "Writer"
        },
        "datePublished": "2023-07-24",
        "dateModified": "2023-07-25",
        "sameAs": [
          "https://www.facebook.com/SUSEWorldwide/about",
          "https://www.youtube.com/channel/UCHTfqIzPKz4f_dri36lAQGA",
          "https://twitter.com/SUSE",
          "https://www.linkedin.com/company/suse"
        ],
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

  <xsl:template name="generate-json-ld">
    <xsl:param name="node"/>
    <xsl:if test="$generate.json-ld != 0">
      <xsl:message>INFO: Generating JSON-LD...</xsl:message>
      <script type="application/ld+json">
{
    "@context": "http://schema.org",
    "@type": "TechArticle",<!--

    -->
        <xsl:call-template name="json-ld-headline"/>
        <xsl:call-template name="json-ld-description"/>
<!--        <xsl:call-template name="json-ld-keywords"/>-->

        <xsl:call-template name="json-ld-license"/><!-- Later -->
        <xsl:call-template name="json-ld-authors-and-authorgroups"/>
        <xsl:call-template name="json-ld-datePublished"/>
        <xsl:call-template name="json-ld-dateModified"/>
<!--        <xsl:call-template name="json-ld-version"/>-->
        <xsl:call-template name="json-ld-publisher"/>
}
      </script>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-ld-headline">
    <xsl:param name="node" select="."/>
    <xsl:variable name="headline" select="normalize-space(($node/d:info/d:meta[@name='title'] | $node/d:info/d:title | $node/d:title)[last()])"/>
    "headline": "<xsl:value-of select="translate($headline, '&quot;', '')"/>",
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

  <xsl:template name="json-ld-license">
    <xsl:param name="node" select="."/>

    <!-- "license": "URL",
         "copyrightNotice": "© 2023 ExampleTech Company. All rights reserved.",
         "copyrightYear": "2023",
    -->
  </xsl:template>

  <xsl:template name="json-ld-authors-and-authorgroups">
    <xsl:param name="node" select="."/>
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
         Yes, it's annoying as fuck. :-(
       - Everything else with <authorgroup> are stored in $authorgroup variable
       - Both node sets contain <authorgroup> elements. We can create a union node set with "|"
       - The <authorgroup> element only deals as a parent element, a wrapper for its content.
       - To see how many elements we have, we need the XPath expression "count($candidate-authors/*)"
         Keep in mind the "/*" at the end.
       - Depending on if we have one element or many, we deal accordingly. If we don't have any element
         at all, we fallback to the default author.
    -->
    <xsl:variable name="authors">
      <xsl:if test="$node/d:info/d:author | $node/d:info/d:corpauthor | $node/d:info/d:othercredit | $node/d:info/d:editor">
        <d:authorgroup>
          <xsl:copy-of select="$node/d:info/d:author |
                               $node/d:info/d:corpauthor |
                               $node/d:info/d:othercredit |
                               $node/d:info/d:editor"
           />
        </d:authorgroup>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="rtf-authors" select="exsl:node-set($authors)/*"/>
    <xsl:variable name="authorgroup" select="$node/d:info/d:authorgroup"/>
    <xsl:variable name="candidate-authors" select="$rtf-authors | $authorgroup"/>

<!--    <xsl:message>INFO: json-ld-authors-and-authorgroups
     authors = <xsl:value-of select="count($authors)"/>
     name(author) = <xsl:value-of select="local-name($authors)"/>
     rtf-authors = <xsl:value-of select="count($rtf-authors/*)"/>
     name(rtf-author) = <xsl:value-of select="local-name($rtf-authors)"/>
     authorgroup = <xsl:value-of select="count($authorgroup)"/>
     name(authorgroup) = <xsl:value-of select="local-name($authorgroup)"/>
     candidate = <xsl:value-of select="count($candidate-authors/*)"/>
     name(candidate) = <xsl:value-of select="local-name($candidate-authors)"/>
    </xsl:message>-->

    <xsl:choose>
      <xsl:when test="number($json-ld-use-individual-authors) = 1 and count($candidate-authors/*) = 1">
        <xsl:message>INFO: found one author</xsl:message>
        <xsl:variable name="person">
          <xsl:call-template name="person.name">
            <xsl:with-param name="node" select="$candidate-authors/*"/>
          </xsl:call-template>
        </xsl:variable>
    "author": {
      "@type": "Person",
      "name": "<xsl:value-of select="$person"/>"<!--,
      "role": "Writer"-->
    },
      </xsl:when>
      <xsl:when test="number($json-ld-use-individual-authors) = 1 and count($candidate-authors/*) > 1">
    "author": [<!--
        --><xsl:call-template name="json-ld-person.name.list">
          <xsl:with-param name="node" select="$candidate-authors"/>
        </xsl:call-template>
    ],
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="json-ld-author-fallback"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="json-ld-author-fallback">
    <xsl:param name="node" select="."/>
    "author": {
       "@type": "<xsl:value-of select="$json-ld-fallback-author-type"/>",
       "name": "<xsl:value-of select="$json-ld-fallback-author-name"/>",
       <xsl:if test="$json-ld-fallback-author-url != ''"
         >"url": "<xsl:value-of select="$json-ld-fallback-author-url"/>",</xsl:if>
       <xsl:if test="$json-ld-fallback-author-logo != ''">
       "logo": "<xsl:value-of select="$json-ld-fallback-author-logo"/>"</xsl:if>
    },
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
          "name": "<xsl:value-of select="string($name)"/>"
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
          <xsl:value-of select="normalize-space(string($node/d:info/d:meta[@name='published']))"/>
        </xsl:when>
        <xsl:when test="normalize-space($node/d:info/d:pubdate) != ''">
          <xsl:value-of select="normalize-space(string($node/d:info/d:pubdate))"/>
        </xsl:when>
        <xsl:when test="normalize-space($node/d:info/d:date) != ''">
          <xsl:value-of select="normalize-space(string($node/d:info/d:pubdate))"/>
        </xsl:when>
        <xsl:when test="$node/d:info/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="normalize-space(string($node/d:info/d:revhistory/d:revision[1]/d:date))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date-check">
      <xsl:call-template name="is-valid-iso-8601-date">
        <xsl:with-param name="text" select="$date"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- If day is missing in YYYY-MM-DD, append "-01" and try again to build a new date -->
    <xsl:variable name="new-date" select="concat($date, '-01')"/>
    <xsl:variable name="date-check-new">
      <xsl:call-template name="is-valid-iso-8601-date">
        <xsl:with-param name="text" select="$new-date" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="candidate-date">
      <xsl:choose>
        <xsl:when test="$date-check-new"><xsl:value-of select="$new-date"/></xsl:when>
        <xsl:when test="$date-check"><xsl:value-of select="$date"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$candidate-date != ''">
    "datePublished": "<xsl:value-of select="$candidate-date"/>",
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">JSON-LD</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Could not create "datePublished" property as no element/value was appropriate.</xsl:text>
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
    <xsl:variable name="date-check">
      <xsl:call-template name="is-valid-iso-8601-date">
        <xsl:with-param name="text" select="$date"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="new-date" select="concat($date, '-01')"/>
    <xsl:variable name="date-check-new">
      <xsl:call-template name="is-valid-iso-8601-date">
        <xsl:with-param name="text" select="$new-date" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="candidate-date">
      <xsl:choose>
        <xsl:when test="$date-check-new"><xsl:value-of select="$new-date"/></xsl:when>
        <xsl:when test="$date-check"><xsl:value-of select="$date"/></xsl:when>
        <xsl:otherwise/>
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

</xsl:stylesheet>
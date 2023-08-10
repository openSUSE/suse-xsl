<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:dm="urn:x-suse:ns:docmanager"
  xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl date d dm">

  <xsl:template match="d:meta[@name='productname']" mode="meta">
    <xsl:variable name="productname" select="normalize-space(string(d:productname[1]))"/>
    <xsl:value-of select="$productname"/>
  </xsl:template>


  <xsl:template match="d:meta[@name='productname']/d:productname[1]/@version" mode="meta">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="d:meta[@name='maintainer']" mode="meta">
    <xsl:variable name="content" select="normalize-space(@content)"/>

    <xsl:choose>
      <xsl:when test="$content">
        <xsl:if test="$include.html.dublincore">
          <meta name="DC.creator" content="{$content}" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">metadata</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:value-of select="concat('In meta[@name=&quot;', @name, '&quot;]')"/>
            <xsl:text> the @content attribute is empty!</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="d:meta[@name='updated']" mode="meta">
    <xsl:variable name="content" select="normalize-space(@content)"/>

    <xsl:choose>
      <xsl:when test="$content">
        <xsl:if test="$include.html.dublincore">
          <meta name="DCTERMS.modified" content="{$content}" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">metadata</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>In meta[@name='updated'], the @content attribute is empty!</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:meta[@name='category']" mode="meta">
    <xsl:variable name="content" select="normalize-space(@content)"/>

    <xsl:choose>
      <xsl:when test="$content">
        <meta name="category" content="{$content}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">metadata</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>In meta[@name='category'], the @content attribute is empty!</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="social-media-opengraph">
    <xsl:param name="node" select="."/>
    <xsl:param name="socialmedia.title"/>
    <xsl:param name="socialmedia.description"/>
    <xsl:variable name="socialmedia.preview" select="concat($canonical-url-base, '/', $socialmedia.preview.default)"/>
    <xsl:variable name="ischunk">
      <xsl:call-template name="chunk"/>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$ischunk = 1">
          <xsl:apply-templates mode="chunk-filename" select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($root.filename,$html.ext)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="canonical.url" select="concat($canonical-url-base,'/',$filename)"/>
    <xsl:variable name="meta.nodes" select="$node/d:info/d:meta|$node/ancestor::*/d:info/d:meta"/>
    <xsl:variable name="description">
      <xsl:choose>
        <xsl:when test="$meta.nodes[@name='social-descr']">
          <xsl:choose>
            <xsl:when test="string-length($meta.nodes[@name='social-descr']) &lt; $socialmedia.description.length">
              <xsl:value-of select="$meta.nodes[@name='social-descr']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='social-descr'] contains more than </xsl:text>
                  <xsl:value-of select="concat($socialmedia.description.length, ' characters!')"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:value-of select="substring(normalize-space($meta.nodes[@name = 'social-descr']), 1, $socialmedia.description.length)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$socialmedia.description">
          <xsl:choose>
            <xsl:when test="string-length($socialmedia.description) > $socialmedia.description.length">
              <xsl:call-template name="ellipsize.text">
                <xsl:with-param name="input" select="$socialmedia.description"/>
                <xsl:with-param name="ellipsize.after" select="$socialmedia.description.length"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$socialmedia.description"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log.message">
            <xsl:with-param name="level">warn</xsl:with-param>
            <xsl:with-param name="context-desc">metadata</xsl:with-param>
            <xsl:with-param name="message">
              <xsl:text>No meta[@name='social-descr'] found!</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
      <xsl:when test="$meta.nodes[@name='title']">
        <xsl:variable name="tmp" select="normalize-space($meta.nodes[@name='title'][last()])"/>
        <xsl:choose>
          <xsl:when test="$tmp = ''">
            <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='title'] is empty! Add some text.</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
          </xsl:when>
          <xsl:when test="string-length($tmp) &lt; $socialmedia.title.length">
            <xsl:value-of select="$tmp"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='title'] contains more than </xsl:text>
                  <xsl:value-of select="concat($socialmedia.title.length, ' characters!')"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="ellipsize.text">
                <xsl:with-param name="input" select="$tmp" />
                <xsl:with-param name="ellipsize.after" select="$search.title.length" />
              </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$socialmedia.title"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>

<!--    <xsl:message>social-media-opengraph:
      canonical-url-base=<xsl:value-of select="$canonical-url-base"/>
      socialmedia.preview=<xsl:value-of select="$socialmedia.preview"/>
      description=<xsl:value-of select="$description"/>
      title=<xsl:value-of select="$title"/>
    </xsl:message>
-->
    <xsl:if test="$canonical-url-base != ''">
      <!-- These Open Graph and Twitter Cards properties need a canonical URL -->
      <link rel="canonical" href="{$canonical.url}"/>
      <xsl:text>&#10;</xsl:text>
      <!-- These Open Graph and Twitter Cards properties need a canonical URL -->
      <meta property="og:url" content="{$canonical.url}"/>
      <xsl:text>&#10;</xsl:text>
      <meta property="og:image" content="{concat($canonical-url-base,'/',$socialmedia.preview)}"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="meta-generator"/>
    </xsl:if>

    <meta property="og:title" content="{$title}"/>
    <xsl:text>&#10;</xsl:text>

    <meta property="og:description" content="{$description}"/>
    <xsl:text>&#10;</xsl:text>

    <meta property="og:type" content="{$opengraph.type}"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <xsl:template name="social-media-twitter">
    <xsl:param name="node" select="."/>
    <xsl:param name="socialmedia.title"/>
    <xsl:param name="socialmedia.description"/>
    <xsl:variable name="socialmedia.preview" select="concat($canonical-url-base, '/', $socialmedia.preview.default)"/>
    <xsl:variable name="meta.nodes" select="$node/d:info/d:meta|$node/ancestor::*/d:info/d:meta"/>
    <xsl:variable name="description">
      <xsl:choose>
        <xsl:when test="$meta.nodes[@name='social-descr']">
          <xsl:choose>
            <xsl:when test="string-length($meta.nodes[@name='social-descr']) &lt; $socialmedia.description.length">
              <xsl:call-template name="trim.text">
                <xsl:with-param name="contents" select="$meta.nodes[@name = 'social-descr']" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='social-descr'] contains more than </xsl:text>
                  <xsl:value-of select="concat($socialmedia.description.length, ' characters!')"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:value-of select="normalize-space(substring($meta.nodes[@name = 'social-descr'], 1, $socialmedia.description.length))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$socialmedia.description">
          <xsl:choose>
            <xsl:when test="string-length($socialmedia.description) > $socialmedia.description.length">
              <xsl:call-template name="ellipsize.text">
                <xsl:with-param name="input">
                  <xsl:call-template name="trim.text">
                    <xsl:with-param name="contents" select="$socialmedia.description"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="ellipsize.after" select="$socialmedia.description.length"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="trim.text">
                <xsl:with-param name="contents" select="$socialmedia.description" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log.message">
            <xsl:with-param name="level">warn</xsl:with-param>
            <xsl:with-param name="context-desc">metadata</xsl:with-param>
            <xsl:with-param name="message">
              <xsl:text>No meta[@name='social-descr'] found!</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$meta.nodes[@name='title']">
          <xsl:variable name="tmp">
            <xsl:call-template name="trim.text">
            <xsl:with-param name="contents" select="$meta.nodes[@name='title'][last()]" />
          </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$tmp = ''">
              <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='title'] is empty! Add some text.</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="string-length($tmp) &lt; $search.title.length">
              <xsl:value-of select="$tmp"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="log.message">
                <xsl:with-param name="level">warn</xsl:with-param>
                <xsl:with-param name="context-desc">metadata</xsl:with-param>
                <xsl:with-param name="message">
                  <xsl:text>The meta[@name='title'] contains more than 65 characters!</xsl:text>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:call-template name="ellipsize.text">
                <xsl:with-param name="input" select="$tmp"/>
                <xsl:with-param name="ellipsize.after" select="$search.title.length"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="trim.text">
            <xsl:with-param name="contents" select="$socialmedia.title" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

  <!--<xsl:message>social-media-twitter:
      canonical-url-base=<xsl:value-of select="$canonical-url-base"/>
      socialmedia.preview=<xsl:value-of select="$socialmedia.preview"/>
      description=<xsl:value-of select="$description"/>
      title=<xsl:value-of select="$title"/>
    </xsl:message>-->

    <meta name="twitter:card" content="{$twittercards.type}"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:if test="$canonical-url-base != ''">
      <meta name="twitter:image" content="{$socialmedia.preview}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>

    <meta name="twitter:title" content="{$title}"/>
    <xsl:text>&#10;</xsl:text>

    <meta name="twitter:description" content="{$description}"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:if test="string-length($twittercards.twitter.account) &gt; 0">
      <meta name="twitter:site" content="{$twittercards.twitter.account}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
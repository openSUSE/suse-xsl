<!--

-->

<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template name="product.name">
    <!-- One can use role="abbrev" to additionally store a short version
    of the productname. This is helpful to make the best of the space
    available in the living column titles of the FO version.
    In general, we want the long/official version, though. Dito for the
    productnumber below. -->
    <xsl:param name="prefer-abbreviation" select="0"/>
    <xsl:variable name="meta.nodes" select="d:info/d:meta|ancestor::*/d:info/d:meta"/>
    
    <!--
      First we search for all productname[@role='abbrev'], starting in the nearest node followed
      by its ancestors.
    -->
    <xsl:choose>
      <xsl:when test="$meta.nodes[@name='bugtracker']/d:phrase[@name='productname'] and $prefer-abbreviation = 0">/
        <xsl:apply-templates select="$meta.nodes[@name='bugtracker']/d:phrase[@name='productname'][last()]" mode="meta"/>
      </xsl:when>
      <xsl:when test="*/d:productname[@role='abbrev'] and $prefer-abbreviation = 1">
        <xsl:apply-templates select="(*/d:productname[@role='abbrev'])[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productname[@role='abbrev'] and $prefer-abbreviation = 1">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productname[@role='abbrev'])[last()]"/>
      </xsl:when>
      <xsl:when test="$meta.nodes[@name='productname']/d:productname">
        <xsl:apply-templates select="$meta.nodes[@name='productname']/d:productname[1]" />
      </xsl:when>
      <xsl:when test="*/d:productname[not(@role='abbrev')]">
        <xsl:apply-templates select="(*/d:productname[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productname[not(@role='abbrev')]">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productname[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productname)[last()]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="product.number">
    <!-- See comment in product.name... -->
    <xsl:param name="prefer-abbreviation" select="0"/>
    <xsl:variable name="meta.nodes" select="d:info/d:meta|ancestor::*/d:info/d:meta"/>
    
    <!-- FIXME: This choose mechanism is a little wonky around inheritance and
    abbreviation preference. May need a bit more think. -->
    <xsl:choose>
      <xsl:when test="$meta.nodes[@name='productname']/d:productname/@version">
        <!-- We should probably split the version attrib value? -->
        <xsl:apply-templates select="$meta.nodes[@name='productname']/d:productname[1]/@version" />
      </xsl:when>
      <xsl:when test="$meta.nodes[@name='bugtracker']/d:phrase[@name='productnumber'] and $prefer-abbreviation = 0">
        <xsl:apply-templates select="$meta.nodes[@name='bugtracker']/d:phrase[@name='productnumber'][last()]" mode="meta"/>
      </xsl:when>
      <xsl:when test="*/d:productnumber[@role='abbrev'] and $prefer-abbreviation = 1">
        <xsl:apply-templates select="(*/d:productnumber[@role='abbrev'])[last()]"/>
      </xsl:when>
      <xsl:when test="*/d:productnumber[not(@role='abbrev')]">
        <xsl:apply-templates select="(*/d:productnumber[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:when test="*/d:productnumber">
        <xsl:apply-templates select="(*/d:productnumber)[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productnumber[@role='abbrev'] and $prefer-abbreviation = 1">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productnumber[@role='abbrev'])[last()]"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::*/*/d:productnumber[not(@role='abbrev')]">
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productnumber[not(@role='abbrev')])[last()]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="(ancestor-or-self::*/*/d:productnumber)[last()]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="version.info">
    <xsl:param name="prefaced" select="0"/>
    <xsl:param name="prefer-abbreviation" select="0"/>

    <xsl:variable name="product-name">
      <xsl:call-template name="product.name">
        <xsl:with-param name="prefer-abbreviation" select="$prefer-abbreviation"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="product-number">
      <xsl:call-template name="product.number">
        <xsl:with-param name="prefer-abbreviation" select="$prefer-abbreviation"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$prefaced = 1 and ($product-name != '' or $product-number != '')">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">version.info</xsl:with-param>
      </xsl:call-template>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:copy-of select="$product-name"/>
    <xsl:if test="$product-name != '' and $product-number != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:copy-of select="$product-number"/>
  </xsl:template>

  <xsl:template name="version.info.headline">
    <xsl:variable name="info-text">
      <xsl:call-template name="version.info">
        <xsl:with-param name="prefaced" select="0"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$generate.version.info != 0 and $info-text != ''">
      <fo:block role="big-version-info"><xsl:copy-of select="$info-text"/></fo:block>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
<?xml version="1.0"?>
<!--
  Purpose:
    Contains all parameters that are relevant to DAPS branding packages.
    Handles some parameter concatenation aspects.

  Author(s):  Stefan Knorr <sknorr@suse.de>
  Copyright:  2015, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Parameters... -->

  <xsl:param name="homepage" select="''"/>
  <xsl:param name="overview-page" select="''"/>
  <xsl:param name="overview-page-title" select="''"/>

  <xsl:param name="build.for.web" select="0"/>

  <xsl:param name="optimize.plain.text" select="0"/>

  <xsl:param name="admon.graphics" select="1"/>
  <xsl:param name="admon.style" select="''"/>


  <!-- Paths (from DAPS) -->

  <xsl:param name="styleroot" select="'UNSET'"/>
  <xsl:param name="brandingroot" select="'UNSET'"/>

  <!-- This is a bit unusual, but I wanted to handle this here without
       introducing a new template... -->
  <xsl:param name="styleroot.unset">
    <xsl:if test="$styleroot = 'UNSET' or $styleroot = ''">
      <xsl:message terminate="yes">ERROR: Styleroot is not set.</xsl:message>
    </xsl:if>
  </xsl:param>

  <!-- Postal address on the second page (can be left empty) -->
  <!-- Use \n for line breaks -->
  <xsl:param name="imprint.address.postal">Example Holdings Inc.\n1 Example Blvd\nExampletown, XSLT\nThe World</xsl:param>

  <!-- Web link on the title page (can be left empty) -->
  <xsl:param name="imprint.address.url">https://www.example.com/</xsl:param>


  <!-- Paths (generated) -->

  <!-- Make sure there is a slash at the end. DAPS usually takes care of
       this but making extra sure shouldn't hurt... -->
  <xsl:param name="styleroot-slash">
    <xsl:variable name="length" select="string-length($styleroot)"/>
    <xsl:choose>
      <!-- Obviously, forgetting the slash is not the only mistake you can make.
           You could also add superfluous spaces around your styleroot etc.
           We won't try to take care of that (for the moment). -->
      <xsl:when test="substring($styleroot, $length, $length + 1) != '/'"><xsl:value-of select="concat($styleroot, '/')"/></xsl:when>
        <!-- Only in XSLT: length + 1 and you are still within the bounds of
             the string... -->
      <xsl:otherwise><xsl:value-of select="$styleroot"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="brandingroot-slash">
    <xsl:variable name="length" select="string-length($brandingroot)"/>
    <xsl:choose>
      <xsl:when test="substring($brandingroot, $length, $length + 1) != '/'"><xsl:value-of select="concat($brandingroot, '/')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$brandingroot"/></xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Root directories for the files we reference from the output -->
  <xsl:param name="assetroot">
    <xsl:choose>
      <xsl:when test="$stylesheet.type = 'XSL-FO'">
        <xsl:choose>
          <xsl:when test="$brandingroot != 'UNSET' and $brandingroot != ''"><xsl:value-of select="$brandingroot-slash"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="concat($styleroot-slash,'branding-source/')"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$stylesheet.type = 'XHTML 1'">static/</xsl:when>
      <xsl:when test="$stylesheet.type != ''">
        <xsl:message>WARNING: Value of parameter $stylesheet.type not recognized.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>WARNING: Parameter $stylesheet.type not defined.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>


  <xsl:param name="folder.images">
    <xsl:choose>
      <xsl:when test="$stylesheet.type = 'XSL-FO' and $format.print = 1">images-grayscale/</xsl:when>
      <xsl:otherwise>images/</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="path.images" select="concat($assetroot, $folder.images)"/>

  <xsl:param name="path.images.admonition" select="concat($path.images,'admonition/')"/>
  <xsl:param name="path.images.draft" select="concat($path.images,'draft/')"/>
  <xsl:param name="path.images.logo" select="concat($path.images,'logo/')"/>
  <xsl:param name="path.images.navigation" select="concat($path.images,'navigation/')"/>

  <xsl:param name="path.css" select="concat($assetroot, 'css/')"/>
  <xsl:param name="path.js" select="concat($assetroot, 'js/')"/>

</xsl:stylesheet>

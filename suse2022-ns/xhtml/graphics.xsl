<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    A very simplified version of the process.image template that only
    serves as a makeshift measure until the $link.to.self.for.mediaobject has
    arrived upstream.

    FIXME: Remove this file when DocBook 1.79.0 comes out. (Of course, with this
    file's process.image template, the processor has far less to do, so maybe
    we should keep it..?)

   Author(s):   Stefan Knorr<sknorr@suse.de>,
                Thomas Schraitle <toms@opensuse.org>
   Copyright:   2013-2022, Stefan Knorr, Thomas Schraitle

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xtext="xalan://com.nwalsh.xalan.Text"
  xmlns:lxslt="http://xml.apache.org/xslt"
  xmlns:simg="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.ImageIntrinsics"
  xmlns:ximg="xalan://com.nwalsh.xalan.ImageIntrinsics"
  exclude-result-prefixes="xlink xtext lxslt d simg ximg xtext"
  extension-element-prefixes="xtext" version="1.0">

  <lxslt:component prefix="xtext" elements="d:insertfile"/>


<xsl:template name="process.image">
  <!-- When this template is called, the current node should be  -->
  <!-- a graphic, inlinegraphic, imagedata, or videodata. All    -->
  <!-- those elements have the same set of attributes, so we can -->
  <!-- handle them all in one place.                             -->
  <xsl:param name="tag" select="'img'"/>
  <xsl:param name="alt"/>
  <xsl:param name="longdesc"/>

  <!-- The HTML img element only supports the notion of content-area
       scaling; it doesn't support the distinction between a
       content-area and a viewport-area, so we have to make some
       compromises.

       1. If only the content-area is specified, everything is fine.
          (If you ask for a three inch image, that's what you'll get.)

       2. If only the viewport-area is provided:
          - If scalefit=1, treat it as both the content-area and
            the viewport-area. (If you ask for an image in a five inch
            area, we'll make the image five inches to fill that area.)
          - If scalefit=0, ignore the viewport-area specification.

          Note: this is not quite the right semantic and has the additional
          problem that it can result in anamorphic scaling, which scalefit
          should never cause.

       3. If both the content-area and the viewport-area is specified
          on a graphic element, ignore the viewport-area.
          (If you ask for a three inch image in a five inch area, we'll assume
           it's better to give you a three inch image in an unspecified area
           than a five inch image in a five inch area.

       Relative units also cause problems. As a general rule, the stylesheets
       are operating too early and too loosely coupled with the rendering engine
       to know things like the current font size or the actual dimensions of
       an image. Therefore:

       1. We use a fixed size for pixels, $pixels.per.inch

       2. We use a fixed size for "em"s, $points.per.em

       Percentages are problematic. In the following discussion, we speak
       of width and contentwidth, but the same issues apply to depth and
       contentdepth

       1. A width of 50% means "half of the available space for the image."
          That's fine. But note that in HTML, this is a dynamic property and
          the image size will vary if the browser window is resized.

       2. A contentwidth of 50% means "half of the actual image width". But
          the stylesheets have no way to assess the image's actual size. Treating
          this as a width of 50% is one possibility, but it produces behavior
          (dynamic scaling) that seems entirely out of character with the
          meaning.

          Instead, the stylesheets define a $nominal.image.width
          and convert percentages to actual values based on that nominal size.

       Scale can be problematic. Scale applies to the contentwidth, so
       a scale of 50 when a contentwidth is not specified is analagous to a
       width of 50%. (If a contentwidth is specified, the scaling factor can
       be applied to that value and no problem exists.)

       If scale is specified but contentwidth is not supplied, the
       nominal.image.width is used to calculate a base size
       for scaling.

       Warning: as a consequence of these decisions, unless the aspect ratio
       of your image happens to be exactly the same as (nominal width / nominal height),
       specifying contentwidth="50%" and contentdepth="50%" is NOT going to
       scale the way you expect (or really, the way it should).

       Don't do that. In fact, a percentage value is not recommended for content
       size at all. Use scale instead.

       Finally, align and valign are troublesome. Horizontal alignment is now
       supported by wrapping the image in a <div align="{@align}"> (in block
       contexts!). I can't think of anything (practical) to do about vertical
       alignment.
  -->

  <xsl:variable name="width-units">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="@width">
        <xsl:call-template name="length-units">
          <xsl:with-param name="length" select="@width"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(@depth) and $default.image.width != ''">
        <xsl:call-template name="length-units">
          <xsl:with-param name="length" select="$default.image.width"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="@width">
        <xsl:choose>
          <xsl:when test="$width-units = '%'">
            <xsl:value-of select="@width"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@width"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="not(@depth) and $default.image.width != ''">
        <xsl:value-of select="$default.image.width"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scalefit">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="@contentwidth or @contentdepth">0</xsl:when>
      <xsl:when test="@scale">0</xsl:when>
      <xsl:when test="@scalefit"><xsl:value-of select="@scalefit"/></xsl:when>
      <xsl:when test="$width != '' or @depth">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scale">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">1.0</xsl:when>
      <xsl:when test="@contentwidth or @contentdepth">1.0</xsl:when>
      <xsl:when test="@scale">
        <xsl:value-of select="@scale div 100.0"/>
      </xsl:when>
      <xsl:otherwise>1.0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'graphic'
                      or local-name(.) = 'inlinegraphic'">
        <!-- handle legacy graphic and inlinegraphic by new template --> 
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- imagedata, videodata, audiodata -->
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="img.src.path.pi">
    <xsl:call-template name="pi.dbhtml_img.src.path">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <!-- is the file path relative and can be modified by img.src.path? -->
  <xsl:variable name="is.relative">
    <xsl:choose>
      <xsl:when test="$img.src.path != '' and
                      $tag = 'img' and
                      not(starts-with($filename, '/')) and
                      not(starts-with($filename, 'file:/')) and
                      not(contains($filename, '://'))">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="filename.for.graphicsize">
    <xsl:choose>
      <xsl:when test="$img.src.path.pi != ''">
        <xsl:value-of select="concat($img.src.path.pi, $filename)"/>
      </xsl:when>
      <xsl:when test="$is.relative = 1 and
                      $graphicsize.use.img.src.path != 0">
        <xsl:value-of select="concat($img.src.path, $filename)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="realintrinsicwidth">
    <!-- This funny compound test works around a bug in XSLTC -->
    <xsl:choose>
      <xsl:when test="$use.extensions != 0 and $graphicsize.extension != 0
                      and not(@format='SVG')">
        <xsl:choose>
          <xsl:when test="function-available('simg:getWidth')">
            <xsl:value-of select="simg:getWidth(simg:new($filename.for.graphicsize),
                                                $nominal.image.width)"/>
          </xsl:when>
          <xsl:when test="function-available('ximg:getWidth')">
            <xsl:value-of select="ximg:getWidth(ximg:new($filename.for.graphicsize),
                                                $nominal.image.width)"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="intrinsicwidth">
    <xsl:choose>
      <xsl:when test="$realintrinsicwidth = 0">
       <xsl:value-of select="$nominal.image.width"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$realintrinsicwidth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="intrinsicdepth">
    <!-- This funny compound test works around a bug in XSLTC -->
    <xsl:choose>
      <xsl:when test="$use.extensions != 0 and $graphicsize.extension != 0
                      and not(@format='SVG')">
        <xsl:choose>
          <xsl:when test="function-available('simg:getDepth')">
            <xsl:value-of select="simg:getDepth(simg:new($filename.for.graphicsize),
                                                $nominal.image.depth)"/>
          </xsl:when>
          <xsl:when test="function-available('ximg:getDepth')">
            <xsl:value-of select="ximg:getDepth(ximg:new($filename.for.graphicsize),
                                                $nominal.image.depth)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$nominal.image.depth"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nominal.image.depth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="contentwidth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="@contentwidth">
        <xsl:variable name="units">
          <xsl:call-template name="length-units">
            <xsl:with-param name="length" select="@contentwidth"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$units = '%'">
            <xsl:variable name="cmagnitude">
              <xsl:call-template name="length-magnitude">
                <xsl:with-param name="length" select="@contentwidth"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$intrinsicwidth * $cmagnitude div 100.0"/>
            <xsl:text>px</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@contentwidth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$intrinsicwidth"/>
        <xsl:text>px</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scaled.contentwidth">
    <xsl:if test="$contentwidth != ''">
      <xsl:variable name="cwidth.in.points">
        <xsl:call-template name="length-in-points">
          <xsl:with-param name="length" select="$contentwidth"/>
          <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
          <xsl:with-param name="em.size" select="$points.per.em"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="round($cwidth.in.points div 72.0 * $pixels.per.inch * $scale)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="html.width">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="$width-units = '%'">
        <xsl:value-of select="$width"/>
      </xsl:when>
      <xsl:when test="$width != ''">
        <xsl:variable name="width.in.points">
          <xsl:call-template name="length-in-points">
            <xsl:with-param name="length" select="$width"/>
            <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
            <xsl:with-param name="em.size" select="$points.per.em"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="round($width.in.points div 72.0 * $pixels.per.inch)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="contentdepth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="@contentdepth">
        <xsl:variable name="units">
          <xsl:call-template name="length-units">
            <xsl:with-param name="length" select="@contentdepth"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$units = '%'">
            <xsl:variable name="cmagnitude">
              <xsl:call-template name="length-magnitude">
                <xsl:with-param name="length" select="@contentdepth"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$intrinsicdepth * $cmagnitude div 100.0"/>
            <xsl:text>px</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@contentdepth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$intrinsicdepth"/>
        <xsl:text>px</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scaled.contentdepth">
    <xsl:if test="$contentdepth != ''">
      <xsl:variable name="cdepth.in.points">
        <xsl:call-template name="length-in-points">
          <xsl:with-param name="length" select="$contentdepth"/>
          <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
          <xsl:with-param name="em.size" select="$points.per.em"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="round($cdepth.in.points div 72.0 * $pixels.per.inch * $scale)"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="depth-units">
    <xsl:if test="@depth">
      <xsl:call-template name="length-units">
        <xsl:with-param name="length" select="@depth"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="depth">
    <xsl:if test="@depth">
      <xsl:choose>
        <xsl:when test="$depth-units = '%'">
          <xsl:value-of select="@depth"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="length-spec">
            <xsl:with-param name="length" select="@depth"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="html.depth">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0"></xsl:when>
      <xsl:when test="$depth-units = '%'">
        <xsl:value-of select="$depth"/>
      </xsl:when>
      <xsl:when test="@depth and @depth != ''">
        <xsl:variable name="depth.in.points">
          <xsl:call-template name="length-in-points">
            <xsl:with-param name="length" select="$depth"/>
            <xsl:with-param name="pixels.per.inch" select="$pixels.per.inch"/>
            <xsl:with-param name="em.size" select="$points.per.em"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="round($depth.in.points div 72.0 * $pixels.per.inch)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="viewport">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="local-name(.) = 'inlinegraphic'
                      or ancestor::inlinemediaobject
                      or ancestor::inlineequation">0</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$make.graphic.viewport"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


<!--  <xsl:message>=====================================
  filename: <xsl:value-of select="$filename"/>
  current element: <xsl:value-of select="name(.)"/> / <xsl:call-template name="xpath.location"/>
  alt: <xsl:value-of select="$alt"/>
  scale: <xsl:value-of select="$scale"/>, <xsl:value-of select="$scalefit"/>
  @contentwidth <xsl:value-of select="@contentwidth"/>
  $contentwidth <xsl:value-of select="$contentwidth"/>
  scaled.contentwidth: <xsl:value-of select="$scaled.contentwidth"/>
  @width: <xsl:value-of select="@width"/>
  width: <xsl:value-of select="$width"/>
  html.width: <xsl:value-of select="$html.width"/>
  @contentdepth <xsl:value-of select="@contentdepth"/>
  $contentdepth <xsl:value-of select="$contentdepth"/>
  scaled.contentdepth: <xsl:value-of select="$scaled.contentdepth"/>
  @depth: <xsl:value-of select="@depth"/>
  depth: <xsl:value-of select="$depth"/>
  html.depth: <xsl:value-of select="$html.depth"/>
  align: <xsl:value-of select="@align"/>
  valign: <xsl:value-of select="@valign"/></xsl:message>

-->
  <xsl:variable name="scaled"
              select="@width|@depth|@contentwidth|@contentdepth
                        |@scale|@scalefit"/>

  <xsl:variable name="img">
    <!-- We don't distinguish between SVG and bitmap anymore.
    -->
      <xsl:variable name="src">
        <xsl:choose>
          <xsl:when test="$is.relative = 1">
            <xsl:value-of select="$img.src.path" />
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$filename" />
      </xsl:variable>
      <xsl:variable name="imgcontents">
        <xsl:element name="{$tag}">
          <xsl:if test="$tag = 'img' and ../../self::imageobjectco">
            <xsl:variable name="mapname">
              <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="../../areaspec" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$scaled">
                <!-- It might be possible to handle some scaling; needs -->
                <!-- more investigation -->
                <xsl:message>
                  <xsl:text>Warning: imagemaps not supported </xsl:text>
                  <xsl:text>on scaled images</xsl:text>
                </xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="border">0</xsl:attribute>
                <xsl:attribute name="usemap">
                  <xsl:value-of select="concat('#', $mapname)" />
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>

          <xsl:attribute name="src">
            <xsl:value-of select="$src" />
          </xsl:attribute>

          <xsl:if test="@align">
            <xsl:attribute name="align">
              <xsl:choose>
                <xsl:when test="@align = 'center'">middle</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@align" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>

          <xsl:call-template name="process.image.attributes">
            <xsl:with-param name="alt">
              <xsl:choose>
                <xsl:when test="$alt != ''">
                  <xsl:copy-of select="$alt" />
                </xsl:when>
                <xsl:when test="ancestor::d:figure">
                  <xsl:variable name="fig.title">
                    <xsl:apply-templates select="ancestor::figure/title/node()"
                     />
                  </xsl:variable>
                  <xsl:value-of select="normalize-space($fig.title)" />
                </xsl:when>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="html.depth" select="$html.depth" />
            <xsl:with-param name="html.width" select="$html.width" />
            <xsl:with-param name="longdesc" select="$longdesc" />
            <xsl:with-param name="scale" select="$scale" />
            <xsl:with-param name="scalefit" select="$scalefit" />
            <xsl:with-param name="scaled.contentdepth"
              select="$scaled.contentdepth" />
            <xsl:with-param name="scaled.contentwidth"
              select="$scaled.contentwidth" />
            <xsl:with-param name="viewport" select="$viewport" />
          </xsl:call-template>
        </xsl:element>
      </xsl:variable>

        <xsl:choose>
          <xsl:when test="$link.to.self.for.mediaobject = 0">
            <xsl:copy-of select="$imgcontents"/>
          </xsl:when>
          <xsl:otherwise>
            <a href="{$src}">
              <xsl:copy-of select="$imgcontents"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
  </xsl:variable>

  <xsl:variable name="bgcolor">
    <xsl:call-template name="pi.dbhtml_background-color">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="use.viewport"
                select="$viewport != 0
                        and ($html.width != ''
                             or ($html.depth != '' and $depth-units != '%')
                             or $bgcolor != ''
                             or @valign)"/>

  <xsl:choose>
    <xsl:when test="$use.viewport">
      <table border="{$table.border.off}">
        <xsl:if test="$div.element != 'section'">
          <xsl:attribute name="summary">manufactured viewport for HTML img</xsl:attribute>
        </xsl:if>
        <xsl:if test="$css.decoration != ''">
          <xsl:attribute name="style">cellpadding: 0; cellspacing: 0;</xsl:attribute>
        </xsl:if>
        <xsl:if test="$html.width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="$html.width"/>
          </xsl:attribute>
        </xsl:if>
        <tr>
          <xsl:if test="$html.depth != '' and $depth-units != '%'">
            <!-- don't do this for percentages because browsers get confused -->
            <xsl:choose>
              <xsl:when test="$css.decoration != 0">
                <xsl:attribute name="style">
                  <xsl:text>height: </xsl:text>
                  <xsl:value-of select="$html.depth"/>
                  <xsl:text>px</xsl:text>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="height">
                  <xsl:value-of select="$html.depth"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <td>
            <xsl:if test="$bgcolor != ''">
              <xsl:choose>
                <xsl:when test="$css.decoration != 0">
                  <xsl:attribute name="style">
                    <xsl:text>background-color: </xsl:text>
                    <xsl:value-of select="$bgcolor"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="bgcolor">
                    <xsl:value-of select="$bgcolor"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:if test="@align">
              <xsl:attribute name="align">
                <xsl:value-of select="@align"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@valign">
              <xsl:attribute name="valign">
                <xsl:value-of select="@valign"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$img"/>
          </td>
        </tr>
      </table>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$img"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="$tag = 'img' and ../../self::imageobjectco and not($scaled)">
    <xsl:variable name="mapname">
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="../../areaspec"/>
      </xsl:call-template>
    </xsl:variable>

    <map name="{$mapname}">
      <xsl:for-each select="../../areaspec//area">
        <xsl:variable name="units">
          <xsl:choose>
            <xsl:when test="@units = 'other' and @otherunits">
              <xsl:value-of select="@otherunits"/>
            </xsl:when>
            <xsl:when test="@units">
              <xsl:value-of select="@units"/>
            </xsl:when>
            <!-- areaspec|areaset/area -->
            <xsl:when test="../@units = 'other' and ../@otherunits">
              <xsl:value-of select="../@otherunits"/>
            </xsl:when>
            <xsl:when test="../@units">
              <xsl:value-of select="../@units"/>
            </xsl:when>
            <!-- areaspec/areaset/area -->
            <xsl:when test="../../@units = 'other' and ../../@otherunits">
              <xsl:value-of select="../@otherunits"/>
            </xsl:when>
            <xsl:when test="../../@units">
              <xsl:value-of select="../../@units"/>
            </xsl:when>
            <xsl:otherwise>calspair</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
 
        <xsl:choose>
          <xsl:when test="$units = 'calspair' or
                          $units = 'imagemap'">
            <xsl:variable name="coords" select="normalize-space(@coords)"/>

            <area shape="rect">
              <xsl:variable name="linkends">
                <xsl:choose>
                  <xsl:when test="@linkends">
                    <xsl:value-of select="normalize-space(@linkends)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="normalize-space(../@linkends)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
 
              <xsl:variable name="href">
                <xsl:choose>
                  <xsl:when test="@xlink:href">
                    <xsl:value-of select="@xlink:href"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="../@xlink:href"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
 
              <xsl:choose>
                <xsl:when test="$linkends != ''">
                  <xsl:variable name="linkend">
                    <xsl:choose>
                      <xsl:when test="contains($linkends, ' ')">
                        <xsl:value-of select="substring-before($linkends, ' ')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$linkends"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  
                  <xsl:variable name="target" select="key('id', $linkend)[1]"/>
                 
                  <xsl:if test="$target">
                    <xsl:attribute name="href">
                      <xsl:call-template name="href.target">
                        <xsl:with-param name="object" select="$target"/>
                      </xsl:call-template>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="$href != ''">
                  <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                  </xsl:attribute>
                </xsl:when>
              </xsl:choose>
 
              <xsl:if test="alt">
                <xsl:attribute name="alt">
                  <xsl:value-of select="alt[1]"/>
                </xsl:attribute>
              </xsl:if>
 
              <xsl:attribute name="coords">
                <xsl:choose>
                  <xsl:when test="$units = 'calspair'">

                    <xsl:variable name="p1"
                                select="substring-before($coords, ' ')"/>
                    <xsl:variable name="p2"
                                select="substring-after($coords, ' ')"/>
         
                    <xsl:variable name="x1" select="substring-before($p1,',')"/>
                    <xsl:variable name="y1" select="substring-after($p1,',')"/>
                    <xsl:variable name="x2" select="substring-before($p2,',')"/>
                    <xsl:variable name="y2" select="substring-after($p2,',')"/>
         
                    <xsl:variable name="x1p" select="$x1 div 100.0"/>
                    <xsl:variable name="y1p" select="$y1 div 100.0"/>
                    <xsl:variable name="x2p" select="$x2 div 100.0"/>
                    <xsl:variable name="y2p" select="$y2 div 100.0"/>
         
         <!--
                    <xsl:message>
                      <xsl:text>units: </xsl:text>
                      <xsl:value-of select="$units"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="$x1p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$y1p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$x2p"/><xsl:text>, </xsl:text>
                      <xsl:value-of select="$y2p"/><xsl:text>, </xsl:text>
                    </xsl:message>
         
                    <xsl:message>
                      <xsl:text>      </xsl:text>
                      <xsl:value-of select="$intrinsicwidth"/>
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="$intrinsicdepth"/>
                    </xsl:message>
         
                    <xsl:message>
                      <xsl:text>      </xsl:text>
                      <xsl:value-of select="$units"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of 
                            select="round($x1p * $intrinsicwidth div 100.0)"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($intrinsicdepth
                                       - ($y2p * $intrinsicdepth div 100.0))"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($x2p * 
                                            $intrinsicwidth div 100.0)"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="round($intrinsicdepth
                                       - ($y1p * $intrinsicdepth div 100.0))"/>
                    </xsl:message>
         -->
                    <xsl:value-of 
                             select="round($x1p * $intrinsicwidth div 100.0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="round($intrinsicdepth
                                        - ($y2p * $intrinsicdepth div 100.0))"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of 
                             select="round($x2p * $intrinsicwidth div 100.0)"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="round($intrinsicdepth
                                      - ($y1p * $intrinsicdepth div 100.0))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$coords"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </area>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Warning: only calspair or </xsl:text>
              <xsl:text>otherunits='imagemap' supported </xsl:text>
              <xsl:text>in imageobjectco</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </map>
  </xsl:if>
</xsl:template>

<xsl:template name="process.image.attributes">
  <xsl:param name="alt"/>
  <xsl:param name="html.width"/>
  <xsl:param name="html.depth"/>
  <xsl:param name="longdesc"/>
  <xsl:param name="scale"/>
  <xsl:param name="scalefit"/>
  <xsl:param name="scaled.contentdepth"/>
  <xsl:param name="scaled.contentwidth"/>
  <xsl:param name="viewport"/>

  <xsl:choose>
    <xsl:when test="@contentwidth or @contentdepth">
      <!-- ignore @width/@depth, @scale, and @scalefit if specified -->
      <xsl:if test="@contentwidth and $scaled.contentwidth != ''">
        <xsl:attribute name="width">
          <xsl:value-of select="$scaled.contentwidth"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@contentdepth and $scaled.contentdepth != ''">
        <xsl:attribute name="height">
          <xsl:value-of select="$scaled.contentdepth"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:when>

    <xsl:when test="number($scale) != 1.0">
      <!-- scaling is always uniform, so we only have to specify one dimension -->
      <!-- ignore @scalefit if specified -->
      <xsl:attribute name="width">
        <xsl:value-of select="$scaled.contentwidth"/>
      </xsl:attribute>
    </xsl:when>

    <xsl:when test="$scalefit != 0">
      <xsl:choose>
        <xsl:when test="contains($html.width, '%')">
          <xsl:choose>
            <xsl:when test="$viewport != 0">
              <!-- The *viewport* will be scaled, so use 100% here! -->
              <xsl:attribute name="width">
                <xsl:value-of select="'100%'"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="width">
                <xsl:value-of select="$html.width"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:when test="contains($html.depth, '%')">
          <!-- HTML doesn't deal with this case very well...do nothing -->
        </xsl:when>

        <xsl:when test="$scaled.contentwidth != '' and $html.width != ''
                        and $scaled.contentdepth != '' and $html.depth != ''">
          <!-- scalefit should not be anamorphic; figure out which direction -->
          <!-- has the limiting scale factor and scale in that direction -->
          <xsl:choose>
            <xsl:when test="$html.width div $scaled.contentwidth &gt;
                            $html.depth div $scaled.contentdepth">
              <xsl:attribute name="height">
                <xsl:value-of select="$html.depth"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="width">
                <xsl:value-of select="$html.width"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:when test="$scaled.contentwidth != '' and $html.width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="$html.width"/>
          </xsl:attribute>
        </xsl:when>

        <xsl:when test="$scaled.contentdepth != '' and $html.depth != ''">
          <xsl:attribute name="height">
            <xsl:value-of select="$html.depth"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>

  <xsl:variable name="alt.candidate">
    <xsl:choose>
      <!-- Try other first -->
      <xsl:when test="../../d:textobject/d:phrase">
          <xsl:apply-templates select="../../d:textobject/d:phrase/node()"/>
      </xsl:when>
      <xsl:when test="../../../d:caption[d:para]">
        <xsl:apply-templates select="../../../d:caption/d:para[1]"/>
      </xsl:when>
      <xsl:when test="ancestor::d:figure/d:title and normalize-space(string(ancestor::d:figure/d:title)) != ''">
        <xsl:value-of select="ancestor::d:figure/d:title"/>
      </xsl:when>
      <xsl:when test="ancestor::d:figure/d:title and normalize-space(string(ancestor::d:figure/d:title)) = ''">
        <!-- Edge cases where we have a <title>, but it's emmpty :-( -->
        <xsl:variable name="div"
          select="(ancestor::d:sect5 | ancestor::d:sect4 | ancestor::d:sect3 | ancestor::d:sect2 | ancestor::d:sect1 |
                   ancestor::d:section |
                   ancestor::d:chapter | ancestor::d:appendix | ancestor::d:glossary | ancestor::d:preface |
                   ancestor::d:part | ancestor::d:book)[last()]"/>
        <xsl:variable name="candidate-title" select="($div/d:title | $div/d:info/d:title)[last()]"/>
        <xsl:variable name="image-number">
          <xsl:number count="d:figure"
            from="d:appendix | d:article | d:glossary | d:preface | d:chapter | d:sect1 | d:sect2 | d:sect3 | d:section"
            level="any" format="1" />
        </xsl:variable>
        <xsl:value-of select="concat('#',  $image-number, ': ', $candidate-title)"/>
      </xsl:when>
      <xsl:when test="$alt != ''">
        <xsl:value-of select="$alt"/>
      </xsl:when>
      <xsl:when test="ancestor::d:informalfigure">
        <xsl:variable name="candidate-title"
          select="(ancestor::*[d:title][1]/d:title | ancestor::*[d:info/d:title][1]/d:info/d:title)[last()]"/>
        <xsl:variable name="image-number"
          select="count(ancestor::d:informalfigure/preceding-sibling::d:informalfigure) + 1"/>
        <xsl:value-of select="concat('#',  $image-number, ': ', $candidate-title)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="div"
          select="(ancestor::d:sect5 | ancestor::d:sect4 | ancestor::d:sect3 | ancestor::d:sect2 | ancestor::d:sect1 |
                   ancestor::d:section |
                   ancestor::d:chapter | ancestor::d:appendix | ancestor::d:glossary | ancestor::d:preface |
                   ancestor::d:part | ancestor::d:book)[last()]"/>
        <xsl:variable name="candidate-title" select="($div/d:title | $div/d:info/d:title)[last()]"/>
        <xsl:value-of select="$candidate-title"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Issue #474: support alt/title attributes in images -->
  <xsl:attribute name="alt">
    <xsl:value-of select="normalize-space($alt.candidate)"/>
  </xsl:attribute>
  <!-- If we have an alt, use title as well. -->
  <xsl:attribute name="title">
    <xsl:value-of select="normalize-space($alt.candidate)"/>
  </xsl:attribute>

  <!-- Turn off longdesc attribute since not supported by browsers
  <xsl:if test="$longdesc != ''">
    <xsl:attribute name="longdesc">
      <xsl:value-of select="$longdesc"/>
    </xsl:attribute>
  </xsl:if>
  -->

  <xsl:if test="@align and $viewport = 0">
    <xsl:attribute name="align">
      <xsl:choose>
        <xsl:when test="@align = 'center'">middle</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@align"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:if>

  <xsl:call-template name="extension.process.image.attributes"/>
</xsl:template>

</xsl:stylesheet>

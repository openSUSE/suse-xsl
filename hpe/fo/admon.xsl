<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Re-Style admonitions

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
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="date">


<xsl:template match="note|important|warning|caution|tip">
  <xsl:call-template name="graphical.admonition"/>
</xsl:template>

<xsl:template name="admon.symbol">
  <xsl:param name="color" select="'&dark-green;'"/>
  <xsl:param name="node" select="."/>

  <!-- Hierarchy of admonition symbols:
  https://en.wikipedia.org/wiki/Precautionary_statement
  DocBook (currently) does not support "danger," but on the other hand has
  both "note" and "tip" at the lowest end. -->
  <svg:svg width="36" height="36">
    <svg:g>
      <xsl:if test="$writing.mode = 'rl'">
        <xsl:attribute name="transform">matrix(-1,0,0,1,36,0)</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="local-name($node)='warning'">
            <svg:path d="M 17.990234 1.2832031 L 17.574219 1.4726562 C 13.91211 3.1489262 9.7968746 4.0351562 5.6875 4.0351562 C 4.669924 4.0351562 4.6689444 4.0351562 4.6464844 9.1542969 L 4.6328125 13.279297 C 4.6280815 14.296681 4.6441056 15.407827 4.7285156 16.447266 C 5.4530026 24.104615 10.056947 30.525696 17.558594 34.275391 L 17.990234 34.498047 L 17.992188 34.5 L 17.992188 34.498047 L 18.423828 34.275391 C 25.925475 30.525696 30.529419 24.104615 31.253906 16.447266 C 31.338316 15.407827 31.35434 14.296681 31.349609 13.279297 L 31.335938 9.1542969 C 31.313477 4.0351564 31.3125 4.0351563 30.294922 4.0351562 C 26.185547 4.0351562 22.070312 3.1489259 18.408203 1.4726562 L 17.992188 1.2832031 L 17.990234 1.2832031 z M 17.990234 3.4765625 C 17.990785 3.4768041 17.991637 3.4763209 17.992188 3.4765625 C 21.512262 5.0215206 25.405885 5.8945508 29.316406 6.0195312 C 29.332036 7.6298828 29.343749 11.011718 29.349609 13.283203 C 29.355909 14.416537 29.320809 15.535962 29.216797 16.712891 C 28.434511 23.317289 24.43453 28.879926 17.992188 32.257812 C 17.991679 32.257546 17.990743 32.258079 17.990234 32.257812 C 11.547892 28.879926 7.5479113 23.317289 6.765625 16.712891 C 6.6616134 15.535962 6.6265125 14.416537 6.6328125 13.283203 C 6.6386725 11.011718 6.6503856 7.6298829 6.6660156 6.0195312 C 10.576537 5.8945508 14.47016 5.0215211 17.990234 3.4765625 z"
              fill="{$color}"/>
        </xsl:when>
        <xsl:when test="local-name($node)='tip'">
            <svg:path d="M 18 0 C 11.145508 0 5.5683594 5.5761714 5.5683594 12.429688 C 5.5683594 17.951171 8.8588865 20.964844 10.439453 22.414062 C 10.687011 22.640625 10.966309 22.899414 11.044922 23.003906 C 11.622559 23.774414 12.362793 24.995117 12.554688 27 L 13 27 L 14.560547 27 L 21.439453 27 L 23 27 L 23.445312 27 C 23.637695 24.99707 24.37793 23.777343 24.957031 23.003906 C 25.035161 22.898437 25.314453 22.639648 25.5625 22.412109 C 27.142578 20.956055 30.429688 17.925293 30.429688 12.429688 C 30.429688 5.5761724 24.854492 0 18 0 z M 18 2 C 23.751953 2 28.429688 6.6787104 28.429688 12.429688 C 28.429688 17.048828 25.682617 19.581055 24.207031 20.941406 C 23.821289 21.295898 23.541993 21.552734 23.353516 21.804688 C 22.625977 22.777344 22.128906 23.84375 21.808594 25 L 14.191406 25 C 13.87207 23.842773 13.374024 22.775391 12.646484 21.804688 C 12.456543 21.550781 12.177735 21.295898 11.791016 20.941406 C 10.315431 19.588867 7.5703125 17.071289 7.5703125 12.429688 C 7.5703124 6.6787104 12.248535 2 18 2 z M 19.5625 3.7519531 C 19.222977 3.7270965 18.883057 3.876831 18.675781 4.1679688 L 11.228516 14.59375 C 11.010746 14.898438 10.98291 15.297851 11.154297 15.630859 C 11.325683 15.963866 11.668457 16.173828 12.042969 16.173828 L 16.753906 16.173828 L 15.535156 21.658203 C 15.432129 22.12207 15.669434 22.595703 16.103516 22.789062 C 16.234863 22.847652 16.373047 22.875 16.509766 22.875 C 16.824707 22.875 17.131836 22.726562 17.324219 22.457031 L 24.771484 12.033203 C 24.989256 11.728515 25.016602 11.327149 24.845703 10.994141 C 24.673828 10.661134 24.332031 10.451172 23.957031 10.451172 L 19.246094 10.451172 L 20.464844 4.9667969 C 20.567383 4.5029297 20.331055 4.03125 19.896484 3.8378906 C 19.788086 3.7894287 19.675674 3.7602387 19.5625 3.7519531 z M 17.447266 9.328125 L 17.023438 11.234375 C 16.95752 11.530273 17.031249 11.839844 17.220703 12.076172 C 17.410644 12.312988 17.696777 12.451172 18 12.451172 L 22.013672 12.451172 L 18.552734 17.294922 L 18.976562 15.390625 C 19.04248 15.094726 18.96875 14.785156 18.779297 14.548828 C 18.589356 14.312011 18.303223 14.173828 18 14.173828 L 13.986328 14.173828 L 17.447266 9.328125 z M 12.730469 29 L 12.730469 31 L 23.230469 31 L 23.230469 29 L 12.730469 29 z M 14.417969 33 C 14.716797 34.701172 16.194336 36 17.980469 36 C 19.765625 36 21.244141 34.701172 21.541016 33 L 19.478516 33 C 19.234375 33.587891 18.654297 34 17.980469 34 C 17.304688 34 16.726563 33.587891 16.480469 33 L 14.417969 33 z"
              fill="{$color}"/>
        </xsl:when>
        <!-- The symbol for these two is currently the same, however,
        important is orange &amp; caution is red. -->
        <xsl:when test="local-name($node)='important' or local-name($node)='caution'">
            <svg:path d="M 19,7.2988281 19,5.815918 C 20.161133,5.4013672 21,4.3017578 21,3 21,1.3457031 19.654297,0 18,0 c -1.654297,0 -3,1.3457031 -3,3 0,1.3017578 0.838379,2.4013672 2,2.8154297 l 0,1.4833984 C 10.29834,7.8125 5,13.416992 5,20.248047 l 0,9.96875 0.6835938,0.227539 c 1.953125,0.651367 3.9467773,1.143555 5.9663082,1.476562 C 12.773438,34.371094 15.231445,36 18,36 c 2.768555,0 5.226562,-1.628906 6.350586,-4.079102 2.019531,-0.333007 4.012695,-0.825195 5.96582,-1.476562 L 31,30.216797 31,20.248047 C 31,13.416992 25.701172,7.8125 19,7.2988281 Z M 18,2 c 0.551269,0 1,0.4487305 1,1 0,0.5512695 -0.448731,1 -1,1 -0.55127,0 -1,-0.4487305 -1,-1 0,-0.5512695 0.44873,-1 1,-1 z m 0,7.2480469 c 6.06543,0 11,4.9345701 11,11.0000001 l 0,4.564453 c -7.123047,2.219727 -14.877441,2.21875 -22,0 L 7,20.248047 C 7,14.182617 11.93457,9.2480469 18,9.2480469 Z M 18,34 c -1.492188,0 -2.851562,-0.669922 -3.777344,-1.74707 1.25293,0.12207 2.512207,0.190429 3.777344,0.190429 1.265625,0 2.524414,-0.06836 3.777344,-0.190429 C 20.851562,33.330078 19.492187,34 18,34 Z M 7,28.767578 7,26.90625 c 3.572266,1.048828 7.286133,1.577148 11,1.577148 3.714844,0 7.427734,-0.52832 11,-1.577148 l 0,1.861328 c -7.12793,2.224609 -14.871582,2.224609 -22,0 z"
              fill="{$color}"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- It's a note. (Or something undefined.) -->
            <svg:path d="M 18 6.2011719 L 0.19921875 13.005859 L 3.9628906 14.445312 L 3.9628906 22.970703 L 0.3359375 29.798828 L 9.5898438 29.798828 L 5.9628906 22.976562 L 5.9628906 15.208984 L 7.3007812 15.720703 L 7.3007812 22.333984 L 7.71875 22.632812 C 10.535157 24.645507 14.283203 25.798828 18 25.798828 C 21.716797 25.798828 25.464844 24.645508 28.28125 22.632812 L 28.699219 22.333984 L 28.699219 15.71875 L 35.800781 13.005859 L 18 6.2011719 z M 18 8.3417969 L 30.199219 13.005859 L 18 17.667969 L 5.8007812 13.005859 L 18 8.3417969 z M 9.3007812 16.484375 L 18 19.808594 L 26.699219 16.484375 L 26.699219 21.291016 C 24.289063 22.867188 21.079102 23.798828 18 23.798828 C 14.920898 23.798828 11.710449 22.867188 9.3007812 21.291016 L 9.3007812 16.484375 z M 4.9609375 25.353516 L 6.2617188 27.798828 L 3.6640625 27.798828 L 4.9609375 25.353516 z"
              fill="{$color}"/>
        </xsl:otherwise>
      </xsl:choose>
    </svg:g>
  </svg:svg>
</xsl:template>

<xsl:template name="admon.symbol.color">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="$format.print = 1">
      <xsl:text>&darker-gray;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="local-name($node)='warning' or
                        local-name($node)='caution'">
          <!-- The symbol for these two is currently the same -->
          <xsl:text>&dark-blood;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='tip'">
          <xsl:text>&navy-green;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='important'">
          <xsl:text>&mid-orange;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- It's a note. (Or something undefined.) -->
          <xsl:text>&dark-plum;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="compact.or.normal.block">
 <xsl:variable name="color">
  <xsl:call-template name="admon.symbol.color"/>
 </xsl:variable>
 <fo:block>
  <xsl:attribute name="color">
   <xsl:choose>
    <xsl:when test="not(@role = 'compact')">
     <xsl:value-of select="$color"/>
    </xsl:when>
    <xsl:otherwise>&darker-gray;</xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <xsl:value-of select="@role"/>
  <xsl:apply-templates select="." mode="object.title.markup">
   <xsl:with-param name="allow-anchors" select="1"/>
  </xsl:apply-templates>
 </fo:block>
</xsl:template>

<xsl:template name="graphical.admonition">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="color">
   <xsl:call-template name="admon.symbol.color"/>
  </xsl:variable>
  <xsl:variable name="graphic.width">
    <xsl:choose>
      <xsl:when test="@role='compact'">5</xsl:when>
      <xsl:otherwise>8</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="padding">
    <xsl:choose>
      <xsl:when test="@role='compact'">0.7mm</xsl:when>
      <xsl:otherwise>3mm</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:block id="{$id}" xsl:use-attribute-sets="graphical.admonition.properties">
    <fo:list-block
      provisional-distance-between-starts="{&columnfragment; + &gutterfragment;}mm"
      provisional-label-separation="&gutter;mm">
      <fo:list-item>
          <fo:list-item-label end-indent="label-end()">
            <fo:block text-align="start" padding-before="1.2mm" padding-after="1.2mm">
              <fo:instream-foreign-object content-width="{$graphic.width}mm">
                <xsl:call-template name="admon.symbol">
                  <xsl:with-param name="color" select="$color"/>
                </xsl:call-template>
              </fo:instream-foreign-object>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()">
            <fo:block padding-start="{(&gutter; - 0.75) div 2}mm"
              padding-before="{$padding}" padding-after="{$padding}">
              <xsl:if test="((title or info/title) or ($admon.textlabel != 0 and not(@role='compact')))">
                <xsl:choose>
                 <xsl:when test="@role='compact'">
                  <fo:block
                   xsl:use-attribute-sets="admonition.title.properties admonition.compact.title.properties">
                   <xsl:call-template name="compact.or.normal.block"/>
                  </fo:block>
                 </xsl:when>
                 <xsl:otherwise>
                  <fo:block xsl:use-attribute-sets="admonition.title.properties admonition.normal.title.properties">
                   <xsl:call-template name="compact.or.normal.block"/>
                  </fo:block>
                 </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
              <fo:block xsl:use-attribute-sets="admonition.properties">
                <xsl:apply-templates/>
              </fo:block>
            </fo:block>
          </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

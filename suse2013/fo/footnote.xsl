<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
   Contains code related to footnotes.

  Author(s):  Stefan Knorr <sknorr@suse.de>
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2017

-->
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="footnote/para[1]
                     |footnote/simpara[1]
                     |footnote/formalpara[1]"
              priority="2">
  <!-- this only works if the first thing in a footnote is a para, -->
  <!-- which is ok, because it usually is. -->
  <fo:block xsl:use-attribute-sets="footnote.wrap">
    <fo:inline xsl:use-attribute-sets="serif.bold">
      <xsl:apply-templates select="ancestor::footnote" mode="footnote.number"/>
    </fo:inline>
    <fo:leader leader-pattern="space" leader-length="0.5em"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

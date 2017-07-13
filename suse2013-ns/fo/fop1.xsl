<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl d">


  <xsl:template name="fop1-document-information">
    <xsl:variable name="authors"
      select="(//d:author|//d:editor|//d:corpauthor|//d:authorgroup)[1]"/>
    <xsl:variable name="node"
      select="(/* | key('id', $rootid))[last()]"/>

    <xsl:variable name="title">
      <xsl:apply-templates select="$node[1]" mode="label.markup"/>
      <xsl:apply-templates select="$node[1]" mode="title.markup"/>
      <xsl:variable name="productname">
         <xsl:value-of select="$node[1]/*/d:productname[1]"/>
      </xsl:variable>
      <xsl:variable name="productnumber">
         <xsl:value-of select="$node[1]/*/d:productnumber[1]"/>
      </xsl:variable>
      <xsl:if test="$productname != ''">
        <!-- Checking for productname only is not an oversight - if there is
             no name, we likely don't want to display the version either. -->
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$productname"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$productnumber"/>
      </xsl:if>
    </xsl:variable>

    <fo:declarations>
      <x:xmpmeta xmlns:x="adobe:ns:meta/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
          <rdf:Description rdf:about=""
            xmlns:dc="http://purl.org/dc/elements/1.1/">
            <!-- Dublin Core properties go here -->

            <!-- Title -->
            <dc:title>
              <xsl:value-of select="normalize-space($title)"/>
            </dc:title>

            <!-- Author -->
            <xsl:if test="$authors">
              <xsl:variable name="author">
                <xsl:choose>
                  <xsl:when test="$authors[self::d:authorgroup]">
                    <xsl:call-template name="person.name.list">
                      <xsl:with-param name="person.list"
                        select="$authors/*[self::d:author|self::d:corpauthor|
                                     self::d:othercredit|self::d:editor]"
                      />
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="$authors[self::d:corpauthor]">
                    <xsl:value-of select="$authors"/>
                  </xsl:when>
                  <xsl:when test="$authors[d:orgname]">
                    <xsl:value-of select="$authors/d:orgname"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="person.name">
                      <xsl:with-param name="node" select="$authors"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <dc:creator>
                <xsl:value-of select="normalize-space($author)"/>
              </dc:creator>
            </xsl:if>

            <!-- Subject -->
            <xsl:if test="//d:subjectterm">
              <dc:description>
                <xsl:for-each select="//d:subjectterm">
                  <xsl:value-of select="normalize-space(.)"/>
                  <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </dc:description>
            </xsl:if>
          </rdf:Description>

          <rdf:Description rdf:about=""
            xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
            <!-- PDF properties go here -->

            <!-- Keywords -->
            <xsl:if test="//d:keyword">
              <pdf:Keywords>
                <xsl:for-each select="//d:keyword">
                  <xsl:value-of select="normalize-space(.)"/>
                  <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </pdf:Keywords>
            </xsl:if>
          </rdf:Description>

          <rdf:Description rdf:about=""
            xmlns:xmp="http://ns.adobe.com/xap/1.0/">
            <!-- XMP properties go here -->

            <!-- Creator Tool -->
            <xmp:CreatorTool>
              <xsl:value-of select="$pdf-creator"/>
            </xmp:CreatorTool>
          </rdf:Description>

        </rdf:RDF>
      </x:xmpmeta>
    </fo:declarations>
  </xsl:template>

  <xsl:template match="d:set|d:book|d:article" mode="fop1.outline"
    priority="2">

    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <xsl:variable name="bookmark-label">
      <xsl:apply-templates select="." mode="object.title.markup"/>
    </xsl:variable>
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table"
          select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:bookmark internal-destination="{$id}">
      <xsl:attribute name="starting-state">
        <xsl:value-of select="$bookmarks.state"/>
      </xsl:attribute>
      <fo:bookmark-title>
        <xsl:value-of select="normalize-space($bookmark-label)"/>
      </fo:bookmark-title>
    </fo:bookmark>

    <xsl:if  test="contains($toc.params, 'toc')
      and (d:book|d:part|d:reference|d:preface|d:chapter|d:appendix|d:article|d:topic
      |d:glossary|d:bibliography|d:index|d:setindex
      |d:refentry
      |d:sect1|d:sect2|d:sect3|d:sect4|d:sect5|d:section)">
      <fo:bookmark internal-destination="toc...{$id}">
        <fo:bookmark-title>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'TableofContents'"/>
          </xsl:call-template>
        </fo:bookmark-title>
      </fo:bookmark>
    </xsl:if>
    <xsl:apply-templates select="*" mode="fop1.outline"/>
  </xsl:template>


</xsl:stylesheet>

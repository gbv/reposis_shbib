<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" 
  xmlns:pica="info:srw/schema/5/picaXML-v1.0"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="i18n xsl str pica" >
  <xsl:param name="parentId" />
  <xsl:param name="WebApplicationBaseURL" />

  <!-- <xsl:include href="copynodes.xsl" /> -->
  
  <xsl:variable name="ppn" select="//mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-601']" />
  <!-- <xsl:variable name="picaUrl" select="concat($WebApplicationBaseURL,'unapiproxy/?format=picaxml&amp;id=gvk:ppn:', $ppn )" />
  <xsl:variable name="picaXml" select="document($picaUrl)" /> -->
  
  <!-- <xsl:key name="kDatafield" match="$picaXml/pica:record/pica:datafield" use="position()"/>  -->

  <xsl:template match="/record">
    <mods:mods>
      <xsl:apply-templates />
    </mods:mods>
  </xsl:template>

  <xsl:template match="datafield[@tag='002@']">
    <xsl:variable name="cat002at" select="subfield[@code='0']" />
    <xsl:variable name="physForm" select="substring($cat002at,1,1)"/>
    <xsl:variable name="pubKind" select="substring($cat002at,2,1)"/>
    <xsl:choose>
      <xsl:when test="contains('a',$pubKind) and $physForm='A'">
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#book"/>
      </xsl:when>
      <xsl:otherwise>
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#{$pubKind}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="datafield[@tag='021A']">
    <mods:titleInfo>
      <mods:title><xsl:value-of select="subfield[@code='a']" /></mods:title>
      <mods:subTitle><xsl:value-of select="subfield[@code='d']" /></mods:subTitle>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="datafield[@tag='028A' or @tag='028B' or @tag='028C']">
    <mods:name type="personal" usage="primary">
      <mods:namePart type="family"><xsl:value-of select="subfield[@code='A']" /></mods:namePart>
      <mods:namePart type="given"><xsl:value-of select="subfield[@code='D']" /></mods:namePart>
      <mods:role>
        <mods:roleTerm type="text"><xsl:value-of select="subfield[@code='B']" /></mods:roleTerm>
      </mods:role>
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code"><xsl:value-of select="subfield[@code='4']" /></mods:roleTerm>
      </mods:role>
      <mods:nameIdentifier>(DE-601)<xsl:value-of select="subfield[@code='9']" /></mods:nameIdentifier>
      <mods:nameIdentifier type="gnd"><xsl:value-of select="substring-after(subfield[@code='7'],'gnd/')" /></mods:nameIdentifier>
    </mods:name>
  </xsl:template>

    
</xsl:stylesheet>
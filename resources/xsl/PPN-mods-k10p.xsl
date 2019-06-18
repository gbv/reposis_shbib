<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">
  <xsl:variable name="XSL_VERSION_PICA2MODS">pica2mods-xslt v1.2.0 </xsl:variable>
  <xsl:import href="pica2mods_EPUB.xsl" />
  <xsl:import href="pica2mods_KXP.xsl" />
  <xsl:import href="pica2mods_RAK.xsl" />
  <xsl:import href="pica2mods_RDA.xsl" />
  <xsl:output method="xml" indent="yes" xalan:indent-amount="4" />
  <xsl:param name="WebApplicationBaseURL">http://rosdok.uni-rostock.de/</xsl:param>
  <xsl:param name="parentId" /> <!-- to do editor, could be obsolete -->
  <xsl:variable name="ubr_pica2mods_version">UB Rostock: Pica2MODS 20190122</xsl:variable>
  <xsl:variable name="mycoreRestAPIBaseURL" select="concat($WebApplicationBaseURL,'api/v1/')" />
  <xsl:template match="/p:record">
    <xsl:text>
</xsl:text>
    <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" version="3.6"
      xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
      <xsl:choose>
        <xsl:when test="./p:datafield[@tag='209O']/p:subfield[@code='a' and contains(.,':doctype:epub')]">
          <xsl:apply-templates mode="EPUB" select="." />
        </xsl:when>
        <xsl:when test="./p:datafield[@tag='007G']/p:subfield[@code='i']/text()='KXP'">
          <xsl:apply-templates mode="KXP" select="." />
        </xsl:when>
        <xsl:when test="not(./p:datafield[@tag='011B']) and ./p:datafield[@tag='010E']/p:subfield[@code='e']/text()='rda'">
          <xsl:apply-templates mode="RDA" select="." />
        </xsl:when>
        <xsl:otherwise>
          <!-- früher: RAK -->
          <xsl:apply-templates mode="KXP" select="." />
        </xsl:otherwise>
      </xsl:choose>
    </mods:mods>
  </xsl:template>
</xsl:stylesheet> 

  
  
  
  <xsl:template match="pica:datafield[@tag='010@']">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc4646')" />
    <xsl:variable name="biblCode" select="pica:subfield[@code='a']" />
    <xsl:variable name="rfcCode">
      <xsl:value-of select="$languages//category[label[@xml:lang='x-bibl']/@text = $biblCode]/@ID" />
    </xsl:variable>
    <mods:language>
      <mods:languageTerm authority="rfc4646" type="code">
        <xsl:value-of select="$rfcCode"/>    
      </mods:languageTerm>
    </mods:language>
  </xsl:template>
  
  
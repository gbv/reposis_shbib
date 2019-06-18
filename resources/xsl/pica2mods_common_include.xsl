<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:p="info:srw/schema/5/picaXML-v1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="p xalan fn">  
  
  <xsl:template name="COMMON_UBR_Class_Doctype">
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:for-each select="./p:datafield[@tag='036E' or @tag='036L']/p:subfield[@code='a']/text()">
      <xsl:variable name="pica4110" select="translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ')" />
      <xsl:for-each select="document(concat($mycoreRestAPIBaseURL, 'classifications/doctype'))//category[./label[@xml:lang='x-pica-0500-2']]">
        <xsl:if
          test="$pica4110 = translate(./label[@xml:lang='x-pica-4110']/@text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ', 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ') and contains(./label[@xml:lang='x-pica-0500-2']/@text, $pica0500_2)">
          <xsl:element name="mods:classification">
            <xsl:attribute name="authorityURI">http://rosdok.uni-rostock.de/classifications/doctype</xsl:attribute>
            <xsl:attribute name="valueURI"><xsl:value-of select="concat('http://rosdok.uni-rostock.de/classifications/doctype#', ./@ID)" /></xsl:attribute>
            <xsl:attribute name="displayLabel">doctype</xsl:attribute>
            <xsl:value-of select="./label[@xml:lang='de']/@text" />
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="COMMON_SHBIB_Class_Doctype">
    <xsl:variable name="pica0500_1" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:variable name="pica0500_2" select="substring(./p:datafield[@tag='002@']/p:subfield[@code='0'],2,1)" />
    <xsl:choose>
      <xsl:when test="contains('a',$pica0500_2) and $pica0500_1='A'">
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#book"/>
      </xsl:when>
      <xsl:otherwise>
        <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#{$pica0500_2}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="COMMON_MIR_Class_Collection">
    <!-- to Do -->
  </xsl:template>
  
  <xsl:template name="COMMON_Class_Doctype">
    <xsl:call-template name="COMMON_SHBIB_Class_Doctype" />
  </xsl:template>
  
</xsl:stylesheet>
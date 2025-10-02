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

  <xsl:include href="xslInclude:PPN-mods-simple"/>
  <xsl:include href="copynodes.xsl" />
  
  <xsl:variable name="ppn" select="//mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-601']" />
  <!-- <xsl:variable name="picaUrl" select="concat($WebApplicationBaseURL,'unapiproxy/?format=picaxml&amp;id=gvk:ppn:', $ppn )" /> -->
  <xsl:variable name="picaUrl" select="concat('https://reposis-test.gbv.de/shbib/unapiproxy/?format=picaxml&amp;id=gvk:ppn:', $ppn )" />
  <xsl:variable name="picaXml" select="document($picaUrl)" />
  
  <!-- <xsl:key name="kDatafield" match="$picaXml/pica:record/pica:datafield" use="position()"/>  -->

  <xsl:template match="/">
    <mods:mods>
      <xsl:apply-templates select="mods:mods/*" />
      <mods:identifier invalid="yes" type="uri">
        <xsl:value-of select="concat('//gso.gbv.de/DB=2.1/PPNSET?PPN=', $ppn)" />
      </mods:identifier>
      
      <xsl:for-each select="$picaXml/pica:record/pica:datafield[@tag='201D'][pica:subfield[@code='a'][text()='0068']]">
        <xsl:variable name="current201D" select="."/>
        <xsl:for-each select="following-sibling::pica:datafield[@tag='209A'][preceding-sibling::pica:datafield[@tag='201D'][1]/pica:subfield[@code='a']/text()=$current201D/pica:subfield[@code='a']/text()][preceding-sibling::pica:datafield[@tag='201D'][1]/@occurrence=$current201D/@occurrence]">
          <xsl:variable name="shelfmark" select="pica:subfield[@code='a']"/>
          <xsl:if test=" string-length($shelfmark) &gt; 0 and not($shelfmark='Einzelsignatur')">
            <mods:location> 
              <mods:physicalLocation authority="ELN">0068</mods:physicalLocation>
              <mods:shelfLocator>
                <xsl:value-of select="$shelfmark"/>
              </mods:shelfLocator>
            </mods:location>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:variable name="cat002at" select="$picaXml/pica:record/pica:datafield[@tag='002@']/pica:subfield[@code='0']" />
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
      
    </mods:mods>
  </xsl:template>

  <xsl:template match="*">
    <xsl:element name="mods:{name()}">
      <xsl:copy-of select="namespace::*" />
      <xsl:apply-templates select="node()|@*" />
    </xsl:element>
  </xsl:template> 

  
  
  <!-- remove invalid mods -->
  <!-- <xsl:template match="mods:extent[text()]">
  </xsl:template>
   -->
  <xsl:template match="mods:identifier[@type='isbn'][string-length(.)=10]">
    <mods:identifier>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="substring(.,1,1)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,2,5)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,7,3)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,10,1)"/>
    </mods:identifier>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='isbn'][string-length(.)=13]">
    <mods:identifier>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="substring(.,1,3)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,4,1)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,5,5)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,10,3)"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,13,1)"/>
    </mods:identifier>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='oclc']">
  </xsl:template>
  
  <xsl:template match="mods:identifier[string-length(@type) = 0]">
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[count(*) = 0]">
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[string-length(@type) = 0]">
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[@type='series'][not (starts-with(mods:identifier[@type='local'],'(DE-601)'))]">
    
    <xsl:variable name="seriesTitle" select="normalize-space(mods:titleInfo/mods:title)" >
    </xsl:variable>
    
    <xsl:variable name="seriesPPN" select="$picaXml/pica:record/pica:datafield[@tag='036F'][preceding-sibling::*[ 1]/@tag='036E'][preceding-sibling::*[ 1]/pica:subfield[@code='a']=$seriesTitle]/pica:subfield[@code='9']" />
    <xsl:variable name="hostPPN"   select="$picaXml/pica:record/pica:datafield[@tag='036D'][preceding-sibling::*[ 1]/@tag='036C'][preceding-sibling::*[ 1]/pica:subfield[@code='a']=$seriesTitle]/pica:subfield[@code='9']" />
    <!-- <xsl:variable name="seriesPPN"  select="$picaXml/pica:record/pica:datafield[@tag='036F'][substring(pica:subfield[@code='a'],1,string-length($seriesTitle))=$seriesTitle]/pica:subfield[@code='9']" />  -->
    <!-- <xsl:variable name="seriesPPN2" select="$picaXml/pica:record/pica:datafield[@tag='036F'][position()]/pica:subfield[@code='9']" />  -->
    <!-- <xsl:variable name="hostPPN"    select="$picaXml/pica:record/pica:datafield[@tag='036D'][substring(pica:subfield[@code='a'],1,string-length($seriesTitle))=$seriesTitle]/pica:subfield[@code='9']" />  -->
    <!-- <xsl:variable name="hostPPN2"   select="$picaXml/pica:record/pica:datafield[@tag='036D'][position()]/pica:subfield[@code='9']" />  -->
    
    
    <xsl:if test="not(following-sibling::mods:relatedItem[@type='series'][mods:titleInfo/mods:title=$seriesTitle])"> 
      <xsl:choose>
        <xsl:when test="$hostPPN">
          <mods:relatedItem type="host">
            <mods:identifier type="local">(DE-601)<xsl:value-of select="$hostPPN" /></mods:identifier>
            <xsl:apply-templates select="*" />
          </mods:relatedItem>
        </xsl:when>
        <xsl:when test="$seriesPPN">
          <mods:relatedItem type="series">
            <mods:identifier type="local">(DE-601)<xsl:value-of select="$seriesPPN" /></mods:identifier>
            <xsl:apply-templates select="*" />
          </mods:relatedItem>
        </xsl:when>
        <xsl:otherwise>
          <mods:relatedItem type="series">
            <xsl:apply-templates select="*" />
          </mods:relatedItem>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  
  
  
  
  <xsl:template match="mods:nameIdentifier[starts-with(.,'(DE-588)')]">
    <mods:nameIdentifier type="gnd">
      <xsl:value-of select="substring-after(.,')')"/>
    </mods:nameIdentifier>
  </xsl:template>
  
  
  <xsl:template match="mods:part[mods:extent/@unit='pages']">
    <mods:part>
      <xsl:variable name="issue" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='e']" />
      <xsl:variable name="volume" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='d']" />
      <xsl:variable name="year" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='j']" />
      <xsl:variable name="spezialIssue" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='f']" />
      <xsl:variable name="partText" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='y']" />
      <xsl:if test="$partText">
        <mods:text><xsl:value-of select="$partText" /></mods:text>
      </xsl:if>
      <xsl:if test="not(mods:detail[@type='issue']) and ($issue or $spezialIssue)">
        <mods:detail type="issue">
          <xsl:if test="$spezialIssue" >
            <mods:caption><xsl:value-of select="$spezialIssue"/></mods:caption>
          </xsl:if>
          <xsl:if test="$issue" >
            <mods:number><xsl:value-of select="$issue"/></mods:number>
          </xsl:if>
        </mods:detail>
      </xsl:if>
      <xsl:if test="not(mods:detail[@type='volume']) and $volume">
        <mods:detail type="volume">
          <mods:number><xsl:value-of select="$volume"/></mods:number>
        </mods:detail>
      </xsl:if>
      <xsl:apply-templates />
    </mods:part>
  </xsl:template>
    
</xsl:stylesheet>
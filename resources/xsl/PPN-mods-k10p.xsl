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

  <xsl:template match="/">
    <mods:mods>
      <xsl:apply-templates/>
    </mods:mods>
  </xsl:template>

  <!-- <xsl:template match="pica:record">
    <xsl:apply-templates />
  </xsl:template>-->
  
  <!--  remove Status dates -->
  <xsl:template match="pica:datafield[@tag='001A' or @tag='001B' or @tag='001D' or @tag='001E']">
  </xsl:template>

  <xsl:template match="pica:datafield[@tag='002@']">
    <xsl:variable name="cat002at" select="pica:subfield[@code='0']" />
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
  
  <xsl:template match="pica:datafield[@tag='003@']">
    <mods:identifier type="uri" invalid="yes">//gso.gbv.de/DB=2.1/PPNSET?PPN=<xsl:value-of select="pica:subfield[@code='0']" /></mods:identifier>
    <mods:identifier type="local" invalid="yes">(DE-601)<xsl:value-of select="pica:subfield[@code='0']" /></mods:identifier>
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='021A']">
    <mods:titleInfo>
      <mods:title><xsl:value-of select="pica:subfield[@code='a']" /></mods:title>
      <mods:subTitle><xsl:value-of select="pica:subfield[@code='d']" /></mods:subTitle>
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='028A' or @tag='028B' or @tag='028C']">
    <mods:name type="personal" usage="primary">
      <mods:namePart type="family"><xsl:value-of select="pica:subfield[@code='A']" /><xsl:value-of select="pica:subfield[@code='a']" /></mods:namePart>
      <mods:namePart type="given"><xsl:value-of select="pica:subfield[@code='D']" /><xsl:value-of select="pica:subfield[@code='d']" /></mods:namePart>
      <mods:role>
        <xsl:choose>
          <xsl:when test="pica:subfield[@code='B']">
            <mods:roleTerm type="text"><xsl:value-of select="pica:subfield[@code='B']" /></mods:roleTerm>
          </xsl:when>
          <xsl:when test="pica:subfield[@code='4']">
            <mods:roleTerm authority="marcrelator" type="code"><xsl:value-of select="pica:subfield[@code='4']" /></mods:roleTerm>
          </xsl:when>
          <xsl:otherwise>
            <mods:roleTerm authority="marcrelator" type="code">aut</mods:roleTerm>
          </xsl:otherwise>
        </xsl:choose>
      </mods:role>
      <xsl:if test="pica:subfield[@code='9']">
        <mods:nameIdentifier>(DE-601)<xsl:value-of select="pica:subfield[@code='9']" /></mods:nameIdentifier>
      </xsl:if>
      <xsl:if test="pica:subfield[@code='7']">
        <mods:nameIdentifier type="gnd"><xsl:value-of select="substring-after(pica:subfield[@code='7'],'gnd/')" /></mods:nameIdentifier>
      </xsl:if>
    </mods:name>
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='031A']">
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='031A']" mode="modsPart">
   <mods:part>
     <xsl:if test="pica:subfield[@code='d']">
       <mods:detail type="volume">
         <mods:number><xsl:value-of select="pica:subfield[@code='d']" /></mods:number>
       </mods:detail>
     </xsl:if>
     <xsl:if test="pica:subfield[@code='e']">
       <mods:detail type="issue">
         <mods:number><xsl:value-of select="pica:subfield[@code='e']" /></mods:number>
       </mods:detail>
     </xsl:if>
     <xsl:if test="pica:subfield[@code='h']">
       <mods:extent unit="pages">
         <mods:list><xsl:value-of select="pica:subfield[@code='h']" /></mods:list>
       </mods:extent>
     </xsl:if>
   </mods:part>
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='036F']">
    <mods:relatedItem type="series">
      <mods:titleInfo>
        <mods:title><xsl:value-of select="pica:subfield[@code='a']" /></mods:title>
        <mods:subTitle><xsl:value-of select="pica:subfield[@code='d']" /></mods:subTitle>
      </mods:titleInfo>
      <mods:identifier type="local">(DE-601)<xsl:value-of select="pica:subfield[@code='9']" /></mods:identifier>
      <mods:originInfo eventType="publication">
        <mods:publisher supplied="yes"><xsl:value-of select="pica:subfield[@code='n']" /></mods:publisher>
        <mods:place>
          <mods:placeTerm type="text"><xsl:value-of select="pica:subfield[@code='p']" /></mods:placeTerm>
        </mods:place>
        <mods:dateIssued encoding="w3cdtf" point="start"><xsl:value-of select="pica:subfield[@code='h']" /></mods:dateIssued>
      </mods:originInfo>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="pica:datafield[@tag='039B']">
    <xsl:variable name="displayLabel" select="subfield[@code='i']"/>
    <mods:relatedItem type="host" displayLabel="{$displayLabel}">
      <mods:titleInfo>
        <mods:title><xsl:value-of select="pica:subfield[@code='t']" /></mods:title>
        <xsl:if test="pica:subfield[@code='z']">
          <mods:subTitle><xsl:value-of select="pica:subfield[@code='z']" /></mods:subTitle>
        </xsl:if>
      </mods:titleInfo>
      <xsl:if test="pica:subfield[@code='9']">
        <mods:identifier type="local">(DE-601)<xsl:value-of select="pica:subfield[@code='9']" /></mods:identifier>
      </xsl:if>
      <xsl:if test="pica:subfield[@code='1']">
        <mods:identifier type="issn"><xsl:value-of select="pica:subfield[@code='1']" /></mods:identifier>
      </xsl:if>
      <xsl:if test="pica:subfield[@code='e'] or pica:subfield[@code='d'] or pica:subfield[@code='f']">
        <mods:originInfo eventType="publication">
          <xsl:if test="pica:subfield[@code='e']">
            <mods:publisher supplied="yes"><xsl:value-of select="pica:subfield[@code='e']" /></mods:publisher>
          </xsl:if>
          <xsl:if test="pica:subfield[@code='d']">
            <mods:place>
              <mods:placeTerm type="text"><xsl:value-of select="pica:subfield[@code='d']" /></mods:placeTerm>
            </mods:place>
          </xsl:if>
          <mods:dateIssued encoding="w3cdtf" point="start"><xsl:value-of select="pica:subfield[@code='f']" /></mods:dateIssued>
        </mods:originInfo>
      </xsl:if>
      
      <xsl:apply-templates select="//pica:datafield[@tag='031A']" mode="modsPart"/>
    </mods:relatedItem>
  </xsl:template>
  
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
  
  <xsl:template match="pica:subfield">
    <xsl:value-of select="concat(@code,':',.) "/>
  </xsl:template>
  
  <xsl:template match="pica:datafield">
    <mods:note>
      <xsl:value-of select="concat(@tag,': ')"/>
      <xsl:apply-templates />
    </mods:note>
  </xsl:template>
    
</xsl:stylesheet>
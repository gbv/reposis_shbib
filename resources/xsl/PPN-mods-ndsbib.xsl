<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" 
  xmlns:pica="info:srw/schema/5/picaXML-v1.0"
  exclude-result-prefixes="i18n xsl" >
  <xsl:param name="parentId" />

  <xsl:include href="xslInclude:PPN-mods-simple"/>
  <xsl:include href="copynodes.xsl" />
  
  <xsl:variable name="ppn" select="//mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-601']" />
  <xsl:variable name="picaUrl" select="concat('https://reposis-test.gbv.de/shbib/unapiproxy/?format=picaxml&amp;id=gvk:ppn:', $ppn )" />
  <xsl:variable name="picaXml" select="document($picaUrl)" />

  <xsl:template match="/">
    <mods:mods>
      <xsl:apply-templates select="mods:mods/*" />
      <mods:identifier invalid="yes" type="uri">
        <xsl:value-of select="concat('//gso.gbv.de/DB=2.1/PPNSET?PPN=', $ppn)" />
      </mods:identifier>
      
      <xsl:variable name="shelfmark" select="$picaXml/pica:record/pica:datafield[@tag='201D'][pica:subfield[@code='a'][text()='0068']]/following-sibling::pica:datafield[@tag='209A']/pica:subfield[@code='a']" />
      <xsl:if test=" string-length($shelfmark) &gt; 0 and not($shelfmark='Einzelsignatur')">
        <mods:location> 
          <mods:shelfLocator>
            <xsl:value-of select="$shelfmark"/>
          </mods:shelfLocator>
        </mods:location>
      </xsl:if>
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

  <xsl:template match="mods:originInfo[not(@eventType)]">
    <xsl:if test="not(//mods:mods/mods:originInfo/@eventType='publication')">
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="node()|@*" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:originInfo[@eventType='publication']">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
      <xsl:if test="not(mods:edition) and ../mods:originInfo[not(@eventType)]/mods:edition">
        <xsl:copy-of select="../mods:originInfo[not(@eventType)]/mods:edition" />
      </xsl:if>
    </xsl:copy>
  </xsl:template> 

  <xsl:template name="yearRAK2w3cdtf">
    <xsl:param name="date"/>
    <xsl:value-of select="translate($date,'[]?ca','')"/>
  </xsl:template>
  
  <xsl:template match="mods:genre[@authority='marcgt']">
  </xsl:template>
  
  <xsl:template match="mods:dateIssued[@encoding='marc'][not(../mods:dateIssued[not(@encoding)])]">
    <mods:dateIssued encoding="marc">
      <xsl:value-of select="."/>
    </mods:dateIssued>
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="."/>
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="mods:dateIssued[not(@encoding)]">
    <!-- TODO: check date format first! -->
    <mods:dateIssued>
      <xsl:value-of select="."/>
    </mods:dateIssued>
    <xsl:choose>
      <xsl:when test="starts-with(.,'Januar')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Februar')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'März')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'April')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Mai')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Juni')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Juli')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'August')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'September')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Oktober')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'November')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:when test="starts-with(.,'Dezember')">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="concat(substring-after(.,' '),'')"/>
        </mods:dateIssued>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="datevalue">
          <xsl:call-template  name="yearRAK2w3cdtf">
            <xsl:with-param name="date" select="node()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($datevalue,'-')">
            <mods:dateIssued encoding="w3cdtf" point="start">
              <xsl:value-of select="substring-before($datevalue,'-')"/>
            </mods:dateIssued>
            <xsl:variable name="datevalueAfter" select="substring-after($datevalue,'-')" />
            <xsl:if test="string-length($datevalueAfter)">
              <mods:dateIssued encoding="w3cdtf" point="end">
                <xsl:value-of select="$datevalueAfter"/>
              </mods:dateIssued>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <mods:dateIssued encoding="w3cdtf">
              <xsl:value-of select="$datevalue"/>
              <xsl:apply-templates select="@*" />
            </mods:dateIssued>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:languageTerm[@authority='iso639-2b']">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc4646')" />
    <xsl:variable name="rfcCode">
      <xsl:value-of select="$languages//category[contains(label[@xml:lang='x-bibl']/@text, .)]/@ID" />
    </xsl:variable>
    <mods:languageTerm authority="rfc4646" type="code">
      <xsl:value-of select="$rfcCode"/>    
    </mods:languageTerm>
  </xsl:template>
  
  <!-- remove all classifications -->
  <xsl:template match="mods:classification">
  </xsl:template>
  
  <!-- remove all subjects -->
  <xsl:template match="mods:subject">
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
    
    <xsl:variable name="seriesTitle" select="mods:titleInfo/mods:title" />
    <xsl:variable name="seriesPPN" select="$picaXml/pica:record/pica:datafield[@tag='036F'][pica:subfield[@code='a']=$seriesTitle]/pica:subfield[@code='9']" />
    <xsl:variable name="seriesPPN2" select="$picaXml/pica:record/pica:datafield[@tag='036F'][position()]/pica:subfield[@code='9']" />
    <xsl:variable name="hostPPN" select="$picaXml/pica:record/pica:datafield[@tag='036D'][pica:subfield[@code='a']=$seriesTitle]/pica:subfield[@code='9']" />
    <xsl:variable name="hostPPN2" select="$picaXml/pica:record/pica:datafield[@tag='036D'][position()]/pica:subfield[@code='9']" />
    
    <xsl:if test="not(following-sibling::mods:relatedItem[@type='series'][mods:titleInfo/mods:title=$seriesTitle])"> 
      <xsl:choose>
        <xsl:when test="$hostPPN or $hostPPN2">
          <mods:relatedItem type="host">
            <xsl:choose>
              <xsl:when test="$hostPPN">
                <mods:identifier type="local">(DE-601)<xsl:value-of select="$hostPPN" /></mods:identifier>
              </xsl:when>
              <xsl:when test="$hostPPN2">
                <mods:identifier type="local">(DE-601)<xsl:value-of select="$hostPPN2" /></mods:identifier>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="*" />
          </mods:relatedItem>
        </xsl:when>
        <xsl:otherwise>
          <mods:relatedItem type="series">
            <xsl:choose>
              <xsl:when test="$seriesPPN">
                <mods:identifier type="local">(DE-601)<xsl:value-of select="$seriesPPN" /></mods:identifier>
              </xsl:when>
              <xsl:when test="$seriesPPN2">
                <mods:identifier type="local">(DE-601)<xsl:value-of select="$seriesPPN2" /></mods:identifier>
              </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="*" />
          </mods:relatedItem>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:number">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="contains(.,'Band')">
          <xsl:value-of select="substring-after(.,'Band')"/>
        </xsl:when>
        <xsl:when test="contains(.,'Teil')">
          <xsl:value-of select="substring-after(.,'Teil')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>  
  
  
  
  <!-- not useable because level switches between volume and issue -->
  <!-- <xsl:template match="mods:detail[@level='1'][not(../mods:detail[@type='volume'])][string-length(text()) > 0]">
    <mods:detail type="volume" level="1">
      <xsl:apply-templates />
    </mods:detail>
  </xsl:template>
  
  <xsl:template match="mods:detail[@level='2'][not(../mods:detail[@type='issue'])][string-length(text()) > 0]">
    <mods:detail type="issue" level="2">
      <xsl:apply-templates />
    </mods:detail>
  </xsl:template>
   -->
  
  <xsl:template match="mods:start[contains(.,'-')]">
    <mods:start><xsl:value-of select="substring-before(.,'-')"/></mods:start>
    <mods:end><xsl:value-of select="substring-after(.,'-')"/></mods:end>
  </xsl:template>
  
  <xsl:template match="mods:name[@type='corporate'][not(mods:role)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code">ctb</mods:roleTerm>
      </mods:role>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[starts-with(.,'(DE-588)')]">
    <mods:nameIdentifier type="gnd">
      <xsl:value-of select="substring-after(.,')')"/>
    </mods:nameIdentifier>
  </xsl:template>
  
  <xsl:template match="mods:detail[not(@type)]">
  </xsl:template>
  
  <xsl:template match="mods:part[mods:extent/@unit='pages']">
    <mods:part>
      <xsl:variable name="issue" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='e']" />
      <xsl:variable name="volume" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='d']" />
      <xsl:variable name="year" select="$picaXml/pica:record/pica:datafield[@tag='031A']/pica:subfield[@code='j']" />
      <xsl:if test="not(mods:detail[@type='issue']) and $issue">
        <mods:detail type="issue">
          <mods:number><xsl:value-of select="$issue"/></mods:number>
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
  
  <xsl:template match="mods:note[@type='action' or @type='bibliography']">
  </xsl:template>
    
</xsl:stylesheet>
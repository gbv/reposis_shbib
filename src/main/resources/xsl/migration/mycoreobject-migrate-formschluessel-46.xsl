<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="1.0"
                
                >
  <xsl:include href="copynodes.xsl" />
 
  <xsl:template match="mods:classification[@authorityURI='http://www.mycore.org/classifications/shbib_formschluessel']">
    <xsl:variable name="kat" select="substring-after(@valueURI,'#')"/>
    <xsl:choose>
      <xsl:when test="$kat=='Ausstellungen'">
        <mods:classification authorityURI="http://www.mycore.org/classifications/shbib_formschluessel" displayLabel="shbib_formschluessel" valueURI="http://www.mycore.org/classifications/shbib_formschluessel#46"/>
      </xsl:when>
      <xsl:otherwise>
        <mods:classification authorityURI="http://www.mycore.org/classifications/shbib_formschluessel" displayLabel="shbib_formschluessel" valueURI="http://www.mycore.org/classifications/shbib_formschluessel#$kat"/>
      </xsl:otherwise>
	</xsl:choose>
  </xsl:template>
   
  <xsl:template match="mods:mods[not(mods:originInfo[@eventType='publication'])]">
    <xsl:copy>
      
	  <xsl:apply-templates select="*" />
      
      <mods:originInfo eventType="publication">
        <xsl:call-template name="getPublisherFromZDB">
        </xsl:call-template>
      </mods:originInfo>
	  
    </xsl:copy>
  </xsl:template>

  
</xsl:stylesheet>
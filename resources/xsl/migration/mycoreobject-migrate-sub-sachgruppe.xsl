<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="1.0"
                
                >
  <xsl:include href="copynodes.xsl" />
 
   
  <xsl:template match="modsSourceContainer[@type='local']/mods:mods/mods:subject[@xlink:href='shbib_sachgruppen']">
    <mods:subject xlink:href="xpointer(//mods:mods/mods:classification%5B@authorityURI='http://www.mycore.org/classifications/shbib_sachgruppen'%5D%5B1%5D)" xlink:type="simple">
      <mods:topic><xsl:value-of select="."></xsl:value-of></mods:topic>
    </mods:subject>
  </xsl:template>
  
  
</xsl:stylesheet>
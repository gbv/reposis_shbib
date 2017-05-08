<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  exclude-result-prefixes="i18n mcrver">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template  name="mir.header">
    <div id="head" class="container">
      <div class="row">
        <div id="header_back">
          <div id="header_heading">
            <div> Schleswig-Holsteinische <br/>Landesbibliothek</div>
            <div id="header_subheading"> Schleswig-Holsteinische Bibliographie online </div>
          </div>
          <div id="header_flag"></div>
          <div id="header_ship"></div>
          <div id="header_building"></div>
          <div id="header_login"><xsl:call-template name="mir.top-navigation" /></div>
          <div id="header_search">
            <form action="{$WebApplicationBaseURL}servlets/solr/find?q={0}" role="search">
              <div>
                <input id="header_searchInput" name="q" placeholder="Schnellsuche" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="search-query" type="text" />
                <button id="header_searchSubmit" type="submit" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
              </div>
            </form> 
          </div>
        </div>
        <noscript>
          <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
            <xsl:value-of select="i18n:translate('mir.noScript.text')" />&#160;
            <a href="http://www.enable-javascript.com/de/" target="_blank">
              <xsl:value-of select="i18n:translate('mir.noScript.link')" />
            </a>
            .
          </div>
        </noscript>
      </div>
    </div>
    
  </xsl:template>

  <xsl:template name="mir.top-navigation">
  <div class="navbar navbar-default mir-prop-nav">
    <nav class="mir-prop-nav-entries">
      <ul class="nav navbar-nav pull-right">
        <xsl:call-template name="mir.loginMenu" />
      </ul>
    </nav>
  </div>
  </xsl:template>

  <xsl:template name="mir.navigation">
    <div class="navbar navbar-default mir-side-nav">
      <nav class="mir-main-nav-entries">
        <!-- <form action="{$WebApplicationBaseURL}servlets/solr/find?q={0}" class="navbar-form form-inline" role="search">
          <div class="form-group">
            <input name="q" placeholder="{i18n:translate('mir.cosmol.navsearch.placeholder')}" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="form-control search-query" id="searchInput" type="text" />
          </div>
          <button type="submit" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
        </form>  -->
        <ul class="nav navbar-nav">
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='main']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
          <xsl:call-template name="mir.basketMenu" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='misc']" />
        </ul>
      </nav>
    </div>
  </xsl:template>

  <xsl:template name="mir.footer">
    
    <div class="container">
        <div class="row">
          <div id="footer_wave" />
        </div>
        <div id="menu" class="row">
            <div class="col-xs-2">
            </div>
            <div class="col-xs-8 text-center">
                <ul id="sub_menu">
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/item[@href='/content/below/impressum.xml']" />
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/item[@href='/content/below/contact.xml']" />
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/item[@href='/content/below/rights.xml']" />
                </ul>
            </div>
            <div class="col-xs-2">
                <div >
                    <a href="https://www.gbv.de/Verbundzentrale/index">
                        <img src="{$WebApplicationBaseURL}images/logo_vzg.png" class="img-responsive" title="Verbundzentrale des GBV" alt="hosted by VZG"/>
                    </a>
                </div>
            </div>
        </div>
        <div id="credits" class="row">
            <div class="col-xs-4">
                <div id="copyright">© Schleswig-Holsteinische Bibliographie 2016</div>
            </div>
            <div class="col-xs-4">
                <div id="powered_by">
                    <a href="http://www.mycore.de">
                        <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
                        <img src="{$WebApplicationBaseURL}images/logo_mycore.png" style="height: 30px;" title="{$mcr_version}" alt="powered by MyCoRe"/>
                    </a>
                </div>
            </div>
            <div class="col-xs-4">
            </div>
        </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
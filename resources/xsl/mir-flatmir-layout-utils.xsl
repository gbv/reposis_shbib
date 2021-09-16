<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template name="mir.navigation">

    <div class="header-box">
      <div class="container no-padding">
        <div class="row">
          <div class="col-12">
            <div class="header-box__content clearfix">
              <div id="options_nav_box" class="mir-prop-nav">
                <nav>
                  <ul class="navbar-nav ml-auto flex-row">
                    <xsl:call-template name="mir.loginMenu" />
                    <xsl:call-template name="mir.languageMenu" />
                  </ul>
                </nav>
              </div>
              <div id="project_logo_box">
                <a href="https://www.schleswig-holstein.de/DE/Landesregierung/LBSH/lbsh_node.html">
                  <span class="d-none">Schleswig-Holsteinische Landesbibliothek</span>
                  <img src="{$WebApplicationBaseURL}images/logo-shlb.png" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="mir-main-nav">
      <div class="container no-padding">
        <div class="row">
          <div class="col-12">

            <a
              class="project-link"
              href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}">
              <div class="project-header">
                <div class="project-header__name">
                  <h1>
                    Schleswig-Holsteinische
                    <span>Bibliographie online</span>
                  </h1>
                </div>
              </div>
            </a>

            <nav class="navbar navbar-expand-lg navbar-light">

              <button
                class="navbar-toggler"
                type="button"
                data-toggle="collapse"
                data-target="#mir-main-nav__entries"
                aria-controls="mir-main-nav__entries"
                aria-expanded="false"
                aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
              </button>

              <div id="mir-main-nav__entries" class="collapse navbar-collapse mir-main-nav__entries">
                <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
                  <xsl:call-template name="project.generate_single_menu_entry">
                    <xsl:with-param name="menuID" select="'brand'"/>
                  </xsl:call-template>
                  <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
                  <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
                  <xsl:call-template name="mir.basketMenu" />
                </ul>
              </div>

              <form
                action="{$WebApplicationBaseURL}servlets/solr/find"
                class="searchfield_box form-inline my-2 my-lg-0"
                role="search">
                <input
                  name="condQuery"
                  placeholder="{i18n:translate('mir.navsearch.placeholder')}"
                  class="form-control mr-sm-2 search-query"
                  id="searchInput"
                  type="text"
                  aria-label="Search" />
                <xsl:choose>
                  <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                    <input name="owner" type="hidden" value="createdby:*" />
                  </xsl:when>
                  <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                    <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                  </xsl:when>
                </xsl:choose>
                <button type="submit" class="btn btn-primary my-2 my-sm-0">
                  <i class="fas fa-search"></i>
                </button>
              </form>

            </nav>

          </div>
        </div>
        <div class="row">
          <div class="col-12 text-right">
            <xsl:choose>
              <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <div class="quick-menu">
                    <a
                      class=""
                      href="{$WebApplicationBaseURL}editor/editor-ppnsource-k10p.xed">
                      Neuaufnahme K10+
                    </a> |
                    <a
                      class=""
                      href="{$WebApplicationBaseURL}content/search/simple_intern.xed">
                      Einfache Suche
                    </a>
                  </div>
              </xsl:when>
            </xsl:choose>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container no-padding">
      <div class="row">
        <div class="col-12">
          <div class="shbib-footer">
            <ul class="internal_links nav">
              <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" mode="footerMenu" />
            </ul>
          </div>
        </div>
      </div>
    </div>
    <div id="shbib_feedback">
      <a href="mailto:bibliographie@shlb.landsh.de">Feedback</a>
    </div>
  </xsl:template>

  <xsl:template name="project.generate_single_menu_entry">
    <xsl:param name="menuID" />
    <li class="nav-item">
      <xsl:variable name="activeClass">
        <xsl:choose>
          <xsl:when test="$loaded_navigation_xml/menu[@id=$menuID]/item[@href = $browserAddress ]">
          <xsl:text>active</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>not-active</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <a id="{$menuID}" href="{$WebApplicationBaseURL}{$loaded_navigation_xml/menu[@id=$menuID]/item/@href}" class="nav-link {$activeClass}" >
        <xsl:choose>
          <xsl:when test="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($CurrentLang)] != ''">
            <xsl:value-of select="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($CurrentLang)]" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($DefaultLang)]" />
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </li>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>

/*
 * $Id$
 * $Revision: 34897 $ $Date: 2016-03-18 17:14:12 +0100 (Fr, 18 Mär 2016) $
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mods;

import java.util.List;
import java.util.Optional;
import java.io.IOException;

import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.jdom2.Content;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.output.XMLOutputter;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSWrapper;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.solr.MCRSolrClientFactory;
import org.mycore.solr.search.MCRSolrSearchUtils;


import org.mycore.common.xml.MCRURIResolver;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;


/**
 * 
 * search in the Index for zhe mycoreid of the relatedItem.
 * search for IDs like PPN 
 *
 * @author Paul Borchert
 */
public class MCRAddRelatedItemIdEventHandler extends MCREventHandlerBase {

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRAddRelatedItemIdEventHandler created");
    	addRelatedItemId(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRAddRelatedItemIdEventHandler updated");
    	addRelatedItemId(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectRepaired(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectRepaired(final MCREvent evt, final MCRObject obj) {
    	addRelatedItemId(obj);
    }

    private final static Logger LOGGER = Logger.getLogger(MCRAddRelatedItemIdEventHandler.class);
    
    private void addRelatedItemId(MCRObject obj) {
    	
    	if (!MCRMODSWrapper.isSupported(obj)){
            return;
        }
    	    	
    	Element mods = new MCRMODSWrapper(obj).getMODS();
        if(mods==null) return;
        //MCRObjectID oid = obj.getId();
        for (Element relatedItem : (List<Element>) (mods.getChildren("relatedItem", MCRConstants.MODS_NAMESPACE))) {
        	String href = relatedItem.getAttributeValue("href", MCRConstants.XLINK_NAMESPACE);
            LOGGER.info("Found related item in " + obj.getId().toString() + ", href=" + href);
            if (href == null || (href != null && !(MCRObjectID.isValid(href)))) {
            	// get PPN from xml <mods:identifier type="local">(DE-601)#######</mods:identifier>
            	XPathFactory xFactory = XPathFactory.instance();
                XPathExpression<Element> expr = xFactory.compile("mods:identifier[starts-with(.,'(DE-601)')]", Filters.element(),
            			 null, MCRConstants.MODS_NAMESPACE, MCRConstants.XLINK_NAMESPACE);
            	List<Element> identifier = expr.evaluate(relatedItem);
            	LOGGER.info("Found Indefiers: " + identifier.size());
                if (identifier.size() == 0) { 
                	LOGGER.warn("No PPN found");
                	continue;
                }
                if (identifier.size() > 1) LOGGER.warn("More than 1 PPN found");
                String identifierValue = identifier.get(0).getText();
                String ppn = identifierValue.substring(identifierValue.lastIndexOf(")") + 1);
                LOGGER.info("Found PPN: " + ppn);
                try {
                    SolrClient solrClient = MCRSolrClientFactory.getSolrClient();
                    List<String> idList = MCRSolrSearchUtils.listIDs(solrClient,"mods.identifier:*PPN="+ppn);
                    LOGGER.info("Found "+idList.size()+"ids ");
                    if (idList.size() == 0) continue;
                    relatedItem.setAttribute("href", idList.get(0), MCRConstants.XLINK_NAMESPACE);
                } catch (SolrServerException e ) {
                	LOGGER.warn("SolrError so the mycoreid of relatedItem wasn't set. ");
                }
               
            } 
             
        }
        
        
        
	}
    
}

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
import java.util.HashMap;
import java.util.Map;
import java.io.IOException;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;
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
 * update the index for subjects  
 *
 * @author Paul Borchert
 */
public class MCRSolrSubjectIndexEventHandler extends MCREventHandlerBase {
	
	private String solrURL = "http://esx-91.gbv.de:8081/solr/shbib_subject/";
	
    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRSolrSubjectIndexEventHandler created");
    	handleSubjectsOfModsObject(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRSolrSubjectIndexEventHandler updated");
    	if (removeMycoreIdsFromSubjectIndex(obj)) handleSubjectsOfModsObject(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectRepaired(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectRepaired(final MCREvent evt, final MCRObject obj) {
    	if (removeMycoreIdsFromSubjectIndex(obj)) handleSubjectsOfModsObject(obj);
    }
    
    @Override
    synchronized protected void handleObjectDeleted(MCREvent evt, MCRObject obj) {
    	removeMycoreIdsFromSubjectIndex(obj);
    }

    private final static Logger LOGGER = Logger.getLogger(MCRSolrSubjectIndexEventHandler.class);
    
    private boolean removeMycoreIdsFromSubjectIndex(MCRObject obj) {
    	
    	String mycoreid = obj.getId().toString();
    	SolrClient solrClient = new HttpSolrClient.Builder(solrURL).build();
    	
    	try {
            SolrQuery query = new SolrQuery();
            query.set("q", "mycoreid:"+mycoreid);
            query.setStart(0);
            query.setRows(10);
            query.setFields("id,displayForm");
            query.setRequestHandler("find");
            
            QueryResponse queryResponse = solrClient.query(query);
                        
            for (SolrDocument subject : queryResponse.getResults()) {
            	SolrInputDocument delDoc = new SolrInputDocument();
                delDoc.addField("id",subject.getFieldValue("id"));
                Map<String, String> mycoreidRemove = new HashMap<String, String>();
                mycoreidRemove.put("removeregex", mycoreid);
                delDoc.addField("mycoreid", mycoreidRemove);
                solrClient.add(delDoc);
                mycoreidRemove = new HashMap<String, String>();
                mycoreidRemove.put("removeregex", mycoreid);
                delDoc.addField("mycoreid.published", mycoreidRemove);
                solrClient.add(delDoc);
            }
            
            solrClient.commit();
            
        } catch (SolrServerException e) {
    	    LOGGER.warn("Solr Error while delete old mycoreids- Subjects of (" + mycoreid + ") were not indexed.");
    	    LOGGER.warn(e.getMessage());
    	    return false;
        } catch (IOException e) {
        	LOGGER.warn("IO Error while delete old mycoreids- Subjects of (" + mycoreid + ") were not indexed.");
        	LOGGER.warn(e.getMessage());
        	return false;
        }
    	return true;
    }
    
    private void handleSubjectsOfModsObject(MCRObject obj) {
    	
    	SolrClient solrClient = new HttpSolrClient.Builder(solrURL).build();
    	
    	if (!MCRMODSWrapper.isSupported(obj)){
            return;
        }
    	    	
    	MCRMODSWrapper wrapper = new MCRMODSWrapper(obj);
    	List<Element> subjects = wrapper.getElements("mods:subject");
        
    	String mycoreid = obj.getId().toString();
    	String publicationState = obj.getService().getState().getID();
        
        String type;
    	String displayForm;
        String gnd;
    	
        for (Element subject : subjects) {
        	LOGGER.info("Process Subject :" + subject);
        	List<Element> children = subject.getChildren();
        	for (Element child : children){
                type = child.getName();
                LOGGER.info("Process Subject (type):" + type);
                displayForm = "";
                gnd = "";
                String authorityURI;
                switch (type) {
                    case "topic":
                	    displayForm = child.getText();
                	    authorityURI = child.getAttributeValue("authorityURI");
                	    if ( authorityURI != null && authorityURI.equals("http://d-nb.info/gnd/")) {
                	    	LOGGER.info("Process Subject (in schleife):" );
                	    	gnd = StringUtils.substringAfter(child.getAttributeValue("valueURI"),"#"); 
                	    }
                        break;
                    case "geographic":
                    	displayForm = child.getText();
                    	authorityURI = child.getAttributeValue("authorityURI");
                    	if (authorityURI != null && authorityURI.equals("http://d-nb.info/gnd/")) {
                	    	gnd = StringUtils.substringAfter(child.getAttributeValue("valueURI"),"#"); 
                	    }
                        break;
                    case "name":
                        displayForm = child.getChild("displayForm",MCRConstants.MODS_NAMESPACE).getText();
                        for (Element identifier : child.getChildren("nameIdentifier",MCRConstants.MODS_NAMESPACE)) {
                        	gnd = (identifier.getAttributeValue("type").equals("gnd")) ? identifier.getText() : null; 
                        }
                        break;
                    default:
                    //throw 
                }
            
                String hashString = displayForm + gnd;
                int idHash = hashString.hashCode();
                
                LOGGER.info("Process Subject (displayForm):" + displayForm);
                LOGGER.info("Process Subject (gnd):" + gnd);
                LOGGER.info("Process Subject (hash):" + idHash);
                LOGGER.info("Process Subject (mycoreid):" + mycoreid);
                LOGGER.info("Process Subject (publicationState):" + publicationState);
                
                
                SolrInputDocument doc = new SolrInputDocument();
                doc.addField("id",idHash);
                doc.addField("displayForm",displayForm);
                doc.addField("subjectType",type);
                doc.addField("identifier.gnd",gnd);
                Map<String, String> mycoreidUpdate = new HashMap<String, String>();
                mycoreidUpdate.put("add", mycoreid);
                doc.addField("mycoreid", mycoreidUpdate);
                if (publicationState.equals("published")) {
                	mycoreidUpdate = new HashMap<String, String>();
                    mycoreidUpdate.put("add", mycoreid);
                    doc.addField("mycoreid.published", mycoreidUpdate);
                }
                
                try {
                    solrClient.add(doc);
                    solrClient.commit();
                } catch (SolrServerException e) {
                	LOGGER.warn("Solr Error - Subjects of (" + mycoreid + ") were not indexed.");
                	LOGGER.warn(e.getMessage());
                } catch (IOException e) {
                	LOGGER.warn("IO Error - Subjects of (" + mycoreid + ") were not indexed.");
                	LOGGER.warn(e.getMessage());
                }
            }
        }
    }
}

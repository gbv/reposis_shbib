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

import org.apache.log4j.Logger;
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
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.datamodel.metadata.MCRObject;


import org.mycore.common.xml.MCRURIResolver;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;


/**
 * 
 * search for category in classifikation shbib_sachgruppen
 * and add a subject if the x Attribute is set. 
 *
 * @author Paul Borchert
 */
public class MCRAddSubjectEventHandler extends MCREventHandlerBase {

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRAddSubjectEventHandler created");
    	addSubject(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("Start MCRAddSubjectEventHandler updated");
    	addSubject(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectRepaired(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectRepaired(final MCREvent evt, final MCRObject obj) {
    	addSubject(obj);
    }

    private final static Logger LOGGER = Logger.getLogger(MCRAddSubjectEventHandler.class);
    
    private static final MCRCategoryDAO DAO = MCRCategoryDAOFactory.getInstance();

    
    private void addSubject(MCRObject obj) {
    	    	
		MCRMODSWrapper mcrmodsWrapper = new MCRMODSWrapper(obj);
        if(mcrmodsWrapper.getMODS()==null){
            return;
        }
        
        for (MCRCategoryID categoryId : mcrmodsWrapper.getMcrCategoryIDs()) {
            MCRCategory category = DAO.getCategory(categoryId, 0);
            LOGGER.info ("Klassifikationid:"+category.getId());
            Optional<MCRLabel> label = category.getLabel("x-topic");
            if (label.isPresent()) {
            	String taskMessage = "add subject from "+category.getId()+" to "+label.toString()+"";
                LOGGER.info(taskMessage);
                Element subject = new Element ("subject", MCRConstants.MODS_NAMESPACE);
                Element topic = new Element ("topic", MCRConstants.MODS_NAMESPACE);
                topic.setText(label.get().getText());
                subject.setContent(topic);
                mcrmodsWrapper.addElement(subject);
            };
            label = category.getLabel("x-geogra");
            if (label.isPresent()) {
            	String taskMessage = "add subject from "+category.getId()+" to "+label.toString()+"";
                LOGGER.info(taskMessage);
                Element subject = new Element ("subject", MCRConstants.MODS_NAMESPACE);
                Element topic = new Element ("geographic", MCRConstants.MODS_NAMESPACE);
                topic.setText(label.get().getText());
                subject.setContent(topic);
                mcrmodsWrapper.addElement(subject);
            };
            
        }
	}
    
}

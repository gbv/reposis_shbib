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

import org.apache.log4j.Logger;
import org.jdom2.Content;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.jdom2.output.XMLOutputter;
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

    private final static Logger LOGGER = Logger.getLogger(MCRMergeModsEventHandler.class);

    
    private void addSubject(MCRObject obj) {
    	    	
		XMLOutputter outp = new XMLOutputter();
    	MCRMetaElement  modsSourceContainer = obj.getMetadata().getMetadataElement("def.modsContainer");
    	    	
    	//Element mergedMods = new Element("mods","mods","http://www.loc.gov/mods/v3");
    	
		MCRMetaXML mx = (MCRMetaXML) modsSourceContainer.getElement(0);
		
		Element metadata = mx.createXML();
		
		//Element mods = null;
	    //Element importedMods = null;
		
		XPathFactory xFactory = XPathFactory.instance();
        XPathExpression<Element> expr = xFactory.compile("mods:classification", Filters.element()
        		, null, MCRConstants.MODS_NAMESPACE, MCRConstants.XLINK_NAMESPACE);
	    	
		for (Element elm : metadata.getChildren()) {
            if (elm.getName() =="mods"){
            	List<Element> classifications = expr.evaluate(elm);
            	for (Element classification : classifications) {
            		LOGGER.info("authorityURI: "+classification.getAttribute("authorityURI"));
            		LOGGER.info("valueURI: "+classification.getAttribute("valueURI"));
            	}
            }
        }
		
    	
    	/*LOGGER.info("Ergebnissmods (gemerged): "+outp.outputString(mergedMods));
    	
    	MCRMetaElement  modsContainer = obj.getMetadata().getMetadataElement("def.modsContainer");
    	MCRMetaXML mx = (MCRMetaXML) modsContainer.getElement(0);
    	Element metadata = mx.createXML();
    	Namespace nsmods = Namespace.getNamespace ("mods","http://www.loc.gov/mods/v3");
    	metadata.removeChild("mods" , nsmods );
    	metadata.addContent(mergedMods);
    	LOGGER.info("Ergebnissmetadata (gemerged): "+outp.outputString(mergedMods));
    	mx.setFromDOM(metadata);*/
	}
    
}

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
import org.mycore.datamodel.common.MCRISO8601Date;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;




/**
 * 
 * update the mods
 *
 * @author Paul Borchert
 */
public class MCRUpdateImportedModsEventHandler extends MCREventHandlerBase {

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("So ich create jetzt das mods mit meiner Klasse MCRUpdateImportedMods2");
    	updateMetadataFromSource(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(final MCREvent evt, final MCRObject obj) {
    	LOGGER.info("So ich update jetzt das mods mit meiner Klasse MCRUpdateImportedMods");
    	updateMetadataFromSource(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectRepaired(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectRepaired(final MCREvent evt, final MCRObject obj) {
    	updateMetadataFromSource(obj);
    }

    private final static Logger LOGGER = Logger.getLogger(MCRUpdateImportedModsEventHandler.class);

    
    private void updateMetadataFromSource(MCRObject obj) {
    	    	
		XMLOutputter outp = new XMLOutputter();
    	MCRMetaElement  modsSourceContainer = obj.getMetadata().getMetadataElement("def.modsSourceContainer");
    	
		for (int i = 0; i < modsSourceContainer.size();i++) {
			MCRMetaXML mx = (MCRMetaXML) modsSourceContainer.getElement(i);
			Element metadata = mx.createXML();
			Element mods = null;
	    	Element importedMods = null;
	    	
			try {
			    for (Element elm : metadata.getChildren()) {
			        String s = outp.outputString(elm);
			        LOGGER.info("Verarbeite - suche uri:"+s);
			        if (elm.getName() == "sourceuri" ) {
			            LOGGER.info("found source:"+elm.getText());
			            String uri;
			            if (elm.getText().indexOf("unapi.k10plus.de") != -1) {
			                uri="xslStyle:pica2mods,mods2mirMods,mods2mods_shbib:"+elm.getText();
			            } else {
			                uri="xslStyle:PPN-mods-gvk,mycoreobject-migrate-nameIdentifier,mods2mirMods,mods2mods_shbib:"+elm.getText();
			            }
			            importedMods = MCRURIResolver.instance().resolve(uri);
			            LOGGER.info("received xml from source: "+outp.outputString(importedMods));
                    };
			    }
			    
			    if (importedMods != null) {	
					metadata.removeChildren("mods",MCRConstants.MODS_NAMESPACE);
					mods= new Element ("mods","mods","http://www.loc.gov/mods/v3");
					mods.addContent(importedMods.cloneContent());
					metadata.addContent(mods);
					metadata.removeChildren("orphaned");
					metadata.removeChildren("updated");
					Element orphaned = new Element ("orphaned");
					orphaned.addContent("false");
					Element updated = new Element ("updated");
					updated.addContent(MCRISO8601Date.now().getISOString());
					metadata.addContent(orphaned);
					metadata.addContent(updated);
					mx.setFromDOM(metadata);
					LOGGER.debug("Ergebnissxml: "+outp.outputString(metadata));
				} else {
					LOGGER.info("no mods to import");
				}
			    
			} catch (MCRException e) {
	            LOGGER.info("Error while getting mods from source. set sourceContainer orphaned", e);
                metadata.removeChildren("orphaned");
                Element orphaned = new Element ("orphaned");
                orphaned.addContent("true");
                metadata.addContent(orphaned);
                mx.setFromDOM(metadata);
			}
			
			
		}
	}
    
}

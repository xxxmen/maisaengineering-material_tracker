/**
 * sExt - scaffolding for ExtJS 
 * 
 *
 * @authors   Hugh Bien and Christopher Stotts 
 * @website   http://www.telaeris.com/
 * @date      8. June 2008
 * @version   1.0
 *
 * @ExtJS license   This code uses the ExtJS libraries for interface functionality.
 *  				The ExtJS libraries included in sExt are covered under the 
 					LGPL for (ExtJS version <= 2.0.2):  http://www.gnu.org/licenses/lgpl.html
 *   				or the GPL(ExtJSv >= 2.1):  http://www.gnu.org/licenses/gpl.html
 * Further ExtJS Licensing info can be found at http://www.extjs.com/license/
 *
 * @license   sExt is licensed under the terms of MIT License
 * 
 * The MIT License
 * 
 * Copyright (c) 2008 Telaeris Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * The `appliction` module handles initialization of the application.
 * By Default, it will open the users resource
 */
 
Ext.BLANK_IMAGE_URL = '../images/default/s.gif';
//    Ext.get('panel').layout.setActiveItem = 1;
var application = function(){        
    /* public properties */
    return {
        init: function(){
            var resourcesCard = { id: 'resources_card', layout: 'border', region: 'center', items: [
                { id: 'navigation', region: 'west', width: 240, collapsible: true, title: "Navigation", split: true, autoScroll: true, collapsed: false },
                { id: 'resources_tab_panel', region: 'center', xtype: 'tabpanel', activeTab: 0, resizeTabs: true }
            ]};
            
            var cardItems = [resourcesCard,
            			{id: 'dashboard_card', html: '<h2>your dashboard can go here</h2>'},
            			{id: 'reports_card', html: '<h2>your reports can go here</h2>'},
            			{id: 'public_site_card', html: '<h2>you can link to or host your public site here</h2>'}];
            
            viewport = new Ext.Viewport({
                layout: 'border',
                items: [
                    { contentEl: 'header', region: 'north', height: 36 },
                    { id: 'cards', layout: 'card', activeItem: 0, region: 'center', items: cardItems }
                ]
            });
            
            telaeris.init();
            telaeris.openResource('users');
            Ext.getCmp('resources_card').fireEvent('resize'); // fixes bug where save button is rendered too low off screen, resize forces it to move up
            Ext.get('header').show();
        },
        removeAssociation: function(params, event){
            var resource = params.resource;
            var association = params.association;
            var url = '/sext/' + resource + '/remove/' + association;
            
            Ext.Ajax.request({
                method: 'POST',
                url: url,
                params: Ext.apply(params.keys, {'_method': 'DELETE'}),
                success: function() { 
                	Ext.getCmp(resource + '_grid').store.load();
                	telaeris.util.message("Relation deleted successfully");
                	telaeris.editRecordFromURL(resource, '/sext/' + resource + '/' + params.keys.resource_id);
                	}
    		});
		}
    };
}();

Ext.onReady(application.init, application, true);

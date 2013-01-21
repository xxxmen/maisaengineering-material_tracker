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
 * The `telaeris` module handles adding resources to the application.
 * Every resource is a Model represented on the server side code.  Each resource will have
 * a form and a grid associated with it.
 */
var telaeris = function(){
    /* Private variables and functions are pre-pended with a $ */
    var $gridConfigs = {}; /* list of grid configs, with the key as the resource name */
    var $formConfigs = {}; /* list of form configs, with the key as the resource name */
    var $navigationLinks = []; /* list of navigation item names (ie. 'Users', 'Jobs', 'Skills', etc...) */
    var $navigationLinksHtml = {}; /* the actual html of each link to render */
    var $tabPanel; /* reference to the component #resources_tab_panel, see application.js for details */
    
    /* Given a resource name and config option, this function will add default config options and store
       it within $gridConfigs for later use */    
    function $addGridConfig(resourceName, config){
        var gridFields = config.gridFields;
        var formFields = config.formFields;
        var allFields = [];
        var gridColumns = [];
        
        // set the defaults for configs
        Ext.applyIf(config, {
            url: '/sext/' + resourceName,
            baseParams: {'_method': 'GET'},
            title: telaeris.util.titleFor(resourceName),
            id: resource + '_grid'
        });
        
        // grab all fields by combining 'gridFields' and 'formFields'
        // we need this info for the grid's unerlaying store
        for(var i=0; i<gridFields.length; i++) { 
            var field = gridFields[i];
            if(typeof field != "string") field = field.id;             // in case it's a grid column config
            if(allFields.indexOf(field) == -1) allFields.push(field);  // make sure they're unique before pushing them
        }
        for(var i=0; i<formFields.length; i++) {
            var field = formFields[i];
            if(typeof field != "string") field = field.name;           // in case it's a form field config
            if(allFields.indexOf(field) == -1) allFields.push(field);  // make sure they're unique before pushing them
        }
        allFields.push('id');
        allFields.push('related_data');
        
        
        // now identify all the grid column configs
        for(var i=0; i<gridFields.length; i++) {
            gridColumns.push($gridColumnConfigFor(gridFields[i]));
        }
        
        // add allFields and gridColumns to the config
        config.allFields = allFields;
        config.gridColumns = gridColumns;
        
        // add grid info to $gridConfigs, grid will be instantiated when needed
        $gridConfigs[resourceName] = config;
    }
    
    /* Given a resource name and config options, $addFormConfig will add default options to the config object
       and will store the config under $formConfigs[resourceName] */
    function $addFormConfig(resourceName, config){
        // set the defaults for configs
        Ext.applyIf(config, {
            url: '/sext/' + resourceName,
            baseParams: {'_method': 'POST'},
            id: resource + '_form',
            failure: Ext.emptyFn,
            success: Ext.emptyFn
        });
        
        // all forms have an 'id' field that's hidden for updates, if it's blank that means the form is doing a create        
        var formItems = [{xtype: 'hidden', name: 'id'}];
        for(var i=0; i<config.formFields.length; i++) {
            var formItem = $formFieldConfigFor(config.formFields[i]);
            formItems.push(formItem);
            if(formItem.xtype == "checkbox") {
                formItems.push({xtype: 'hidden', name: formItem.name, value: '0'});
                var checkboxFilter = {xtype: 'combo', name: formItem.name + '_filter', fieldLabel: formItem.fieldLabel, cls: 'sext_checkbox_filter', displayField: 'id', fields: ['id'],
                                        data: [['Yes'], ['No'], ['Both']]};
                formItems.push($formFieldConfigFor(checkboxFilter));
            }
            if(formItem.xtype == "datefield") {
                var endRangeDate = {xtype: 'datefield', name: formItem.name + '_end_range', fieldLabel: formItem.fieldLabel + " (End Range)", cls: "sext_end_range_date"};
                endRangeDate = $formFieldConfigFor(endRangeDate);
                formItems.push(endRangeDate);
            }
        }
        config.formItems = formItems;
        
        // add to $formConfigs
        $formConfigs[resourceName] = config;
    }
    
    
    /* Given resource name and config option, adds the HTML necessary for a link to $navigationLinks and $navigationLinksHtml */
    function $addNavigationLink(resourceName, config){
        if($navigationLinks.indexOf(resourceName) != -1) return; //already added
        config.icon = config.icon || "document.png";
        // config.header = config.header || "Resources";
        
        $navigationLinks.push(resourceName);
        $navigationLinksHtml[resourceName] = '<li><a href="#" onclick="telaeris.openResource(\'' + resourceName + '\'); return false;"><img src="/images/icons/' + config.icon + '" /> ' + telaeris.util.titleFor(resourceName) + '</a></li>';
    
    }
    
    /* Takes the config for a grid column and adds in default options that are left blank */
    function $gridColumnConfigFor(column){
        if(typeof column == "string") column = { id: column };
        Ext.applyIf(column, {
            header: telaeris.util.titleFor(column.id),
            sortable: true,
            dataIndex: column.id
        });
        return column;
    }
    
    /* If the tab is open, search the given resource using the given query.  
    If a function is passed in (fn), call it after the store is loaded */
    function $doSearch(query, resourceName, fn){
        var grid = Ext.getCmp(resourceName + '_grid');
        var store = grid.store;
        var params = {
            query: query,
            start: 0,
            limit: 40
        };
        
        // clear the baseParams of any filters
        var filters = grid.form.getForm().getValues();
        filters['filter'] = 'true';
        for(var param in filters) {delete store.baseParams[param];}
        
        store.load({params: params});
        store.on('load', fn, store, {single:true});
    }
    
    /* Takes the config option for a form field and adds in default options that are left blank.
       If a string is passed in, assume the xtype of the field should be 'textfield'.
      */
    function $formFieldConfigFor(field){
        if(typeof field == "string") {
            field = { name: field };
        }
        Ext.applyIf(field, {
            xtype: 'textfield',
            fieldLabel: telaeris.util.titleFor(field.name),
            msgTarget: 'under',
            width: "75%"
        });
                
        // apply defaults for combos
        if(field.xtype == 'combo'){
            if(field.url) {
                field.store = new Ext.data.JsonStore({
                    url: field.url,
                    totalProperty: 'count',
                    baseParams: { '_method': 'GET' },
                    root: 'records',
                    autoLoad: (field.autoLoad != undefined ? field.autoLoad : true),
                    fields: ['id', field.displayField]
                });
            } else if(field.data) {
                Ext.applyIf(field, {
                    mode: 'local',
                    editable: false
                });
                field.store = new Ext.data.SimpleStore({
                    autoLoad: true,
                    fields: field.fields,
                    data: field.data
                });
            }
            Ext.applyIf(field, {
                minListWidth: 300,
                triggerAction: 'all',
                mode: 'remote',
                editable: true,
                selectOnFocus: true,
                valueField: 'id',
                hiddenName: field.name,
                title: "Select " + field.fieldLabel
            });
            if(field.fieldLabel.match(/ id$/) && field.name.match(/_id$/)) 
                field.fieldLabel = field.fieldLabel.slice(0, field.fieldLabel.length-3);
        }
        
        // apply defaults for datefields
        if(field.xtype == "datefield") {
            Ext.applyIf(field, {
                altFormats: "m/d/Y|Y-m-d|Y/m/d",
                format: 'm/d/Y'
            });
        }
        
        // now apply defaults for certain xtypes
        if(field.xtype == 'checkbox'){
            Ext.applyIf(field, {
               inputValue: 1,
               style: 'margin-top: 6px;'
            });
        }
        
        return field;
    }
    
    function $editRecord(form, record, resourceName){
        var relatedData = Ext.get(resourceName + '_related_data');
        form.setValues(record.data); 

            Ext.DomHelper.overwrite(resourceName + '_related_data', '');
            // relatedData = relatedData.replaceWith({tag: 'table', id: resourceName + '_related_data'});
            // relatedData = Ext.get(resourceName + '_related_data')

            if(record && record.data && record.data['related_data'] && (record.data['related_data'].length > 0)) {
                var rdHtml = "<table>";
                rdHtml += '<tr><th colspan="3">Related Data</th></tr>';
                for(var i=0; i<record.data['related_data'].length; i++) {
                    var row = record.data['related_data'][i];
                    var rowValue = row.value;
                    var removeLink = '';
                    var secondary = '';
                    if(row.command) {
                        var cmd = row.command;
                        var args = row.args || {};
                        cmd = cmd + "(" + Ext.util.JSON.encode(args) + "); return false;";
                        rowValue = '<a href="#" onclick=\'' + cmd + '\'>' + rowValue + '</a>';
                    }
                    
                    if(row.secondary) {
                        for(var j=0; j<row.secondary.length; j++){
                            var cmd = row.secondary[j].command;
                            var confirm = row.secondary[j].confirm;
                            var args = row.secondary[j].args || {};
                            var label = row.secondary[j].label;
                            cmd = cmd + "(" + Ext.util.JSON.encode(args) + ", event); return false;";
                            if(confirm){
                                cmd = 'telaeris.util.confirm("' + confirm + '", function(){' + cmd  + '});';
                            }
                            secondary += '<a href="#" onclick=\'' + cmd + '\'>' + label + '</a>';
                        }
                    }
                    
                    rdHtml += '<tr><td>' + row.label + '</td><td>' + rowValue + '</td><td class="secondary">' + secondary + '</td></tr>';
                }
                rdHtml += "</table>";
                Ext.DomHelper.overwrite(resourceName + '_related_data', rdHtml);
            }
        
        
    }
    
    
        function $createCSVUploadWindow(thisURL, thisName, grid_id){
			var resourceForm = new Ext.form.FormPanel({
                    method: "POST",
                    labelAlign: 'left', 
                    autoScroll: true, 
                    buttonAlign: 'left',
                    layout: 'fit',
                    height: 100,
                    fileUpload: true,
                    title: "Select " + thisName + " CSV for Upload", 
                    border: true, bodyStyle: 'padding: 4px;',
                    items: [{id: 'upload_field',xtype:'textfield',fieldLabel:'File', name:'file_upload', inputType: 'file'}] 
                });
                resourceForm.addButton({text: 'Save Data',
                    handler: function(){
                        var submitOpt = {
                        	waitMsg: 'Saving File ...', 
                        	method: 'POST', 
                        	url: thisURL
                        };
                        submitOpt.success = function(){
                        	telaeris.util.message("File Uploaded successfully");
                        	Ext.getCmp(grid_id).store.load();
                    	};
                        submitOpt.failure = function(request, response){
                        	var errors = Ext.util.JSON.decode(response.response.responseText).errors;
                        	telaeris.util.message("File Upload Failed " + errors, 10000);
                        	
                    	};
                        resourceForm.getForm().submit(submitOpt);
                        Ext.getCmp('csv_upload_window').hide();
                    }
                });
                var myWindow = new Ext.Window({
                    id: 'csv_upload_window',
                    items: [resourceForm],
                    closeAction: 'hide',
                    constrain: true,
                    modal: true,
                    width: 250,
                    height: 'auto'
                });
                myWindow.show();
			
		}
    
    /* Instantiates a new Ext GridPanel given a resourceName.  The resource config options should have already been made via telaeris.resources function.
       This function will just look up the resourceName in $gridConfigs and create a new grid from that.  The grid will:
       * have a JsonStore
       * have pagination already included
       * support searching
       * handle rowclicks by retrieving data and filling out the related form
     */ 
    function $createGrid(resourceName, options){
        var resourceStore, resourceGrid;        
        var config = $gridConfigs[resourceName];
        var csvDownloadButton = new Ext.Button({
            text: 'Download ' + resourceName + ' CSV',
            handler: function(){
                Ext.Msg.show({
                    title: 'Please Confirm', 
                    msg:'Do you want to include Readable Names Instead of IDs?', 
                    buttons: Ext.Msg.YESNOCANCEL,
                    fn: function(response){
                        if(response == "yes"){
                            window.open(config.url + '/csv_export/?related_values=true');
                        }
                        else if(response == "no"){
                            window.open(config.url + '/csv_export');
                        }
                }
            });
            }	
        });
        var csvUploadButton = new Ext.Button({
        	text: 'Upload ' + resourceName + ' CSV',
            handler: function(){
            	$createCSVUploadWindow(config.url + '/csv_import', resourceName, config.id);
        	}
        });
        
        var resourceSearchBox = new Ext.form.TwinTriggerField({
            id: resourceName + '_search',
            emptyText: "search " + resourceName,
            trigger1Class: 'x-form-search-trigger',
            trigger2Class: 'x-form-clear-trigger',
            onTrigger1Click: function(){
                //Trigger2 is a search
                var v = this.getValue();
                if(v.length > 0){
                    telaeris.util.message(resourceName + ' search for \'' + v + '\'');
                    $doSearch(v, resourceName);
                }
                else{
                    this.setValue('');
                    $doSearch('', resourceName);
                    //this.triggerBlur();
                }
            },
            onTrigger2Click: function(){
                //Trigger2 is a clear
                this.setValue('');
                $doSearch('', resourceName);
                
            }
            });
            //Enter is a search
            resourceSearchBox.on('specialkey', function(f, e){
                if (e.getKey() == e.ENTER) {
                    e.preventDefault();
                    this.onTrigger1Click();
                }
            });
            
        
        options = options || {};
        Ext.applyIf(options, {
            autoLoad: true
        });
        
        resourceStore = new Ext.data.JsonStore({
            url: config.url,
            baseParams: config.baseParams,
            autoLoad: options.autoLoad,
            totalProperty: 'count',
            root: 'records',
            fields: config.allFields,
            remoteSort: true
        });
        
        resourceGrid = new Ext.grid.GridPanel({
            store: resourceStore,
            stripeRows: true,
            columns: config.gridColumns,
            viewConfig: {forceFit: true},
            region: 'center',
            autoScroll: true,
            loadMask: true,
            id: config.id,
            tbar: new Ext.Toolbar({ items: [csvDownloadButton,csvUploadButton,{xtype: 'tbfill'}, resourceSearchBox] }),
            bbar: new Ext.PagingToolbar({
                store: resourceStore,
                displayInfo: true,
                pageSize: 40,
                items: [
                    {xtype: 'tbbutton', text: 'Add Record', handler: function() {
                        resourceGrid.form.getForm().reset();
                        Ext.DomHelper.overwrite(resourceName + '_related_data', '');
                    }},
                    // shows the extra search fields (for date ranges and checkboxes)
                    {xtype: 'tbbutton', text: 'Toggle Search', handler: function(){
                        var selector = '#' + resourceName + '_form .sext_end_range_date, .sext_checkbox_filter';
                        selector += ',#' + resourceName + '_form input[type=checkbox]';
                        Ext.select(selector).each(function(){
                            var formItem = this.up('div.x-form-item');
                            formItem.setVisibilityMode(Ext.Element.DISPLAY);
                            formItem.toggle();
                        });
                    }},
                    {xtype: 'tbbutton', text: 'Clear Search', handler: function() {
                        Ext.getCmp(resourceName + '_search').setValue('');
                        $doSearch('', resourceName);
                        Ext.getCmp(resourceName + '_grid').form.getForm().reset();
                    }}
                ]
            })
        });
        
        resourceGrid.getSelectionModel().on('rowselect', function(selectModel, rowIndex){
           resourceGrid.fireEvent('rowclick', resourceGrid, rowIndex);
        });
        
        resourceGrid.on('rowclick', function(grid, rowIndex){
            var record = grid.getStore().getAt(rowIndex);
            
            $editRecord(grid.form.getForm(), record, resourceName);
        });
        
        resourceGrid.on('rowcontextmenu', function(grid, rowIndex, ajaxEvent){
            var deleteHandler = function(){
                telaeris.util.confirm("Are you sure you want to delete this record?", function(){
                    var row = grid.store.getAt(rowIndex);
                    Ext.Ajax.request({
                        method: 'POST',
                        url: '/sext/' + resourceName + '/' + row.data.id,
                        params: {'_method': 'DELETE'},
                        success: function() { grid.store.load();}
                    });
                });
            };
            
            var menuItems = [];
            menuItems.push({text: 'Delete Record', handler: deleteHandler});            
            var menu = new Ext.menu.Menu({
                allowOtherMenus: false,
                items: menuItems
            });
            ajaxEvent.stopEvent();
            menu.showAt(ajaxEvent.getXY()); 
        });
        
        resourceGrid.resourceName = resourceName;
        
        return resourceGrid;
    }

    function $createForm(resourceName){
        var config = $formConfigs[resourceName];
        var formItems = config.formItems;
        
        var formPanelItems = {
            layout: "column",
            border: false,
            items: [ {
                columnWidth: 0.55,
                border: false,
                xtype: "panel",
                items: {
                    xtype: "fieldset",
                    cls: "fieldset",
                    border: false,
                    title: "",
                    autoHeight: true,
                    autoWidth: true,
                    items: formItems
                }
            }, {
                columnWidth: 0.42,
                border: false,
                xtype: 'panel',
                items: { xtype: "tbtext", text: '<div id="' + resourceName + '_related_data" class="related_data"></div>' }
            }]
        };
                                                        
        var form = new Ext.form.FormPanel(Ext.apply({ onSubmit: Ext.emptyFn,
                                        id: config.id,
                                        method: "POST",
                                        labelAlign: 'left', autoScroll: true, buttonAlign: 'left', 
                                        labelWidth: 150,
                                        region: 'south',
                                        collapsible: true,
                                        title: "Details",
                                        autoScroll: true,
                                        split: true,
                                        height: 330,
                                        border: true, bodyStyle: 'padding: 4px;', items: formPanelItems
                                      }, config.formConfig));     
        
        form.addButton({text: 'Save Data',
                            handler: function(){
                                var submitOpt = { waitMsg: 'Saving data ...', method: 'POST', url: config.url, params: config.baseParams };
                                var recordId = form.getForm().getValues().id;
                                if(recordId && recordId.match(/\d+/)) {
                                    submitOpt.params['_method'] = 'PUT';
                                    submitOpt.url = submitOpt.url + '/' + recordId;
                                    submitOpt.success = function(){
                                        form.grid.store.load();
                                        telaeris.util.message("Data was saved successfully");
                                        config.success();
                                    };
                                } else {
                                    submitOpt.params['_method'] = 'POST';
                                    submitOpt.success = function(json){
                                        form.grid.store.load();
                                        telaeris.util.message("Data was saved successfully");
                                        form.getForm().reset();
                                        config.success();
                                    };
                                }
        
                                submitOpt.failure = config.failure;
        
                                form.getForm().submit(submitOpt);
                            }});
                                    
        
        form.addButton({text: 'Search Data',
                        handler: function(){
                            var store = form.grid.store;
                            var newParams = form.getForm().getValues();
                            delete newParams['id'];
                            newParams.filter = "true";
                            
                            store.baseParams = Ext.applyIf(newParams, store.baseParams);
                            store.load({params: store.baseParams});
                            
                            form.getForm().setValues(newParams);
                        }});                                   
        
        return form;
    }
    
    return {
        /**
         * Takes a config object and creates grids/forms for each item.
         *
         * Example:
         *      telaeris.resources({
         *          user: {
         *              category:     "Administration",
         *              gridFields:   ['first_name', 'last_name', 'mi', 'date_of_birth'],
         *              formFields:   ['first_name', 'last_name', 'date_of_birth', 'location']
         *          }
         *      });
         */
        resources: function(resourceConfigs){
            for(resource in resourceConfigs){
                
                var config = resourceConfigs[resource];
                if(config.isHeader){
                    $navigationLinks.push(resource);
                    var title = '';
                    if(config.title){
                        title = config.title;
                    }
                    else{
                        title = telaeris.util.titleFor(resource);
                    }
                    $navigationLinksHtml[resource] = '<li class="header">' + title + '</li>';
                }
                else{
                                    
                    // add the grid
                    $addGridConfig(resource, {
                        url: config.url,
                        baseParams: config.baseParams,
                        title: config.title,
                        id: config.id,
                        formFields: config.formFields,//needs to know for hidden fields.
                        gridFields: config.gridFields,
                        gridConfig: config.gridConfig
                    });
                    
                    // now add the form
                    $addFormConfig(resource, {
                        url: config.url,
                        baseParams: config.baseParams,
                        id: config.id,
                        formFields: config.formFields,
                        formConfig: config.formConfig
                    });
                    
                    // add to the navigation list
                    $addNavigationLink(resource, {
                        icon: config.icon
                    });
                }
            }  
        },

        /**
         * Function which creates forms on top of windows.
         *
         * Example:
         *      telaeris.windows({
         *          'contact_us': {
         *              url: '/sext/contact_us',
         *              formFields: ['email', 'subject', 'message']
         *          },
         *  
         *          'delete_my_account': {
         *              formFields: [{xtype: 'hidden', name: 'id'}]         
         *          }
         *      });
         *
         *      telaeris.windows['contact_us'].show();
         *      telaeris.windows['delete_my_account'].show();
         */
        windows: function(resourceConfigs){
            for(resource in resourceConfigs){
                var config = resourceConfigs[resource];
                Ext.applyIf(config, {
                    url: '/sext/' + resource,
                    id: resource + "_window",
                    formID: resource + "_form",
                    baseParams: {},
                    title: telaeris.util.titleFor(resource),
                    success: Ext.emptyFn,
                    failure: Ext.emptyFn,
                    onShow: Ext.emptyFn
                });
                var formPanelItems = [];
                for(var i=0; i<config.formFields.length; i++){
                    var formItem = $formFieldConfigFor(config.formFields[i]);
                    formPanelItems.push(formItem);
                    if(formItem.xtype == "checkbox") formPanelItems.push({xtype: 'hidden', name: formItem.name, value: '0'});
                }
                var resourceForm = new Ext.form.FormPanel({
                    id: config.formID,
                    onSubmit: Ext.emptyFn,
                    method: "POST",
                    labelAlign: 'left', autoScroll: true, buttonAlign: 'left',
                    labelWidth: 100, title: config.title, border: true, bodyStyle: 'padding: 4px;', items: formPanelItems 
                });
                resourceForm.addButton({text: 'Save Data',
                    handler: function(){
                        var submitOpt = {waitMsg: 'Saving data ...', method: 'POST', url: config.url, params: config.baseParams };
                        submitOpt.success = config.success;
                        submitOpt.failure = config.failure;
                        resourceForm.getForm().submit(submitOpt);
                        telaeris.windows[resource].hide();
                    }
                });
                telaeris.windows[resource] = new Ext.Window({
                    id: config.id,
                    items: [resourceForm],
                    closeAction: 'hide',
                    modal: true,
                    width: 640
                });
                telaeris.windows[resource].on('show', config.onShow);
            }
        },
        
        renderNav: function(){
            // now render the navigation
            var navHtml = '<ul id="resource_navigation">';
            for(var i=0; i<$navigationLinks.length; i++){
                var resourceName = $navigationLinks[i];
                navHtml += $navigationLinksHtml[resourceName];
            }
            navHtml += '</ul>';

            var nav = Ext.getCmp('navigation');
            nav.add({xtype: 'tbtext', text: navHtml});
            nav.doLayout();
        },
        
        linkTo: function(params){
            telaeris.openResource(params.resource, {autoLoad: false});
            
            if(params.id) {
                var grid = Ext.getCmp(params.resource + '_grid');
                var store = grid.store;
                var newParams = {id: params.id, filter: 'true'};
            
                store.baseParams = Ext.applyIf(newParams, store.baseParams);
                store.load({params: store.baseParams});
                    
                store.on('load', function(){
                    if(store.data.length == 0) return;
                    grid.fireEvent('rowclick', grid, 0);                
                    grid.getSelectionModel().selectFirstRow();
                }, store, {single: true});
            }
            
            if(params['values']){
                var form = Ext.getCmp(params.resource + '_grid').form;
                form.getForm().setValues(params['values']);
            }
        },
      
        editRecordFromURL: function(resourceName, this_url){
           var form = Ext.getCmp(resourceName + '_form').getForm();
           //Mask the form while we're loading
           Ext.get(resourceName + '_form').mask('Loading ' + resourceName);
           
           Ext.Ajax.request({
                method: 'GET',
                url: this_url,
                params: {
                    '_method': 'GET'
                },
                success: function(response){
                    var record = {
                            data: Ext.util.JSON.decode(response.responseText).record
                        };
                        
                        $editRecord(form, record, resourceName);
                    Ext.get(resourceName + '_form').unmask();
                },
                failure: function(){
                    Ext.get(resourceName + '_form').unmask();
                }
            });  	
        },
        
        
        openResource: function(resourceName, options){
            // if the tab already exists, just open it
            if(Ext.get(resourceName + '_tab')){
                $tabPanel.activate(resourceName + '_tab');
                return;
            }
            
            var grid = $createGrid(resourceName, options);
            var form = $createForm(resourceName, options);
            grid.store.on('load', function(){
                    if(this.data.length == 0) return;
                    this.fireEvent('rowclick', grid, 0);                
                    grid.getSelectionModel().selectFirstRow();
                }, grid.store, {single: true});
            grid.form = form;
            form.grid = grid;
            var gridContainer = {layout: 'fit', split: true, region: 'center', items: grid};
                        
            $tabPanel.add({id: resourceName + '_tab', closable: true, title: telaeris.util.titleFor(resourceName), layout: 'border', items: [form, gridContainer]});
            $tabPanel.activate($tabPanel.items.length - 1);
            Ext.getCmp(resourceName + '_tab').doLayout();
            
            // hide search fields for date ranges and checkbox filters
            Ext.select('.sext_end_range_date, .sext_checkbox_filter').each(function(){
                var formItem = this.up('div.x-form-item');
                formItem.setVisibilityMode(Ext.Element.DISPLAY);  // use display:none NOT visiliby:hidden, which hides any whitespace
                formItem.hide();
            });
        },
        
        init: function(){
            // set tabPanel on telaeris module for testing purposes
            $tabPanel = Ext.getCmp('resources_tab_panel');
            telaeris.tabPanel = $tabPanel;            
            this.renderNav();
        }
    };
}();


/**
 * Utility methods are included in telaeris.util.
 * They are just useful functions that aren't exactly core to what the normal telaeris module does.
 */
telaeris.util = function(){
    return {
        /**
         * Given an underscore string, returns the Title version with spaces with first letter capitalized
         * Examples:  'user_name' -> 'User name', 'first_name' -> 'First name', 'email_address' -> 'Email address'
         */
        titleFor: function(string){
            var header = string.replace(/(_|\.)+/g, " ");
            
            // if the string is empty just return itself
            if(!header[0]) return header;
            
            // capitalize the first letter and return value
            var start = header[0].toUpperCase();
            if(header.length > 1)
                return start + header.slice(1, header.length);
            else
                return start;
        },
        
        // For grid renderers, inside a gridConfig pass this function as a renderer option to format a date as m/d/Y
        dateFormat: Ext.util.Format.dateRenderer('m/d/Y'),
        
        // For grid renderers, inside a gridConfig pass this function as a renderer option to format a boolean as "Yes" or "No"
        boolFormat: function(value){
            return (String(value) == "true" || String(value) == "1" ? "Yes" : "No");
        },
        
        /**
         * Displays a flash message for 5 seconds at the top of the page
         */
        message: function(msg, timeout){
        	if(timeout == undefined){timeout = 5000}
            // fill in the html for #flash_message
            var msgDiv = Ext.get('flash_message');
            msgDiv.update(msg);
            msgDiv.show(true);

            // set the message count
            if(!telaeris.util.message.count || telaeris.util.message.count <= 0) telaeris.util.message.count = 0;
            telaeris.util.message.count++;
                        
            // make the message disappear after 5 seconds
            setTimeout(function(){
                telaeris.util.message.count--;
                if(telaeris.util.message.count <= 0) {
                    telaeris.util.message.count = 0;
                    msgDiv.hide(true);
                }
            }, timeout);
        },
        
        /**
         * For development purposes only (ie. do not use this function in production)
         * Given an object, displays an alert box with information about it (a list of all of its properties)
         */
        inspect: function(object){
            var properties = [];
            var output = "";
            
            for(var i in object) properties.push(i);
            properties.sort();
            for(var i = 0; i < properties.length; i++) output += properties[i] + ", ";
            
            // remove extra commas
            if(properties.length > 0) output = output.slice(0, output.length - 2);
            
            alert(output);
            return output;
        },
        
        /**
         * Does an Ext style confirmation box similar to Javascript's built in confirm() method.
         * Pass in a function as the second parameter, the function will get executed if the user clicks "Okay"
         */
        confirm: function(msg, fn){
            var newFn = function(response){
                if(response == "yes" && fn) fn();
            };
            Ext.Msg.confirm("Please Confirm", msg, newFn);
        }
    };
}();
// Tried to get the selectFirstRow method to work with this fix, but it doesnt.
// You can probably pull this out. It doesn't really effect anything. (Adam, 01/20/09).
/*Ext.override(Ext.grid.GridView, {
//use this code to override and retain original
    // private
    afterRender: Ext.grid.GridView.prototype.afterRender.createSequence(function () {
        this.fireEvent("viewready", this);//new event
    })
});
*/
/*******************************************************************************
* Main Ext Overrides for this Application:
*******************************************************************************/

// Prevents the editor from destroying a non-existant field and throwing errors.
Ext.override(Ext.Editor, {
    beforeDestroy: function() {
        if (this.field) {
            this.field.destroy();
            this.field = null;
        }
    }
});

// Added to fix IE6 TextArea issue:
// http://www.yui-ext.com/forum/showthread.php?t=65947
Ext.override(Ext.form.Field, {
    adjustWidth: function(tag, w) {
        if ((typeof w == 'number') && !this.normalWidth &&
        (Ext.isIE6 || !Ext.isStrict) && /input|textarea/i.test(tag) && !this.inEditor) {
            return w - 3;
        }
        return w;
    }
});


/* Over writing the original to include method setup */
Ext.data.JsonStore = function(c) {

    if (c.method === undefined) {
        c.method = 'POST';
    }

    Ext.data.JsonStore.superclass.constructor.call(this, Ext.apply(c, {
        proxy: !c.data ? new Ext.data.HttpProxy({
            url: c.url,
            method: c.method
        }) : undefined,
        reader: new Ext.data.JsonReader(c, c.fields)
    }));
};
Ext.extend(Ext.data.JsonStore, Ext.data.Store);

Ext.override(Ext.form.Field, {
  	afterRender : function () {
        if (this.qtipText) {
            Ext.QuickTips.register({
                target:  this.getEl(),
                title: '',
                text: this.qtipText,
                enabled: true
            });
            var label = findLabel(this);
            if (label) {
                Ext.QuickTips.register({
                    target:  label,
                    title: '',
                    text: this.qtipText,
                    enabled: true
                });
            }
        }
        Ext.form.Field.superclass.afterRender.call(this);
        this.initEvents();
        this.initValue();
  	}
});

/*
Ext.override(Ext.grid.RowSelectionModel,  {

    initEvents : function () {
        if(!this.grid.enableDragDrop && !this.grid.enableDrag){
            this.grid.on("rowmousedown", this.handleMouseDown, this);
        }
        else {
            this.grid.on("rowclick", function(grid, rowIndex, e) {
                if(e.button === 0 && !e.shiftKey && !e.ctrlKey) {
                    this.selectRow(rowIndex, false);
                    grid.view.focusRow(rowIndex);
                }
            }, this);
        }

        this.rowNav = new Ext.KeyNav(this.grid.getGridEl(), {
            "up" : function(e){
                if(!e.shiftKey){
                    this.selectPrevious(e.shiftKey);
                }else if(this.last !== false && this.lastActive !== false){
                    var last = this.last;
                    this.selectRange(this.last,  this.lastActive-1);
                    this.grid.getView().focusRow(this.lastActive);
                    if(last !== false){
                        this.last = last;
                    }
                }else{
                    this.selectFirstRow();
                }
            },
            "down" : function(e){
                if(!e.shiftKey){
                    this.selectNext(e.shiftKey);
                }else if(this.last !== false && this.lastActive !== false){
                    var last = this.last;
                    this.selectRange(this.last,  this.lastActive+1);
                    this.grid.getView().focusRow(this.lastActive);
                    if(last !== false){
                        this.last = last;
                    }
                }else{
                    this.selectFirstRow();
                }
            },
            scope: this
        });

        var view = this.grid.view;
        view.on("refresh", this.onRefresh, this);
        view.on("rowupdated", this.onRowUpdated, this);
        view.on("rowremoved", this.onRemove, this);
    },

    handleMouseDown : function(g, rowIndex, e){
        if(e.button !== 0 || this.isLocked()){
            return;
        };
        var view = this.grid.getView();
        if(e.shiftKey && this.last !== false){
            var last = this.last;
            this.selectRange(last, rowIndex, e.ctrlKey);
            this.last = last;
            view.focusRow(rowIndex);
        }else{
            var isSelected = this.isSelected(rowIndex);
            if(e.ctrlKey && isSelected){
                this.deselectRow(rowIndex);
            }else if(!isSelected || this.getCount() > 1){
                this.selectRow(rowIndex, e.ctrlKey || e.shiftKey);
            view.focusRow(rowIndex);
            }
        }
    }
});
*/

/******************************************************************************/


/**
 * The `telaeris` module handles adding resources to the application.
 * Every resource is a Model represented on the server side code.  Each resource will have
 * a form and a grid associated with it.
 */
var telaeris = function() {
    /* Private variables and functions are pre-pended with a $ */

    /* list of grid configs, with the key as the resource name */
    var $formConfigs = {};
    /* list of form configs, with the key as the resource name */
    var $navigationLinks = [];
    /* list of navigation item names (ie. 'Users', 'Jobs', 'Skills', etc...) */
    var $navigationLinksHtml = {};
    /* the actual html of each link to render */
    var $tabPanel;
    /* reference to the component #resources_tab_panel, see application.js for details */

    //Add each field from the multi-dimensional array of formFields
    //Into the flat array for allfields
    function $addFormFieldsToAllFields(formFields, allFields) {
        for (var i = 0; i < formFields.length; i++) {
            var field = formFields[i];
            if ((field.xtype == 'panel') || (field.xtype == 'fieldset') &&
            field.items && (field.items.length > 0)) {
                $addFormFieldsToAllFields(field.items, allFields);
                continue;
            }

            if (typeof field != "string") {
                field = field.name;
            }
            // in case it's a form field config
            if (allFields.indexOf(field) == -1) {
                allFields.push(field);
            }
            // make sure they're unique before pushing them
        }
    }

    /**************************************************************************
    ADD GRID CONFIG
   **************************************************************************/

    /* Given a resource name and config option, this function will add default config options and store
       it within gridConfigs for later use */
    function $addGridConfig(resourceName, config) {
        var gridFields = config.gridFields;
        var formFields = config.formFields;
        var allFields = [];
        var gridColumns = [];

        // set the defaults for configs
        Ext.applyIf(config, {
            url: "/" + resourceName,
            baseParams: {
                '_method': 'GET'
            },
            title: telaeris.util.titleFor(resourceName),
            id: resource + '_grid'
        });

        var i = 0;
        // grab all fields by combining 'gridFields' and 'formFields'
        // we need this info for the grid's unerlaying store
        for (i = 0; i < gridFields.length; i++) {
            var field = gridFields[i];
            if (typeof field != "string") {
                field = field.id;
            }
            // in case it's a grid column config
            if (allFields.indexOf(field) == -1) {
                allFields.push(field);
            }
            // make sure they're unique before pushing them
        }

        //Add each field from the multi-dimensional array of formFields
        //Into the flat array for allfields
        $addFormFieldsToAllFields(formFields, allFields);

        // These get added to all grid stores so that the models can use them
        // in the case they need to store these values.
        allFields.push('id');
        allFields.push('related_data');
        allFields.push('user_note_data');
        allFields.push('references_data');


        // now identify all the grid column configs
        for (i = 0; i < gridFields.length; i++) {
            gridColumns.push($gridColumnConfigFor(gridFields[i]));
        }

        // add allFields and gridColumns to the config
        config.allFields = allFields;
        config.gridColumns = gridColumns;

        // add grid info to gridConfigs, grid will be instantiated when needed
        telaeris.gridConfigs[resourceName] = config;
    }


    /**************************************************************************
    ADD FORM CONFIG
   **************************************************************************/
    /* Given a resource name and config options, $addFormConfig will add default options to the config object
       and will store the config under $formConfigs[resourceName] */
    function $addFormConfig(resourceName, config) {
        // set the defaults for configs
        Ext.applyIf(config, {
            url: resourceName,
            baseParams: {
                '_method': 'POST'
            },
            id: resource + '_form',
            failure: Ext.emptyFn,
            success: Ext.emptyFn
        });

        // all forms have an 'id' field that's hidden for updates, if it's blank that means the form is doing a create
        var formItems = [{
            xtype: 'hidden',
            name: 'id'
        }];
        for (var i = 0; i < config.formFields.length; i++) {
            var formItem = $formFieldConfigFor(config.formFields[i]);
            formItems.push(formItem);
            /*
            if (formItem.xtype == "checkbox") {
                formItems.push({
                    xtype: 'hidden',
                    name: formItem.name,
                    value: '0'
                });
                var checkboxFilter = {
                    xtype: 'combo',
                    name: formItem.name + '_filter',
                    fieldLabel: formItem.fieldLabel,
                    cls: 'sext_checkbox_filter',
                    displayField: 'id',
                    fields: ['id'],
                    data: [['Yes'], ['No'], ['Both']]
                };
                formItems.push($formFieldConfigFor(checkboxFilter));
            }
            */
            if (formItem.xtype == "datefield") {
                var endRangeDate = {
                    xtype: 'datefield',
                    name: formItem.name + '_end_range',
                    fieldLabel: formItem.fieldLabel + " (End Range)",
                    cls: "sext_end_range_date"
                };
                endRangeDate = $formFieldConfigFor(endRangeDate);
                formItems.push(endRangeDate);
            }
        }
        config.formItems = formItems;

        // add to $formConfigs
        $formConfigs[resourceName] = config;
    }


    /* Given resource name and config option, adds the HTML necessary for a link to $navigationLinks and $navigationLinksHtml */
    function $addNavigationLink(resourceName, config) {
        if ($navigationLinks.indexOf(resourceName) != -1) {
            return;
        }
        //already added
        config.icon = config.icon || "document.png";
        // config.header = config.header || "Resources";
        $navigationLinks.push(resourceName);
        $navigationLinksHtml[resourceName] = '<li><a href="#" onclick="telaeris.openResource(\'' + resourceName + '\'); return false;"><img src="/assets/icons/' + config.icon + '" /> ' + telaeris.util.titleFor(resourceName) + '</a></li>';

    }

    /* Takes the config for a grid column and adds in default options that are left blank */
    function $gridColumnConfigFor(column) {
        if (typeof column == "string") {
            column = {
                id: column
            };
        }
        Ext.applyIf(column, {
            header: telaeris.util.titleFor(column.id),
            sortable: true,
            dataIndex: column.id
        });
        return column;
    }

    /* If the tab is open, search the given resource using the given query.
    If a function is passed in (fn), call it after the store is loaded */
    function $doSearch(query, resourceName) {
        var grid = Ext.getCmp(resourceName + '_grid');
        var store = grid.store;
        if(query === ''){
            //Reset the searching boolean
            store.searchingData = false;
        }


        var params = {
            query: query,
            start: 0,
            limit: 40
        };

        Ext.applyIf(params, store.baseParams);

        // clear the baseParams of any filters
        //var filters = grid.form.getForm().getValues();
        //filters['filter'] = 'true';
        //for (var param in filters) {
        //    delete store.baseParams[param];
        //}

        //Define the callback function before calling load....
        store.on('load',
        function(records, operation, success, options) {
            Ext.getCmp(resourceName + '_grid').getSelectionModel().selectFirstRow();
        },
        grid, {
            single: true
        });

        store.load({
            params: params
        });
    }


    /**************************************************************************
    FORM FIELD CONFIG FOR
   **************************************************************************/

    /* Takes the config option for a form field and adds in default options that are left blank.
       If a string is passed in, assume the xtype of the field should be 'textfield'.
      */
    function $formFieldConfigFor(field) {
        if (typeof field == "string") {
            field = {
                name: field
            };
        }
        field.name = field.name || '';
        Ext.applyIf(field, {
            xtype: 'textfield',
            fieldLabel: telaeris.util.titleFor(field.name),
            msgTarget: 'under'
            //width: '70%'
            //anchor:'-20'
            //
        });



        //Recurse through panels and fieldsets
        //We want all these parameters applied to those items also.
        if ((field.xtype == 'panel') || (field.xtype == 'fieldset') &&
        (field.items && field.items.length > 0)) {
            var i = 0;
            for (i = 0; i < field.items.length; i++) {
                $formFieldConfigFor(field.items[i]);
            }
            return field;
        }



        // apply defaults for combos
        if (field.xtype == 'combo') {
            if (field.url) {
                field.store = new Ext.data.JsonStore({
                    url: field.url,
                    totalProperty: 'count',
                    baseParams: {
                        '_method': 'GET'
                    },
                    root: 'records',
                    autoLoad: (field.autoLoad !== undefined ? field.autoLoad: true),
                    fields: ['id', field.displayField]
                });
            } else if (field.data) {
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
                minListWidth: 200,
                triggerAction: 'all',
                mode: 'remote',
                editable: true,
                selectOnFocus: true,
                valueField: 'id',
                listeners:{
                blur:{
                		fn:function() {
	                    if(!this.getRawValue()) {
	                        this.setValue();
	                    }
	                }}
            		},
                hiddenName: field.name,
                title: "Select " + field.fieldLabel
            });
            if (field.fieldLabel.match(/ id$/) && field.name.match(/_id$/)) {
                field.fieldLabel = field.fieldLabel.slice(0, field.fieldLabel.length - 3);
            }
        }

        // apply defaults for datefields
        if (field.xtype == "datefield") {
            Ext.applyIf(field, {
                altFormats: "m/d/Y|Y-m-d|Y/m/d",
                format: 'm/d/Y'
            });
        }

        // now apply defaults for certain xtypes
        if (field.xtype == 'checkbox') {
            Ext.applyIf(field, {
                inputValue: 1,
                style: 'margin-top: 6px;'
            });
        }

        return field;
    }



    /**************************************************************************
    CREATE CSV UPLOAD WINDOW
   **************************************************************************/

    function $createCSVUploadWindow(thisURL, thisName, grid_id) {
        var resourceForm = new Ext.form.FormPanel({
            method: "POST",
            anchor: '85%',
            defaults: {
                anchor: '-20'
            },
            labelAlign: 'left',
            autoScroll: false,
            buttonAlign: 'left',
            layout: 'fit',
            height: 100,
            fileUpload: true,
            title: "Select " + thisName + " CSV for Upload",
            border: true,
            bodyStyle: 'padding: 4px;',
            items: [{
                id: 'upload_field',
                xtype: 'textfield',
                fieldLabel: 'File',
                name: 'file_upload',
                inputType: 'file'
            }]
        });
        resourceForm.addButton({
            text: 'Save Data',
            handler: function() {
                var submitOpt = {
                    waitMsg: 'Saving File ...',
                    method: 'POST',
                    url: thisURL
                };
                submitOpt.success = function() {
                    telaeris.util.message("File Uploaded successfully");
                    var store = Ext.getCmp(grid_id).store;
                    store.load({
                        params: store.lastOptions.params
                    });
                };
                submitOpt.failure = function(request, response) {
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

    /**************************************************************************
    CREATE GRID
   **************************************************************************/
    /* Instantiates a new Ext GridPanel given a resourceName.  The resource config options should have already been made via telaeris.resources function.
       This function will just look up the resourceName in gridConfigs and create a new grid from that.  The grid will:
       * have a JsonStore
       * have pagination already included
       * support searching
       * handle rowclicks by retrieving data and filling out the related form
     */
    function $createGrid(resourceName, options) {
        var resourceStore;
        var resourceGrid;
        var config = telaeris.gridConfigs[resourceName];

        /*
        var csvDownloadButton = new Ext.Button({
            text: 'Download ' + resourceName + ' CSV',
            handler: function() {
                Ext.Msg.show({
                    title: 'Please Confirm',
                    msg: 'Do you want to include Readable Names Instead of IDs?',
                    buttons: Ext.Msg.YESNOCANCEL,
                    fn: function(response) {
                        if (response == "yes") {
                            window.open(config.url + '/csv_export/?related_values=true');
                        }
                        else if (response == "no") {
                            window.open(config.url + '/csv_export');
                        }
                    }
                });
            }
        });
        var csvUploadButton = new Ext.Button({
            text: 'Upload ' + resourceName + ' CSV',
            handler: function() {
                $createCSVUploadWindow(config.url + '/csv_import', resourceName, config.id);
            }
        });*/

        var resourceSearchBox = new Ext.form.TwinTriggerField({
            id: resourceName + '_search',
            emptyText: "search " + resourceName,
            trigger1Class: 'x-form-search-trigger',
            trigger2Class: 'x-form-clear-trigger',
            onTrigger1Click: function() {
                //Trigger2 is a search
                var v = this.getValue();
                if (v.length > 0) {
                    telaeris.util.message(resourceName + ' search for \'' + v + '\'');
                    //$doSearch(v, resourceName,Ext.getCmp(resourceName + '_grid').getSelectionModel().selectFirstRow);
                    $doSearch(v, resourceName);
                }
                else {
                    this.setValue('');
                    $doSearch('', resourceName);
                    //this.triggerBlur();
                }
            },
            onTrigger2Click: function() {
                //Trigger2 is a clear
                this.setValue('');
                $doSearch('', resourceName);

            }
        });
        //Enter is a search
        resourceSearchBox.on('specialkey',
        function(f, e) {
            if (e.getKey() == e.ENTER) {
                e.preventDefault();
                this.onTrigger1Click();
            }
        });


        options = options || {};
        Ext.applyIf(options, {
            autoLoad: false
        });

        config.gridConfig = config.gridConfig || {};

		Ext.applyIf(config.baseParams, {
			'_method': 'GET',
			'filter2': '',
			limit: 40
		});

        config.gridConfig.sortInfo = config.gridConfig.sortInfo || {};

        config.gridConfig.groupingStore = config.gridConfig.groupingStore || false;
		config.gridConfig.groupingStoreConfig = config.gridConfig.groupingStoreConfig || {};

        if (config.gridConfig.groupingStore === true) {
            var ourReader = new Ext.data.JsonReader({
                url: config.url,
                baseParams: config.baseParams,
                totalProperty: 'count',
                root: 'records',
                fields: config.allFields
            });


            resourceStore = new Ext.data.GroupingStore(Ext.applyIf(config.gridConfig.groupingStoreConfig, {
                url: config.url,
                groupField: config.gridConfig.groupingField,
                baseParams: config.baseParams,
                proxy: new Ext.data.HttpProxy(Ext.apply(config.baseParams, {
                    url: config.url
                })),
                reader: ourReader,
                autoLoad: options.autoLoad,
                remoteSort: true,
                remoteGroup: false,
                unGrouped: false,
                sortInfo: Ext.applyIf(config.gridConfig.sortInfo, {
                    field: config.gridColumns[1].id,
                    direction: "ASC"
                })
            }));
        }
        else{
            resourceStore = new Ext.data.JsonStore({
                url: config.url,
                baseParams: config.baseParams,
                autoLoad: options.autoLoad,
                totalProperty: 'count',
                root: 'records',
                fields: config.allFields,
                remoteSort: true,
                sortInfo: Ext.applyIf(config.gridConfig.sortInfo, {
                    field: config.gridColumns[0].id,
                    direction: "ASC"
                })
            });
        }
        resourceStore.searchingData = false;


        var buttonBarItems = [];

        config.gridConfig.noSearchButton = config.gridConfig.noSearchButton || false;

        if (config.gridConfig.noSearchButton === false) {
            buttonBarItems.push({
                xtype: 'tbbutton',
                text: 'List All',
                iconCls: 'icon-list-view',
                handler: function() {


                    var grid = Ext.getCmp(resourceName + '_grid');

                    //reset the sort info if it exists
                    if(config.gridConfig.sortInfo){
                        grid.store.sortInfo = config.gridConfig.sortInfo;
                    }
                    else{
                        //Clear out the sortInfo
                        delete grid.store.sortInfo;
                    }

                    Ext.getCmp(resourceName + '_search').setValue('');
                    $doSearch('', resourceName);

                    //Reset the searching boolean(should be ond inside doSearch anyways)
                    grid.store.searchingData = false;
                    if (grid.form) {
                    	grid.form.getForm().reset();
                    }
                }
            });
        }


        config.gridConfig.addButton = config.gridConfig.addButton || {};
        //Apply the default Add Record button if it's not overridden
        Ext.applyIf(config.gridConfig.addButton, {
            xtype: 'tbbutton',
            text: 'Add Record',
            iconCls: 'icon-plus',
            handler: function() {
                Ext.getCmp(resourceName + '_form').getForm().reset();
                Ext.DomHelper.overwrite(resourceName + '_related_data', '');
                $formConfigs[resourceName].maximizeForm();
            }
        });

        config.gridConfig.noAddButton = config.gridConfig.noAddButton || false;

        if (
        ((currentUser.admin === true) || (config.gridConfig.addButton.allCanAdd === true)) &&
        (config.gridConfig.noAddButton !== true)
        ) {
            buttonBarItems.push(config.gridConfig.addButton);
        }

        // Add any other bottom toolbar buttons
        if (config.gridConfig.additionalButtons) {
        	var additionalButtons = config.gridConfig.additionalButtons;
        	var adButtonsLen = additionalButtons.length;
        	for (var i = 0; i < adButtonsLen; i++) {
               	buttonBarItems.push(additionalButtons[i]);
            }
        }

        buttonBarItems.push({xtype: 'tbfill'});


        if (config.gridConfig.helpText) {
        	buttonBarItems.push({
        		xtype: 'tbbutton',
        		text: '',
               tooltip: 'Help Center',
        		iconCls: 'icon-help',
        		handler: function () {
        			var window = new Ext.Window({
        				title: 'Help Center',
        				width: 400,
        				y: 200,
        				items: [
        					{
        						xtype: 'panel',
        						html: config.gridConfig.helpText,
//        						bodyStyle: 'padding: 10px;',
        						cls: 'help-text'
        					}
        				]
        			});

        			window.show();
        		}
        	});
        }

        if (config.gridConfig.advSearch) {
            buttonBarItems.push({xtype: 'tbspacer'});
            buttonBarItems.push({
                xtype: 'tbbutton',
                text: 'Advanced Search',
                tooltip: 'Advanced Search',
                iconCls: 'icon-magnifier-zoom-in',
                handler: config.gridConfig.advSearch.handler
            });
        }

        buttonBarItems.push({xtype: 'tbspacer'});
        buttonBarItems.push(resourceSearchBox);
        config.gridConfig.noPaging = config.gridConfig.noPaging || false;
        var buttonBar;
		var topBar;

        if (config.gridConfig.noPaging === true) {
            //add a parameter
            resourceStore.baseParams.all_index = "true";
            topBar = new Ext.Toolbar({
                items: buttonBarItems
            });
        }
        else {
            topBar = new Ext.Toolbar({
                items: buttonBarItems
            });

			var pageSize = config.gridConfig.pageSize || config.baseParams.limit;
            buttonBar = new Ext.PagingToolbar({
                id: config.id + '_toolbar',
                store: resourceStore,
                //displayInfo: true,
                pageSize: pageSize,
                listeners:{
                    'beforechange':function(toolbar,params){
                        if(toolbar.store.searchingData){
                            //Keep the previous parameters from the store.
                            var new_params = {};
                            //Copy the last params
                            Ext.apply(new_params,toolbar.store.lastOptions.params);
                            //Overwrite them with the new params(start,limit)
                            Ext.apply(new_params,params);
                            //Copy them back...
                            Ext.apply(params,new_params);
                        }

                    }
                }
            });
        }

        Ext.applyIf(config.gridConfig, {
            stripeRows: true,
            columns: config.gridColumns,
            viewConfig: {
                forceFit: true
            },
            height: 200,
            autoScroll: false,
            loadMask: true,
            id: config.id,
            deferRowRender: false,
            cellDoubleClick: false,
            tbar: null,
            bbar: null
        });

        Ext.apply(config.gridConfig, {
            bbar: buttonBar,
            tbar: topBar,
            store: resourceStore
        });

        resourceGrid = new Ext.grid.GridPanel(config.gridConfig);

        if (resourceGrid.getSelectionModel().hasListener('rowselect') === false) {
            resourceGrid.getSelectionModel().on('rowselect',
            function(selectModel, rowIndex) {
                resourceGrid.fireEvent('rowclick', resourceGrid, rowIndex);
            });
        }
        if (resourceGrid.hasListener('rowclick') === false) {
            resourceGrid.on('rowclick',
            function(grid, rowIndex) {
                var record = grid.getStore().getAt(rowIndex);
                var form = grid.form ? grid.form.getForm() : null;
				if (form) {
                	telaeris.editRecord(form, record, resourceName);
                }
            });
        }

        if ((config.gridConfig.refreshStores !== undefined)) {
        	var storesToRefresh = config.gridConfig.refreshStores;

        	var storeRefresher = function () {
        		var stores = storesToRefresh;
		        	var storeCount = stores.length;
		        	var storeName = '';
	        	for (var j = 0; j < storeCount; j++) {
	        		storeName = stores[j];
	        		telaeris.stores[storeName].load();
	        	}
            };
        	resourceGrid.store.on('load', storeRefresher);
        }

        var previousContextMenus = resourceGrid.hasListener('rowcontextmenu');


        resourceGrid.on('rowcontextmenu',
        function(grid, rowIndex, ajaxEvent) {
            //Add a selection of the row which was right clicked before the context menu
            grid.getSelectionModel().selectRow(rowIndex, true);
        });

		if (resourceGrid.cellDoubleClick) {
			resourceGrid.on('celldblclick', resourceGrid.cellDoubleClick);
		}

        if (previousContextMenus === false) {
            resourceGrid.on('rowcontextmenu',

            function(grid, rowIndex, ajaxEvent) {
                var menuItems = [];
                config.gridConfig.otherMenuItems = config.gridConfig.otherMenuItems || [];



               	var otherMenuItems = config.gridConfig.otherMenuItems;
	        	var otherMenuItemsLen = otherMenuItems.length;
	        	for (var i = 0; i < otherMenuItemsLen; i++) {
	               	menuItems.push(otherMenuItems[i]);
	            }

                if (currentUser.admin === true) {
                    menuItems.push({
                        text: 'Delete Record',
                        handler: telaeris.util.deleteHandler.createCallback(grid, rowIndex),
                        iconCls: 'icon-cross'
                    });
                }

                if (menuItems.length > 0) {
                    var menu = new Ext.menu.Menu({
                        allowOtherMenus: false,
                        items: menuItems
                    });

                    ajaxEvent.stopEvent();
                    menu.showAt(ajaxEvent.getXY());
                }
            });
        }
        resourceGrid.resourceName = resourceName;

        return resourceGrid;
    }


    /**************************************************************************
    CREATE FORM
   **************************************************************************/

    // Creates the Form
    function $createForm(resourceName) {
        var config = $formConfigs[resourceName];
        var formItems = config.formItems;

        formItems.push({
         	xtype: 'box',
		    autoEl: {
		        tag: 'div',
	        	'class': 'related_data',
	        	id: resourceName + '_related_data',
	        	html: ''
		    }
		});

        // User notes
        Ext.applyIf(config.formConfig, {
            showUserNotes: true,
            hasReferences: false
        });
        // Sets default
        if (config.formConfig.showUserNotes === true) {
            var notes_header_tpl = '';
            // Hides the edit link for non-admins
            var notes_data_tpl = '';
            if (currentUser.admin) {
                // Shows the edit link for admins
                notes_header_tpl = '<th>Links</th>';
                notes_data_tpl = '<td><a href="#" onclick="return telaeris.openResource(\'user_notes\', {maximizeForm:true, title: \'User Notes\', record_url:\'/user_notes/{id}\' });">(edit note)</a></td>';
            }
            formItems.push({
                // Builds the form table of notes
                fieldLabel: 'User Notes',
                id: resourceName + '_user_note_data',
                xtype: 'notesview',
                name: 'user_note_data',
                tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th  style="width: 70px;">Note Text</th><th>Submitted By</th><th>Status</th><th>Reason</th>', notes_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{note:htmlEncode}</td>', '<td class="detail_note">{submitting_user:htmlEncode}</td>', '<td class="detail_note">{status:htmlEncode}</td>', '<td class="detail_note">{reason:htmlEncode}</td>', notes_data_tpl, '</tr>', '</tpl>', '</table>'),
                width: 550,
                store: new Ext.data.JsonStore({
                    autoLoad: false,
                    fields: ['note', 'submitting_user', 'status', 'id', 'reason'],
                    data: []
                })
            });
        }

        // References: Gets added to the bottom of the form if hasReferences == true.
        if (config.formConfig.hasReferences === true) {
            var notes_header_tpl = '';
            // Hides the edit link for non-admins
            var notes_data_tpl = '';
            if (currentUser.admin) {
                // Shows the edit link for admins
                notes_header_tpl = '<th>Admin</th>';

                notes_data_tpl = '<td><a href="#" onclick="telaeris.util.deleteReferenceAndReload(\'/piping_reference_attachings/{piping_reference_attaching_id}\', Ext.getCmp(\'' + resourceName + '_grid\').getStore(), \'{description}\', {}); return false;">(remove)</a></td>';
            }
            formItems.push({
                // Builds the form table of notes
                fieldLabel: 'References',
                id: resourceName + '_references_data',
                xtype: 'notesview',
                name: 'references_data',
                tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th style="width: 200px;">Description</th>', '<th style="width: 50px;">Type</th>', notes_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note"><a href="#" onclick="telaeris.openURL(\'{link}\'); return false;">{description:htmlEncode}</a></td>', '<td class="detail_note">{reference_type}</td>', notes_data_tpl, '</tr>', '</tpl>', '</table>'),
                width: 550,
                store: new Ext.data.JsonStore({
                    autoLoad: false,
                    fields: ['id', 'description', 'link', 'reference_type', 'piping_reference_attaching_id'],
                    data: []
                })
            });
        }

        formItems.push({
         	xtype: 'box',
		    autoEl: {
		        tag: 'div',
	        	'class': 'related_data',
	        	id: resourceName + '_edit_note',
	        	html: ''
		    }
		});

        // Sets the main form callback functions
        config.formConfig = config.formConfig || {};
        config.formConfig.success = config.formConfig.success || Ext.emptyFn;
        config.formConfig.failure = config.formConfig.failure || Ext.emptyFn;

        // Sizing functions
        config.minimizeForm = function() {
            //Ext.getCmp(resourceName + '_form').setHeight(50);
            //var size = Ext.getCmp(resourceName + '_tab').getEl().getHeight();
            //Ext.getCmp(resourceName + '_tab').layout.north.getSplitBar().setCurrentSize(50);
            if (Ext.getCmp(resourceName + '_tab')) {
                var size = Ext.getCmp(resourceName + '_tab').getEl().getHeight();
                Ext.getCmp(resourceName + '_north').setHeight(size - 75);
                Ext.getCmp(resourceName + '_north').ownerCt.doLayout();
                config.restoreForm();
            }
        };
        config.maximizeForm = function() {
            if (Ext.getCmp(resourceName + '_north') && Ext.getCmp(resourceName + '_maximize')) {
                Ext.getCmp(resourceName + '_north').hide();
                Ext.getCmp(resourceName + '_maximize').hide();
                Ext.getCmp(resourceName + '_restore').show();
                Ext.getCmp(resourceName + '_tab').doLayout();
            }
            Ext.getCmp('resources_tab_panel').el.toggle();
            Ext.getCmp('resources_tab_panel').el.toggle();
        };
        config.restoreForm = function() {
            if (Ext.getCmp(resourceName + '_north') && Ext.getCmp(resourceName + '_maximize')) {
                Ext.getCmp(resourceName + '_north').show();
                Ext.getCmp(resourceName + '_maximize').show();
                Ext.getCmp(resourceName + '_restore').hide();
                Ext.getCmp(resourceName + '_tab').doLayout();
            }

            Ext.getCmp('resources_tab_panel').el.toggle();
            Ext.getCmp('resources_tab_panel').el.toggle();
        };

        // Sets form defaults
        Ext.applyIf(config.formConfig, {
            items: formItems,
            id: resourceName + '_form',
            region: 'center',
            onSubmit: Ext.emptyFn,
            method: "POST",
            labelAlign: 'left',
            autoScroll: true,
            buttonAlign: 'left',
            labelWidth: 150,
            anchor: '85%',
            defaults: {
                anchor: '-20'
            },
            //autoHeight: true,
            //collapsible: true,
            //title: "Details",
            //autoScroll: true,
            //split: true,
            height: 100,
            /*toolTarget: 'tbar',
            tools: [{
                id: 'restore',
                handler: config.restoreForm
            },
            {
                id: 'maximize',
                handler: config.maximizeForm
            }],*/

            border: true,
            bodyStyle: 'padding: 4px;',
            showUserNotes: true
        });

    // Form title
        var new_title = config.formConfig.title;
        if ((new_title) && (new_title !== '')) {
            delete config.formConfig.title;
        }
        else {
            new_title = "Details";
        }
        // Toobar Items
        var tbarItems = [{id: resourceName + '_form_top_toolbar_title',xtype: 'tbtext', text: ("<span style='font-weight: bold;'>" + new_title+ "</span>")},
        {
            xtype: 'tbfill'
        }];

        tbarItems.push({
         //   xtype: 'button',
            id: resourceName + '_minimize',
            icon: '/assets/minimize.gif',
            handler: config.minimizeForm
        });
        tbarItems.push({
           // xtype: 'button',
            id: resourceName + '_maximize',
            icon: '/assets/maximize.gif',
            handler: config.maximizeForm
        });

        tbarItems.push({
            //xtype: 'button',
            id: resourceName + '_restore',
            hidden: true,
            icon: '/assets/restore.gif',
            handler: config.restoreForm
        });

        tbarItems.push({
            xtype:'tbspacer',
            width:15
        });

/*
        // Top Toolbar
        config.formConfig.tbar = new Ext.ux.CoolToolbar({
            id: resourceName + '_header',
            title: new_title,
            items: tbarItems
        });*/
        config.formConfig.tbar = new Ext.Toolbar({
            cls: 'x-panel-header',
            id: resourceName + '_header',
            title: new_title,
            items: tbarItems
        });
        config.formConfig.bbar = [];

        // Bottom Toolbar
        // Allows for config-overridable array of bottom toolbar buttons
        if (config.formConfig.saveButtonReplacement && (config.formConfig.saveButtonReplacement !== null)) {
        	var saveButtonReplacement = config.formConfig.saveButtonReplacement;
        	var saveButtonsLen = saveButtonReplacement.length;
        	for (var i = 0; i < saveButtonsLen; i++) {
               	config.formConfig.bbar.push(saveButtonReplacement[i]);
            }
        }
        else {
            if (currentUser.admin === true) {
                // Default "Save" button
                config.formConfig.bbar.push({
                    xtype: 'button',
                    text: 'Save Data',
                    iconCls: 'icon-disk',
                    // Button press
                    handler: function() {
                        var submitOpt = {
                            waitMsg: 'Saving data ...',
                            method: 'POST',
                            params: {}
                        };
                        Ext.apply(submitOpt, {
                            url: config.url
                        });
                        Ext.apply(submitOpt.params, config.baseParams);
                        var recordId = form.getForm().getValues().id;
                        // If the form has an assigned record ID, assume "update" (PUT)
                        if (recordId && recordId.match(/\d+/)) {
                            submitOpt.params['_method'] = 'PUT';
                            submitOpt.url = submitOpt.url + '/' + recordId;
                            submitOpt.success = function(basicForm, action) {
                                // Grabs the id of the saved record.
                                var recordId = action.result.record.id;

                                // Grabs the store of the associated grid.
                                var store = form.grid.store;

                                // After load, scrolls to the saved record's row
                                // and selects it so you know which record
                                // was just edited.
                                store.on('load',
                                function() {
                                    var rowNumber = store.find('id', recordId);
                                    form.grid.getView().focusRow(rowNumber);
                                    form.grid.getSelectionModel().selectRow(rowNumber);
                                },
                                this, {
                                    single: true
                                });

                                store.load({
                                    params: store.lastOptions.params
                                });


                                telaeris.util.message("Data was saved successfully");
                                config.formConfig.success();
                            };
                        }
                        // If for does not have an assigned record ID, assume "create" (PUT)
                        else {
                            submitOpt.params['_method'] = 'POST';
                            submitOpt.success = function(basicForm, action) {
                                // Grabs the id of the saved record.
                                var recordId = action.result.record.id;

                                // Grabs the store of the associated grid.
                                var store = form.grid.store;

                                // After load, scrolls to the saved record's row
                                // (if it is in the shown list)
                                // and selects it so you know which record
                                // was just created.
                                store.on('load',
                                function() {
                                    var rowNumber = store.find('id', recordId);
                                    if (rowNumber > -1) {
                                        form.grid.getView().focusRow(rowNumber);
                                        form.grid.getSelectionModel().selectRow(rowNumber);
                                    }
                                },
                                this, {
                                    single: true
                                });

                                store.load({
                                    params: store.lastOptions.params
                                });
                                telaeris.util.message("New record successfully created");
                                form.getForm().reset();
                                config.formConfig.success();
                            };
                        }

					    submitOpt.failure = function submitFailure(form, action) {
					    	if (action.failureType == Ext.form.Action.CONNECT_FAILURE) {
						    	telaeris.util.message("There was a server error and Administrators have been notified.");
						    }
					    };

                        form.getForm().submit(submitOpt);
                    }
                });
                /*
                if (telaeris.allConfigs[resourceName].gridConfig.advSearch) {
                    config.formConfig.bbar.push(
                    {
                        id:'cancel_advanced_search_' + resourceName,
                        xtype: 'tbbutton',
                        text: 'Cancel Advanced Search',
                        tooltip: 'Cancel Advanced Search',
                        iconCls: 'icon-clear-form',
                        hidden:true,
                        handler: telaeris.allConfigs[resourceName].gridConfig.advSearch.cancelHandler
                    });
                }

                config.formConfig.bbar.push({
                	xtype: 'tbspacer'
                });
                config.formConfig.bbar.push({
                	xtype: 'tbspacer'
                });*/
                config.formConfig.bbar.push({
                	xtype: 'tbseparator'
                });
                config.formConfig.bbar.push({
                	xtype: 'tbspacer'
                });
                config.formConfig.bbar.push({
                	xtype: 'tbspacer'
                });
            }
        }

        // Adds a "Search Data" button that searches all records using
        // the field values typed into the form fields.
        //Set noSearchButton to something other than false in formConfig to remove it
        config.formConfig.noSearchButton = config.formConfig.noSearchButton || false;
        if (config.formConfig.noSearchButton === false) {
            config.formConfig.bbar.push({
                text: 'Search Data',
                iconCls: 'icon-magnifier',
                handler: function() {
                    var store = form.grid.store;
                    var newParams = form.getForm().getValues();
                    delete newParams.id;
                    newParams.filter = "true";

                    //store.baseParams = Ext.applyIf(newParams, store.baseParams);
                    store.load({
                        params: newParams
                    });

                    store.searchingData = true;
                    //if we've defined a function to run after a search, run it now.
                    //This might have to happen in a single event on load for the store.
                    if (config.formConfig.afterSearch){
                        config.formConfig.afterSearch();
                    }

                    form.getForm().setValues(newParams);
                }
            });
            config.formConfig.bbar.push({
                text: 'Clear Form',
                iconCls: 'icon-clear-form',
                handler: function() {
                    form.getForm().reset();
                }
            });
        }

        // Add a blank filler to push the next buttons to the right.
        config.formConfig.bbar.push({
            xtype: 'tbfill'
        });

        // Add any other bottom toolbar buttons
        if (config.formConfig.additionalButtons) {
        	var additionalButtons = config.formConfig.additionalButtons;
        	var adButtonsLen = additionalButtons.length;
        	for (var i = 0; i < adButtonsLen; i++) {
               	config.formConfig.bbar.push(additionalButtons[i]);
            }
        }

        // Add a "Add Reference" button to each form bottom bar unless hasReferences
        // has been explicitly set to "false".
        if (config.formConfig.hasReferences === true &&
        	config.formConfig.referencesClass &&
        	currentUser.popv_viewer === false
        )
        {
            config.formConfig.bbar.push({
                xtype: 'tbbutton',
                text: 'Add Reference',
                iconCls: 'icon-note-add',
                handler: function() {
                    var attachable_type = config.formConfig.referencesClass;
                    var attachable_id = Ext.getCmp(resourceName + '_form').getForm().getValues(false).id;
                    showReferencesWindow(attachable_type, attachable_id);
                }
            });
        }

        // Add a "Add User Note" button to each form bottom bar unless showUserNotes
        // has been explicitly set to "false".
        // has been explicitly set to "false".
        if (config.formConfig.showUserNotes === true && currentUser.popv_viewer === false) {
            config.formConfig.bbar.push({
                xtype: 'tbbutton',
                text: 'Add User Note',
                iconCls: 'icon-note-add',
                handler: function() {
                    var form = Ext.getCmp(resourceName + '_form');
                    var basicForm = form.getForm();
                    var values = basicForm.getValues(false);
                    // Grabs all fields worth referencing
                    var record_id = values.id;
                    var our_fields = [];
                    var item;
                    // Loops through each data field, grabbing the name,
                    // and looking up the actual form fields by that name.
                    // Then filters out certain xtypes, and adds them
                    // to the array for loading into the UserNotes data store.
                    for (var prop in values) {
                        item = form.find('name', prop);
                        item = item[0];
                        if (!item) {
                        	continue;
                        }
                        else {
	                        if ((item.xtype != 'hidden') &&
	                        	(item.xtype != 'tbtext') &&
	                        	(item.name != 'id') &&
	                        	(item.xtype != 'checkbox')
	                        )
	                        {
	                            our_fields.push(item);
	                        }
	                    }
                    }

                    // Loads the data and shows the window.
                    createUserNotesWindow(resourceName, record_id, our_fields);
                }
            });
        }

        var form = new Ext.form.FormPanel(config.formConfig);
        return form;
    }

    /******************************************************************************
  RETURN
******************************************************************************/
    return {
        stores: {},
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
        resources: function(resourceConfigs) {
            for (resource in resourceConfigs) {

                var config = resourceConfigs[resource];
                telaeris.allConfigs[resource] = config;
                if (config.isHeader) {
                    $navigationLinks.push(resource);
                    var title = '';
                    if (config.title) {
                        title = config.title;
                    }
                    else {
                        title = telaeris.util.titleFor(resource);
                    }
                    $navigationLinksHtml[resource] = '<li class="header">' + title + '</li>';
                }
                else if (config.isHtml || config.panel) {
                    Ext.applyIf(config.title, config.id);
                }
                else {
                    Ext.applyIf(config.title, config.id);
                    // add the grid config.  the object isn't actually created here
                    $addGridConfig(resource, {
                        url: config.url,
                        baseParams: config.baseParams,
                        title: config.title,
                        id: config.id,
                        formFields: config.formFields,
                        //needs to know for hidden fields.
                        gridFields: config.gridFields,
                        gridConfig: config.gridConfig
                    });

                    config.noForm = config.noForm || false;
                    if (config.noForm !== true) {
                        // now add the form
                        $addFormConfig(resource, {
                            url: config.url,
                            baseParams: config.baseParams,
                            id: config.id,
                            formFields: config.formFields,
                            formConfig: config.formConfig
                        });
                    }
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
         *
         *		Set "windowFormButtons = false" to prevent any buttons from showing.
         */
        windows: function(resourceConfigs) {
            for (resource in resourceConfigs) {
                var resourceName = resource;
                var config = resourceConfigs[resource];
                Ext.applyIf(config, {
                    url: resourceName,
                    id: resourceName + "_window",
                    formID: resourceName + "_window_form",
                    baseParams: {},
                    //title: telaeris.util.titleFor(resourceName),
                    onSubmit: Ext.emptyFn,
                    success: Ext.emptyFn,
                    failure: Ext.emptyFn,
                    onShow: Ext.emptyFn
                });
                var formPanelItems = [];
                for (var i = 0; i < config.formFields.length; i++) {
                    var formItem = $formFieldConfigFor(config.formFields[i]);
                    formPanelItems.push(formItem);
                    /*
                    if (formItem.xtype == "checkbox") {
                        formPanelItems.push({
                            xtype: 'hidden',
                            name: formItem.name,
                            value: '0'
                        });
                    }*/
                }
                config.formConfig = config.formConfig || {};
                Ext.applyIf(config.formConfig, {
                    id: config.formID,
                    method: "POST",
                    anchor: '85%',
                    defaults: {
                        anchor: '-20'
                    },
                    labelAlign: 'left',
                    autoScroll: false,
                    buttonAlign: 'left',
                    labelWidth: 150,
                    border: true,
                    bodyStyle: 'padding: 4px;',
                    items: formPanelItems
                });

                var resourceForm = new Ext.form.FormPanel(config.formConfig);

                // Adds the window buttons.
                if (config.windowFormButtons && (config.windowFormButtons.length > 0)) {
                    for (i = 0; i < config.windowFormButtons.length; i++) {
                        resourceForm.addButton(config.windowFormButtons[i]);
                    }
                }
                else if (config.windowFormButtons !== false) {
                    resourceForm.addButton({
                        text: 'Save Data',
                        handler: function() {
                            var submitOpt = {
                                waitMsg: 'Saving data ...',
                                method: 'POST',
                                url: config.url,
                                params: config.baseParams
                            };
                            submitOpt.success = config.success;
                            submitOpt.failure = config.failure;
                            var form_values = resourceForm.getForm().getValues();
                            Ext.apply(submitOpt.params, form_values);
                            resourceForm.getForm().submit(submitOpt);
                            telaeris.windows[resourceName].hide();
                        }
                    });
                }
                config.listeners = config.listeners || {};

                config.windowConfig = config.windowConfig || {};

                Ext.applyIf(config.windowConfig, {
                    id: config.id,
                    items: [resourceForm],
                    closeAction: 'hide',
                    title: config.title,
                    modal: true,
                    listeners: config.listeners,
                    width: 640,
                    y: 130
                });
                telaeris.windows[resourceName] = new Ext.Window(config.windowConfig);

            }
        },

        renderNav: function() {
            // now render the navigation
            var navHtml = '<ul id="resource_navigation">';
            for (var i = 0; i < $navigationLinks.length; i++) {
                var resourceName = $navigationLinks[i];
                navHtml += $navigationLinksHtml[resourceName];
            }
            navHtml += '</ul>';

            var nav = Ext.getCmp('navigation_panel');
            nav.add({
                xtype: 'tbtext',
                text: navHtml
            });
            nav.doLayout();
        },

        linkTo: function(params) {
            telaeris.openResource(params.resource, {
                autoLoad: false
            });

            if (params.id) {
                var grid = Ext.getCmp(params.resource + '_grid');
                var store = grid.store;
                var newParams = {
                    id: params.id,
                    filter: 'true'
                };

                store.baseParams = Ext.applyIf(newParams, store.baseParams);
                store.load({
                    params: store.baseParams
                });

                /*
                store.on('load',
                function() {
                    if (store.data.length == 0) return;
                    //grid.fireEvent('rowclick', grid, 0);
                    grid.getSelectionModel().selectFirstRow();
                },
                store, {
                    single: true
                });*/
            }

            if (params.values) {
                var form = Ext.getCmp(params.resource + '_grid').form;
                form.getForm().setValues(params.values);
            }
        },
        updateRelatedData: function(form, record, resourceName) {

            var relatedData = Ext.get(resourceName + '_related_data');
            Ext.DomHelper.overwrite(resourceName + '_related_data', '');
            //relatedData = relatedData.replaceWith({tag: 'table', id: resourceName + '_related_data'});
            //relatedData = Ext.get(resourceName + '_related_data')
            if (record && record.data && record.data.related_data && (record.data.related_data.length > 0)) {
                var rdHtml = "<table>";

                if (record.data.related_data[0].secondary) {
                    rdHtml += '<tr><th colspan="' + (record.data.related_data[0].secondary.length + 2) + '">Related Data</th></tr>';
                }
                else {
                    rdHtml += '<tr><th colspan="3">Related Data</th></tr>';
                }

                for (var i = 0; i < record.data.related_data.length; i++) {
                    var row = record.data.related_data[i];
                    var rowValue = row.value;
                    var secondary = '';
                    if (row.command) {
                        var cmd = row.command;
                        var args = row.args || {};
                        cmd = cmd + "(" + Ext.util.JSON.encode(args) + "); return false;";
                        rowValue = '<a href="#" onclick=\'' + cmd + '\'>' + rowValue + '</a>';
                    }

                    if (row.secondary) {
                        for (var j = 0; j < row.secondary.length; j++) {
                            var cmd = row.secondary[j].command;
                            var confirm = row.secondary[j].confirm;
                            var args = row.secondary[j].args || {};
                            var label = row.secondary[j].label;
                            if (cmd) {
                                cmd = cmd + "(" + Ext.util.JSON.encode(args) + ", event); return false;";
                                if (confirm) {
                                    cmd = 'telaeris.util.confirm("' + confirm + '", function(){' + cmd + '});';
                                }
                                secondary += '<a href="#" onclick=\'' + cmd + '\'>' + label + '</a>';
                            }
                            else {
                                secondary += label + '</td><td class="secondary">';
                            }
                        }
                    }

                    rdHtml += '<tr><td>' + row.label + '</td><td>' + rowValue + '</td><td class="secondary">' + secondary + '</td></tr>';
                }
                rdHtml += "</table>";
                Ext.DomHelper.overwrite(resourceName + '_related_data', rdHtml);
            }

        },
        editRecord: function(form, record, resourceName) {
            form.setValues(record.data);
            telaeris.updateRelatedData(form, record, resourceName);
        },

        editRecordFromURL: function(resourceName, this_url) {
            var form = Ext.getCmp(resourceName + '_form').getForm();
            //Mask the form while we're loading
            Ext.get(resourceName + '_form').mask('Loading ' + resourceName);

            form.load({
                scope: Ext.getCmp(resourceName + '_form').getForm(),
                method: 'GET',
                url: this_url,
                params: {
                    '_method': 'GET'
                },
                success: function(form, data) {
                    var record = {
                        data: Ext.util.JSON.decode(data.response.responseText).data
                    };
                    telaeris.editRecord(form, record, resourceName);
                    //telaeris.updateRelatedData(form, record, resourceName);
                    Ext.get(resourceName + '_form').unmask();
                },
                failure: function() {
                    Ext.get(resourceName + '_form').unmask();
                }
            });
        },
        //This function will reload the data for a single record into any grid.
        reloadSingleStoreRecord: function(record, inputted_url, other_data) {
            var localURL = record.store.url + '/' + record.data.id;
            if (inputted_url) {
                localURL = inputted_url;
            }
            Ext.applyIf(localURL, record.store.url + '/' + record.data.id);
            Ext.Ajax.request({
                method: "POST",
                url: localURL,
                params: {
                    '_method': 'GET'
                },
                success: function(response) {
                	var responseText = Ext.util.JSON.decode(response.responseText);
                    var new_data = responseText.data;
                    Ext.apply(record.data, new_data);
                    Ext.apply(record.data, other_data);
                    record.commit();
                }
            });
        },
        restoreTabs: function() {
            Ext.Ajax.request({
                method: "POST",
                url: '/sext/tabs',
                params: {
                    '_method': 'GET'
                },
                success: function(response) {
                    var recordData = "";
                    if (response.responseText !== "") {
                        recordData = Ext.util.JSON.decode(response.responseText).record;
                    }
                    var tab_data = [];
                    if (recordData !== "") {
                        tab_data = Ext.util.JSON.decode(recordData);
                    }

                    Ext.getCmp('resources_tab_panel').items.each(function(tab, index, length) {
                        Ext.getCmp('resources_tab_panel').remove(tab);
                    });
                    if (tab_data.length <= 0) {
                        //alert('NO TAB DATA RESTORES THE BOMS GRID');
                        telaeris.openResource('boms', {
                            title: 'Bill of Materials(All)',
                            filterParam: 'all'
                        });

                    }
                    else {

                        Ext.Msg.progress('Loading Tabs...');
                        for (var index = 0; index < tab_data.length; index++) {
                            var tab = tab_data[index];
                            Ext.Msg.updateProgress(index / tab_data.length, index + '/' + tab_data.length + ' Tabs Loaded');

                            if (tab.resourceName.match(/piping_class_detail_/)) {
                                showOrCreatePipingDetail(tab.baseParams.piping_class_id, tab.baseParams.class_code);
                                Ext.apply(telaeris.gridConfigs[tab.resourceName].baseParams, tab.baseParams);

                            }
                            else {
                                Ext.apply(telaeris.gridConfigs[tab.resourceName].baseParams, tab.baseParams);

                            }

                            // Workaround so that the filter2 param gets correctly loaded in telaeris.openResource.
                            var options = {
                                title: tab.tabTitle,
                                noSave: true
                            };
                            if (tab.baseParams.filter2) {
                                options.filterParam = tab.baseParams.filter2;
                            }

                            telaeris.openResource(tab.resourceName, options);

                        }

                    }
                    //Ext.Msg.alert('Done Loading Tabs');
                    Ext.Msg.updateProgress(1, '  ', '  ');
                    Ext.Msg.hide();
                    Ext.getCmp('resources_card').fireEvent('resize');
                }
            });
        },
        saveTabs: function() {
            var tabdata = [];
            //object format is:
            // [{resourceName : 'name',
            //	baseParams:{}
            //    }]
            Ext.getCmp('resources_tab_panel').items.each(function(tab, index, length) {
                var resourceName = tab.id.replace("_tab", "");
                var tabItem = {
                    'resourceName': resourceName,
                    'tabTitle': tab.title
                };
                if (Ext.getCmp(resourceName + '_grid')) {
                    Ext.apply(tabItem.baseParams, Ext.getCmp(resourceName + '_grid').store.baseParams);
                }
                tabdata.push(tabItem);

            });


            Ext.Ajax.request({
                method: "POST",
                url: '/sext/save_tabs',
                params: {
                    '_method': 'PUT',
                    'tabs': Ext.encode(tabdata)
                }
                /*,
                success: function(response) {
                    var tab_return_data = Ext.util.JSON.decode(response.responseText).record;
                    alert('tab_return_data = ' + tab_return_data);
                }*/
            });
        },

        getCurrentResource: function() {
            return $tabPanel.getActiveTab().resourceName;
        },

		getMask: function () {
		    this.tabMask = this.tabMask || new Ext.LoadMask($tabPanel.getEl(), {msg:"Loading..."});
		    return this.tabMask;
		},

        openResource: function(resourceName, options) {
			var tabItems = [];
            options = options || {};

            telaeris.util.message('Opening Resource...');

            this.getMask().show();

            options.activated = options.activated || Ext.emptyFn;

            // if the tab already exists,just open it
            if (Ext.get(resourceName + '_tab')) {
                if (options.activated != Ext.emptyFn) {
                    Ext.getCmp(resourceName + '_tab').on('activate',
                    options.activated,
                    Ext.getCmp(resourceName + '_tab'),
                    {
                        single: true,
                        scope: Ext.getCmp(resourceName + '_tab')
                    }
                    );
                }
                $tabPanel.activate(resourceName + '_tab');
                if (telaeris.allConfigs[resourceName].noForm !== true) {
                    if (options.maximizeForm === true) {
                        $formConfigs[resourceName].maximizeForm();
                    }
                    else if (options.minimizeForm === true) {
                        $formConfigs[resourceName].minimizeForm();
                    }
                    else {
                        $formConfigs[resourceName].restoreForm();
                    }
                }

                var grid = Ext.getCmp(resourceName + '_grid');
                if (options.filterParam) {
                    var currentFilterParam = Ext.getCmp(resourceName + '_grid').store.baseParams.filter2;
                    Ext.apply(Ext.getCmp(resourceName + '_grid').store.baseParams,
                    {
                        filter2: options.filterParam
                    }
                    );
                    //if(currentFilterParam != options.filterParam){
                    if (options.title) {
                        Ext.getCmp(resourceName + '_tab').setTitle(options.title);
                    }
                    //}
                }
            }
            else {
                //If it's specified apply it.  Blank will eliminate it.
                if (options.filterParam) {
                    Ext.apply(
                    telaeris.gridConfigs[resourceName].baseParams,
                    {
                        filter2: options.filterParam
                    }
                    );
                }
                else if (telaeris.gridConfigs[resourceName]) {
                    Ext.apply(
                    telaeris.gridConfigs[resourceName].baseParams,
                    {
                        filter2: ""
                    }
                    );
                }
                if (telaeris.allConfigs[resourceName].panel) {
                    tabItems = [telaeris.allConfigs[resourceName].panel];
                    var title = telaeris.allConfigs[resourceName].title;
                }
                else {
                    var grid = $createGrid(resourceName, options);

                    if (telaeris.allConfigs[resourceName].noForm !== true) {
                        var form = $createForm(resourceName, options);
                        grid.form = form;
                        form.grid = grid;
                    }


                    var gridContainer = {
                        id: resourceName + '_north',
                        layout: 'fit',
                        height: 0.45 * Ext.lib.Dom.getViewHeight(),
                        split: true,
                        autoScroll: false,
                        region: 'north',
                        items: grid
                    };
                    if (telaeris.allConfigs[resourceName].noForm === true) {
                        Ext.apply(gridContainer, {
                            'region': 'center'
                        });
                    }

                    var title = telaeris.gridConfigs[resourceName].title;
                    if (options.title) {
                        title = options.title;
                    }

                    //If noForm is not true
                    if (telaeris.allConfigs[resourceName].noForm !== true) {
                        tabItems.push(form);
                    }
                    tabItems.push(gridContainer);

                }

                if(telaeris.allConfigs[resourceName].dependentStores){

                    for (var i = 0; i < telaeris.allConfigs[resourceName].dependentStores.length; i++) {
                        var storeName = telaeris.allConfigs[resourceName].dependentStores[i];
                        if (telaeris.stores.hasOwnProperty(storeName)) {
                            telaeris.stores[storeName].load();
                        }
                    }

                }

                $tabPanel.add({
                    id: resourceName + '_tab',
                    closable: true,
                    autoScroll: false,
                    title: title,
                    layout: 'border',
                    resourceName: resourceName,
                    items: tabItems
                });

                //Ext.getCmp(resourceName + '_tab').on('activate', function(){alert(resourceName + " Activated!");});
                if (options.activated != Ext.emptyFn) {
                    Ext.getCmp(resourceName + '_tab').on('activate',
                    options.activated,
                    Ext.getCmp(resourceName + '_tab'),
                    {
                        single: true,
                        scope: Ext.getCmp(resourceName + '_tab')
                    }
                    );
                }
                $tabPanel.activate(resourceName + '_tab');

                Ext.getCmp(resourceName + '_tab').doLayout();

                $tabPanel.ownerCt.doLayout();

                // hide search fields for date ranges and checkbox filters
                Ext.select('.sext_end_range_date, .sext_checkbox_filter').each(function() {
                    var formItem = this.up('div.x-form-item');
                    formItem.setVisibilityMode(Ext.Element.DISPLAY);
                    // use display:none NOT visiliby:hidden, which hides any whitespace
                    formItem.hide();
                });

                var grid = Ext.getCmp(resourceName + '_grid');
            }
            options.disableGridLoad = options.disableGridLoad || false;
            if (grid && (options.disableGridLoad !== true)) {
                grid.store.on('load',
                function() {
                    var numberOfRecords = this.getStore().getTotalCount();

                    if (numberOfRecords === 0) {
                        return;
                    }
                    //this.fireEvent('rowclick', grid, 0);
                    var selectionModel = this.getSelectionModel();

                    if  (!resourceName.match(/piping_references/) && !resourceName.match(/piping_class_detail/) && !resourceName.match(/piping_compare/)) {
                        selectionModel.selectFirstRow();
                    }

                    if (telaeris.allConfigs[resourceName].noForm !== true) {
                        if (options.maximizeForm === true) {
                            $formConfigs[resourceName].maximizeForm();
                        }
                        else {
                            $formConfigs[resourceName].restoreForm();
                        }
                    }
                },
                grid,
                {
                    single: true
                }
                );

                Ext.getCmp(resourceName + '_grid').store.load();
            }

            if (options.record) {
                telaeris.editRecord(Ext.getCmp(resourceName + '_form').getForm(), options.record, resourceName);
            }
            if (options.record_url) {
                telaeris.editRecordFromURL(resourceName, options.record_url);
            }

            this.getMask().hide();

        },

        init: function() {
            // set tabPanel on telaeris module for testing purposes
            $tabPanel = Ext.getCmp('resources_tab_panel');
            telaeris.tabPanel = $tabPanel;
        },
        gridConfigs: {},
        allConfigs: {},

        /*
         *	This method sets the report parameters into the reports form
         *	and then shows the modal window containing the form.
         *
         *  This takes in an Object that looks like:
		 *	telaeris.openReportsWindow({
		 *		url: '/piping/all/5',
		 *		class: 'PipingClassReport',
		 *		method: 'details_pdf',
		 *		options: {id: id}
		 *	});
		 *
		 *	You can pass anything you want into options.
		 *  It will be Ext.encode-ed before being sent.
		 */
        openReportsWindow: function (options) {

            telaeris.windows.reports.show();
            var form = Ext.getCmp('reports_window_form');

        	var reportURL = form.findById('reports_window_form_report_url');
        	var reportID = form.findById('reports_window_form_report_id');
        	var reportOptions = form.findById('reports_window_form_report_options');
        	var reportClass = form.findById('reports_window_form_report_class');
        	var reportMethod = form.findById('reports_window_form_report_method');
        	var emailFrom = form.findById('reports_window_form_email_from');

        	reportURL.setValue(options.url);
        	reportClass.setValue(options.report_class);
        	reportMethod.setValue(options.report_method);

        	var email = currentUser.email;
        	if (email === "") {
        		email = "no-reply@" + window.location.hostname;
        	}

        	emailFrom.setValue(email);

            var opts = Ext.encode(options.report_options || {});
            reportOptions.setValue(opts);
        },

        openURL: function (url) {
			Telaeris.skipConfirm = true;
			window.location = url;
			Telaeris.skipConfirm = false;
        },

        addCommentToChangelog: function (id) {
        	var promptAction = function (btn, text){
		    	if (btn == 'ok'){
		    		Ext.Ajax.request({
					   	url: '/record_changelogs/update_comment',
					   	method: 'POST',
					   	success: function () {
					   		telaeris.util.message('Comment successfully added!');
					   		var grid = Ext.getCmp('record_changelogs_grid');
					   		if (grid) {
					   			grid.getStore().load();
					   		}

					   	},
					   	failure: function () {
					   		telaeris.util.message("Comment update failed. Please try again and contact admins if it fails.");
					   	},
					   	params: {
					   		id: id,
					   		comment: text
					   	}
					});
		    	}
			};

        	Ext.Msg.prompt('New Comment', 'Enter a comment for this change:', promptAction, this, true);
        }
    };
} ();


/**
 * Utility methods are included in telaeris.util.
 * They are just useful functions that aren't exactly core to what the normal telaeris module does.
 */
telaeris.util = function() {
    return {
        /*
      Goes through the confirm and AJAX delete process for a grid item
      */
        deleteHandler: function(grid, rowIndex) {
            var row = grid.store.getAt(rowIndex);
            var url = grid.store.url + '/' + row.data.id;
            telaeris.util.confirm(
            "Are you sure you want to delete this record?",
            telaeris.util.deleteAndReloadStoreAjaxCall.createCallback(url, grid.store, grid.store.lastOptions.params)
            );
        },

       	// This function is expecting either {success: true} or {success:false, message:'Your error here'}
       	// to be returned in json encoding.
        deleteAndReloadStoreAjaxCall: function(url, storeToReload, paramsForLoading) {
        	telaeris.util.message('Deleting...');
            Ext.Ajax.request({
                method: 'POST',
                url: url,
                params: {
                    '_method': 'DELETE'
                },
                success: function(response, options) {
                	var result = Ext.decode(response.responseText);
                	if (result.success == false) {
                		var message = 'Record could not be deleted for some reason. Please file a <a href="/tickets/new?referral=popv">bug report</a>';
                		if (result.message) {
                			message = result.message;
                		}
                		telaeris.util.message(message);
                	}
                	else {
		                storeToReload.load({
		                    params: paramsForLoading
		                });
                	}

                }
            });
        },

        deleteMultipleRowsHandler: function(grid) {
        	var selectionModel = grid.getSelectionModel();
        	var records = selectionModel.getSelections();
        	var ids = [];
        	for (var i = 0; i < records.length; i++) {
        		var rec = records[i];
        		ids.push(rec.data.id);
        	}

        	var url = grid.store.url + '/' + ids[0];
        	var storeToReload = grid.store;
        	var paramsForLoading = grid.store.lastOptions.params;

            telaeris.util.confirm("Are you sure you want to delete this record?",
				function () {
		        	telaeris.util.message('Deleting ' + ids.length + ' records...');
		            Ext.Ajax.request({
		                method: 'POST',
		                url: url,
		                params: {
		                    '_method': 'DELETE',
		                    ids: ids.join(',')
		                },
		                success: function(response, options) {
		                	var result = Ext.decode(response.responseText);
		                	if (result.success == false) {
		                		var message = 'Records could not be deleted for some reason. Please file a <a href="/tickets/new?referral=popv">bug report</a>';
		                		if (result.message) {
		                			message = result.message;
		                		}
		                		telaeris.util.message(message);
		                	}
		                	else {
				                storeToReload.load({
				                    params: paramsForLoading
				                });
		                	}
		                }
		            });
				}
            );
        },


        // Shows a pop-up confirmation that, when "yes" is pressed, deletes the clicked-on
        // reference.
        deleteReferenceAndReload: function(url, storeToReload, description, paramsForLoading) {
            telaeris.util.confirm("Please confirm to remove the following reference:<br /><br />" + description,
            this.deleteAndReloadStoreAjaxCall.createCallback(url, storeToReload, storeToReload.lastOptions.params));

        },

        /*
      Goes through the confirm and AJAX archive process for a grid item
      */
        archiveHandler: function(grid, rowIndex) {
            telaeris.util.confirm("Are you sure you want to archive this record?",
            function() {
                var row = grid.store.getAt(rowIndex);

                Ext.Ajax.request({
                    method: 'POST',
                    url: grid.store.url + '/archive/' + row.data.id,
                    params: {
                        '_method': 'POST'
                    },
                    success: function(response) {
                        var success = Ext.util.JSON.decode(response.responseText).success;
                        if(success == true){
                            telaeris.util.message("Success Archiving");
                            var store = grid.store;
                            store.on('load',
                                function() {
                                    var sm = grid.getSelectionModel();
                                    sm.fireEvent('rowselect', sm, rowIndex, row);
                                },
                                grid, {
                                    single: true
                                });

                            store.load({
                                params: store.lastOptions.params
                            });
                        }
                        else{
                          var errors = Ext.util.JSON.decode(response.responseText).errors;
                          telaeris.util.message("FAILURE Archiving : " + errors);
                        }
                    },
                    failure:function(response){
                        var errors = ' No Repsonse';
                        if(response.responseText){
                         errors = Ext.util.JSON.decode(response.responseText).errors;
                        }
                        else{
                         errors = response.statusText;
                        }
                        telaeris.util.message("FAILURE Archiving : " + errors);
                    },
                    listeners:{
                        'requestexception':function(conn, response){
                            telaeris.util.message("FAILURE Archiving : " + response);
                        }
                    }
                }

                );
            });
        },
        unArchiveHandler: function(grid, rowIndex) {
            telaeris.util.confirm("Are you sure you want to unarchive this record?",
            function() {
                var row = grid.store.getAt(rowIndex);

                Ext.Ajax.request({
                    method: 'POST',
                    url: grid.store.url + '/unarchive/' + row.data.id,
                    params: {
                        '_method': 'POST'
                    },
                    success: function(response) {
                        var success = Ext.util.JSON.decode(response.responseText).success;
                        if(success == true){
                            telaeris.util.message("Success Unarchiving");
                            var store = grid.store;
                            store.on('load',
                                function() {
                                    var sm = grid.getSelectionModel();
                                    sm.fireEvent('rowselect', sm, rowIndex, row);
                                },
                                grid, {
                                    single: true
                                });
                            store.load({
                                params: store.lastOptions.params
                            });
                        }
                        else{
                          var errors = Ext.util.JSON.decode(response.responseText).errors;
                          telaeris.util.message("FAILURE Unarchiving : " + errors);
                        }
                    },
                    failure:function(response){
                        var errors = ' No Repsonse';
                        if(response.responseText){
                         errors = Ext.util.JSON.decode(response.responseText).errors;
                        }
                        else{
                         errors = response.statusText;
                        }
                        telaeris.util.message("FAILURE Unarchiving : " + errors);
                    },
                    listeners:{
                        'requestexception':function(conn, response){
                            telaeris.util.message("FAILURE Unarchiving : " + response);
                        }
                    }
                });
            });
        },


        /**
         * Given an underscore string, returns the Title version with spaces with first letter capitalized
         * Examples:  'user_name' -> 'User name', 'first_name' -> 'First name', 'email_address' -> 'Email address'
         */
        titleFor: function(string) {
            //This titleFor code will capitalize all characters.
            var header = string.replace(/(_|\.)+/g, " ");
            var headerArray = header.split(" ");
            var output = '';
            var counter = 0;

            if ((!headerArray) || (headerArray.length === 0)) {
                return header;
            }
            while (counter < headerArray.length) {

                if (headerArray[counter].length > 0) {
                    var start = headerArray[counter].charAt(0);
                    if (start !== undefined) {
                        start = start.toUpperCase();
                        if (headerArray[counter].length > 1) {
                            output += start + headerArray[counter].slice(1, headerArray[counter].length) + ' ';
                        }
                        else {
                            output += start + ' ';
                        }
                    }
                }
                counter++;

            }

            return output;
            /*//Old titleFor Code
            var header = string.replace(/(_|\.)+/g, " ");

            // if the string is empty just return itself
            if (!header[0]) return header;

            // capitalize the first letter and return value
            var start = header[0].toUpperCase();
            if (header.length > 1)
            return start + header.slice(1, header.length);
            else
            return start;*/
        },

        // For grid renderers, inside a gridConfig pass this function as a renderer option to format a date as m/d/Y
        dateFormat: Ext.util.Format.dateRenderer('m/d/Y'),

        // For grid renderers, inside a gridConfig pass this function as a renderer option to format a boolean as "Yes" or "No"
        boolFormat: function(value) {
            return (String(value) == "true" || String(value) == "1" ? "Yes": "No");
        },

        /**
         * Displays a flash message for 5 seconds at the top of the page
         */
        message: function(msg, timeout) {
            if (timeout === undefined) {
                timeout = 5000;
            }
            // fill in the html for #flash_message
            var msgDiv = Ext.get('ajax_loading');
            msgDiv.update(msg);
            msgDiv.show(true);

            // set the message count
            if (!telaeris.util.message.count || telaeris.util.message.count <= 0) {
                telaeris.util.message.count = 0;
            }
            telaeris.util.message.count++;

            // make the message disappear after 5 seconds
            setTimeout(function() {
                telaeris.util.message.count--;
                if (telaeris.util.message.count <= 0) {
                    telaeris.util.message.count = 0;
                    msgDiv.hide(true);
                }
            },
            timeout);
        },

        /**
         * For development purposes only (ie. do not use this function in production)
         * Given an object, displays an alert box with information about it (a list of all of its properties)
         */
        inspect: function(object) {
            var properties = [];
            var values = [];
            var output = "";
			var i;

            for (i in object) {
                properties.push(i);
                values.push(object[i]);
            }
            //properties.sort();
            for (i = 0; i < properties.length; i++) {
                var val = properties[i] + ":" + values[i];
                output += val + ', ';
            }

            // remove extra comma
            //if (properties.length > 0)output = output.slice(0, output.length - 2);
            //alert(output);
            return output;
        },

        /**
         * Does an Ext style confirmation box similar to Javascript's built in confirm() method.
         * Pass in a function as the second parameter, the function will get executed if the user clicks "Okay"
         */
        confirm: function(msg, fn) {
            var newFn = function(response) {
                if (response == "yes" && fn) {
                    fn();
                }
            };
            Ext.Msg.confirm("Please Confirm", msg, newFn);
        },

        trim: function(string) {
            return string.replace(/^\s+|\s+$/g, "");
        }
    };
} ();

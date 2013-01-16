var currentBOMItemIndex = null;
Ext.override(Ext.Button, {
  setSize: function () {
    return true;
  }
});

/******************************************************************************
 Global Stores
 ******************************************************************************/
telaeris.stores.units = new Ext.data.JsonStore({
  storeId: 'units',
  url: '/units_sext',
  method: 'GET',
  totalProperty: 'count',
  baseParams: {
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['description', 'full_description', 'id', 'unit_no'],
  autoLoad: false
});
telaeris.stores.sizes = new Ext.data.JsonStore({
  url: '/piping/piping_sizes',
  storeId: 'piping_sizes',
  totalProperty: 'count',
  baseParams: {
    '_method': 'GET',
    all: 'true'
  },
  sortInfo: {
    field: 'numerical_size',
    direction: 'ASC'
  },
  root: 'records',
  fields: ['piping_size', 'numerical_size', 'id'],
  autoLoad: false
});
telaeris.stores.piping_notes = new Ext.data.JsonStore({
  storeId: 'piping_notes',
  url: '/piping_notes/',
  totalProperty: 'count',
  baseParams: {
    sort: 'piping_notes.note_number',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['note_number', 'note_text', 'id'],
  autoLoad: false
});
telaeris.stores.piping_components = new Ext.data.JsonStore({
  storeId: 'piping_components',
  url: '/piping_components/',
  totalProperty: 'count',
  baseParams: {
    sort: 'piping_components.piping_component',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['piping_component', 'id','has_children'],
  autoLoad: false
});

telaeris.stores.valves = new Ext.data.JsonStore({
  storeId: 'valves',
  url: '/sext/valves/store',
  totalProperty: 'count',
  baseParams: {
    sort: 'valves.valve_code',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true',
    limit: 200
  },
  root: 'records',
  fields: ['valve_code', 'id'],
  autoLoad: false
});

telaeris.stores.valve_components = new Ext.data.JsonStore({
  storeId: 'valve_components',
  url: '/valve_components/',
  totalProperty: 'count',
  baseParams: {
    sort: 'valve_components.order_numbering',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['component_name', 'id', 'order_numbering'],
  autoLoad: false
});

telaeris.stores.units_for_measure = new Ext.data.JsonStore({
  storeId: 'units_for_measure',
  url: '/piping/units_for_measure/',
  totalProperty: 'count',
  baseParams: {
    sort: 'name',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['name', 'combined', 'id'],
  autoLoad: false
});

telaeris.stores.piping_references = new Ext.data.JsonStore({
  storeId: 'piping_references',
  url: '/piping_references/',
  totalProperty: 'count',
  baseParams: {
    sort: 'description',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['id', 'description', 'custom_link', 'filename'],
  autoLoad: false
});

telaeris.stores.manufacturers = new Ext.data.JsonStore({
  storeId: 'manufacturers',
  url: '/manufacturers/',
  totalProperty: 'count',
  baseParams: {
    sort: 'name',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['id', 'name'],
  autoLoad: false
});

telaeris.stores.reference_number_types = new Ext.data.JsonStore({
  storeId: 'reference_number_types',
  url: '/reference_number_types.json',
  totalProperty: 'count',
  baseParams: {
    sort: 'name',
    dir: 'ASC',
    '_method': 'GET',
    all: 'true'
  },
  root: 'records',
  fields: ['id', 'name'],
  autoLoad: false
});

telaeris.stores.classes_only_incl_archived = new Ext.data.JsonStore({
  storeId: 'classes_only_incl_archived',
  url: '/piping/classes_only_incl_archived',
  totalProperty: 'count',
  baseParams: {
    '_method': 'GET',
    all: 'true'
  },
  sortInfo: {
    field: 'class_code',
    direction: 'ASC'
  },
  root: 'records',
  fields: ['class_code', 'id'],
  autoLoad: false
});
/*

From here down we have our basic resources that are available in the navigation panel

*/

/*
They all take on the form of:
telaeris.resources({
    RESOURCENAMEHERE: {
        gridConfig:{
            selModel: new Ext.grid.RowSelectionModel({
                    singleSelect: true
                })
        },
        formConfig:{},
        gridFields: [],
        formFields: []
    }
});
        */

/******************************************************************************
 User Notes Resource
 ******************************************************************************/
//Creates the UserNotes Resource
telaeris.resources({
  user_notes: {
    //dependentStores: [],
    gridConfig: {
      noPaging: true,
      noAddButton: true,
      noSearchButton: true
    },
    formConfig: {
      showUserNotes: false,
      noSearchButton: true,
      saveButtonReplacement: [{
        text: 'Update Note',
        iconCls: 'icon-disk',
        xtype: 'button',
        handler: function () {

          var form = Ext.getCmp('user_notes_form');
          var recordId = form.getForm().getValues().id;

          form.getForm().submit({
            waitMsg: 'Saving data ...',
            method: 'POST',
            url: '/user_notes/' + recordId,
            params: {
              '_method': 'PUT'
            },
            success: function () {
              telaeris.util.message("Data was saved successfully");
              var store = Ext.getCmp('user_notes_grid').store;
              store.load({
                params: store.lastOptions.params
              });
            }
          });
        }
      },
      {
        xtype: 'button',
        text: 'View Original Record',
        iconCls: 'icon-magnifier',
        handler: function (button, test, test1) {
          var record = Ext.getCmp('user_notes_form').getForm().getValues();
          var title = record.original_tab_title;

          if (record.original_resource_name.indexOf('piping_class_detail_') >= 0) {
            var piping_class_id = /[0-9]+/.exec(record.original_resource_name);
            showOrCreatePipingDetail(piping_class_id, record.original_resource_title);
            telaeris.openResource("piping_class_detail_" + piping_class_id, {
              'maximizeForm': true,
              activated: telaeris.editRecordFromURL.createCallback("piping_class_detail_" + piping_class_id, '/piping_class_details/' + record.table_id)
            });
          }
          else {
            telaeris.openResource(record.original_resource_name, {
              'title': record.original_resource_title,
              'maximizeForm': true,
              activated: telaeris.editRecordFromURL.createCallback(record.original_resource_name, '/' + record.original_resource_name + '/' + record.table_id)
            });
          }
        }
      }]
    },
    gridFields: [{
      id: 'note'
    },
    {
      id: 'table_type',
      header: 'Resource Name'
    },
    {
      id: 'table_field_name',
      header: 'Field'
    },
    {
      id: 'submitting_user',
      header: 'Submitted By'
    },
    {
      id: 'reviewing_user',
      header: 'Reviewed By'
    }, 'status'],
    formFields: [{
      xtype: 'hidden',
      name: 'table_resource_name'
    },
    {
      xtype: 'textfield',
      readOnly: true,
      cls: 'purple',
      name: 'original_resource_title',
      fieldLabel: 'Resource Name'
    },
    {
      xtype: 'hidden',
      name: 'original_resource_name'
    },
    {
      xtype: 'textarea',
      name: 'note',
      fieldLabel: 'User Note'
    },
    {
      name: 'table_type',
      xtype: 'hidden'
    },
    {
      name: 'table_id',
      fieldLabel: 'Resource ID',
      xtype: 'hidden',
      readOnly: true,
      cls: 'purple'
    },
    {
      name: 'table_field_name',
      fieldLabel: 'Field Name',
      readOnly: true,
      cls: 'purple'
    },
    {
      xtype: 'textarea',
      name: 'table_field_data',
      fieldLabel: 'Original Data (auto-filled)',
      readOnly: true,
      cls: 'purple'
    },
    {
      xtype: 'tbtext',
      name: 'note_status_text',
      disabled: true,
      text: '<div style="color:red"><br />Note Status and Reason will be Emailed to the Submitter.<br />Rejected Notes will not be visible</div>'

    },
    {
      xtype: 'combo',
      name: 'status',
      fieldLabel: 'Status',
      allowBlank: false,
      mode: 'local',
      triggerAction: 'all',
      editable: false,
      selectOnFocus: true,
      displayField: 'status',
      valueField: 'status',
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['status'],
        data: [{
          'status': 'Not Reviewed'
        },
        {
          'status': 'Approved'
        },
        {
          'status': 'Rejected'
        }]
      })
    },
    {
      xtype: 'textarea',
      name: 'reason',
      fieldLabel: 'Reason'

    },
    {
      xtype: 'combo',
      name: 'hidden',
      fieldLabel: 'Visibility in Form',
      allowBlank: false,
      mode: 'local',
      triggerAction: 'all',
      editable: false,
      selectOnFocus: true,
      displayField: 'status',
      valueField: 'value',
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['status', 'value'],
        data: [{
          'status': 'Visible',
          'value': false
        },
        {
          'status': 'Not Visible',
          'value': true
        }]
      })
    }]
  }
});

/******************************************************************************
 Piping Notes Resource
 ******************************************************************************/
//Creates the Piping Notes Grid/Form
telaeris.resources({
  piping_notes: {
    //dependentStores: ['piping_notes'],
    gridConfig: {
      autoExpandColumn: 'note_text',
      noPaging: true,
      additionalButtons: [{
        xtype: 'button',
        text: 'All Piping Notes PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          telaeris.openReportsWindow({
            url: '/piping/notes_pdf',
            report_class: 'PipingClassReport',
            report_method: 'notes_pdf',
            report_options: {}
          });
          //window.open('/piping/notes_pdf');
        }
      }]
    },
    formConfig: {},
    gridFields: [{
      id: 'note_number',
      width: 15
    }, 'note_text'],
    formFields: [{
      xtype: 'field',
      name: 'note_number'
    },
    {
      xtype: 'textarea',
      name: 'note_text'
    }]
  }
});

/******************************************************************************
 Show Piping notes Window
 ******************************************************************************/
//Opens the New BOM window
var showPipingNotesWindow = function (notes_data) {
  telaeris.windows({
    show_notes: {
      title: 'Line Class Note Description',
      formConfig: {
        autoScroll: true,
        labelWidth: 100,
        height: 300
      },
      formFields: [{
        xtype: 'notesview',
        name: 'piping_notes_data',
        tpl: new Ext.XTemplate('<table class="popv-notes">',
                          '<tr><th style="width: 70px;">Note #</th><th>Note Text</th></tr>',
                          '<tpl for=".">', '<tr>', '<td class="detail_note">{note_number:htmlEncode}</td>',
                          '<td class="detail_note">{note_text:htmlEncode}</td></tr>', '</tpl>', '</table>'),
        fieldLabel: 'Piping Notes',
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['note_number', 'note_text', 'id', 'piping_class_detail_id', 'piping_class_id'],
          data: notes_data
        })
      }],
      windowFormButtons: [{
        xtype: 'button',
        text: 'Close',
        handler: function () {
          telaeris.windows.show_notes.hide();
        }
      }]
    }
  });
  Ext.getCmp('show_notes_window').on('hide', function () {
    telaeris.windows.show_notes.destroy();
  });
  Ext.getCmp('show_notes_window').show();
};


/******************************************************************************
 User Notes Window
 ******************************************************************************/
//Creates the UserNotes Window
telaeris.windows({
  user_notes: {
    'title': "Add User Note",
    url: '/user_notes',
    'baseParams': {
      '_method': 'POST'
    },
    windowFormButtons: [{
      text: 'Save Note',
      handler: function () {
        if (currentUser.popv_viewer === true) {
          return;
        }
        var submitOpt = {
          waitMsg: 'Saving data ...',
          method: 'POST',
          url: '/user_notes',
          params: {
            '_method': 'POST'
          }
        };
        submitOpt.success = function (form, returnValue, id) {
          telaeris.util.message("Note Successfully Submitted");
          //The form ID should be present on the form.
          var user_notes_grid = Ext.getCmp('user_notes_grid');
          if (user_notes_grid) {
            user_notes_grid.store.load({
              params: user_notes_grid.store.lastOptions.params
            });
          }

          //var record = Ext.util.JSON.decode(returnValue.response.responseText).record;
          //Table Type still contains the original resource_name at this point.
          var userNoteWindowForm = Ext.getCmp('user_notes_window_form').getForm();
          var resource_id = userNoteWindowForm.findField('table_id').getValue();
          var resourceName = userNoteWindowForm.findField('original_resource_name').getValue();
          var urlName = resourceName;
          if (urlName.indexOf('piping_class_detail_') >= 0) {
            urlName = 'piping_class_details';
          }
          var url = '/' + urlName + '/' + resource_id;

          //Reload the GRID for the Record we just edited
          var store = Ext.getCmp(resourceName + '_grid').store;
          store.load({
            params: store.lastOptions.params
          });

          //Reload the FORM for the Record we just edited
          telaeris.editRecordFromURL(resourceName, url);
          telaeris.windows.user_notes.hide();
        };
        //submitOpt.failure = config.failure;
        Ext.getCmp('user_notes_window_form').getForm().submit(submitOpt);


      }
    },
    {
      text: 'Cancel',
      handler: function () {
        telaeris.windows.user_notes.hide();
      }
    }],
    formFields: [{
      xtype: 'textfield',
      readOnly: true,
      cls: 'purple',
      name: 'original_resource_title',
      fieldLabel: 'Resource Title'
    },
    {
      xtype: 'hidden',
      name: 'original_resource_name'
    },
    {
      xtype: 'textfield',
      readOnly: true,
      cls: 'purple',
      name: 'table_type',
      fieldLabel: 'Resource Name'
    },
    {
      readOnly: true,
      cls: 'purple',
      xtype: 'hidden',
      name: 'table_id',
      fieldLabel: 'Record ID'
    },
    {
      xtype: 'combo',
      name: 'table_field_name',
      fieldLabel: 'Select a Field',
      allowBlank: false,
      title: null,
      mode: 'local',
      triggerAction: 'all',
      editable: false,
      selectOnFocus: true,
      displayField: 'display_name',
      valueField: 'field_name',
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: Ext.data.Record.create([{
          name: 'field_name',
          mapping: 'name'
        },
        {
          name: 'display_name',
          mapping: 'fieldLabel'
        }]),
        data: []
      }),
      listeners: {
        'select': function (combo, record, index) {
          var resource_name = Ext.getCmp('user_notes_window_form').getForm().findField('table_type').getValue();
          var form = Ext.getCmp(resource_name + '_form').getForm();
          var field_name_value = record.data.field_name;
          var field_value = '';
          if (field_name_value != 'general') {
            var thisField = form.findField(field_name_value);
            if (thisField.xtype == 'combo') {
              field_value = thisField.getRawValue();
            }
            else {
              field_value = thisField.getValue();
            }
          }


          Ext.getCmp('user_notes_window_form').getForm().setValues({
            'table_field_data': field_value,
            'table_field_name': field_name_value
          });
        }
      }


    },
    {
      xtype: 'textarea',
      readOnly: true,
      cls: 'purple',
      name: 'table_field_data',
      fieldLabel: 'Original Data (auto-filled)'
    },
    {
      xtype: 'textarea',
      name: 'note',
      fieldLabel: 'Enter Note Here',
      allowBlank: false

    }],
    success: function () {
      telaeris.util.message("Note Successfully Submitted");

    },
    listeners: {
      'hide': function () {
        Ext.getCmp('user_notes_window_form').getForm().reset();
      }
    }
  }
});


/******************************************************************************
 User Notes Window
 ******************************************************************************/
//Creates the UserNotes Window and populates it with the resource_name/ID of the
//    record we want to add a note to.
var createUserNotesWindow = function (resource_name, resource_id, field_data) {
  if ((resource_name !== '') && (resource_id !== '')) {
    telaeris.windows.user_notes.show();
    var active_tab = Ext.getCmp('resources_tab_panel').activeTab;
    var form = Ext.getCmp('user_notes_window_form').getForm();
    var resourceName = active_tab.id.replace("_tab", "");
    form.setValues({
      'original_resource_name': resourceName,
      'original_resource_title': active_tab.title,
      'table_type': resource_name,
      'table_id': resource_id
    });

    var fieldsField = form.findField('table_field_name');
    field_data.unshift({
      'name': "general",
      'fieldLabel': "General Note"
    });
    fieldsField.store.loadData(field_data);
    fieldsField.setValue('general');
  }
  else {
    telaeris.util.message("Select a Record First!");
  }
};

telaeris.windows({
    'advanced_search_valves': {
      listeners:{
        'render':function(){
          Ext.get('advanced_search_valves_window').mask('Loading');
          Ext.Ajax.request({
              method: 'GET',
              url: '/valves/valve_components/' ,
              params: {
                '_method': 'GET'
              },
              success: function (response) {
                //Decode the response
                Ext.get('advanced_search_valves_window').unmask();
                var responseValue = '';
                responseValue = Ext.util.JSON.decode(response.responseText);
                Ext.getCmp('valves_components_advanced_search').setValue(responseValue.records);

              },
              failure:function(response){
                Ext.get('valves_valve_components_window').unmask();
              }

          });
        }
      },

       formConfig:{
        autoScroll:true,
        height:470
      },
      windowConfig: {
        height: 500,
        width: 600,
        resizable: true
      },

      'title': 'Valves Advanced Search',
      'baseParams': {
        '_method': 'POST'
      },
      formFields: [

    {
      xtype: 'textfield',
      name: 'valve_note'
      //height: 100,
      //anchor: '-20px'
    },
    {
      fieldLabel: 'Type',
      xtype: 'textfield',
      name: 'valve_type'
    },
    {
      fieldLabel: 'Rating',
      xtype: 'textfield',
      name: 'valve_rating'
    },
    {
      fieldLabel: 'Body',
      xtype: 'textfield',
      name: 'valve_body'
    },
    {
      xtype: 'editorgridformfield',
      style: 'padding: 10px;',
      viewConfig: {
        forceFit: true,
        emptyText: 'No Valve Components'
      },
      id:'valves_components_advanced_search',
      name: 'valve_components',
      layout: 'fit',
      autoExpandColumn: 'component_text',
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['valve_component_id', 'valves_valve_component_id','component_name', 'component_text'],
          data: []
        }),
        columns:  [{dataIndex: "component_name",
        header: "Component Name",
        width:100,
        menuDisabled: true,
        sortable:true}
        ,{
          dataIndex: "component_text",
          header: "Component Text",
          //width: 10,
          menuDisabled: true,
          sortable: true,
          editor: new Ext.Editor(new Ext.form.TextField({
            allowBlank: true,
            triggerAction: 'all',
            selectOnFocus: true
          }), {
            autoSize: true,
            id: 'component_text_edfield_adv_search'

          }),
          menuDisabled: true,
          sortable: true
        }]
      }],
    //Use these instead of default Save Data
      windowFormButtons: [{
        xtype: 'button',
        text: 'Search',
        iconCls: 'icon-magnifier',
        handler: function () {
            //Apply our search parameters to the Valves Grid
            var form = Ext.getCmp('advanced_search_valves_window_form');
            var store = Ext.getCmp('valves_grid').store;
            var newParams = form.getForm().getValues();
            var component_values = Ext.getCmp('valves_components_advanced_search').getValue();
            var valve_components = [];
            for(var i= 0;i< component_values.length; i++){
              if(component_values[i].data.component_text !== ''){
                valve_components.push({
                  'valve_component_id':(component_values[i].data.valve_component_id || ''),
                  'component_text':component_values[i].data.component_text,
                  'valves_valve_component_id':(component_values[i].data.valves_valve_component_id || '')
                });
              }
            }
            newParams.valve_components = Ext.util.JSON.encode(valve_components);
            delete newParams.id;
            newParams.filter = "true";

            //store.baseParams = Ext.applyIf(newParams, store.baseParams);
            store.load({
                params: newParams
            });
            store.searchingData = true;


            Ext.getCmp('advanced_search_valves_window').hide();
            //we don't really need this, do we?
            //form.getForm().setValues(newParams);

        }
      },
      {
        xtype: 'button',
        text: 'Cancel',
        handler: function () {
          telaeris.windows.advanced_search_valves.hide();
        }
      }]
    }

  });


/******************************************************************************
 Valve Component Helper functions for HABTM Add/Remove
 ******************************************************************************/
//This may not be an ideal solution, as we may have a memory leak in here
//Create a new window for valves_valve_components and change its parameters each time
//This is for both creation and editing of valves valve components
//Deletes itself once hidden.(on either save or upper-right X cancel)
var createValveCompWindow = function (valve_id, baseParams, title) {
  telaeris.windows({
    'valves_valve_components': {
      formConfig:{
        autoScroll:true,
        height:570
      },
      windowConfig: {
        height: 600,
        width: 600,
        resizable: true
      },
      windowFormButtons:[
      {
        text: 'Save Data',
        handler: function() {
            var grid = Ext.getCmp('valves_grid');
            var record = {};
            if(grid){
              var rowIndex = grid.store.find('id', valve_id);
              record = grid.store.getAt(rowIndex);
            }
            var submitOpt = {
                waitMsg: 'Saving data ...',
                method: 'POST',
                url: '/valves/save_valve_components/' + valve_id,
                params: {valve_components:[]},
                success: function (){
                  if (Ext.getCmp('valves_form')) {
                    telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
                    loadValveRelatedRecords(record);
                  }
                  telaeris.windows.valves_valve_components.hide();
                  telaeris.util.message('Valve Components Saved Successfully');
                },
                failure: function(){
                  if (Ext.getCmp('valves_form')) {
                    telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
                    loadValveRelatedRecords(record);
                  }
                  telaeris.windows.valves_valve_components.hide();
                  telaeris.util.message('Error Saving Valve Components');
                }
            };

            var resourceForm = Ext.getCmp('valves_valve_components_window_form');

            var form_values = resourceForm.getForm().getValues();


            var component_values = Ext.getCmp('valves_components_editorgrid').getValue();
            var valve_components = [];
            for(var i= 0;i< component_values.length; i++){
              valve_components.push({
                'valve_component_id':(component_values[i].data.valve_component_id || ''),
                'component_text':component_values[i].data.component_text,
                'valves_valve_component_id':(component_values[i].data.valves_valve_component_id || '')
              });

            }
            submitOpt.params.valve_components = Ext.util.JSON.encode(valve_components);

            resourceForm.getForm().submit(submitOpt);

        }
      }],
      'title': title,
      'baseParams': baseParams,
        formFields: [
          {
            xtype: 'editorgridformfield',
            style: 'padding: 10px;',
            viewConfig: {
              forceFit: true,
              emptyText: 'No Valve Components'
            },
            id:'valves_components_editorgrid',
            name: 'valve_components',
            layout: 'fit',
            autoExpandColumn: 'component_text',
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['valve_component_id', 'valves_valve_component_id','component_name', 'component_text'],
          data: []
        }),
        columns:  [{dataIndex: "component_name",
        header: "Component Name",
        width:100}
        ,{
          dataIndex: "component_text",
          header: "Component Text",
          //width: 10,
          menuDisabled: true,
          sortable: true,
          editor: new Ext.Editor(new Ext.form.TextField({
            allowBlank: true,
            triggerAction: 'all',
            selectOnFocus: true
          }), {
            autoSize: true,
            id: 'component_text_edfield'

          }),
          menuDisabled: true,
          sortable: false
        }]
      }//End of editorgridformfield
      ]
    }
  });

  Ext.getCmp('valves_valve_components_window').on('hide', function () {
    telaeris.windows.valves_valve_components.destroy();
  });

  //start retrieving the data
  Ext.Ajax.request({
      method: 'GET',
      url: '/valves/valve_components/' + valve_id,
      params: {
        '_method': 'GET'
      },
      success: function (response) {
        //Decode the response
        Ext.get('valves_valve_components_window').unmask();
        var responseValue = '';
        responseValue = Ext.util.JSON.decode(response.responseText);
        Ext.getCmp('valves_components_editorgrid').setValue(responseValue.records);

      },
      failure:function(response){
        Ext.get('valves_valve_components_window').unmask();
      }

  });
  Ext.getCmp('valves_valve_components_window').show();
  Ext.get('valves_valve_components_window').mask('Loading');

};

//Create a new window called valves_valve_components, with the appropriate text, and parameters for EDITING
var editValveComponents = function (valve_id) {
  createValveCompWindow(valve_id,  {
    '_method': 'PUT'
  }, 'Edit Valve Components');
};

//Prompt whether we actually want to do this.
var removeValveComponent = function (valves_valve_component_id, valve_id) {
  telaeris.util.confirm("Are you sure you want to Remove this Valve Component, Component Text will be lost", function () {
    Ext.Ajax.request({
      method: 'POST',
      url: '/sext/valves_valve_components/' + valves_valve_component_id,
      params: {
        '_method': 'DELETE'
      },
      success: function () {
        telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
                var record = {};
        record['data'] = {};
        record.data['id'] = valve_id;
        loadValveRelatedRecords(record);
        var store = Ext.getCmp('valves_grid').store;
        store.load({
          params: store.lastOptions.params
        });
      }
    });
  });
};


/******************************************************************************
 Manufacturers Helper functions for HABTM Add/Remove
 ******************************************************************************/
var createManufacturerFigureNoWindow = function (valve_id, manufacturer_id, text_value, url, baseParams, title, isEditing) {
  telaeris.windows({
    'valves_manufacturers': {
      formID: 'valves_manufacturers_form',
      'title': title,
      url: url,
      'baseParams': baseParams,
      formFields: [{
        fieldLabel: 'Manufacturer',
        xtype: 'combo',
        mode: 'local',
        name: 'manufacturer',
        hiddenName: 'manufacturer_id',
        displayField: 'name',
        valueField: 'id',
        store: telaeris.stores.manufacturers,
        value: manufacturer_id,
        disabled: isEditing
      },
      {
        xtype: 'hidden',
        name: 'valve_id',
        value: valve_id
      },
      {
        xtype: 'textfield',
        name: 'figure_no',
        value: text_value
      }

      ],
      windowFormButtons: [{
        text: 'Save Data',
        handler: function () {
          var submitOpt = {
            waitMsg: 'Saving data ...',
            method: 'POST',
            url: url,
            params: baseParams
          };
          submitOpt.success = function () {
            if (Ext.getCmp('valves_form')) {
              telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
            }

            telaeris.windows.valves_manufacturers.hide();
            Ext.getCmp('valves_form_associated_manufacturers').store.load();
          };

          var resourceForm = Ext.getCmp('valves_manufacturers_form');
          var form_values = resourceForm.getForm().getValues();
          //Manually fill in the manufacturer_id because it can be disabled and won't submit
          form_values.manufacturer_id = Ext.getCmp('valves_manufacturers_form').getForm().findField('manufacturer_id').value;
          Ext.apply(submitOpt.params, form_values);
          if (isNaN(form_values.manufacturer_id) === true) {
            Ext.Msg.confirm('Create Manufacturer', 'This manufacturer does not seem to exist. Would you like to create it?', function (btn, text) {
              if (btn == 'yes') {
                resourceForm.getForm().submit(submitOpt);
              }
            });

          }
          else {
            resourceForm.getForm().submit(submitOpt);
            telaeris.windows.valves_manufacturers.hide();
          }
        }
      },
      {
        text: 'Cancel',
        handler: function () {
          telaeris.windows.valves_manufacturers.hide();
        }
      }]
      //            ,
      //            success: function() {
      //                if (Ext.getCmp('valves_form')) {
      //                    telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
      //                }
      //                telaeris.windows.valves_manufacturers.hide();
      //            }
    }
  });
  Ext.getCmp('valves_manufacturers_window').on('hide', function () {
    telaeris.windows.valves_manufacturers.destroy();
  });
  Ext.getCmp('valves_manufacturers_window').show();
};

//Create a new window called valves_valve_components, with the appropriate text, and parameters for EDITING
var editManufacturerFigureNo = function (manufacturers_valves_id, text_value, valve_id, manufacturer_id) {
  createManufacturerFigureNoWindow(valve_id, manufacturer_id, text_value, '/valves/edit_manufacturer', {
    manufacturers_valves_id: manufacturers_valves_id,
    '_method': 'PUT'
  }, 'Edit Manufacturer Figure No', true);
};

//Create a new window called valves_valve_components, with the appropriate text, and parameters for CREATING
var newManufacturerFigureNo = function (valve_id) {
  createManufacturerFigureNoWindow(valve_id, '', '', '/valves/add_manufacturer', {
    valve_id: valve_id,
    '_method': 'POST'
  }, 'New Manufacturer Figure No', false);
};

//Prompt whether we actually want to do this.
var removeManufacturerFigureNo = function (manufacturers_valves_id, valve_id) {
  telaeris.util.confirm("Are you sure you want to Remove this Link? Figure No will be lost", function () {
    Ext.Ajax.request({
      method: 'POST',
      url: '/valves/delete_manufacturer',
      params: {
        manufacturers_valves_id: manufacturers_valves_id,
        '_method': 'DELETE'
      },
      success: function () {
        telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
        var store = Ext.getCmp('valves_grid').store;
        store.load({
          params: store.lastOptions.params
        });
      }
    });
  });
};
var supersedeManufacturer= function (manufacturers_valves_id, valve_id) {
  telaeris.util.confirm("Are you sure you want to supersede this manufacturer?", function () {
    Ext.Ajax.request({
      method: 'POST',
      url: '/valves/supersede_manufacturer',
      params: {
        manufacturers_valves_id: manufacturers_valves_id,
        '_method': 'POST'
      },
      success: function () {
        telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
        var record = {};
        record['data'] = {};
        record.data['id'] = valve_id;
        loadValveRelatedRecords(record);
        var store = Ext.getCmp('valves_grid').store;
        store.load({
          params: store.lastOptions.params
        });
      }
    });
  });
};
var undoSupersedeManufacturer= function (manufacturers_valves_id, valve_id) {
  telaeris.util.confirm("Are you sure you want to undo the superseding of this manufacturer?", function () {
    Ext.Ajax.request({
      method: 'POST',
      url: '/valves/undo_supersede_manufacturer',
      params: {
        manufacturers_valves_id: manufacturers_valves_id,
        '_method': 'POST'
      },
      success: function () {

        telaeris.editRecordFromURL('valves', '/valves/' + valve_id);
        var record = {};
        record['data'] = {};
        record.data['id'] = valve_id;
        loadValveRelatedRecords(record);
        var store = Ext.getCmp('valves_grid').store;
        store.load({
          params: store.lastOptions.params
        });
      }
    });
  });
};
/******************************************************************************
 Clone ValveClass
 ******************************************************************************/
//Prompt to duplicate Valve.  Send AJAX Call and refresh Grid/Form
var cloneValve = function (grid, rowIndex) {
  var record = grid.getStore().getAt(rowIndex);

  Ext.Msg.prompt('Clone Valve', 'Enter the V# for the new Valve:', function (button, value) {
    if (button == 'ok') {
      Ext.Ajax.request({
        method: 'POST',
        url: '/valves/clone/' + record.data.id,
        params: {
          '_method': 'POST',
          'new_valve_code': value
        },
        success: function (response) {
          var store = Ext.getCmp('valves_grid').store;
          store.load({
            params: store.lastOptions.params
          });
          var record = {};
          json_response = Ext.util.JSON.decode(response.responseText);
          if (json_response.success == true) {
            var new_data = json_response.record;
            var original_valve_code = json_response.original_valve_code;
            var alert_message = 'Successfully cloned Valve \'' + original_valve_code + '\' as \'' + new_data.valve_code + '\'.<br/>';
            alert_message += 'This valve will be set as ARCHIVED until it is ready to be released.';
            Ext.MessageBox.alert('Valve Cloned', alert_message);
            telaeris.util.message('New Cloned Valve ' + new_data.valve_code);
            telaeris.editRecordFromURL('valves', '/valves/' + new_data.id);
            Ext.getCmp('valves_maximize').handler();
          }
          else {
            var original_valve_code = json_response.original_valve_code;
            var alert_message = 'Error cloning Valve \'' + original_valve_code + '\' as \'' + value + '\'.<br/>';
            alert_message += json_response.errors;
            Ext.MessageBox.alert('Error', alert_message);
            telaeris.util.message("Error Cloning Valve '" + value + "'");
          }

        }
      });
    }

  }, grid, false, record.data.valve_code);
};

//Templates to edit and create Valves Components in the form.
var change_manufacturers_header_tpl = '';
var change_manufacturers_data_tpl = '';
var supersede_manufacturers_header_tpl = '';
var supersede_manufacturers_data_tpl = '';
var valves_notes_header_tpl = '';
// Hides the edit link for non-admins
var valves_notes_data_tpl = '';
//Only can edit or delete if you're an admin
if (currentUser.admin) {
  change_manufacturers_header_tpl = "<th>Edit</th><th>Supersede</th><th>Delete</th>";
  change_manufacturers_data_tpl = '' +
                      '<td class="detail_note"><a href="#" onclick="return editManufacturerFigureNo(\'{manufacturers_valves_id:htmlEncode}\',\'{figure_no:htmlEncode}\',\'{valve_id:htmlEncode}\',\'{manufacturer_id:htmlEncode}\');">' +
                      '(edit)</a></td>' +
                     '<td class="detail_note"><a href="#" onclick="supersedeManufacturer(\'{manufacturers_valves_id:htmlEncode}\',\'{valve_id:htmlEncode}\');">' +
                     '(supersede)</a></td>' +
                     '<td class="detail_note"><a href="#" onclick="removeManufacturerFigureNo(\'{manufacturers_valves_id:htmlEncode}\',\'{valve_id:htmlEncode}\');">' +
                     '(remove)</a></td>';


  supersede_manufacturers_header_tpl = "<th>Undo Supersede</th>";
  supersede_manufacturers_data_tpl = '<td class="detail_note"><a href="#" onclick="undoSupersedeManufacturer(\'{manufacturers_valves_id:htmlEncode}\',\'{valve_id:htmlEncode}\');">' +
                     '(undo)</a></td>';
  // Shows the edit link for admins
  valves_notes_header_tpl = '<th>Admin</th>';

  valves_notes_data_tpl = '<td><a href="#" onclick="telaeris.util.deleteReferenceAndReload(\'/piping_reference_attachings/{piping_reference_attaching_id}\', Ext.getCmp(\'valves_grid\').getStore(), \'{description}\', {}); return false;">(remove)</a></td>';

};

/*
var restoreValves = function(){
        Ext.getCmp("valves_grid").store.searchingData = false;
        //Rename the header
        Ext.getCmp("valves_form_top_toolbar_title").setText('<b>Details</b>');

        //hide the Save Data and spacers
        Ext.getCmp("valves_form").getBottomToolbar().find('text', 'Save Data')[0].show();

        Ext.getCmp('cancel_advanced_search_valves').hide();

        //Additional data to search if needed
        Ext.getCmp('valve_component_text_field').hide();
        Ext.getCmp('valve_component_name_field').hide();

        Ext.getCmp('valves_restore').handler();
        Ext.getCmp('valves_minimize').show();

        //Buttons
        Ext.getCmp('add_new_valve_component_button').show();
        Ext.getCmp('add_new_manufacturer_button').show();
        Ext.getCmp('valves_form_associated_valve_components').show();
        //Show the additional search fields(in the case of valves this is the components search)
      };

var showAdvSearchValves = function(){

        //Rename the header
        Ext.getCmp("valves_form_top_toolbar_title").setText('<b>Advanced Search</b>');

        //hide the Save Data and spacers
        Ext.getCmp("valves_form").getBottomToolbar().find('text', 'Save Data')[0].hide();

        //Actually hide lots of things
        Ext.getCmp('valves_maximize').handler();

        //show/hide minimize/maximize
        Ext.getCmp('valves_maximize').hide();
        Ext.getCmp('valves_minimize').hide();
        Ext.getCmp('valves_restore').hide();

        Ext.getCmp('cancel_advanced_search_valves').show();

        Ext.getCmp('valve_component_text_field').show();
        Ext.getCmp('valve_component_name_field').show();
        Ext.getCmp('valves_form_associated_valve_components').hide();
        Ext.getCmp('add_new_valve_component_button').hide();
        Ext.getCmp('add_new_manufacturer_button').hide();

        Ext.getCmp('valves_form').getForm().reset();

        //Show the additional search fields(in the case of valves this is the components search)
      };
*/



  var loadValveRelatedRecords = function(record){
    var table;
    var store;
    table = Ext.getCmp('valves_form_associated_valve_components');
    store = table.store;
    store.removeAll();
    store.load({
      params: {
        id: record.data.id
      }
    });
    table.getEl().up('.x-form-item').setDisplayed(true);



    table = Ext.getCmp('valves_form_associated_manufacturers');
    store = table.store;
    store.removeAll();
    Ext.apply(store.baseParams, {
      id: record.data.id
    });
    store.load();
    table.getEl().up('.x-form-item').setDisplayed(true);

     // Removed access restrictions per Aman Sidhu's request.
    // if (!currentUser.popv_viewer) {
    table = Ext.getCmp('valves_form_associated_old_manufacturers');
    store = table.store;
    store.removeAll();
    Ext.apply(store.baseParams, {
      id: record.data.id
    });

    store.load();


    table.getEl().up('.x-form-item').setDisplayed(true);

    //  }
    table = Ext.getCmp('valves_form_associated_piping_classes');
    store = table.store;
    store.removeAll();
    store.load({
      params: {
        id: record.data.id
      }
    });
    table.getEl().up('.x-form-item').setDisplayed(true);


    table = Ext.getCmp('valves_references_data');
    store = table.store;
    store.removeAll();
    store.load({
      params: {
        id: record.data.id
      }
    });
    table.getEl().up('.x-form-item').setDisplayed(true);
  };
/******************************************************************************
 Valves Resource
 ******************************************************************************/
//Create the valves Grid/Form
telaeris.resources({
  valves: {
    //dependentStores: ['valve_components', 'manufacturers'],
    baseParams: {
      limit: 100
    },
    gridConfig: {
      advSearch:{
        handler:function(){
          telaeris.windows['advanced_search_valves'].show();
        }
      },

      autoExpandColumn: 'valve_note',
      pageSize: 100,
      refreshStores: ['valves'],
      groupingStore: true,
      groupingField: null,
      view: new Ext.grid.GroupingView({
        startCollapsed: false,
        enableNoGroups: true,
        forceFit: true
      }),
      groupingStoreConfig: {
        groupOnSort: false,
        unGrouped: true
      },
      //can only select one at a time.
      sm: new Ext.grid.RowSelectionModel({
        singleSelect: true,
        listeners: {
          'rowselect': {
            fn: function (rowSelectionModel, rowIndex, record) {
              Ext.getCmp('valves_grid').fireEvent('rowclick', Ext.getCmp('valves_grid'), rowIndex);
              loadValveRelatedRecords(record);
            }
          },
          'rowcontextmenu': function () {

          }
        }
      }),
      sortInfo: {
        field: 'valve_code',
        direction: "ASC"
      },
      listeners: {
        //Right Click menu
        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          // Don't show anything only for popv_viewers
          if (!currentUser.popv_viewer) {
            var menuItems = [];
            var record = grid.getStore().getAt(rowIndex);
            menuItems.push({
              text: 'Add Valve Component',
              handler: editValveComponents.createCallback(record.data.id),
              iconCls: 'icon-arrow-in'
            });
            if (currentUser.admin) {
              if(record.data.archived){
                menuItems.push({
                  text: 'Unarchive Record',
                  handler: telaeris.util.unArchiveHandler.createCallback(grid, rowIndex),
                  iconCls: 'icon-archive'
                });
              }
              else{
                menuItems.push({
                  text: 'Archive Record',
                  handler: telaeris.util.archiveHandler.createCallback(grid, rowIndex),
                  iconCls: 'icon-archive'
                });
              }
              menuItems.push({
                text: 'Clone Valve',
                handler: cloneValve.createCallback(grid, rowIndex),
                iconCls: 'icon-page-copy'
              });
              //Finally Delete the archived line class ONLY if you're an admin
              if(record.data.archived){
                menuItems.push({
                    text: 'Delete Record',
                    handler: telaeris.util.deleteHandler.createCallback(grid, rowIndex),
                    iconCls: 'icon-cross'
                });
              }
            }

            var menu = new Ext.menu.Menu({
              allowOtherMenus: false,
              items: menuItems
            });
            ajaxEvent.stopEvent();
            menu.showAt(ajaxEvent.getXY());
          }
        }
      },
      additionalButtons: [{
        xtype: 'tbbutton',
        text: 'View Archived',
        iconCls: 'icon-archive',
        handler: function () {
          telaeris.util.message("Viewing Archived Valves");
          var grid = Ext.getCmp('valves_grid');
          var store = grid.getStore();
          var lastParams = store.lastOptions.params || {};
          var newParams = Ext.apply(lastParams, {
            'archived': 'Yes'
          });
          //Select the first archived record
          store.on('load', function () {
              Ext.getCmp('valves_form').getForm().reset();
              var selectionModel = grid.getSelectionModel();
              selectionModel.selectRow(0);
            }, store, {
              single: true
            }
            // Bind this only once to the store.
          );
          store.load({
            params: newParams
          });
        }
      },
      {
        xtype: 'button',
        text: 'Toggle Grouping',
        iconCls: 'icon-toggle',
        handler: function () {
          var grid = Ext.getCmp('valves_grid');
          var store = grid.getStore();
          if (store.unGrouped) {
            store.groupBy('valve_type');
            store.unGrouped = false;
          }
          else {
            store.clearGrouping();
            store.unGrouped = true;
          }
        }
      },
      {
        xtype: 'button',
        text: 'All Valves PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          telaeris.openReportsWindow({
            url: '/valves/all_pdf',
            report_class: 'ValvesReport',
            report_method: 'all_pdf',
            report_options: {}
          });
          //window.open('/valves/all_pdf');
        }
      }]
    },
    gridFields: [{
      id: "valve_code",
      header: "Valve Code",
      width: 30,
      renderer: function (value, meta, record) {
        if (record.data.archived === true) {
          return value + " (ARCHIVED)";
        }
        else {
          return value;
        }
      }
    },
    {
      header: 'Type',
      id: 'valve_type',
      width: 60
    },
    {
      header: 'Rating',
      id: 'valve_rating',
      width: 50
    },
    {
      header: 'Body',
      id: 'valve_body',
      width: 80
    }],
    formConfig: {

      referencesClass: 'Valve',
      additionalButtons: [{
        xtype: 'button',
        text: 'View Valve Sheet PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          var valve_id = Ext.getCmp('valves_form').getForm().getValues(false).id;
          if (valve_id !== '' && valve_id !== null && valve_id !== undefined) {
            telaeris.openReportsWindow({
              url: '/valves/pdf/' + valve_id,
              report_class: 'ValvesReport',
              report_method: 'pdf',
              report_options: {
                id: valve_id
              }
            });
            //window.open('/valves/pdf/' + valve_id);
          }
          else {
            Ext.MessageBox.alert('No Valve Assigned', 'There is no valve for this Detail');
          }
          //window.open('/valves/pdf/' + Ext.getCmp('valves_form').getForm().getValues(false).id);
        }
      }]
    },
    formFields: ['valve_code',
    {
      xtype: 'textarea',
      name: 'valve_note',
      height: 100,
      anchor: '-20px'
    },
    {
      fieldLabel: 'Type',
      xtype: 'textfield',
      name: 'valve_type'
    },
    {
      fieldLabel: 'Rating',
      xtype: 'textfield',
      name: 'valve_rating'
    },
    {
      fieldLabel: 'Body',
      xtype: 'textfield',
      name: 'valve_body'
    },
    {
      xtype: 'hidden',
      name: 'archived'
    },

    {
      fieldLabel: 'Valve Components',
      xtype: 'notesview',
      id: 'valves_form_associated_valve_components',
      name: 'valve_component_names',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Component</th><th>Component Text</th>', '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{component_name:htmlEncode}</td>', '<td class="detail_note">{component_text:htmlEncode}</td>', '</tr>', '</tpl>', '</table>'),
      width: 550,
      useInternalStore: true,
      store: new Ext.data.JsonStore({
        totalProperty: 'count',
        root: 'records',
        fields: ['component_name', 'component_text', 'valve_id', 'valve_component_id', 'valves_valve_component_id'],
        url: '/valves/related_valve_components',
        method: 'GET',
        autoLoad: false
      })
    },

    {
      hideLabel:true,
      id:'add_new_valve_component_button',
      name: 'add_button',
      xtype: 'button',
      text: 'Edit Valve Components',
      style: 'margin-top: 5px; margin-bottom: 5px; margin-left: 155px;',
      hidden: !currentUser.admin,
      handler: function () {
        editValveComponents(Ext.getCmp('valves_form').getForm().getValues(false).id);
      }
    },

      // Column 1
      {
        xtype: 'panel',
        id:'manufacturers_panel',
        hidden:true,
        border:false,
        items: [

        //Just contains Fieldset
        {
          xtype: 'panel',
          layout: 'form',
          autoHeight: true,
          border: false,
          //The right anchor for all items should only be 5px,
          //instead of -20px(our default)
          items: [{
            fieldLabel: 'Manufacturers',
            hideLabel: false,
            id: 'valves_form_associated_manufacturers',
            xtype: 'notesview',
            name: 'manufacturers_valves',
            tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Manufacturer</th><th>Figure No</th>', change_manufacturers_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{name:htmlEncode}</td>', '<td class="detail_note">{figure_no:htmlEncode}</td>', change_manufacturers_data_tpl, '</tr>', '</tpl>', '</table>'),
            width: 550,
            hidden: false,
            useInternalStore: true,
            store: new Ext.data.JsonStore({
              totalProperty: 'count',
              root: 'records',
              fields: ['name', 'figure_no', 'valve_id', 'manufacturer_id', 'manufacturers_valves_id'],
              url: '/valves/related_manufacturers',
              method: 'GET',
              autoLoad: false,
              listeners:{
                'load':function(store,records,options){
                  if(store.getCount() <= 0){
                    Ext.getCmp('manufacturers_panel').hide();
                  }
                  else{
                    Ext.getCmp('manufacturers_panel').show();
                  }
                }
              }
            })


          },
          {
            xtype: 'component',
            html: '<p>Unless noted, the description above will override the manufacturer’s figure number in the case of difference.</p>',
            style: 'color:red;padding-left:154px;width:450px;'

          }
                    ]

        }]

      },
      //Column 2
      {
        xtype: 'panel',
        id:'superseded_manufacturers_panel',
        hidden:true,
        border:false,
        items: [{
          xtype: 'panel',

          layout: 'form',
          autoHeight: true,
          border: false,

          //The right anchor for all items should only be 5px,
          //instead of -20px(our default)
          items: [{
            fieldLabel: 'Superseded<br/>Manufacturers',
            hideLabel: false,
            id: 'valves_form_associated_old_manufacturers',
            xtype: 'notesview',
            name: 'old_manufacturers_valves',
            tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Superseded<br/>Manufacturer</th><th>Figure No</th>',supersede_manufacturers_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{name:htmlEncode}</td>', '<td class="detail_note">{figure_no:htmlEncode}</td>',supersede_manufacturers_data_tpl, '</tr>', '</tpl>', '</table>'),
            width: 550,
            hidden: false,
            useInternalStore: true,
            store: new Ext.data.JsonStore({
              totalProperty: 'count',
              root: 'records',
              fields: ['name', 'figure_no', 'valve_id', 'manufacturer_id', 'manufacturers_valves_id'],
              url: '/valves/related_old_manufacturers',
              method: 'GET',
              autoLoad: false,
              listeners:{
                'load':function(store,records,options){
                  if(store.getCount() <= 0){
                    Ext.getCmp('superseded_manufacturers_panel').hide();
                  }
                  else{
                    Ext.getCmp('superseded_manufacturers_panel').show();
                  }
                }
              }
            })
          },
          {
            xtype: 'component',
            html: '<p>Superseded manufacturer information is for reference only. Use of these valves for large capital projects requires the project to perform independent auditing per the AML agreement.</p>',
            style: 'color:red;padding-left:154px;width:450px;'
          }/*,
          {
            xtype: 'label',
            text: 'Superseded manufacturer information is for reference only.',
            style: 'color:red;padding:154px;'
          },
          {
            xtype: 'label',
            text: 'Use of these valves for large capital projects requires the ',
            style: 'color:red;padding:154px;'
          },
          {
            xtype: 'label',
            text: 'project to perform independent auditing per the AML agreement.',
            style: 'color:red;padding:154px;'
          }*/]
        }]
      },


    {
      hideLabel: true,
      id:'add_new_manufacturer_button',
      name: 'add_manufacturer_button',
      xtype: 'button',
      text: 'Add New Manufacturer',
      style: 'margin-top: 5px; margin-bottom: 5px; margin-left: 155px;',
      hidden: !currentUser.admin,
      handler: function () {
        newManufacturerFigureNo(Ext.getCmp('valves_form').getForm().getValues(false).id);
      }
    },
    {
      fieldLabel: 'Associated Piping Classes',
      xtype: 'notesview',
      id: 'valves_form_associated_piping_classes',
      name: 'associated_piping_classes',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Class</th><th>Component</th><th>Size</th><th>Description</th></tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{piping_class:htmlEncode}</td>', '<td class="detail_note">{component:htmlEncode}</td>', '<td class="detail_note">{size:htmlEncode}</td>', '<td class="detail_note">{description:htmlEncode}</td>', '</tr>', '</tpl>', '</table>'),
      width: 550,
      useInternalStore: true,
      store: new Ext.data.Store({
        reader: new Ext.data.JsonReader({
          totalProperty: 'count',
          root: 'records',
          fields: ['piping_class', 'component', 'size', 'description']
        }),
        proxy: new Ext.data.HttpProxy({
          url: '/valves/related_piping_classes',
          method: 'GET'
        }),
        autoLoad: false
      })
    },
    { // Builds the form table of notes
      fieldLabel: 'References',
      id: 'valves_references_data',
      xtype: 'notesview',
      name: 'references_data',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th style="width: 200px;">Description</th>', '<th style="width: 50px;">Type</th>', valves_notes_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note"><a href="#" onclick="telaeris.openURL(\'{link}\'); return false;">{description:htmlEncode}</a></td>', '<td class="detail_note">{reference_type}</td>', valves_notes_data_tpl, '</tr>', '</tpl>', '</table>'),
      width: 550,
      useInternalStore: true,
      store: new Ext.data.Store({
        reader: new Ext.data.JsonReader({
          totalProperty: 'count',
          root: 'records',
          fields: ['id', 'description', 'link', 'reference_type', 'piping_reference_attaching_id']
        }),
        proxy: new Ext.data.HttpProxy({
          url: '/valves/related_piping_references',
          method: 'GET'
        }),
        autoLoad: false
      })
    },
    {
      fieldLabel: 'Comments',
      xtype: 'textarea',
      name: 'comments'
    }]
  }
});


/******************************************************************************
 Valve Components Resource
 ******************************************************************************/
//Create the valve components Grid/Form
telaeris.resources({
  valve_components: {
    gridConfig: {
      noPaging: true,
      sortInfo: {
        field: 'order_numbering',
        direction: "ASC"
      }
    },
    formConfig: {},
    gridFields: ['component_name', 'order_numbering'],
    formFields: ['component_name', 'order_numbering']
  }
});

/******************************************************************************
 Manufacturers Resource
 ******************************************************************************/
//Create the valve components Grid/Form
telaeris.resources({
  manufacturers: {
    gridConfig: {
      sortInfo: {
        field: 'name',
        direction: "ASC"
      },
      refreshStores: ['manufacturers']
    },
    formConfig: {},
    gridFields: ['name'],
    formFields: ['name',
    {
      fieldLabel: 'Valves',
      xtype: 'notesview',
      name: 'valves',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Valve Code</th><th>Valve Note</th><th>Figure No</th></tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{valve_code:htmlEncode}</td>', '<td class="detail_note">{valve_note:htmlEncode}</td>', '<td class="detail_note">{figure_no:htmlEncode}</td>', '</tr>', '</tpl>', '</table>'),
      width: 550,
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['valve_code', 'valve_note', 'figure_no', 'id'],
        data: []
      })
    }]
  }
});

/******************************************************************************
 Piping Components Resource
 ******************************************************************************/
//Create the Piping Components Grid/Form
telaeris.resources({
  piping_components: {
    //dependentStores: ['piping_components'],
    gridConfig: {
      refreshStores: ['piping_components'],
      noPaging: true,
      sm: new Ext.grid.RowSelectionModel({
        singleSelect: true,
        listeners: {
          'rowselect': {
            fn: function (rowSelectionModel, rowIndex, record) {

              var form = Ext.getCmp('piping_components_form');

              var field = form.find('name', 'associated_piping_classes');
              field = field[0];
              var store = field.store;

              store.removeAll();
              store.load({
                params: {
                  id: record.data.id
                }
              });
              field.getEl().up('.x-form-item').setDisplayed(true);
            }
          }
        }
      }),
      listeners: {
        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          var menuItems = [];

          if (currentUser.admin) {
            menuItems.push({
              text: 'Delete Record',
              handler: telaeris.util.deleteHandler.createCallback(grid, rowIndex),
              iconCls: 'icon-cross'
            });

            var menu = new Ext.menu.Menu({
              allowOtherMenus: false,
              items: menuItems
            });
            ajaxEvent.stopEvent();
            menu.showAt(ajaxEvent.getXY());
          }
        }
      }
    },
    formConfig: {},
    gridFields: ['piping_component'],
    formFields: ['piping_component',
    {
      name: 'parent_id',
      xtype: 'combo',
      mode: 'local',
      allowBlank: true,
      fieldLabel: 'Parent Component',
      store: telaeris.stores.piping_components,
      displayField: 'piping_component',
      valueField: 'id'

    },
    {
      xtype: 'notesview',
      name: 'subcomponents',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th style="width: 400px;">Component Name</th></tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{piping_component:htmlEncode}</td></tr>', '</tpl>', '</table>'),
      fieldLabel: 'Subcomponents',
      width: 550,
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['piping_component', 'id'],
        data: []
      })
    },
    {
      fieldLabel: 'Associated Classes',
      hideLabel: false,
      xtype: 'notesview',
      name: 'associated_piping_classes',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr>', '<th>Classes</th>', '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{class_codes:htmlEncode}</td>', '</tr>', '</tpl>', '</table>'),
      width: 550,
      hidden: false,
      useInternalStore: true,
      store: new Ext.data.JsonStore({
        totalProperty: 'count',
        root: 'records',
        fields: ['class_codes'],
        url: '/piping_components/associated_piping_classes',
        method: 'GET',
        autoLoad: false
      })
    }]
  }
});

/******************************************************************************
 Create Many BOM Items
 ******************************************************************************/
// Creates the AJAX request to create the bom items.
var addItemsToBom = function (grid, data) {
  //Make sure the bill_id is up to date.
  Ext.each(data, function (record, i) {
    Ext.apply(record, {
      'bill_id': currentUser.current_bom_id
    });
  });

  Ext.Ajax.request({
    method: 'POST',
    url: '/bill_items/create_many',
    params: {
      '_method': 'POST',
      'records': Ext.encode(data)
    },
    success: function () {
      updateCurrentBom(false);
      telaeris.util.message(data.length + ' Items Added to BOM');

      // Highlights the "View Active BOM" div in the nav panel.
      Ext.get('current_bom').highlight();

      // Clears any selected Piping Class Details.
      grid.getSelectionModel().clearSelections();
      if (!Ext.getCmp('boms_form')) {
        return true;
      }
      // Grabs the currently selected BOM record so we can reselect
      // it after bomsGrid.store.load().
      var bomId = Ext.getCmp('boms_form').getForm().getValues(false).id;

      // Grabs the main BOM grid
      var bomsGrid = Ext.getCmp('boms_grid');

      // After BOM grid store load, selects the previously
      // selected BOM record again.
      var store = bomsGrid.store;
      store.on('load', function () {
        var rowIndex = this.find('id', bomId);
        var selectionModel = bomsGrid.getSelectionModel();
        selectionModel.selectRow(rowIndex);
      }, store, {
        single: true
      }
      // Bind this only once to the store.
      );

      // Loads the store with the last params specified, so the
      // page/sort/search params are the same.
      store.load({
        params: store.lastOptions.params
      });

    }
  });
};

/******************************************************************************
 Add Selected Items To BOM
 ******************************************************************************/
// Loops through all the of the passed in grid's records and adds all of
// the selected items to the current bom.
var addSelectedToBOM = function (grid) {
  var data = [];

  Ext.each(grid.store.getRange(), function (record, i) {
    if (record.data.selected === true) {
      data.push({
        'bill_id': currentUser.current_bom_id,
        'quantity': 1,
        'piping_class': record.data.piping_class,
        'piping_component': record.data.piping_component,
        'piping_class_detail_id': record.data.id,
        'description': record.data.description,
        'notes': record.data.valve
      });
    }
  }, grid);

  // If no BOM is set as current, opens a window to create a new one, and
  // passes in the selected items to add to it.
  if ((currentUser.current_bom_id === "") || (currentUser.current_bom_id === undefined)) {
    //Successful creation will trigger sending the selected data anyways.
    createNewBOMWindow(grid, data);
    return;
  }
  if (data.length > 0) {
    addItemsToBom(grid, data);
  }
};

var addNotesToSelected = function (grid) {
  var detail_ids = [];
  var sdetails = '';
  var class_id = '';
//  console.log("Selected Items:");
  Ext.each(grid.store.getRange(), function (record, i) {
    if (record.data.selected === true) {
      //console.log(record.data.id);
      detail_ids.push(record.data.id);

      class_id = record.data.piping_class_id;
    }
  }, grid);

  sdetails = detail_ids.join(',');

  newPipingNote(sdetails, class_id);

};
var selectAllRecords = function (grid) {
  //Selec tthem all, but also set the "selected" variable to true
  grid.getSelectionModel().selectAll();
  Ext.each(grid.store.getRange(), function (record, i) {
    record.data.selected = true;
  //Select all the records.
  }, grid);
  
};

/******************************************************************************
 Piping Notes Search Helper
 ******************************************************************************/
var newPipingNote = function (detail_id, class_id) {
  var TempSearchBox = new Ext.form.TwinTriggerField({
    id: class_id + '_piping_note_filter',
    emptyText: "filter piping notes",
    trigger1Class: 'x-form-search-trigger',
    trigger2Class: 'x-form-clear-trigger',
    fieldLabel: 'Filter Notes',
    labelStyle: 'margin-left: 10px;',
    width: 250,
    onTrigger1Click: function () {
      //Trigger2 is a search
      var v = this.getValue();
      if (v.length > 0) {
        //telaeris.util.message(resourceName + ' search for \'' + v + '\'');
        //$doSearch(v, resourceName,Ext.getCmp(resourceName + '_grid').getSelectionModel().selectFirstRow);
        telaeris.stores.piping_notes.filterBy(function(record, id){
          var numb = record.get('note_number');
          var txt = record.get('note_text');

          pattern = new RegExp(v, 'gi');

          if((pattern.test(numb) || pattern.test(txt))){
            return true;
          }
        });

      }
      else {
        this.setValue('');
        telaeris.stores.piping_notes.clearFilter();
      }
    },
    onTrigger2Click: function () {
      //Trigger2 is a clear
      this.setValue('');
      telaeris.stores.piping_notes.clearFilter();
    },
    listeners: {
      'specialkey': function (f, e) {
        if (e.getKey() == e.ENTER) {
          e.preventDefault();
          this.onTrigger1Click();
        }
      }
    }
  });


  var detail_name = 'piping_class_detail_' + class_id;

  var piping_notes_wingow_tpl = '<div id="test"><tpl for="."><div style="white-space:normal; border:1px solid #DDD;"; class="ux-mselect-item';

  if (Ext.isIE || Ext.isIE7) {
    piping_notes_wingow_tpl += '" unselectable=on';
  }
  else {
    piping_notes_wingow_tpl += ' x-unselectable"';
  }

  piping_notes_wingow_tpl += '>Note#: {note_number} <br/>{note_text}</div></tpl></div>';

  telaeris.windows({
    'piping_notes': {
      windowConfig: {
        height: 340,
        width: 480,
        resizable: false
      },
      formConfig: {
        height: 300
        //bodyStyle:'padding 4px'
      },
      'title': 'Select Piping Notes to Add',
      'baseParams': {
        '_method': 'PUT'
      },
      formFields: [{
        id:'piping_notes_selections',
        xtype: 'listview',
        autoHeight:true,
        mode: 'local',
        multiSelect:true,
        triggerAction: 'all',
        name: 'piping_notes',
        columns:[
          {dataIndex:"note_number", header:'Number',width:.15},
          {dataIndex:"note_text",header:'Note',width:.85,tpl:'<div style="white-space: normal;">{note_text}</div>'}
        ],
        //displayField: 'note_text',
        //valueField: 'id',
        border: true,
        store: telaeris.stores.piping_notes,
        hideLabel: true,
        height: 210,
        width: 435
        //,        tpl: new Ext.XTemplate(piping_notes_wingow_tpl)
      },
      TempSearchBox,
      {
        xtype: 'hidden',
        name: 'piping_class_detail_id',
        value: detail_id
      }],
      windowFormButtons: [{
        xtype: 'button',
        text: 'Add Notes to Detail',
        handler: function () {
          var selectedRecords = Ext.getCmp('piping_notes_selections').getSelectedRecords();
          var record_ids = '';
          for (var i = 0, len = selectedRecords.length; i < len; i++) {
            record_ids += selectedRecords[i].data.id ;
            if(i != (len - 1)){
              record_ids += ',';
            }

          }

          var submitOpt = {
            waitMsg: 'Saving data ...',
            method: 'POST',
            url: '/piping_class_details/add_notes/' + detail_id,
            params: {
              '_method': 'PUT',
              'piping_notes':record_ids
            }
          };




          submitOpt.success = function () {
            if (Ext.get(detail_name + '_tab')) {

              telaeris.editRecordFromURL(detail_name, '/piping_class_details/' + detail_id);
              var grid = Ext.getCmp(detail_name + '_grid');
              grid.getSelectionModel().clearSelections();
              grid.store.load({
                params: grid.store.lastOptions.params
              });

            }

            telaeris.windows.piping_notes.hide();
          };
          Ext.getCmp('piping_notes_window_form').getForm().submit(submitOpt);
          telaeris.windows.piping_notes.hide();
        }
      },
      {
        xtype: 'button',
        text: 'Cancel',
        handler: function () {
          telaeris.windows.piping_notes.hide();
        }
      }]
    }
  });

  telaeris.windows.piping_notes.on('hide', function () {
    telaeris.stores.piping_notes.clearFilter();
    telaeris.windows.piping_notes.destroy();
  });

  telaeris.windows.piping_notes.on('show', function () {
    //telaeris.stores.piping_notes.load();
  });

  telaeris.windows.piping_notes.show();
};

/******************************************************************************
 Remove Piping Notes Helper
 ******************************************************************************/
//Prompt whether we actually want to do this.
var removePipingNote = function (note_id, piping_class_detail_id, piping_class_id, note_number) {
  telaeris.util.confirm("Are you sure you want to remove Note #" + note_number + " from this component?. This cannot be reversed.", function () {
    Ext.Ajax.request({
      method: 'POST',
      url: '/piping_class_details/remove_note/' + piping_class_detail_id,
      params: {
        '_method': 'PUT',
        'piping_note_id': note_id
      },
      success: function () {
        var store = Ext.getCmp('piping_class_detail_' + piping_class_id + '_grid').store;
        store.load({
          params: store.lastOptions.params
        });
        telaeris.editRecordFromURL('piping_class_detail_' + piping_class_id, '/piping_class_details/' + piping_class_detail_id);

      }
    });
  });
};

/******************************************************************************
 Piping Notes Admin Templates
 ******************************************************************************/
//Templates to edit and create Piping Notes in the form.
var change_piping_note_header_tpl = '';
var change_piping_note_data_tpl = '';
//Only can edit or delete if you're an admin
if (currentUser.admin) {
  change_piping_note_header_tpl = "<th>Remove Link</th>";
  change_piping_note_data_tpl = '<td class="detail_note"><a href="#" onclick="removePipingNote(\'{id}\', \'{piping_class_detail_id}\',\'{piping_class_id}\',\'{note_number}\');">(remove)</a></td>';
}

/******************************************************************************
 Piping Class Prepend Description Window - Should be temporary.
 ******************************************************************************/
/*
var openPipingClassDetailsPrependDescriptionWindow = function (grid) {
  var selectionModel = grid.getSelectionModel();
  var selectedRecords = selectionModel.getSelections();
  var pipingClassDetailIds = [];

  for (var i = 0, len = selectedRecords.length; i < len; i++) {
    pipingClassDetailIds.push(selectedRecords[i].data.id);
  }

  telaeris.windows({
    'piping_class_details_description': {
      windowConfig: {
        height: 340,
        width: 480,
        resizable: false
      },
      formConfig: {
        height: 300
        //bodyStyle:'padding 4px'
      },
      'title': 'Add Text to Selected Descriptions',
      'baseParams': {
        '_method': 'PUT'
      },
      formFields: [{
        xtype: 'textarea',
        fieldLabel: 'Text',
        name: 'description',
        height: 210,
        width: 435
      }],
      windowFormButtons: [{
        xtype: 'button',
        text: 'Submit',
        handler: function () {
          var form_values = Ext.getCmp('piping_class_details_description_window_form').getForm().getValues();

          var submitOpt = {
            waitMsg: 'Saving data ...',
            method: 'POST',
            url: '/piping_class_details/prepend_text_to_descriptions',
            params: {
              '_method': 'PUT',
              piping_class_detail_ids: Ext.util.JSON.encode(pipingClassDetailIds)
            }
          };

          //Add the values to the parameters
          Ext.apply(submitOpt.params, form_values);

          submitOpt.success = function () {
            grid.store.load({
              params: grid.store.lastOptions.params
            });
          };
          Ext.getCmp('piping_class_details_description_window_form').getForm().submit(submitOpt);
          telaeris.windows.piping_class_details_description.hide();
        }
      },
      {
        xtype: 'button',
        text: 'Cancel',
        handler: function () {
          telaeris.windows.piping_class_details_description.hide();
        }
      }]
    }
  });
  Ext.getCmp('piping_class_details_description_window').on('hide', function () {
    telaeris.windows.piping_class_details_description.destroy();
  });
  telaeris.windows.piping_class_details_description.show();
};*/

var openValve = function (valve_code) {
  telaeris.openResource('valves', {
    disableGridLoad: true,
    activated: function () {
      var search_box = Ext.getCmp('valves_search');
      search_box.setValue(valve_code);
      search_box.onTrigger1Click();
    }
  });
};
/******************************************************************************
 Compare Piping Classes - Show/Create Resource Tab
 ******************************************************************************/
var comparePipingClasses = function (record_ids, class_title) {
  var record_ids_string = record_ids[0];
  var pcd_name = 'piping_compare_' + record_ids[0];
  for (var i = 1, len = record_ids.length; i < len; i++) {
    record_ids_string = record_ids_string + ',' + record_ids[i];
    pcd_name = pcd_name + '_' + record_ids[i];
  }



  //if the grid does not already exist
  if (!telaeris.gridConfigs[pcd_name]) {
    var object_no_name = {};
    var ourSm = new Ext.grid.CheckboxSelectionModel({
      header: '',
      listeners: {
        // It would make the most sense to use "record.set"
        // here instead of "record.data[key] = ..." but the
        // store.afterEdit method gets called in that case,
        // which makes the grid jumpy. Directly setting the
        // data in the record doesn't have any unwanted callbacks.
        'rowselect': function (selmod, rowIndex, record) {
          record.data.selected = !record.data.selected;

          var grid = Ext.getCmp(pcd_name + '_grid');
          if (grid) {
            grid.fireEvent('rowclick', grid, rowIndex);
          }
        },
        'rowdeselect': function (selmod, rowIndex, record) {
          record.data.selected = !record.data.selected;
        }
      }
    });



    object_no_name[pcd_name] = {
      baseParams: {
        '_method': 'GET'
      },
      url: '/piping/compare_piping_classes/' + record_ids_string,
      title: class_title,
      noForm: true,
      formFields: [],
      //formConfig:{noForm:true},
      gridFields: [{
        id: 'line_class',
        hidden: true,
        sortable: false
      },
      ourSm,
      {
        id: 'piping_class',
        header: 'Class',
        width: 60,
        sortable: false
      },

      {
        id: 'parent_component',
        header: 'Component',
        width: 100,
        hidden: true,
        menuDisabled: true,
        sortable: false,
        hideable: false
      },
      {
        id: 'piping_component',
        header: 'Component',
        width: 220,
        sortable: false
      },
      {
        id: 'size_desc',
        header: 'Size',
        sortable: false
      },
      {
        id: 'description',
        header: 'Description',
        width: 250,
        renderer: function (value, meta, record) {
          return value.replace(/\n/g, "<br />");
        },
        sortable: false
      },
      {
        id: 'valve',
        header: 'Valve Code',
        sortable: false
      },
      {
        id: 'piping_notes',
        header: 'Piping Notes',
        sortable: false
      }],
      gridConfig: {
        refreshStores: ['piping_components', 'valves'],

        //Override the groupBy function for the groupingStore
        //This will allow us to make it so when we try to group by piping_component, we ALWAYS group by parent_component
        groupingStoreConfig: {
          groupOnSort: false,
          groupBy: function (field, forceRegroup) {
            if (this.groupField == field && !forceRegroup) {
              return; // already grouped by this field
            }
            if (field == 'piping_component') {
              field = 'parent_component';
            }
            this.groupField = field;
            if (this.remoteGroup) {
              if (!this.baseParams) {
                this.baseParams = {};
              }
              this.baseParams.groupBy = field;
            }
            if (this.groupOnSort) {
              this.sort(field);
              return;
            }
            if (this.remoteGroup) {
              this.reload();
            } else {
              var si = this.sortInfo || {};
              if (si.field != field) {
                this.applySort();
              } else {
                this.sortData(field);
              }
              this.fireEvent('datachanged', this);
            }
          }

        },
        stripeRows: false,
        sm: ourSm,
        noPaging: true,
        autoExpandColumn: 'description',
        groupingStore: true,
        groupingField: 'parent_component',
        view: new Ext.grid.GroupingView({
          forceFit: true,
          startCollapsed: false,
          enableNoGroups: true,
          getRowClass: function (record, index, rowParams, store) {
            var d = record.data;
            if (d.selected) {
              return 'task-completed';
            }
            else {
              return record.data.line_class;
            }

          }
        }),
        noSearchButton: false,
        listeners: {
          'render': function () {

            Ext.getCmp(pcd_name + '_grid').store.on('load', function () {
              ourSm.clearSelections();
            });
          },
          'celldblclick': function (grid, rowIndex, columnIndex) {
            var record = grid.getStore().getAt(rowIndex);
            if (grid.colModel.config[columnIndex].id == 'valve') {
              openValve(record.data.valve);
            }
            else if (grid.colModel.config[columnIndex].id == 'piping_notes') {
              showPipingNotesWindow(record.data.piping_notes_data);
            }
          },
          'rowclick': Ext.emptyFn,
          'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
            var record = grid.getStore().getAt(rowIndex);
            var menuItems = [];

            if (!currentUser.popv_viewer) {
              menuItems.push({
                text: 'Add Selected Components to BOM',
                handler: addSelectedToBOM.createCallback(grid),
                iconCls: 'icon-arrow-in'
              });
            }

            if (record.data.valve_id) {
              var valveButtonText = 'View Valve Sheet PDF (' + record.data.valve + ')';

              menuItems.push({
                text: valveButtonText,
                handler: function () {
                  if(record.data.valve_count > 0){
                    var id = record.data.valve_id;
                    telaeris.openReportsWindow({
                      url: '/valves/pdf/' + id,
                      report_class: 'ValvesReport',
                      report_method: 'pdf',
                      report_options: {
                        id: id
                      }
                    });
                  }
                  else{
                    Ext.Msg.alert('Alert', 'No Valves Available for this Piping Class.');
                  }
                  //window.open('/valves/pdf/' + record.data.valve_id);
                },
                iconCls: 'icon-zoom'
              });

            }

/* Special hack put in for Chris.  We can remove this now.
            if (MD5(currentUser.login) == "4f4d9b8b81b6f0f3daa72c46fa107142") {
              menuItems.push({
                text: 'Prepend Text to Selected Descriptions',
                handler: function () {
                  openPipingClassDetailsPrependDescriptionWindow(grid);
                }
              });
            }*/

            if (currentUser.admin) {
              menuItems.push({
                text: 'Add Piping Notes',
                handler: addNotesToSelected.createCallback(grid),
                iconCls: 'icon-cross'
              });

              menuItems.push({
                text: 'Delete Record',
                handler: function () {
                  telaeris.util.deleteHandler(Ext.getCmp(pcd_name + '_grid'), rowIndex);
                },
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
          }
        },
        additionalButtons: [{
          xtype: 'button',
          text: 'Toggle Grouping',
          iconCls: 'icon-toggle',
          handler: function () {
            var grid = Ext.getCmp(pcd_name + '_grid');
            if (grid.store.unGrouped) {
              grid.store.groupBy('piping_component');
              grid.store.unGrouped = false;
            }
            else {
              grid.store.clearGrouping();
              grid.store.unGrouped = true;
            }
          }
        },
        {
          text: 'Add Selected Components to BOM',
          hidden: currentUser.popv_viewer,
          handler: function () {
            addSelectedToBOM(Ext.getCmp(pcd_name + '_grid'));
          },
          iconCls: 'icon-arrow-in'
        },
        {
          xtype: 'button',
          text: 'Download Comparison',
          iconCls: 'icon-report-go',
          handler: function () {
            telaeris.openReportsWindow({
              url: '/piping/compare_piping_classes.csv/' + record_ids_string,
              report_class: 'PipingClassReport',
              report_method: 'details_csv',
              report_options: {
                id: record_ids_string
              }
            });

          }
        }]
      }
    };
    telaeris.resources(object_no_name);
  }

};

var pcd_grid_rowaction = new Ext.ux.grid.RowActions({
  header: 'Order',
  id: 'order',
  width: 40,
  hidden: (!currentUser.admin),
  //menuDisabled:true,
  //sortable: true,
  //hideable: true,
  actions: [
  {
    iconCls: 'icon-up',
    tooltip: 'Move Up'
  },
  {
    iconCls: 'icon-down',
    tooltip: 'Move Down'
  }],
  groupActions:[{
         iconCls:'icon-up-many'
        ,qtip:'Move Group Up'
        ,align: "left"
      },
      {
         iconCls:'icon-down-many'
        ,qtip:'Move Group Down'
        ,align: "left"
      }],
  callbacks: {
    'icon-up-many':function(grid, records, action){
      //Send all the record_ids to the appropriate route
      var ids = [];
      for(var i = 0; i < records.length; i++){
        ids.push(records[i].data.id);
      }

       Ext.get(grid.id).mask('Loading');
       Ext.Ajax.request({
        method: 'POST',
        url: '/piping_class_details/decrease_group_order/' + ids.join(','),
        params: {
          '_method': 'POST'
        },
        failure:function(response){
          Ext.get(grid.id).unmask();
          telaeris.util.message("Error Moving Up");
        },
        success: function (response) {
          telaeris.util.message("Success: Group Moved Up");
          //reload the store and unmask
          Ext.get(grid.id).unmask();
          grid.store.load();
        }
      });
    },
    'icon-down-many':function(grid, records, action){
      //Send all the record_ids to the appropriate route
      var ids = [];
      for(var i = 0; i < records.length; i++){
        ids.push(records[i].data.id);
      }

       Ext.get(grid.id).mask('Loading');
       Ext.Ajax.request({
        method: 'POST',
        url: '/piping_class_details/increase_group_order/' + ids.join(','),
        params: {
          '_method': 'POST'
        },
        failure:function(response){
          Ext.get(grid.id).unmask();
          telaeris.util.message("Error Moving Down");
        },
        success: function (response) {
          telaeris.util.message("Success: Group Moved Down");
          //reload the store and unmask
          Ext.get(grid.id).unmask();
          grid.store.load();
        }
      });
    },
    'icon-up': function (grid, record, action, row, col) {
      Ext.get(grid.id).mask('Loading');
      Ext.Ajax.request({
        method: 'POST',
        url: '/piping_class_details/decrease_order/'+ record.data.id,
        params: {
          '_method': 'POST',
          'id': record.data.id
        },
        failure:function(response){
          Ext.get(grid.id).unmask();
          telaeris.util.message("Error Moving Up");
        },
        success: function (response) {
          var rowData = grid.store.getAt(row);
          var index = row;
          index--;
          if (index >= 0) {
            rowData.data['order'] = rowData.data['order'] - 1;
            grid.getStore().removeAt(row);
            grid.getStore().insert(index, rowData);
            telaeris.util.message("Success: Item Moved Up");
          }
          //grid.store.load();
          Ext.get(grid.id).unmask();
        }
      });
    },
    'icon-down': function (grid, record, action, row, col) {
      Ext.get(grid.id).mask('Loading');
      Ext.Ajax.request({
        method: 'POST',
        url: '/piping_class_details/increase_order/'+ record.data.id,
        params: {
          '_method': 'POST',
          'id': record.data.id
        },
        failure:function(response){
          Ext.get(grid.id).unmask();
          telaeris.util.message("Error Moving Down");
        },
        success: function (response) {
          var rowData = grid.store.getAt(row);
          var index = row;
          index++;
          if (index < grid.getStore().getCount()) {
            rowData.data['order'] = rowData.data['order'] + 1;
            grid.getStore().removeAt(row);
            grid.getStore().insert(index, rowData);
            telaeris.util.message("Success: Item Moved Down");
          }

          Ext.get(grid.id).unmask();

        }
      });
    }

  }
});

/******************************************************************************
 Piping Class Details - Show/Create Resource Tab
 ******************************************************************************/
//This does a dynamic creation of the Piping Class Detail.
//We use the Piping_Class ID as our unique identifier for the tab
var showOrCreatePipingDetail = function (record_id, class_code) {
  var pcd_name = 'piping_class_detail_' + record_id;

  if (!telaeris.gridConfigs[pcd_name]) {
    var object_no_name = {};
    var ourSm = new Ext.grid.CheckboxSelectionModel({
      header: '',
      checkOnly:true,
      listeners: {
        // It would make the most sense to use "record.set"
        // here instead of "record.data[key] = ..." but the
        // store.afterEdit method gets called in that case,
        // which makes the grid jumpy. Directly setting the
        // data in the record doesn't have any unwanted callbacks.
        'rowselect': function (selmod, rowIndex, record) {
          record.data.selected = !record.data.selected;

          var grid = Ext.getCmp(pcd_name + '_grid');
          if (grid) {
            grid.fireEvent('rowclick', grid, rowIndex);
          }
        },
        'rowdeselect': function (selmod, rowIndex, record) {
          record.data.selected = !record.data.selected;
        }
      }
    });

    var groupingView = new Ext.grid.GroupingView({
      startCollapsed: true,
      enableNoGroups: true,
      forceFit: true,
      getRowClass: function (r) {
        var d = r.data;
        if (d.selected) {
          return 'task-completed';
        }
        return '';
      }
    });


    object_no_name[pcd_name] = {
      baseParams: {
        '_method': 'GET',
        'piping_class_id': record_id,
        'filter': 'true'
      },
      //dependentStores: ['valves', 'piping_notes', 'piping_components'],
      url: 'piping_class_details',
      title: class_code,
      formConfig: {
        height: 50,
        hasReferences: true,
        referencesClass: 'PipingClassDetail',
        noSearchButton: true,
        success: function () {
          Ext.getCmp(pcd_name + '_restore').handler();
        },
        additionalButtons: [{
          xtype: 'tbbutton',
          text: 'View Valve Sheet PDF',
          iconCls: 'icon-report',
          handler: function () {
            var valve_id = Ext.getCmp(pcd_name + '_form').valve_id;
            if (valve_id !== '' && valve_id !== null && valve_id !== undefined) {
              telaeris.openReportsWindow({
                url: '/valves/pdf/' + valve_id,
                report_class: 'ValvesReport',
                report_method: 'pdf',
                report_options: {
                  id: valve_id
                }
              });
              //window.open('/valves/pdf/' + valve_id);
            }
            else {
              Ext.MessageBox.alert('No Valve Assigned', 'There is no valve for this Detail');
            }
            return false;
          }
        }]
      },
      gridConfig: {
        plugins: [pcd_grid_rowaction],
        helpText: '<h1>Piping Class Details</h1>' + '<p><label>Add Components to BOM:</label> Select one or more rows (hold SHIFT or CTRL to select more than one) and either click the "Add Selected Components to BOM" button at the top of the list or right-click and select the similarly named option from the menu.</p>' + '<p><label>View Details:</label> To view the individual components, click on the "Component:" headers to expand them, or click the "Toggle Grouping" button at the top of the list to expand all groupings.</p>' + '<p><label>View Valve Sheets:</label> For those components that have associated valves, there are three ways to see the valve information. <br/>1) Right-click on the row and select "View Valve Sheet PDF" to download or email the PDF of the valve info. <br/>2) Double-click on the valve code in the row to open up the Valves list and form to view just that valve record. <br/>3) Select the row and click the "View Valve Sheet PDF" button at the bottom of the "Details" form. </p>' + '<p><label>View Piping Notes:</label> Double-click on the Piping Note numbers in the row to open a window with the associated piping notes.</p>' + '<p><label>Modify Piping Notes:</label> Admins have the special priviledge of modifying the Piping Notes for Class Details. Select the record of interest, and the bottom "Details" panel gives you the option to remove existing notes or add new notes to the record.</p>',

        //Override the groupBy function for the groupingStore
        //This will allow us to make it so when we try to group by piping_component, we ALWAYS group by parent_component
        groupingStoreConfig: {
          groupOnSort: false,
          groupBy: function (field, forceRegroup) {
            if (this.groupField == field && !forceRegroup) {
              return; // already grouped by this field
            }
            if (field == 'piping_component') {
              field = 'parent_component';
            }
            this.groupField = field;
            if (this.remoteGroup) {
              if (!this.baseParams) {
                this.baseParams = {};
              }
              this.baseParams.groupBy = field;
            }
            if (this.groupOnSort) {
              this.sort(field);
              return;
            }
            if (this.remoteGroup) {
              this.reload();
            } else {
              var si = this.sortInfo || {};
              if (si.field != field) {
                this.applySort();
              } else {
                this.sortData(field);
              }
              this.fireEvent('datachanged', this);
            }
          }

        },

        sortInfo: {
          'field': 'order',
          'direction': 'ASC'
        },
        sm: ourSm,
        addButton: {
          xtype: 'tbbutton',
          text: 'Add New Component',
          iconCls: 'icon-plus',
          handler: function () {
            Ext.getCmp(pcd_name + '_form').getForm().reset();
            Ext.DomHelper.overwrite(pcd_name + '_related_data', '');
            Ext.DomHelper.overwrite(pcd_name + '_piping_notes_data', '');
            Ext.getCmp(pcd_name + '_add_piping_note_button').hide();
            Ext.getCmp(pcd_name + '_piping_notes_data').hide();
            Ext.getCmp(pcd_name + '_maximize').handler();

            //Set the value for piping_class_id to the same as the grid...
            Ext.getCmp(pcd_name + '_form').getForm().findField('piping_class_id').setValue(record_id);
          }
        },
        noPaging: true,
        autoExpandColumn: 'description',
        groupingStore: true,
        groupingField: 'parent_component',
        view: groupingView,
        noSearchButton: false,
        listeners: {
          'render': function () {

            // Ext.getCmp(pcd_name + '_minimize').handler();
            Ext.getCmp(pcd_name + '_grid').store.on('load', function () {
              ourSm.clearSelections();
            });
          },
          'celldblclick': function (grid, rowIndex, columnIndex) {
            var record = grid.getStore().getAt(rowIndex);
            if (grid.colModel.config[columnIndex].id == 'valve') {
              openValve(record.data.valve);
            }
            else if (grid.colModel.config[columnIndex].id == 'piping_notes') {
              showPipingNotesWindow(record.data.piping_notes_data);
            }
          },
          'rowclick': function (grid, rowIndex, ajaxEvent) {
            if (currentUser.admin) {
              Ext.getCmp(pcd_name + '_add_piping_note_button').show();
            }
            Ext.getCmp(pcd_name + '_piping_notes_data').show();
            //Need to do this here, since we override
            var record = grid.getStore().getAt(rowIndex);
            telaeris.editRecord(grid.form.getForm(), record, pcd_name);
            Ext.getCmp(pcd_name + '_form').valve_id = record.data.valve_id;
            Ext.getCmp(pcd_name + '_subcomponent_selection').hide();
          },
          'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
            var record = grid.getStore().getAt(rowIndex);
            var menuItems = [];

            if (!currentUser.popv_viewer) {
              menuItems.push({
                text: 'Add Selected Components to BOM',
                handler: addSelectedToBOM.createCallback(grid),
                iconCls: 'icon-arrow-in'
              });
            }

            if (record.data.valve_id) {
              var valveButtonText = 'View Valve Sheet PDF (' + record.data.valve + ')';

              menuItems.push({
                text: valveButtonText,
                handler: function () {
                  var id = record.data.valve_id;
                  telaeris.openReportsWindow({
                    url: '/valves/pdf/' + id,
                    report_class: 'ValvesReport',
                    report_method: 'pdf',
                    report_options: {
                      id: id
                    }
                  });
                  //window.open('/valves/pdf/' + record.data.valve_id);
                },
                iconCls: 'icon-zoom'
              });

            }

/*
//Was temporary hack
if (MD5(currentUser.login) == "4f4d9b8b81b6f0f3daa72c46fa107142") {
              menuItems.push({
                text: 'Prepend Text to Selected Descriptions',
                handler: function () {
                  openPipingClassDetailsPrependDescriptionWindow(grid);
                }
              });
            }*/

            if (currentUser.admin) {
              menuItems.push({
                text: 'Select All Records',
                handler: selectAllRecords.createCallback(grid),
                iconCls: 'icon-accept'
              });
              menuItems.push({
                text: 'Add Piping Notes',
                handler: addNotesToSelected.createCallback(grid),
                iconCls: 'icon-note-add'
              });
              menuItems.push({
                text: 'Delete Selected Records',
                handler: function () {
                  telaeris.util.deleteMultipleRowsHandler(Ext.getCmp(pcd_name + '_grid'));
                },
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
          }
        },
        additionalButtons: [{
          xtype: 'button',
          text: 'Toggle Grouping',
          iconCls: 'icon-toggle',
          handler: function () {
            var grid = Ext.getCmp(pcd_name + '_grid');
            if (grid.store.unGrouped) {
              grid.store.groupBy('piping_component');
              grid.store.unGrouped = false;
            }
            else {
              grid.store.clearGrouping();
              grid.store.unGrouped = true;
            }
          }
        },
        {
          text: 'Add Selected Components to BOM',
          hidden: currentUser.popv_viewer,
          handler: function () {
            addSelectedToBOM(Ext.getCmp(pcd_name + '_grid'));
          },
          iconCls: 'icon-arrow-in'
        },
        {
          text: 'Reset Details Order',
          hidden: !currentUser.admin,
          iconCls: 'icon-defaults',
          handler: function () {
            telaeris.util.confirm("Are you sure you want to Reset the Ordering of this Piping Class?  This Can not be undone", function () {
              Ext.Ajax.request({
                  method: 'POST',
                  url: '/piping/reset_class_order/' + record_id,
                  params: {
                    '_method': 'POST'
                  },
                  success: function () {
                    var store = Ext.getCmp(pcd_name + '_grid').store;
                    store.load({
                      params: store.lastOptions.params
                    });
                  }
                });

            });

            }
          }



        ]
      },

      gridFields: [

      ourSm, pcd_grid_rowaction,
      /*{
          id: 'order',
          header:'Order Value'
      },*/
      {
        id: 'piping_component',
        header: 'Component',
        width: 220
      },
      {
        id: 'parent_component',
        header: 'Component',
        width: 100,
        hidden: true,
        menuDisabled: true,
        sortable: false,
        hideable: false
      },
      {
        id: 'size_desc',
        header: 'Size'
      },
      {
        id: 'description',
        header: 'Description',
        width: 250,
        renderer: function (value, meta, record) {
          return value.replace(/\n/g, "<br />");
        }
      },
      {
        id: 'valve',
        header: 'Valve Code'
      }, 'piping_notes'],
      formFields: [{
        xtype: 'hidden',
        name: 'selected'
      },
      /*{
        fieldLabel: 'Order',
        name: 'order'
      },*/

      {
        fieldLabel: 'Piping Component',
        xtype: 'combo',
        name: 'piping_component_id',
        mode: 'local',
        store: telaeris.stores.piping_components,
        displayField: 'piping_component',
        listeners:{'select':function(combo,record,index){
           if(record.data.has_children){
             Ext.getCmp(pcd_name + '_subcomponent_selection').show();
             Ext.getCmp(pcd_name + '_subcomponent_selection').store.load({
                      params: {parent_id:record.data.id}
                    });
           }
           else{
             Ext.getCmp(pcd_name + '_subcomponent_selection').hide();
           }

        }}
      },
      {
        id:pcd_name + '_subcomponent_selection',
        xtype: 'listview',
        autoHeight:true,
        mode: 'local',
        hidden:true,

        multiSelect:true,
        triggerAction: 'all',
        name: 'selected_subcomponents',
        columnSort:false,
        columns:[
          {dataIndex:"piping_component", header:'Component Name',width:.9}
        ],
        //displayField: 'note_text',
        //valueField: 'id',
        border: true,
        store: new Ext.data.JsonStore({
          url: '/piping_components',
          totalProperty: 'count',
          baseParams: {
            '_method': 'GET',
            'filter':'true',
            sort: 'piping_components.piping_component',
            dir: 'ASC',
            '_method': 'GET',
            all: 'true'
          },
          sortInfo: {
            field: 'piping_component',
            direction: 'ASC'
          },
          root: 'records',
          fields: ['piping_component', 'id'],
          autoLoad: false
        }),
        hideLabel: false,
        fieldLabel:'Subcomponents',

        listeners:{
          'selectionchange':function(view,selections){
            var selectedRecords = Ext.getCmp(pcd_name + '_subcomponent_selection').getSelectedRecords();
            var record_ids = '';
            for (var i = 0, len = selectedRecords.length; i < len; i++) {
              record_ids += selectedRecords[i].data.id ;
              if(i != (len - 1)){
                record_ids += ',';
              }
            }
            Ext.getCmp(pcd_name + '_subcomponent_ids_field').setValue(record_ids);
          }

        }

        //,        tpl: new Ext.XTemplate(piping_notes_wingow_tpl)
      },
      {
        xtype:'hidden',
        name:'subcomponent_ids',
        id:pcd_name + '_subcomponent_ids_field'
      },
      {
        fieldLabel: 'Valve',
        xtype: 'combo',
        name: 'valve_id',
        mode: 'local',
        store: telaeris.stores.valves,
        displayField: 'valve_code'
      },
      {
        xtype:'hidden',
        name:'piping_class_id'
      },
      {
        fieldLabel: 'Size',
        name: 'size_desc'
      },
      {
        fieldLabel: 'Description',
        xtype: 'textarea',
        name: 'description',
        height: 150
      },
      {
        fieldLabel: 'Piping Notes',
        xtype: 'notesview',
        name: 'piping_notes_data',
        id: pcd_name + '_piping_notes_data',
        tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th style="width: 70px;">Note #</th><th>Note Text</th>', change_piping_note_header_tpl, '</tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{note_number:htmlEncode}</td>', '<td class="detail_note">{note_text:htmlEncode}</td>', change_piping_note_data_tpl, '</tr>', '</tpl>', '</table>'),
        width: 550,
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['note_number', 'note_text', 'id', 'piping_class_detail_id', 'piping_class_id'],
          data: []
        })
      },
      {
        hideLabel:true,
        text: 'Add Piping Note',
        id: pcd_name + '_add_piping_note_button',
        name: 'add_button',
        xtype: 'button',
        style: 'margin: 10px 5px;',
        hidden: !currentUser.admin,
        handler: function () {
          var values = Ext.getCmp(pcd_name + '_form').getForm().getValues(false);
          var piping_detail_id = values.id;
          if (piping_detail_id === "") {
            Ext.Msg.alert('Alert', 'You must select a piping class detail before adding notes.');
            return;
          }
          var class_id = values.piping_class_id;
          newPipingNote(piping_detail_id, class_id);
        }
      },
      {
        xtype: 'hidden',
        name: 'piping_notes'
      }]
    };

    telaeris.resources(object_no_name);
  }
};

function openPipingComparison() {
  var grid = Ext.getCmp('piping_grid');
  var selection_model = grid.getSelectionModel();

  if (selection_model.getCount() > 1) {
    var selections = selection_model.getSelections();
    var class_names = '';
    var record_ids = [];
    var record_ids_string = '';
    for (var i = 0, len = selections.length; i < len; i++) {
      record_ids.push(selections[i].data.id);
      if (i !== 0) {
        record_ids_string = record_ids_string + '_';
        class_names = class_names + " vs ";
      }
      class_names = class_names + selections[i].data.class_code;
      record_ids_string = record_ids_string + selections[i].data.id;
    }
    comparePipingClasses(record_ids, class_names);
    telaeris.openResource("piping_compare_" + record_ids_string);
  }
}


telaeris.windows({
    'advanced_search_piping': {
      windowConfig: {
        //height: 340,
        width: 480,
        resizable: true
      },
      formConfig: {
        //height: 300
        //bodyStyle:'padding 4px'
      },
      'title': 'Piping Advanced Search',
      'baseParams': {
        '_method': 'POST'
      },
      formFields: [
'class_code',
'service',
'flange_rating',
'max_pressure',
'max_temp',
'corrosion_allow',
'piping_material',
'small_fitting',
 'valve_body_material',
'valve_trim',
'gasket_material',
'gasket_bolting',
'instr_spec',
'comments'
],
    //Use these instead of default Save Data
      windowFormButtons: [{
        xtype: 'button',
        text: 'Search',
        iconCls: 'icon-magnifier',
        handler: function () {
            //Apply our search parameters to the Valves Grid
            var form = Ext.getCmp('advanced_search_piping_window_form');
            var store = Ext.getCmp('piping_grid').store;
            var newParams = form.getForm().getValues();
            delete newParams.id;
            newParams.filter = "true";

            //store.baseParams = Ext.applyIf(newParams, store.baseParams);
            store.load({
                params: newParams
            });
            store.searchingData = true;


            Ext.getCmp('advanced_search_piping_window').hide();
            //we don't really need this, do we?
            //form.getForm().setValues(newParams);

        }
      },
      {
        xtype: 'button',
        text: 'Cancel',
        handler: function () {
          telaeris.windows.advanced_search_piping.hide();
        }
      }]
    }

  });

/******************************************************************************
 Piping Classes Resource
 ******************************************************************************/
//Main Piping Classes Grid/Form View.
telaeris.resources({
  piping: {
    title: 'Piping Classes',

    gridConfig: {
      advSearch:{
        handler:function(){
          telaeris.windows['advanced_search_piping'].show();
        }
      },
      viewConfig: {
        forceFit: false
      },
      helpText: '<h1>Piping Classes</h1>' + '<p><label>View Piping Class Details:</label> Double-click on a row to open a new tab with all of the details for that class. Alternatively, right-click a row and select "View Piping Components for #CLASS_NAME"</p>' + '<p><label>Compare Classes:</label> Select two or more rows by holding either the SHIFT or CTRL key and selecting the desired rows. Once selected, right-click one of the highlighted rows and select the menu option "Compare Piping Classes...". This will open a new tab with the Details for each class highlighted in different colors and shown side-by-side.</p>' + '<p><label>Search Using the Form:</label> You can search specific fields by entering the search term into the appropriate form field. First click the "Clear Form" button at the bottom of the form, then enter your term/s into the fields. When ready, press "Search Data", and the results will be displayed in the upper list.</p>' + '<p><label>View Archived Classes:</label> Archived Piping Classes can be viewed by clicking the "View Archived" button at the top of the list.</p>',
      width: 1024,
      noPaging: true,
      autoScroll: true,
      minColumnWidth: 40,
      autoFill: true,
      sm: new Ext.grid.RowSelectionModel({
        singleSelect: false,
        listeners: {
          'selectionchange': function (selModel) {
            var button = Ext.getCmp('piping_compare_classes_button');
            var selectedRowCount = selModel.getCount();

            if (selectedRowCount > 1) {
              button.enable();
            }
            else {
              button.disable();
            }
          }
        }
      }),
      sort: 'class_code',
      noDisplayInfo: false,
      autoLoad: false,

      //autoExpandColumn: 'service',
      listeners: {
        'rowclick':function(grid, rowIndex) {
          var record = grid.getStore().getAt(rowIndex);
          var form = grid.form ? grid.form.getForm() : null;
          //Only show the cross reference stuff when we're archived
          if(record.data.archived){
            Ext.getCmp('cross_reference_combo').show();
            Ext.getCmp('cross_reference_link').show();
          }
          else{
            Ext.getCmp('cross_reference_combo').hide();
            Ext.getCmp('cross_reference_link').hide();
          }

          if (form) {
            telaeris.editRecord(form, record, 'piping');
          }
        },
        'rowdblclick': function (grid, rowIndex, ajaxEvent) {
          var record = grid.getStore().getAt(rowIndex);
          var record_id = record.data.id;
          showOrCreatePipingDetail(record_id, record.data.class_code);
          telaeris.openResource("piping_class_detail_" + record_id);
        },
        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          ajaxEvent.stopEvent();
          var record = grid.getStore().getAt(rowIndex);
          var record_id = record.data.id;
          var menuItems = [];


          var selection_model = grid.getSelectionModel();

          if (selection_model.getCount() > 1) {
            var selections = selection_model.getSelections();
            var class_names = selections[0].data.class_code;
            var record_ids = [selections[0].data.id];
            var record_ids_string = selections[0].data.id;
            for (var i = 1, len = selections.length; i < len; i++) {
              record_ids.push(selections[i].data.id);
              class_names = class_names + " vs " + selections[i].data.class_code;
              record_ids_string = record_ids_string + '_' + selections[i].data.id;
            }
            var header_text = "";
            if (selections.length > 4) {
              header_text = "Compare Many Piping Classes";
            }
            else {
              header_text = "Compare Piping Classes " + class_names;
            }



            menuItems.push({
              text: header_text,
              iconCls: 'icon-application-view-detail',
              handler: function () {
                comparePipingClasses(record_ids, class_names);
                telaeris.openResource("piping_compare_" + record_ids_string);
              }
            });

          }

          menuItems.push({
            text: 'View Piping Components for ' + record.data.class_code,
            iconCls: 'icon-application-view-detail',
            handler: function () {
              showOrCreatePipingDetail(record_id, record.data.class_code);
              telaeris.openResource("piping_class_detail_" + record_id);
            }
          });

          if (currentUser.admin) {
            if(record.data.archived){
              menuItems.push({
                text: 'Unarchive Record',
                handler: telaeris.util.unArchiveHandler.createCallback(grid, rowIndex),
                iconCls: 'icon-archive'
              });
            }
            else{
              menuItems.push({
                text: 'Archive Record',
                handler: telaeris.util.archiveHandler.createCallback(grid, rowIndex),
                iconCls: 'icon-archive'
              });
            }


            menuItems.push({
              text: 'Clone Piping Class',
              handler: clonePipingClass.createCallback(grid, rowIndex),
              iconCls: 'icon-page-copy'
            });
            //Finally Delete the archived line class ONLY if you're an admin
            if(record.data.archived){
              menuItems.push({
                  text: 'Delete Record',
                  handler: telaeris.util.deleteHandler.createCallback(grid, rowIndex),
                  iconCls: 'icon-cross'
              });
            }
          }
          var thisMenu = new Ext.menu.Menu({
            allowOtherMenus: false,
            items: menuItems
          });
          thisMenu.showAt(ajaxEvent.getXY());
        }
      },
      additionalButtons: [{
        xtype: 'tbbutton',
        text: 'View Archived',
        iconCls: 'icon-archive',
        //hidden: currentUser.popv_viewer,
        handler: function () {
          telaeris.util.message("Viewing Archived Piping Classes");
          var grid = Ext.getCmp('piping_grid');
          var store = grid.getStore();
          var lastParams = store.lastOptions.params || {};
          var newParams = Ext.apply(lastParams, {
            'archived': 'Yes'
          });
          //Select the first archived record
          store.on('load', function () {
              Ext.getCmp('piping_form').getForm().reset();
              var selectionModel = grid.getSelectionModel();
              selectionModel.selectRow(0);

            }, store, {
              single: true
            }
            // Bind this only once to the store.
          );
          store.load({
            params: newParams
          });
        }
      },
      {
        xtype: 'button',
        text: 'All Piping Classes PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          telaeris.openReportsWindow({
            url: '/piping/all_classes_pdf',
            report_class: 'PipingClassReport',
            report_method: 'all_classes_pdf',
            report_options: {}
          });
          // window.open('/piping/all_classes_pdf');
        }
      },
      {
        xtype: 'button',
        text: 'Compare Classes',
        id: 'piping_compare_classes_button',
        iconCls: 'icon-application-tile-vertical',
        disabled: true,
        tooltip: 'Select two or more rows using your SHIFT or CTRL keys to use this feature.',
        handler: function () {
          openPipingComparison();
        }
      }]
    },
    gridFields: [{
      id: 'class_code',
      header: 'Class',
      renderer: function (value, meta, record) {
        if (record.data.archived === true) {
          return value + " (ARCHIVED)";
        }
        else {
          return value;
        }
      }
    },
    {
      header: 'Service',
      id: 'service',
      width: 220
    },
    {
      header: 'Flange Rating',
      id: 'flange_rating'
    },
    {
      header: 'Max Pressure',
      id: 'max_pressure'
    },
    {
      header: 'Max Temp',
      id: 'max_temp'
    },
    {
      header: 'Corrosion Allowance',
      id: 'corrosion_allow'
    },
    {
      header: 'Piping Material',
      id: 'piping_material'
    },
    {
      header: 'Small Fittings',
      id: 'small_fitting'
    },
    {
      header: 'Valve Body Material',
      id: 'valve_body_material'
    },
    {
      header: 'Valve Trim',
      id: 'valve_trim'
    },
    {
      header: 'Gasket Type',
      id: 'gasket_material'
    },
    {
      header: 'Gasket Bolting',
      id: 'gasket_bolting'
    },
    {
      header: 'Instr. Spec',
      id: 'instr_spec'
    },
    {
      header: 'Last Rev. Date',
      id: 'updated_at'
    },
    {
      header: 'Comments',
      id: 'comments',
      width: 150
    }],
    formConfig: {
      hasReferences: true,
      referencesClass: 'PipingClass',
      additionalButtons: [{
        xtype: 'button',
        text: 'Class Details PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          var id = Ext.getCmp('piping_form').getForm().getValues(false).id;
          telaeris.openReportsWindow({
            url: '/piping/details_pdf/' + id,
            report_class: 'PipingClassReport',
            report_method: 'details_pdf',
            report_options: {
              id: id
            }
          });
          //window.open('/piping/details_pdf/' + Ext.getCmp('piping_form').getForm().getValues(false).id);
        }
      },
      {
        xtype: 'button',
        text: 'Class Valves PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          var valve_count = Ext.getCmp('piping_form').getForm().getValues(false).valve_count;
          if(valve_count > 0){
             var id = Ext.getCmp('piping_form').getForm().getValues(false).id;
              telaeris.openReportsWindow({
                url: '/piping/valves_pdf/' + id,
                report_class: 'PipingClassReport',
                report_method: 'valves_pdf',
                report_options: {
                  id: id
                }
              });
          }
          else{
            Ext.Msg.alert('Alert', 'No Valves Available for this Piping Class.');
          }


          //window.open('/piping/valves_pdf/' + Ext.getCmp('piping_form').getForm().getValues(false).id);
        }
      }]
    },
    formFields: [
    {
      xtype:"notesview",
      fieldLabel: 'Cross Reference Link',
      name: 'cross_reference_class_link_id',
      id:'cross_reference_link',
      tpl:new Ext.XTemplate('<tpl for="."><a ' +
                      'onClick="' +
                      'showOrCreatePipingDetail({id}, \'{class_code}\');' +
                      'telaeris.openResource(\'piping_class_detail_{id}\');' +
                      'return false;" href="#">' +
                      '{class_code}</a></tpl>'),
      //tpl:new Ext.XTemplate('<tpl for="."><a href="{link}"/></tpl>'),
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['id','class_code'],
          data: [],
          listeners: {
            'load': function (store) {
              if(Ext.getCmp('cross_reference_link')){
                if(store.getCount <= 0){
                  Ext.getCmp('cross_reference_link').hide();
                }
                else{
                  Ext.getCmp('cross_reference_link').show();
                }
              }
            }
          }
        })

    },
    {
      name: 'class_only',
      xtype: 'combo',
      mode: 'local',
      width: 450,
      minListWidth: 450,
      fieldLabel: 'Cross Reference Class',
      name: 'cross_reference_class_id',
      id:'cross_reference_combo',
      hiddenName: 'cross_reference_class_id',
      hiddenId: 'cross_reference_class_id',
      displayField: 'class_code',
      emptyText: '--Class--',
      triggerAction: 'all',
      editable: false,
      selectOnFocus: true,
      allowBlank:true,
      listeners: {
        'select': function (combo, record, index) {
          if(Ext.getCmp('cross_reference_link')){
            var store = Ext.getCmp('cross_reference_link').store;
            store.removeAll();

            //modify the Link when we select the combo
            store.loadData(record.data);
          }
        }
      },
      store: new Ext.data.JsonStore({
        storeId: 'piping_class_codes_only',
        url: '/piping/classes_only',
        totalProperty: 'count',
        baseParams: {
          '_method': 'GET',
          all: 'true'
        },
        sortInfo: {
          field: 'class_code',
          direction: 'ASC'
        },
        root: 'records',
        fields: ['class_code', 'id'],
        autoLoad: true,
        listeners: {
          'load': function (store) {
            var record_1 = store.getAt(1).copy();
            Ext.data.Record.id(record_1);
            record_1.data.id = '';
            record_1.data.class_code = '--Empty--';
            store.insert(0,record_1);
          }
        }
      }),
      hidden:(!currentUser.admin)
    },

    {
      xtype: 'panel',
      layout: 'column',
      border: false,
      defaults: {
        // Defaults for the Column Panels:
        columnWidth: 0.5,
        layout: 'form',
        hideLabels: true,
        border: false,
        defaults: {
          // These are then the defaults for the fieldsets
          anchor: '100%',
          //And these are the defaults for the items in the fieldsets
          defaults: {
            anchor: '-5'
          }
        }
      },
      items: [{
        // Column 1
        xtype: 'panel',
        items: [
        //Just contains Fieldset
        {
          xtype: 'panel',
          layout: 'form',
          autoHeight: true,
          border: false,
          //The right anchor for all items should only be 5px,
          //instead of -20px(our default)
          items: [{
            xtype: 'textfield',
            name: 'class_code'
          },
          {
            xtype: 'textarea',
            name: 'service',
            height: 120
          },
          {
            xtype: 'textfield',
            name: 'flange_rating'
          },

          {
            xtype: 'textfield',
            name: 'corrosion_allow'
          },
          {
            xtype: 'textfield',
            name: 'small_fitting'
          }]
        }]
      },

      {
        // Column 1
        xtype: 'panel',
        items: [
        //Just contains Fieldset
        {
          xtype: 'panel',
          layout: 'form',
          autoHeight: true,
          border: false,
          //The right anchor for all items should only be 5px,
          //instead of -20px(our default)
          items: [

          {
            xtype: 'textfield',
            name: 'valve_trim'
          },
          {
            xtype: 'textfield',
            name: 'instr_spec'
          },
          {
            xtype: 'textfield',
            name: 'max_pressure'
          },
          {
            xtype: 'textfield',
            name: 'max_temp'
          },
          {
            xtype: 'textfield',
            name: 'piping_material'
          },
          {
            xtype: 'textfield',
            name: 'valve_body_material'
          },
          {
            xtype: 'textfield',
            name: 'gasket_material'
          },
          {
            xtype: 'textfield',
            name: 'gasket_bolting'
          },
          {
            xtype: 'hidden',
            name:'archived',
            fieldLabel: 'Archived'
          }]
        }]
      }]
    },
    {
      xtype: 'panel',
      layout: 'form',
      border: false,
      defaults: {
        anchor: '-5'
      },
      items: [{
        xtype: 'textarea',
        name: 'special_note',
        height: 80,
        style: 'color: #0A0'
      },
      {
        xtype: 'textarea',
        name: 'maintenance_note',
        height: 80
      },
      {
        xtype: 'textarea',
        name: 'comments',
        height: 80
      },
      {
        xtype:'hidden',
        name:'valve_count',
        hidden:true
      }]
    }]
  }
});

/******************************************************************************
 Clone Piping Class
 ******************************************************************************/
//Prompt to duplicate Piping Class.  Send AJAX Call and refresh Grid/Form
var clonePipingClass = function (grid, rowIndex) {
  var record = grid.getStore().getAt(rowIndex);

  Ext.Msg.prompt('Clone Piping Class', 'Enter the Class Code for the new Piping Class:', function (button, value) {
    if (button == 'ok') {
      Ext.Ajax.request({
        method: 'POST',
        url: '/piping/clone_class/' + record.data.id,
        params: {
          '_method': 'POST',
          'new_class_code': value
        },
        success: function (response) {
          var store = Ext.getCmp('piping_grid').store;
          store.load({
            params: store.lastOptions.params
          });
          var record = {};
          json_response = Ext.util.JSON.decode(response.responseText);
          var new_data = json_response.record;

          var original_class_code = json_response.original_class_code;
          var alert_message = 'Successfully cloned Piping Class \'' + original_class_code + '\' as \'' + new_data.class_code + '\'.<br/>';
          alert_message += 'This class will be set as ARCHIVED until it is ready to be released.';
          Ext.MessageBox.alert('Piping Class Cloned', alert_message);
          telaeris.util.message('New Cloned Piping Class ' + new_data.class_code);
          telaeris.editRecordFromURL('piping', '/piping/' + new_data.id);
          Ext.getCmp('piping_maximize').handler();
        }
      });
    }

  }, grid, false, record.data.class_code);
};

/******************************************************************************
 Bill of Materials Helpers
 ******************************************************************************/
//Opens the BOM Item Window to create a new BOM Item
var newBOMItem = function () {
  currentBOMItemIndex = null;
  telaeris.windows.bom_item_window.show();

  Ext.getCmp('add_bom_item_button').setText('Add Item to BOM');
};

var saveBomLineItem = function (grid, record, action, row, col) {
      record.data.hide_save_icon = true;

      var theseParams = {
        '_method': 'PUT'
      };
      Ext.apply(theseParams, record.data);
      Ext.Ajax.request({
        method: 'POST',
        url: '/bill_items/' + record.data.id,
        params: theseParams,
        success: function () {
          //also call editRecordFromURL to reload the edited item.
          //telaeris.editRecordFromURL('boms', '/boms/' + record.data.id);
          //reload the store because its data will be different
          /*if (Ext.getCmp('boms_grid')) {
            var store = Ext.getCmp('boms_grid').store;
            store.load({
              params: store.lastOptions.params
            });
          }*/
          record.data.hide_save_icon = true;
          record.commit();
          telaeris.reloadSingleStoreRecord(record, '/bill_items/' + record.data.id, {
            hide_save_icon: true
          });
          Ext.get('bom_builder_grid').unmask();
          Ext.getCmp('bom_builder_grid').store.sort('line_num','ASC');

          //WHY WOULD WE UPDATE THE BOM INFO HERE?
          //if (record.data.bill_id == currentUser.current_bom_id) {
          //  updateCurrentBom(false);
          //}
        }
      });


    };
//Actions for the Individual Bill Line Items
var bom_grid_rowaction = new Ext.ux.grid.RowActions({
  header: '',
  actions: [{
    iconCls: 'icon-undo',

    //qtipIndex: 'qtip2',
    //iconIndex: 'action2'
    hideIndex: 'hide_save_icon'
    //text: 'Open'
  },
  {
    iconCls: 'icon-disk',
    tooltip: 'Configure',
    qtipIndex: 'qtip2',
    //iconIndex: 'action2'
    hideIndex: 'hide_save_icon'
    //text: 'Open'
  },
  {
    iconCls: 'icon-pencil',
    tooltip: 'Edit',
    hideIndex: 'is_not_owner'

  },
  {
    iconCls: 'icon-cross',
    tooltip: 'Delete',
    hideIndex: 'is_not_owner'
  }],

  callbacks: {
    'icon-undo': function (grid, record, action, row, col) {
      telaeris.reloadSingleStoreRecord(record, '/bill_items/' + record.data.id, {
        hide_save_icon: true
      });
    },
    'icon-disk': saveBomLineItem,
    'icon-cross': function (grid, record, action, row, col) {
      removeBillItem(grid, record);
    },
    'icon-pencil': function (grid, record, action, row, col) {
      editBillItem(grid, row);
    }

  }
});
var editBillItem = function (grid, rowIndex) {
  //Open the window for editing the BOM Item
  currentBOMItemIndex = rowIndex;
  Ext.getCmp('add_bom_item_button').setText('Save Item to BOM');
  telaeris.windows.bom_item_window.show();
};
var removeBillItem = function (grid, record) {
  //It's a local item, just remove it from the store'
  if (record.data.id === '') {
    Ext.getCmp('bom_builder_grid').store.remove(record);
    telaeris.util.message('Bill of Material Line Item Removed ' + record.data.description);
  }
  else {
    //It's a remote item, and needs to be queried'
    //Our confirmation comes on success
    telaeris.util.confirm("Are you sure you want to delete this Bill Item?", function () {
      Ext.Ajax.request({
        method: 'POST',
        url: '/bill_items/' + record.data.id,
        params: {
          '_method': 'DELETE'
        },
        success: function () {
          var store = Ext.getCmp('boms_grid').store;
          store.load({
            params: store.lastOptions.params
          });
          Ext.getCmp('bom_builder_grid').store.remove(record);
          telaeris.util.message('Bill of Material Line Item Removed ' + record.data.description);
          if (record.data.bill_id == currentUser.current_bom_id) {
            updateCurrentBom(false);
          }
        }
      });
    });
  }
};
// Makes an ajax call to grab the current bom record, and loads it into the form.
var updateCurrentBom = function (showForm) {
  if (currentUser.popv_user === false) {
    return;
  }

  // If the current bom id is defined, make an ajax request to grab it.
  if (currentUser.current_bom_id !== "") {
    Ext.Ajax.request({
      method: 'GET',
      url: '/boms/' + currentUser.current_bom_id,
      params: {
        '_method': 'GET'
      },
      success: function (response) {
        var record = {
          data: Ext.util.JSON.decode(response.responseText).data
        };

        updateCurrentBomFromRecord(record);

        // Navigates to the form and opens it if showForm == true.
        if (showForm) {
          telaeris.openResource('boms', {
            maximizeForm: true,
            filterParam: 'current',
            title: 'Bill of Materials(Current)',
            record: record
          });
        }
      }
    });
  }
  // If the current bom id isn't defined for the current user, load nothing.
  else {
    updateCurrentBomFromRecord(undefined);
    if (showForm) {
      //Clear the form before we do this
      Ext.getCmp('boms_form').getForm().reset();
      telaeris.openResource('boms', {
        filterParam: 'all',
        title: 'Bill of Materials(All)'
      });
    }
  }
};
// Loads the passed in record into the current bom form.
var updateCurrentBomFromRecord = function (record) {
  var currentString = 'View Active BOM';
  var dateDiv = '';
  var onClick = 'createNewBOMWindow(); return false;';
  if (record && record.data) {
    currentUser.current_bom_id = record.data.id;
    var htmlString = '' + record.data.tracking + ' (' + record.data.num_items + ' items)<br/>' + record.data.description.substring(0, 30) + '...<br />Updated: ' + record.data.updated_at.substring(0, 10);
    dateDiv = {
      tag: 'div',
      'class': 'current_bom',
      html: htmlString
    };
    //checkBomsRecordsForCurrentBOM(Ext.getCmp('boms_grid').store.getRange());
    onClick = 'updateCurrentBom(true); return false;';

    //In addition to update the DOM element, let's try to see if the BOMS
    //Editor is open to that record.
    if(Ext.getCmp('boms_form')){
      telaeris.editRecordFromURL('boms', '/boms/' + record.data.id);

    }
  }

  Ext.DomHelper.overwrite('current_bom', [{
    tag: 'a',
    cls: 'icon-report-go',
    html: currentString,
    href: '#',
    onClick: onClick
  },
  dateDiv]);
};

/******************************************************************************
 Create New Bill of Materials Window
 ******************************************************************************/
//Opens the New BOM window
var createNewBOMWindow = function (caller, selected_items) {
  telaeris.windows({
    new_bom: {
      title: 'Create New Bill of Materials',
      url: 'boms',
      baseParams: {
        '_method': 'POST'
      },
      formFields: [{
        fieldLabel: 'Unit',
        xtype: 'combo',
        mode: 'remote',
        name: 'unit_id',
        displayField: 'full_description',
        valueField: 'id',
        store: telaeris.stores.units,
        allowBlank: false,
        minChars: 2
      },
      {
        fieldLabel: 'Description',
        xtype: 'textarea',
        name: 'description',
        allowBlank: false
      },
      {
        fieldLabel: 'Default Piping Size',
        name: 'default_piping_size',
        xtype: 'combo',
        mode: 'local',
        id: 'default_piping_size_combo',
        displayField: 'piping_size',
        valueField: 'piping_size',
        triggerAction: 'all',
        editable: false,
        selectOnFocus: true,
        store: telaeris.stores.sizes
      }],
      windowFormButtons: [{
        xtype: 'button',
        text: 'Create New BOM',
        handler: function () {
          var submitOpt = {
            waitMsg: 'Saving data ...',
            method: 'POST',
            params: {
              '_method': 'POST'
            },
            scope: Ext.getCmp('boms_form'),
            url: '/boms/'
          };
          var grid = Ext.getCmp('boms_grid');
          submitOpt.success = function (grid, response) {
            telaeris.windows.new_bom.hide();
            var record = {};
            var new_data = Ext.util.JSON.decode(response.response.responseText).record;
            telaeris.util.message('New Bill of Materials Created Tracking # is ' + new_data.tracking);
            record.data = new_data;
            updateCurrentBomFromRecord(record);
            if (Ext.getCmp('boms_grid')) {
              Ext.getCmp('boms_grid').store.on('load', function () {
                Ext.getCmp('boms_grid').selModel.selectFirstRow();
                telaeris.editRecordFromURL('boms', '/boms/' + new_data.id);
              }, grid, {
                single: true
              });

              Ext.getCmp('boms_grid').store.load();
            }

            //We selected some items and this BOM creation is following that.
            if ((selected_items !== undefined) && (selected_items.length !== undefined) && (selected_items.length > 0)) {
              addItemsToBom(caller, selected_items);
            }
          };

          // Removed so duplicate data isn't sent, because the
          // following submit() call already grabs the form
          // data and sends it in the POST request.
          //var record = Ext.getCmp('new_bom_window_form').getForm().getValues();
          //Ext.apply(submitOpt.params, record);
          Ext.getCmp('new_bom_window_form').getForm().submit(submitOpt);
        }
      },
      {
        xtype: 'button',
        text: 'Cancel',
        handler: function () {
          telaeris.windows.new_bom.hide();
        }
      }]
    }
  });
  Ext.getCmp('new_bom_window').on('hide', function () {
    telaeris.windows.new_bom.destroy();
  });
  telaeris.stores.units.load();
  telaeris.stores.sizes.load();
  Ext.getCmp('new_bom_window').show();
};

/******************************************************************************
 Bill of Materials Status Handler for Form Buttons
 ******************************************************************************/
//Opens the New BOM window
//If you are allowed to edit this BOM in the first place
var showOrHideFormBasedOnStatus = function (record) {
  var status = record.data.status;
  if (record.data.is_editable_by_current_user === true) {
    //Depending on the Status of the BOM, you will have different options.
    if (status == "Draft") {
      Ext.getCmp('save_draft_boms_button').show();
      if (record.data.unit_id && record.data.unit_id !== "") {
        Ext.getCmp('finalize_button').show();
      }
      else {
        Ext.getCmp('finalize_button').hide();
      }
      Ext.getCmp('create_req_button').hide();
      Ext.getCmp('supersede_bom_button').hide();
    }
    else if (status == 'Finalized') {
      Ext.getCmp('save_draft_boms_button').hide();
      Ext.getCmp('finalize_button').hide();
      Ext.getCmp('create_req_button').show();
      Ext.getCmp('supersede_bom_button').hide();
    }
    else if (status == 'Created') {
      Ext.getCmp('save_draft_boms_button').hide();
      Ext.getCmp('finalize_button').hide();
      Ext.getCmp('create_req_button').hide();
      Ext.getCmp('supersede_bom_button').show();
    }
    //This else if for superseded should not be needed
    //No one can be the owner of a Superseded BOM.
    else if (status == 'Superseded' || record.data.superseded === true) {
      Ext.getCmp('save_draft_boms_button').hide();
      Ext.getCmp('finalize_button').hide();
      Ext.getCmp('create_req_button').hide();
      Ext.getCmp('supersede_bom_button').hide();
    }

    //If the status is finalized, but the material request wasn't created, leave the button out there
    //        if(!((record.data.material_request_id) && (record.data.material_request_id != null)) &&
    //                (status == 'Finalized')){
    //            Ext.getCmp('finalize_and_create_req_button').show();
    //        }
    if (status == "Draft") {
      Ext.getCmp('add_new_bom_item').show();
      Ext.getCmp('bom_builder_grid').tools.plus.show();
      Ext.DomHelper.overwrite('boms_edit_note', '');
    }
    else {
      Ext.getCmp('add_new_bom_item').hide();
      Ext.getCmp('bom_builder_grid').tools.plus.hide();
      Ext.DomHelper.overwrite('boms_edit_note', 'Only Draft Bills of Materials can be edited.');
    }
  }
  else {
    Ext.getCmp('save_draft_boms_button').hide();
    Ext.getCmp('finalize_button').hide();
    Ext.getCmp('create_req_button').hide();
    Ext.getCmp('add_new_bom_item').hide();
    Ext.getCmp('bom_builder_grid').tools.plus.hide();
    Ext.getCmp('copy_button').show();
    if (status == 'Created' || status == 'Finalized') {
      Ext.getCmp('supersede_bom_button').show();
    }
    else {
      Ext.getCmp('supersede_bom_button').hide();
    }
    Ext.DomHelper.overwrite('boms_edit_note', 'Only POPV Admins or the Owner can Edit a Bill of Material');
  }
};

/******************************************************************************
 Bill of Materials Resource
 ******************************************************************************/
telaeris.resources({
  boms: {
    //dependentStores: ['units', 'sizes', 'piping_notes', 'piping_components', 'valves', 'valve_components', 'units_for_measure', 'reference_number_types'],
    gridConfig: {
      autoExpandColumn: 'description',
      selModel: new Ext.grid.RowSelectionModel({
        singleSelect: true
      }),
      refreshStores: ['units', 'units_for_measure', 'sizes'],
      noSearchButton: true,
      listeners: {
        'rowclick': function (grid, rowIndex) {
          var record = grid.getStore().getAt(rowIndex);
          showOrHideFormBasedOnStatus(record);
          //This will manually set the field, but isn't a solution
          //           Ext.getCmp("bom_builder_grid").setValue(record.data['bom_items']);
          telaeris.editRecord(grid.form.getForm(), record, 'boms');
        },

        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          //    var newDeleteHandler = function(grid, rowIndex){
          //    telaeris.util.deleteHandler(grid, rowIndex);
          //};
          var menuItems = [];
          var record = grid.store.getAt(rowIndex);
          if (record.data.is_editable_by_current_user === true) {

            menuItems.push({
              text: 'Set as Current BOM',
              iconCls: 'icon-asterisk-yellow',
              handler: function () {
                var record = grid.store.getAt(rowIndex);
                Ext.Ajax.request({
                  method: 'POST',
                  url: '/boms/set_current/' + record.data.id,
                  params: {
                    '_method': 'POST'
                  },
                  success: function () {
                    updateCurrentBomFromRecord(record);
                    telaeris.editRecord(grid.form.getForm(), record, 'boms');
                    var store = Ext.getCmp('boms_grid').store;
                    store.load({
                      params: store.lastOptions.params
                    });
                  }
                });
              }
            });
            menuItems.push({
              text: 'Delete Bill #' + record.data.tracking,
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
        }
      },
      sortInfo: {
        field: 'tracking',
        direction: 'DESC'
      },
      addButton: {
        xtype: 'button',
        text: 'Create New Bill of Materials',
        iconCls: 'icon-plus',
        allCanAdd: true,
        handler: createNewBOMWindow
      }
    },
    formConfig: {
      hasReferences: true,
      referencesClass: 'Bill',
      showUserNotes: false,
      title: "Edit Bill of Material",
/*listeners: {

            'resize':  function(){
              //Ext.getCmp('boms_form').doLayout();
              if(Ext.get('bom_builder_grid')){
                  if(Ext.getCmp('bom_builder_grid').rendered != 'false'){
                    Ext.getCmp('bom_builder_grid').setSize(Ext.getCmp('boms_form').getSize().width - 100);
                }
            }

            }
            },*/
      noSearchButton: true,
      saveButtonReplacement: [{
        id: 'save_draft_boms_button',
        text: 'Save Draft',
        iconCls: 'icon-disk',
        xtype: 'button',
        hidden: true,
        handler: function () {
          updateBOM('Draft');
        }

      },
      {
        id: 'finalize_button',
        xtype: 'button',
        iconCls: 'icon-image',
        text: 'Finalize',
        hidden: true,
        handler: function () {
          telaeris.util.confirm("Are you sure you want to finalize this Bill of Materials?", function () {
            updateBOM('Finalized');
          });
        }
      },
      {
        id: 'create_req_button',
        xtype: 'button',
        iconCls: 'icon-image',
        text: 'Create Material Request',
        hidden: true,
        handler: function () {
          telaeris.util.confirm("This will create a Material Request from this Bill of Materials.  Are you sure?", function () {
            updateBOM('Created');
          });
        }
      },
      {
        id: 'supersede_bom_button',
        xtype: 'button',
        text: 'Supersede BOM',
        iconCls: 'icon-image-link',
        hidden: true,
        handler: function () {
          telaeris.util.confirm("This will create a new revision of this BOM.  Are you sure?", function () {
            updateBOM('Superseded');
          });
        }
      },
      {
        id: 'copy_button',
        xtype: 'button',
        iconCls: 'icon-image',
        text: 'Copy BOM',
        // hidden: true,
        handler: function () {
          telaeris.util.confirm("Are you sure you want to make a copy of this Bill of Materials?", function () {
            updateBOM('Copy');
          });
        }
      },
      {
        xtype: 'tbfill'

      },
      {
        xtype: 'button',
        text: 'RFQ',
        iconCls: 'icon-report-edit',
        handler: function () {
          var id = Ext.getCmp('boms_form').getForm().getValues(false).id;
          telaeris.openReportsWindow({
            url: '/boms/request_for_quote_pdf/' + id,
            report_class: 'BillsReport',
            report_method: 'request_for_quote_pdf',
            report_options: {
              id: id
            }
          });
          //window.open('/boms/request_for_quote_pdf/' + Ext.getCmp('boms_form').getForm().getValues(false).id);
        }
      },
      {
        xtype: 'button',
        text: 'CSV',
        iconCls: 'icon-page-excel',
        handler: function () {
          window.open('/boms/csv/' + Ext.getCmp('boms_form').getForm().getValues(false).id);
        }
      },
      {
        xtype: 'button',
        text: 'PDF',
        iconCls: 'icon-report-go',
        handler: function () {
          var id = Ext.getCmp('boms_form').getForm().getValues(false).id;
          telaeris.openReportsWindow({
            url: '/boms/pdf/' + id,
            report_class: 'BillsReport',
            report_method: 'pdf',
            report_options: {
              id: id
            }
          });
          //window.open('/boms/pdf/' + Ext.getCmp('boms_form').getForm().getValues(false).id);
        }
      },
      {
        xtype: 'button',
        text: 'Excel',
        iconCls: 'icon-page-excel',
        handler: function () {
          window.open('/boms/excel.xml?r=' + new Date().getTime() + '&bill_id=' + Ext.getCmp('boms_form').getForm().getValues(false).id);
        }
      }

      ]

    },
    gridFields: [{
      //xtype: 'field',
      header: 'Tracking #',
      width: 35,
      id: 'tracking',
      renderer: function (value, meta, record) {
        if (record.data.id == currentUser.current_bom_id) {
          return value + " (Current)";
        }
        else {
          return value;
        }

      }
    }, 'description',
    {
      header: '# of Items',
      id: 'num_items',
      width: 17
    },
    {
      id: 'status',
      width: 40,
      renderer: function (value, meta) {
        if (value == 'Draft') {
          meta.css = 'error';
        }
        return value;
      }
    },
    {
      header: 'Created By',
      id: 'created_name',
      width: 45
    },
    {
      header: 'Last Updated',
      id: 'updated_at',
      width: 60
    }],
    formFields: [{
      xtype: 'hidden',
      name: 'material_request_id'
    },
    {
      xtype: 'hidden',
      name: 'is_editable_by_current_user'
    },
    {
      xtype: 'hidden',
      name: 'created_by'
    },
    {
      xtype: 'hidden',
      name: 'bom_data',
      id: 'bom_data'
    },

    {
      xtype: 'panel',
      layout: 'column',
      border: false,
      //bodyStyle:'padding:2px 0px',
      defaults: {
        //Defaults for the Column Panels.
        columnWidth: 0.5,
        layout: 'form',
        hideLabels: true,
        border: false,


        //These are then the defaults for the fieldsets
        defaults: {
          anchor: '100%',

          //And these are the defaults for the items in the fieldsets
          //Anchor '-5'
          defaults: {
            anchor: '-5'
          }

        }
        //                ,bodyStyle:'padding:4px'
      },
      items: [
      //Column Layout Items
      {
        xtype: 'panel',
        //title: 'Column 1',
        items: [
        //Just contains Fieldset
        {
          xtype: 'fieldset',
          layout: 'form',
          autoHeight: true,
          border: false,
          //The right anchor for all items should only be 5px,
          //instead of -20px(our default)
          items: [{
            xtype: 'textfield',
            name: 'description',
            fieldLabel: 'Description'
          },
          {
            xtype: 'combo',
            name: 'unit_id',
            mode: 'remote',
            allowBlank: false,
            minListWidth: 350,
            displayField: 'full_description',
            valueField: 'id',
            fieldLabel: 'Unit',
            store: telaeris.stores.units,
            minChars: 2
          },
          {
            xtype: 'datefield',
            name: 'required_on',
            //hideLabel: true
            fieldLabel: 'Required On'
          },
          {
            xtype: 'textfield',
            name: 'work_order',
            //hideLabel: true
            fieldLabel: 'Work Order'
          },
          {
            fieldLabel: 'Reference 1 Type',
            xtype: 'combo',
            name: 'reference_number_1_type',
            mode: 'local',
            editable: false,
            allowBlank: false,
            //                        minListWidth: 350,
            displayField: 'name',
            valueField: 'name',
            store: telaeris.stores.reference_number_types,
            minChars: 2
          },
          {
            fieldLabel: 'Reference 1',
            xtype: 'textfield',
            name: 'reference_number_1'
          },
          {
            fieldLabel: 'Reference 2 Type',
            xtype: 'combo',
            name: 'reference_number_2_type',
            mode: 'local',
            editable: false,
            allowBlank: false,
            //                        minListWidth: 350,
            displayField: 'name',
            valueField: 'name',
            store: telaeris.stores.reference_number_types,
            minChars: 2
          },
          {
            fieldLabel: 'Reference 2',
            xtype: 'textfield',
            name: 'reference_number_2'
          },
          {
            fieldLabel: 'Reference 3 Type',
            xtype: 'combo',
            name: 'reference_number_3_type',
            mode: 'local',
            editable: false,
            allowBlank: false,
            //                        minListWidth: 350,
            displayField: 'name',
            valueField: 'name',
            store: telaeris.stores.reference_number_types,
            minChars: 2
          },
          {
            fieldLabel: 'Reference 3',
            xtype: 'textfield',
            name: 'reference_number_3'
          },
          {
            xtype: 'textfield',
            name: 'requestor_department',
            //hideLabel: true
            fieldLabel: 'Department'
          },
          {
            fieldLabel: 'Default Piping Size',
            name: 'default_piping_size',
            xtype: 'combo',
            mode: 'local',
            displayField: 'piping_size',
            valueField: 'piping_size',
            triggerAction: 'all',
            editable: false,
            selectOnFocus: true,
            store: telaeris.stores.sizes
          }]
        }]
      },
      //end column 1
/* {
          xtype:'panel',
          //title: 'Column MIDDLE',
          border:false,
          columnWidth: .04,
          layout:'fit',
          items:[{
          xtype: 'labelnl',
          text: ' '
      }]
      },*/

      {
        //title: 'Column 2',
        xtype: 'panel',
        items: [

        {
          xtype: 'fieldset',
          layout: 'form',
          autoHeight: true,
          border: false,
          items: [

          {

            xtype: 'textfield',
            name: 'tracking',
            readonly: true,
            cls: 'purple',
            fieldLabel: 'Tracking'
            //hideLabel:true
          },
          {
            xtype: 'textfield',
            name: 'created_name',
            //hideLabel: true,
            fieldLabel: 'Created By',
            readOnly: true,
            cls: 'purple'
          },
          {
            xtype: 'textfield',
            name: 'status',
            //hideLabel: true,
            fieldLabel: 'Status',
            readOnly: true,
            cls: 'purple'
          },
          {
            xtype: 'combo',
            name: 'delivery_type',
            fieldLabel: 'Delivery Type',
            editable: false,
            store: ['Normal', 'Expedited', 'ASAP'],
            value: 'Normal'
          },
          {
            xtype: 'textfield',
            name: 'deliver_to',
            fieldLabel: 'Deliver To'
          },
          {
            xtype: 'textfield',
            name: 'attention',
            fieldLabel: 'Attention'
          },
          {
            xtype: 'textfield',
            name: 'will_call',
            fieldLabel: 'Will Call'
          },
          {
            xtype: 'textfield',
            name: 'will_call_extension_or_radio',
            fieldLabel: 'Ext / Radio'
          },
          {
            xtype: 'combo',
            name: 'stage',
            fieldLabel: 'Stage',
            editable: false,
            store: [
              [1, 'Yes'],
              [0, 'No']
            ]

          },
          {
            xtype: 'textfield',
            name: 'suggested_vendor',
            fieldLabel: 'Suggested Vendor'
          },
          {
            xtype: 'textarea',
            name: 'special_instructions',
            anchor: '99%',
            fieldLabel: 'Special Instructions'
          }]
        }]
      }
      //end column 2
      ]
      //End of columns
    },

    {

      xtype: 'editorgridformfield',
      style: 'padding: 10px;',
      //This will disable the "ENTER" key moving to next line
      sm:new Ext.grid.RowSelectionModel({moveEditorOnEnter:false}),
      viewConfig: {
        forceFit: true,
        emptyText: 'No Items in this Bill of Material'
      },
      id: 'bom_builder_grid',
      name: 'bom_items',
      layout: 'fit',

      title: "Bill of Material Items",
      tools: [{
        id: 'plus',
        handler: newBOMItem,
        qtip: 'Add Item to Bill of Materials'
      }],
      listeners: {
        'beforeedit': function (this_event) {
          if (this_event.record.data.is_not_owner === true) {
            this_event.cancel = true;
          }
        },
        'afteredit': function (e) {
          //If we're on the line_num c olumn

          if(e.column === 0){
            Ext.get('bom_builder_grid').mask('Loading');
            saveBomLineItem(e.grid, e.record, 'afteredit', e.row, e.column);
          }
          else if (e.record.dirty) {
            e.record.data.hide_save_icon = false;

            //Instead of just committing,
            //We fire the update event for the store,
            //Since this will leave the dirty flag in place
            //And redraw our save/undo icons
            e.record.store.fireEvent('update', e.record.store, e.record, Ext.data.Record.EDIT);
          }
        },
        //'rowdblclick':function(grid, rowIndex, ajaxEvent){
        //        var record = grid.store.getAt(rowIndex);
        //        if((currentUser.admin)||(record.data.is_not_owner == false)){
        //      editBillItem(grid, rowIndex);
        //        }
        //    },
        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          var record = grid.store.getAt(rowIndex);
          var menuItems = [];
          var status = Ext.getCmp('boms_form').getForm().getValues().status;
          if (status == 'Draft') {
            if (record.data.is_editable_by_current_user === true) {
              menuItems.push({
                text: 'Edit Bill Item',
                handler: editBillItem.createCallback(grid, rowIndex),
                iconCls: 'icon-pencil'
              });
              menuItems.push({
                text: 'Delete Bill Item',
                handler: removeBillItem.createCallback(grid, record),
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
          }
        }
      },

      autoExpandColumn: 'notes',
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['id', 'bill_id', 'quantity', 'piping_class', 'piping_class_detail_id', 'piping_component', 'size_1', 'size_2', 'unit_of_measure', 'description', 'notes', 'piping_class_id', 'piping_component_id', 'line_num',
        {
          name: 'is_not_owner',
          type: 'boolean',
          defaultValue: false
        },
        {
          name: 'hide_save_icon',
          type: 'boolean',
          defaultValue: true
        }],
        data: []
      }),
      plugins: [bom_grid_rowaction],
      columns: [{
        dataIndex: "line_num",
        header: "#",
        width: 10,
        menuDisabled: true,
        sortable: false,
        editor: new Ext.Editor(new Ext.form.TextField({
          allowBlank: false,
          triggerAction: 'all',
          selectOnFocus: true
        }), {
          autoSize: true,
          id: 'line_no_edfield'

        }),
        menuDisabled: true,
        sortable: false
      },

      {
        dataIndex: "quantity",
        header: "Qty",
        width: 20,

        editor: new Ext.Editor(new Ext.form.NumberField({
          allowBlank: false
        }), {
          autoSize: "width",
          id: 'qty_edfield'
        }),
        menuDisabled: true,
        sortable: false
      },
      {
        dataIndex: "unit_of_measure",
        header: "UoM",
        width: 20,
        editor: new Ext.Editor(new Ext.form.ComboBox({
          mode: 'local',
          allowBlank: true,
          triggerAction: 'all',
          displayField: 'name',
          emptyText: '',
          valueField: 'name',
          editable: false,
          selectOnFocus: true,
          store: telaeris.stores.units_for_measure
        }), {
          autoSize: true,
          id: 'uom_edfield'
        }),
        menuDisabled: true,
        sortable: false
      },
      {
        dataIndex: "size_1",
        header: "Size 1",
        width: 25,
        editor: new Ext.Editor(new Ext.form.ComboBox({
          mode: 'local',
          allowBlank: true,
          emptyText: '--Size 1--',
          triggerAction: 'all',
          displayField: 'piping_size',
          valueField: 'piping_size',
          editable: true,
          selectOnFocus: true,
          store: telaeris.stores.sizes
        }), {
          autoSize: true,
          id: 'sz1_edfield'
        }),
        listeners:{'select':function(){
          alert('check the size here');
        }},

        menuDisabled: true,
        sortable: false
      },
      {
        dataIndex: "size_2",
        header: "Size 2",
        width: 25,
        editor: new Ext.Editor(new Ext.form.ComboBox({
          mode: 'local',
          allowBlank: true,
          emptyText: '--Size 2--',
          triggerAction: 'all',
          displayField: 'piping_size',
          valueField: 'piping_size',
          editable: true,
          selectOnFocus: true,
          store: telaeris.stores.sizes,
          listeners: {
            blur: function () {
              if (!this.getRawValue()) {
                this.setValue();
              }
            }
          }
        }), {
          autoSize: true,
          id: 'sz2_edfield'
        }),
        menuDisabled: true,
        sortable: false
      },
      {
        dataIndex: "piping_component",
        header: "Component",
        width: 85,
        menuDisabled: true,
        sortable: false
      },
      {
        dataIndex: "piping_class",
        header: "Class",
        width: 25,
        menuDisabled: true,
        sortable: false

      },
      {
        dataIndex: "description",
        header: "Description",
/* editor: new Ext.Editor(new Ext.form.TextArea({
                    allowBlank: false
                }), {
                    autoSize: "width",
                    id:'desc_edfield'
                }),*/
        menuDisabled: true,
        sortable: false,
        width: 150
      },
      {
        dataIndex: "notes",
        header: "Notes",
/*  editor: new Ext.Editor(new Ext.form.TextArea({
                    allowBlank: true
                }), {
                    autoSize: "width",
                    id:'notes_edfield'
                }),*/
        menuDisabled: true,
        sortable: false
      },
      bom_grid_rowaction]
    },
    {
      id: 'add_new_bom_item',
      name: 'add_button',
      fieldLabel: false,
      xtype: 'button',
      text: 'Add New Item to BOM',
      style: 'margin: 10px 5px;',
      handler: newBOMItem
    }]
  }
});

/******************************************************************************
 More Bill of Materials Helpers
 ******************************************************************************/
// This saves, finalizes, creates material requests from, and supersedes BOMS.
// Pass in either 'Draft', 'Finalized', 'Created', or 'Superseded' as `status` to
// perform the necessary action.
var updateBOM = function (status) {
  var form = Ext.getCmp('boms_form');
  var basicForm = form.getForm();
  var formValues = basicForm.getValues(false);
  var recordId = formValues.id;

  // Common defaults
  submitOpt = {
    waitMsg: 'Saving data ...',
    method: 'POST',
    params: {
      '_method': 'PUT'
    },
    scope: Ext.getCmp('boms_form')
  };

  // Sets url and success callback for superseding a BOM.
  if (status == 'Superseded') {
    Ext.apply(submitOpt, {
      url: '/boms/supersede/' + recordId,
      success: function (form, response) {
        var grid = Ext.getCmp('boms_grid');
        var store = grid.store;


        var record = {};
        var responseText = Ext.util.JSON.decode(response.response.responseText);
        record.data = responseText.record;

        // Sets the current bom to the new draft bom and shows it.
        currentUser.current_bom_id = record.data.id;

        updateCurrentBom(false);


        store.load({
          params: store.lastOptions.params,
          callback: function () {
            // Grabs the record index from the store based on record id.
            var rowIndex = store.find('id', record.data.id);
            // Selects that row in the grid, which will load the
            // data into the form again using the updated store info.
            grid.getSelectionModel().selectRow(rowIndex);
            // Change form viewing based on status.
            showOrHideFormBasedOnStatus(record);
            // Scrolls to that row.
            grid.getView().focusRow(rowIndex);
          }
        });
      }
    });
  }
  // We don't really care about the actual form data, since the BOM
  // isn't being updated in this server call, but its easiest to stick into
  // this giant "updatedBOM" method anyway, for clarity of flow.
  else if (status == 'Created') {
    Ext.apply(submitOpt, {
      url: '/boms/create_material_request/' + recordId,
      success: function (form, response) {
        var record = {};
        var grid = Ext.getCmp('boms_grid');
        var store = grid.store;

        var responseText = Ext.util.JSON.decode(response.response.responseText);
        record.data = responseText.record;
        telaeris.util.message(responseText.message);

        store.load({
          params: store.lastOptions.params,
          callback: function () {
            // Grabs the record index from the store based on record id.
            var rowIndex = store.find('id', recordId);
            // Selects that row in the grid, which will load the
            // data into the form again using the updated store info.
            grid.getSelectionModel().selectRow(rowIndex);
            // Change form viewing based on status.
            showOrHideFormBasedOnStatus(record);
            // Scrolls to that row.
            grid.getView().focusRow(rowIndex);

          }
        });

      }
    });
  }

  else if (status == 'Copy') {
    Ext.apply(submitOpt, {
      url: '/boms/copy/' + recordId,
      success: function (form, response) {
        var record = {};
        var grid = Ext.getCmp('boms_grid');
        var store = grid.store;

        var responseText = Ext.util.JSON.decode(response.response.responseText);
        record.data = responseText.record;
        telaeris.util.message(responseText.message);

        store.load({
          params: store.lastOptions.params,
          callback: function () {
            // Grabs the record index from the store based on record id.
            var rowIndex = store.find('id', recordId);
            // Selects that row in the grid, which will load the
            // data into the form again using the updated store info.
            grid.getSelectionModel().selectRow(rowIndex);
            // Change form viewing based on status.
            showOrHideFormBasedOnStatus(record);
            // Scrolls to that row.
            grid.getView().focusRow(rowIndex);

          }
        });

      }
    });
  }

  // Sets the url and callback for updating a BOM.
  // Makes sure the BOM items get serialized and added to the params.
  else if (status == 'Draft' || status == 'Finalized') {

    // Sets the desired status on the form so it gets submitted.
    basicForm.setValues({
      status: status
    });

    //Get the Bill Items Data for the params
    var data = [];
    Ext.each(
    Ext.getCmp('bom_builder_grid').store.getRange(), function (r, i) {
      data.push(r.data);
    }, this);

    Ext.apply(submitOpt, {
      url: '/boms/' + recordId,
      params: {
        'bom_data': Ext.encode(data),
        // Add the Bill Items to the params.
        '_method': 'PUT'
      },
      success: function (form, response) {
        var record = {};
        var store;

        var responseText = Ext.util.JSON.decode(response.response.responseText);
        record.data = responseText.record;
        telaeris.util.message(responseText.message);

        var grid = Ext.getCmp('boms_grid');
        store = grid.store;

        store.load({
          params: store.lastOptions.params,
          callback: function () {
            // Grabs the record index from the store based on record id.
            var rowIndex = store.find('id', record.data.id);
            // Selects that row in the grid.
            grid.getSelectionModel().selectRow(rowIndex);
            // Change form viewing based on status.
            showOrHideFormBasedOnStatus(record);
            // Scrolls to that row.
            grid.getView().focusRow(rowIndex);

          }
        });
      }
    });
  }

  // This submits the form data by appending it to the end of the params
  // submitOpt already defines.
  Ext.getCmp('boms_form').getForm().submit(submitOpt);
};

var customBOMFieldsValidator = function (value) {
  var form = Ext.getCmp('bom_item_window_window_form');
  if (form) {
    return (value && value !== "");
  }
  else {
    return false;
  }
};

telaeris.windows({
  bom_item_window: {
    id: 'add_bom_item',
    name: 'add_fieldset',
    width: 700,
    height: 400,
    title: 'Add Bill of Material Item',
    loadMask: 'Loading...',
    disabled: true,
    //An array of buttons to use instead of just the "Save Data" button
    windowFormButtons: [{
      id: 'add_bom_item_button',
      xtype: 'button',
      text: 'Add Item to BOM',
      handler: function () {
        var bill_id = Ext.getCmp('bill_id').getValue();
        var piping_class_detail_id = Ext.getCmp('piping_detail_description_combo').getValue();
        var piping_class_name = Ext.getCmp('piping_class_only_combo').getRawValue();
        var piping_component_name = Ext.getCmp('piping_component_combo').getRawValue();

        var class_detail_record_index = Ext.getCmp('piping_detail_description_combo').store.find('id', piping_class_detail_id);
        var class_detail_record = Ext.getCmp('piping_detail_description_combo').store.getAt(class_detail_record_index);
        var description = '';
        var form = Ext.getCmp('bom_item_window_window_form');

        var chkValue = form.getForm().getValues(false).custom_item;
        description = Ext.getCmp('piping_detail_description').getRawValue();

        var valid = true;
        //Validations
        if (chkValue && chkValue == "0") {
          if (Ext.isEmpty(piping_class_detail_id) || Ext.isEmpty(description)) {
            Ext.getCmp('piping_detail_description_combo').markInvalid("Must have a value");
            valid = false;
          }
          if (!piping_class_name) {
            Ext.getCmp('piping_class_only_combo').markInvalid("Must have a value");
            valid = false;
          }
          if (!piping_component_name || piping_component_name == '--Select Component--') {
            Ext.getCmp('piping_component_combo').markInvalid("Must have a value");
            valid = false;
          }
        }
        if (valid === false) {
          return;
        }

        var size1 = Ext.getCmp('size_1_combo').getRawValue();
        var size2 = Ext.getCmp('size_2_combo').getRawValue();
        var unit_of_measure = Ext.getCmp('unit_of_measure_combo').getValue();
        var notes = Ext.getCmp('bom_window_notes').getValue();

        var quantity = Ext.getCmp('bom_quantity').getValue();

        var postMethod = 'POST';
        var postURL = '/bill_items';

        //If it's an existing item
        if (currentBOMItemIndex !== null) {
          postMethod = 'PUT';
          postURL = '/bill_items/' + Ext.getCmp('bom_item_window_window_form').getForm().getValues(false).bill_item_id;
        }

        Ext.Ajax.request({
          method: postMethod,
          url: postURL,
          params: {
            '_method': postMethod,
            'bill_id': bill_id,
            'quantity': quantity,
            'piping_class': piping_class_name,
            'piping_component': piping_component_name,
            'piping_class_detail_id': piping_class_detail_id,
            'description': description,
            'notes': notes,
            'size_1': size1,
            'size_2': size2,
            'unit_of_measure': unit_of_measure
          },
          success: function () {
            if (bill_id == currentUser.current_bom_id) {
              updateCurrentBom(false);
            }

            //also call editRecordFromURL to reload the edited item.
            telaeris.editRecordFromURL('boms', '/boms/' + bill_id);

            //Hide the window when we're done
            telaeris.windows.bom_item_window.hide();

            //reload the store because its data will be different
            if (Ext.getCmp('boms_grid')) {
              var store = Ext.getCmp('boms_grid').store;
              store.load({
                params: store.lastOptions.params
              });
            }
          }
        });
      }
    },
    {
      xtype: 'button',
      text: 'Cancel',
      handler: function () {
        telaeris.windows.bom_item_window.hide();
      }
    }],
    //The extra config options we want to use instead of the defaults
    //Anything can be overridden here.
    windowConfig: {
      listeners: {
        'beforeshow': function () {
          // Grabs the default piping size from the boms form textfield.
          var defaultPipingSize = Ext.getCmp('boms_form').getForm().getValues().default_piping_size;
          var record;
          var localCounter = 0;
          //If it's an existing item, we need to load it up
          if (currentBOMItemIndex !== null) {
            Ext.get('add_bom_item').mask('Loading');
            record = Ext.getCmp('bom_builder_grid').store.getAt(currentBOMItemIndex);

            //Set the values of IDs for the stores
            Ext.getCmp('piping_component_combo').store.baseParams.piping_class_id = record.data.piping_class_id;
            Ext.getCmp('piping_detail_description_combo').store.baseParams.piping_class_id = record.data.piping_class_id;
            Ext.getCmp('piping_detail_description_combo').store.baseParams.piping_component_id = record.data.piping_component_id;

            //Set the values of the fields
            Ext.getCmp('bill_item_id').setValue(record.data.id);
            Ext.getCmp('bill_id').setValue(record.data.bill_id);
            Ext.getCmp('bom_quantity').setValue(record.data.quantity);
            Ext.getCmp('piping_detail_description').setValue(record.data.description);
            Ext.getCmp('size_1_combo').setValue(record.data.size_1);
            Ext.getCmp('size_2_combo').setValue(record.data.size_2);
            Ext.getCmp('unit_of_measure_combo').setValue(record.data.unit_of_measure);
            Ext.getCmp('bom_window_notes').setValue(record.data.notes);

            //If the piping_class doesn't exist in reality, we need to reset all three anyways.
            if (Ext.isEmpty(record.data.piping_class_detail_id) && !Ext.isEmpty(record.data.description)) {
              Ext.get('add_bom_item').unmask();
              Ext.getCmp('bom_item_window_window_form').getForm().findField('custom_item').setValue(true);
            }
            else {
              Ext.getCmp('bom_item_window_window_form').getForm().findField('custom_item').setValue(false);
            }

            
            if (!Ext.isEmpty(record.data.piping_class_id)) {
              localCounter++;

              Ext.getCmp('piping_detail_description_combo').store.on('load', function () {
                Ext.getCmp('piping_detail_description_combo').setValue(record.data.piping_class_detail_id);
                localCounter--;
                if (localCounter <= 0) {
                  Ext.get('add_bom_item').unmask();
                }
              }, this, {
                single: true
              });

              Ext.getCmp('piping_detail_description_combo').store.load();
            }

            var value_record = record;
            if (!Ext.isEmpty(record.data.piping_component_id)) {
              localCounter++;
              Ext.getCmp('piping_component_combo').store.on('load', function (store) {
                Ext.getCmp('piping_component_combo').setValue(value_record.data.piping_component_id);
                var record_location = Ext.getCmp('piping_component_combo').store.findBy(

                function (local_record, id) {
                  return (local_record.data.id == value_record.data.piping_component_id);
                });

                localCounter--;
                if (localCounter <= 0) {
                  Ext.get('add_bom_item').unmask();
                }
              }, this, {
                single: true
              });

              Ext.getCmp('piping_component_combo').store.load();
            }

            //Always load the piping class combo box
            localCounter++;
            Ext.getCmp('piping_class_only_combo').store.on('load', function () {
              Ext.getCmp('piping_class_only_combo').setValue(record.data.piping_class_id);
              localCounter--;
              if (localCounter <= 0) {
                Ext.get('add_bom_item').unmask();
              }
            }, this, {
              single: true
            });
            Ext.getCmp('piping_class_only_combo').store.load();
          }

          else if (Ext.getCmp('bom_builder_grid').store.getAt(0)) {
            record = Ext.getCmp('bom_builder_grid').store.getAt(0);
            Ext.get('add_bom_item').mask('Loading');

            // Clear the combos:
            Ext.getCmp('bill_id').setValue(Ext.getCmp('boms_form').getForm().getValues(false).id);
            Ext.getCmp('bom_quantity').setValue('1');
            Ext.getCmp('size_1_combo').setValue(defaultPipingSize);
            Ext.getCmp('size_2_combo').setValue('');
            Ext.getCmp('unit_of_measure_combo').setValue('');
            Ext.getCmp('bom_window_notes').setValue('');
            Ext.getCmp('piping_detail_description_combo').setValue('');
            Ext.getCmp('piping_detail_description_combo').store.removeAll();
            Ext.getCmp('piping_component_combo').setValue('');
            Ext.getCmp('piping_component_combo').store.removeAll();
            Ext.getCmp('piping_detail_description').setValue('');

            Ext.getCmp('piping_class_only_combo').store.on('load', function () {
              Ext.getCmp('piping_class_only_combo').setValue(record.data.piping_class_id);
              Ext.getCmp('piping_component_combo').store.baseParams.piping_class_id = record.data.piping_class_id;
              Ext.getCmp('piping_component_combo').store.load();
              Ext.getCmp('piping_detail_description_combo').store.baseParams.piping_class_id = record.data.piping_class_id;
              Ext.get('add_bom_item').unmask();
            }, this, {
              single: true
            });
            Ext.getCmp('piping_class_only_combo').store.load();
            Ext.getCmp('bom_item_window_window_form').getForm().findField('custom_item').setValue(false);
          }
          else {
            //clear the combos:
            Ext.getCmp('bill_id').setValue(Ext.getCmp('boms_form').getForm().getValues(false).id);

            Ext.getCmp('bom_quantity').setValue('1');
            Ext.getCmp('size_1_combo').setValue(defaultPipingSize);
            Ext.getCmp('size_2_combo').setValue('');
            Ext.getCmp('unit_of_measure_combo').setValue('');
            Ext.getCmp('bom_window_notes').setValue('');
            Ext.getCmp('piping_detail_description_combo').setValue('');
            Ext.getCmp('piping_detail_description_combo').store.removeAll();
            Ext.getCmp('piping_component_combo').setValue('');
            Ext.getCmp('piping_component_combo').store.removeAll();
            Ext.getCmp('piping_class_only_combo').setValue('');
            Ext.getCmp('piping_detail_description').setValue('');
            Ext.getCmp('bom_item_window_window_form').getForm().findField('custom_item').setValue(false);
            //Always load the piping class combo box
            localCounter++;
            Ext.getCmp('piping_class_only_combo').store.on('load', function () {
              //Ext.getCmp('piping_class_only_combo').setValue(record.data.piping_class_id);
              localCounter--;
              if (localCounter <= 0) {
                Ext.get('add_bom_item').unmask();
              }
            }, this, {
              single: true
            });
            Ext.getCmp('piping_class_only_combo').store.load();
          }
        }
      }
    },

    formFields: [{
      xtype: 'hidden',
      name: 'bill_item_id',
      id: 'bill_item_id'
    },
    {
      name: 'custom_item',
      xtype: 'checkbox',
      fieldLabel: 'Custom Item',
      listeners: {
        'check': function (cbox, checked) {
          if (checked) {
            Ext.getCmp('piping_detail_description_combo').disable();
            Ext.getCmp('piping_component_combo').disable();
            Ext.getCmp('piping_class_only_combo').disable();
            Ext.getCmp('piping_detail_description_combo').setValue('');
            Ext.getCmp('piping_detail_description_combo').store.removeAll();
            Ext.getCmp('piping_component_combo').setValue('');
            Ext.getCmp('piping_component_combo').store.removeAll();
            Ext.getCmp('piping_class_only_combo').setValue('');
          }
          else {
            Ext.getCmp('piping_detail_description_combo').enable();
            Ext.getCmp('piping_component_combo').enable();
            Ext.getCmp('piping_class_only_combo').enable();
          }
        }
      }
    },
    {
      xtype: 'hidden',
      name: 'bill_id',
      id: 'bill_id'
    },
    {
      name: 'class_only',
      xtype: 'combo',
      id: 'piping_class_only_combo',
      mode: 'local',
      width: 450,
      minListWidth: 450,
      fieldLabel: 'Piping Class',
      hiddenName: 'piping_class_only_combo_id',
      hiddenId: 'piping_class_only_combo_id',
      displayField: 'class_code',
      emptyText: '--Class--',
      triggerAction: 'all',
      validator: customBOMFieldsValidator,
      editable: false,
      selectOnFocus: true,
      listeners: {
        'select': function (combo, record, index) {
          var comp_combo = Ext.getCmp('piping_component_combo');
          comp_combo.store.baseParams.piping_class_id = record.data.id;
          Ext.getCmp('piping_detail_description_combo').store.baseParams.piping_class_id = record.data.id;

          comp_combo.store.load();
          comp_combo.setRawValue('--Select Component--');
          Ext.getCmp('piping_detail_description_combo').setRawValue('--Select Component--');
        }
      },
      store: new Ext.data.JsonStore({
        storeId: 'piping_class_codes_only',
        url: '/piping/classes_only',
        totalProperty: 'count',
        baseParams: {
          '_method': 'GET',
          all: 'true'
        },
        sortInfo: {
          field: 'class_code',
          direction: 'ASC'
        },
        root: 'records',
        fields: ['class_code', 'id'],
        autoLoad: false
      })
    },
    {
      name: 'piping_component',
      xtype: 'combo',
      id: 'piping_component_combo',
      mode: 'local',
      fieldLabel: 'Piping Component',
      hiddenName: 'piping_component_combo_id',
      hiddenId: 'piping_component_combo_id',
      displayField: 'piping_component',
      emptyText: '--Select Class--',
      triggerAction: 'all',
      validator: customBOMFieldsValidator,
      editable: false,
      selectOnFocus: true,
      listeners: {
        'select': function (combo, record, index) {
          var comp_combo;
          var unit_of_measure;

          comp_combo = Ext.getCmp('piping_detail_description_combo');
          comp_combo.store.baseParams.piping_component_id = record.data.id;
          comp_combo.store.load();
          comp_combo.setRawValue('--Select Detail--');

          // Sets the unit of measure depending of if the
          // component is a pipe or not.
          if (record.data.piping_component == 'PIPE') {
            unit_of_measure = 'FT';
          }
          else {
            unit_of_measure = 'EA';
          }
          Ext.getCmp('unit_of_measure_combo').setValue(unit_of_measure);
        }
      },
      width: 450,
      minListWidth: 450,
      store: new Ext.data.JsonStore({
        url: '/piping/piping_components',
        totalProperty: 'count',
        baseParams: {
          '_method': 'GET'
        },
        sortInfo: {
          field: 'piping_component',
          direction: 'ASC'
        },
        root: 'records',
        fields: ['piping_component', 'id'],
        autoLoad: false
      })
    },
    {
      name: 'piping_description',
      xtype: 'combo',
      width: 450,
      minListWidth: 450,
      id: 'piping_detail_description_combo',
      hiddenName: 'piping_detail_description_combo_id',
      hiddenId: 'piping_detail_description_combo_id',
      fieldLabel: 'Piping Description',
      displayField: 'size_and_desc',
      valueField: 'id',
      tpl: new Ext.XTemplate('<tpl for="."><div style="white-space:normal"; class="x-combo-list-item" >{size_and_desc:htmlEncode}</div></tpl>'),
      mode: 'local',
      listeners: {
        'select': function (combo, record, index) {
          var sNotes = Ext.getCmp('bom_window_notes').getValue();
          if (!Ext.isEmpty(record.data.valve_code)) {
            if (Ext.isEmpty(sNotes)) {
              Ext.getCmp('bom_window_notes').setValue(record.data.valve_code);
            }
            else if (!sNotes.match(record.data.valve_code)) {
              Ext.getCmp('bom_window_notes').setValue(record.data.valve_code + " -- " + sNotes);
            }
          }
          var form = Ext.getCmp('bom_item_window_window_form');
          var sDesc = record.data.description;
          Ext.getCmp('piping_detail_description').setValue(sDesc);
        }
      },
      emptyText: '--Select Class--',
      triggerAction: 'all',
      editable: true,
      validator: customBOMFieldsValidator,
      selectOnFocus: true,
      store: new Ext.data.JsonStore({
        url: '/piping/piping_class_details',
        totalProperty: 'count',
        baseParams: {
          '_method': 'GET',
          all: 'true'
        },
        sortInfo: {
          field: 'description',
          direction: 'ASC'
        },
        root: 'records',
        fields: ['size_desc', 'description', 'size_and_desc', 'valve_code', 'id'],
        autoLoad: false
      })
    },
    {
      id: 'piping_detail_description',
      name: 'description',
      xtype: 'textarea'
    },
    {
      name: 'size_1',
      xtype: 'combo',
      mode: 'local',
      id: 'size_1_combo',
      fieldLabel: 'Size 1',
      displayField: 'piping_size',
      emptyText: '--Size 1--',
      triggerAction: 'all',
      editable: true,
      selectOnFocus: true,
      width: 150,
      minListWidth: 150,
      store: telaeris.stores.sizes
    },
    {
      name: 'size_2',
      xtype: 'combo',
      mode: 'local',
      id: 'size_2_combo',
      fieldLabel: 'Size 2',
      displayField: 'piping_size',
      emptyText: '--Size 2--',
      triggerAction: 'all',
      editable: true,
      selectOnFocus: true,
      width: 150,
      minListWidth: 150,
      store: telaeris.stores.sizes
    },
    {
      name: 'unit_of_measure',
      xtype: 'combo',
      mode: 'local',
      id: 'unit_of_measure_combo',
      fieldLabel: 'Unit of Measure',
      valueField: 'name',
      displayField: 'combined',
      emptyText: '',
      triggerAction: 'all',
      editable: false,
      selectOnFocus: true,
      width: 150,
      minListWidth: 150,
      store: telaeris.stores.units_for_measure
    },
    {
      id: 'bom_window_notes',
      name: 'notes',
      width: 300,
      xtype: 'textarea'
    },
    {
      name: 'bom_quantity',
      xtype: 'numberfield',
      allowBlank: false,
      id: 'bom_quantity',
      width: 50,
      fieldLabel: 'Quantity',
      value: '1'
    }]
  }
});

// Shows the resource for modifying all piping_references.
telaeris.resources({
  'piping_references': {
    //dependentStores: ['piping_references'],
    gridConfig: {
      autoExpandColumn: 'description',
      sortInfo: {
        field: 'description',
        direction: "ASC"
      },
      listeners: {
        //Right Click menu
        'rowcontextmenu': function (grid, rowIndex, ajaxEvent) {
          var menuItems = [];
          var record = grid.getStore().getAt(rowIndex);

          // If custom_link is specified, show the menu for
          // opening it in a new window.
          if (record.data.custom_link !== '') {
            menuItems.push({
              text: 'Open Link',
              handler: function () {
                window.open(record.data.custom_link);
              },
              iconCls: 'icon-arrow-in'
            });
          }
          // Else if file_link is specified, open that.
          else if (record.data.file_link !== '') {
            menuItems.push({
              text: 'Download File',
              handler: function () {
                window.open(record.data.file_link);
              },
              iconCls: 'icon-arrow-in'
            });
          }
          menuItems.push({
            text: 'Delete Record',
            handler: telaeris.util.deleteHandler.createCallback(grid, rowIndex),
            iconCls: 'icon-cross'
          });
          var menu = new Ext.menu.Menu({
            allowOtherMenus: false,
            items: menuItems
          });
          ajaxEvent.stopEvent();
          menu.showAt(ajaxEvent.getXY());
        }
      }
    },
    gridFields: [{
      id: 'description',
      width: 100,
      sortable: true
    },
    {
      id: 'reference_type',
      header: 'Type',
      width: 100,
      sortable: true
    },
    {
      id: 'reference',
      width: 100,
      sortable: false
    },
    {
      id: 'attachings_count',
      width: 100,
      sortable: true
    },
    {
      id: 'created_at',
      width: 100,
      sortable: true
    },
    {
      id: 'updated_at',
      width: 100,
      sortable: true
    }],
    formConfig: {
      fileUpload: true,
      showUserNotes: false
    },
    formFields: [{
      xtype: 'panel',
      border: false,
      layout: 'form',
      defaults: {
        width: 400
      },
      items: [{
        fieldLabel: 'Description',
        name: 'description',
        xtype: 'textfield',
        id: 'piping_reference_description'
      },
      {
        fieldLabel: 'Custom Link (URL)',
        name: 'custom_link',
        xtype: 'textfield'
      },
      {
        xtype: 'box',
        autoEl: {
          tag: 'label',
          cls: 'x-form-item-label',
          html: '&nbsp;&nbsp;&nbsp;&nbsp;-- OR --'
        }
      },
      {
        fieldLabel: 'File to Upload',
        id: 'piping_reference_fields_data',
        name: 'data',
        xtype: 'textfield',
        inputType: 'file',
        hideMode: 'display',
        hideParent: true,
        style: 'width: 100px;'
      },
      {
        fieldLabel: 'Filename (auto-filled)',
        name: 'filename',
        xtype: 'textfield',
        disabled: true
      },
      {
        fieldLabel: 'File Link (auto-filled)',
        name: 'file_link',
        xtype: 'textfield',
        disabled: true
      },
      {
        fieldLabel: 'Show Reference in Navigation Panel',
        xtype: 'checkbox',
        name: 'show_public_link'
        //,disabled: !currentUser.admin
      },
      {
        xtype: 'notesview',
        name: 'piping_reference_attachings',
        //                        id: pcd_name + '_piping_notes_data',
        tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th style="width: 70px;">Model</th><th>Description</th></tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{model:htmlEncode}</td>', '<td class="detail_note">{description:htmlEncode}</td></tr>', '</tpl>', '</table>'),
        fieldLabel: 'Attached To',
        width: 300,
        store: new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['model', 'description'],
          data: []
        })
      }]
    }]
  }
});


telaeris.windows({
  'references': {
    //dependentStores: ['piping_references'],
    title: "Add Reference",
    url: '/piping_references',
    baseParams: {
      '_method': 'POST'
    },
    windowFormButtons: false,
    formConfig: {
      bodyStyle: 'padding: 0px;',
      anchor: '100%',
      defaults: {},
      fileUpload: true,
      autoHeight: true
    },
    formFields: [{
      // "Attach To" Fieldset
      xtype: 'fieldset',
      title: 'Attach To:',
      autoHeight: true,
      style: 'margin: 10px;',
      items: [{
        fieldLabel: 'Type',
        name: 'attachable_type_field',
        xtype: 'textfield',
        disabled: true
      },
      {
        fieldLabel: 'ID',
        name: 'attachable_id_field',
        xtype: 'textfield',
        disabled: true
      },
      {
        name: 'attachable_type',
        xtype: 'hidden'
      },
      {
        name: 'attachable_id',
        xtype: 'hidden'
      }]
    },
    {
      // Tabpanel
      title: 'Choose Reference',
      xtype: 'tabpanel',
      plain: true,
      id: 'references_form',
      activeItem: 0,
      border: false,
      autoHeight: true,
      items: [{
        // First Tab
        title: 'Select Reference',
        id: 'references_select_form',
        xtype: 'panel',
        layout: 'form',
        border: false,
        bodyStyle: 'padding: 10px;',
        buttonAlign: 'center',
        autoHeight: true,
        defaults: {
          anchor: '90%'
        },
        items: [{
          fieldLabel: 'Reference',
          xtype: 'combo',
          name: 'piping_reference',
          hiddenName: 'piping_reference_id',
          mode: 'local',
          triggerAction: 'all',
          editable: false,
          selectOnFocus: true,
          displayField: 'description',
          msgTarget: 'under',
          valueField: 'id',
          store: telaeris.stores.piping_references
        },
        {
          name: 'resource',
          xtype: 'hidden'
        }],
        buttons: [{
          // Handles submitting the Reference attaching.
          text: 'Add Reference',
          handler: function () {
            var form = Ext.getCmp('references_window_form');

            // If the attachable fields are filled in,
            // cancel the submission and warn the user.
            var values = form.getForm().getValues();
            if (values.attachable_type === '' || values.attachable_id === '') {
              telaeris.util.message("Error: ");
              return;
            }

            var submitOpt = {
              waitMsg: 'Saving data ...',
              method: 'POST',
              url: '/piping_reference_attachings'
            };

            // Success handler
            submitOpt.success = function (basicForm, action) {
              telaeris.util.message("Reference Succesfully Attached!");
              telaeris.windows.references.hide();
            };

            // Failure handler
            submitOpt.failure = function (basicForm, action) {
              telaeris.util.message("Reference Attachment Failed");
            };
            // Submit the form.
            form.getForm().submit(submitOpt);
          }
        },
        {
          text: 'Cancel',
          handler: function () {
            telaeris.windows.references.hide();
          }
        }

        ]
      },
      {
        // Second Tab
        title: 'Create Reference',
        id: 'references_create_form',
        xtype: 'panel',
        layout: 'form',
        border: false,
        bodyStyle: 'padding: 10px;',
        buttonAlign: 'center',
        autoHeight: true,
        defaults: {
          anchor: '90%',
          msgTarget: 'under'
        },
        items: [{
          fieldLabel: 'Description',
          name: 'description',
          xtype: 'textfield',
          width: 300
        },
        {
          fieldLabel: 'Custom Link (URL)',
          name: 'custom_link',
          xtype: 'textfield',
          width: 300
        },
        {
          xtype: 'box',
          autoEl: {
            tag: 'label',
            cls: 'x-form-item-label',
            html: '&nbsp;&nbsp;&nbsp;&nbsp;-- OR --'
          }
        },
        {
          fieldLabel: 'File to Upload',
          name: 'data',
          xtype: 'textfield',
          inputType: 'file',
          hideMode: 'display',
          hideParent: true,
          style: 'width: 100px;',
          width: 300
        }],
        buttons: [{
          // Handles creating and attaching a new Reference
          text: 'Create and Attach',
          handler: function () {
            var form = Ext.getCmp('references_window_form');

            // If the attachable fields are filled in,
            // cancel the submission and warn the user.
            var values = form.getForm().getValues();
            if (values.attachable_type === '' || values.attachable_id === '') {
              telaeris.util.message("Error: Please close this window and try again.");
              return;
            }

            var submitOpt = {
              waitMsg: 'Saving data ...',
              method: 'POST',
              url: '/piping_reference_attachings/create_with_piping_reference'
            };

            // Success handler
            submitOpt.success = function (basicForm, action) {
              telaeris.util.message("Reference Succesfully Attached!");
              telaeris.windows.references.hide();
            };
            // Failure handler
            submitOpt.failure = function (basicForm, action) {
              telaeris.util.message("Reference Attachment Failed");
            };
            // Form submission
            form.getForm().submit(submitOpt);
          }
        },
        {
          text: 'Cancel',
          handler: function () {
            telaeris.windows.references.hide();
          }
        }

        ]
      }]
    }],
    listeners: {
      // Resets the form when hidden.
      'hide': function () {
        Ext.getCmp('references_window_form').getForm().reset();
      }
    }
  }
});

// Takes a String for the Rails Classname of the attachable class,
// and a number/String for the id of the record to attach to.
// Shows the window and loads the data into the fields.

function showReferencesWindow(attachable_type, attachable_id) {
  if (attachable_type === '' || attachable_id === '') {
    Ext.Msg.alert("Error", "Please select a record first.");
    return;
  }
  telaeris.windows.references.show();
  var form = Ext.getCmp('references_window_form');
  form.getForm().setValues({
    attachable_type: attachable_type,
    attachable_type_field: attachable_type,
    attachable_id: attachable_id,
    attachable_id_field: attachable_id
  });
}


var valveComparisonPanelConfig = function (panelId) {
  return {
    xtype: 'form',
    id: panelId,
    border: false,
    bodyStyle: 'padding: 10px;',
    columnWidth: 0.5,
    defaults: {
      // These are then the defaults for the fieldsets
      anchor: '-5',
      //And these are the defaults for the items in the fieldsets
      defaults: {
        anchor: '-5'
      }
    },
    items: [{
      id: panelId + '_combo',
      xtype: 'combo',
      disableKeyFilter: true,
      displayField: 'valve_code',
      valueField: 'id',
      editable: true,
      enableKeyEvents: true,
      fieldLabel: 'Valve',
      mode: 'local',
      name: 'valve_id',
      readOnly: false,
      selectOnFocus: true,
      store: telaeris.stores.valves,
      triggerAction: 'all',
      listeners: {
        'select': function (combo, record, index) {
          var this_combo = combo;
          Ext.getCmp(panelId).getEl().mask('Loading ' + record.data.valve_code);
          //record doesn't contain the valve components at the moment.
          //make an ajax call whose success populates the valve_component_names field immediately following this.
          //This its the valve components notesview item.  =>
          Ext.Ajax.request({
            method: 'GET',
            url: '/sext/valves/' + record.data.id,
            failure: function () {
              this_combo.ownerCt.getEl().unmask();
            },
            success: function (response) {
              //also call editRecordFromURL to reload the edited item.
              //telaeris.editRecordFromURL('boms', '/boms/' + record.data.id);
              var json_response = Ext.util.JSON.decode(response.responseText);
              var form = Ext.getCmp(panelId);
              form.getForm().setValues(json_response.data);
            }
          });

          var table;
          var store;

          table = this_combo.ownerCt.find('name', 'valve_component_names');
          table = table[0];
          store = table.store;
          store.removeAll();
          store.load({
            params: {
              id: record.data.id
            }
          });
          table.getEl().up('.x-form-item').setDisplayed(true);

          table = this_combo.ownerCt.find('name', 'manufacturers_valves');
          table = table[0];
          store = table.store;
          store.removeAll();
          store.load({
            params: {
              id: record.data.id
            }
          });
          table.getEl().up('.x-form-item').setDisplayed(true);
        }
      }
    },
    {
      fieldLabel: 'Type',
      xtype: 'textfield',
      name: 'valve_type',
      readonly: true
    },
    {
      fieldLabel: 'Rating',
      xtype: 'textfield',
      name: 'valve_rating',
      readonly: true
    },
    {
      fieldLabel: 'Body',
      xtype: 'textfield',
      name: 'valve_body',
      readonly: true
    },
    {
      fieldLabel: 'Valve Components',
      xtype: 'notesview',
      name: 'valve_component_names',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tpl for="."><tpl if="xindex &lt;= 1"><tr><th>Component</th><th>Component Text</th><th><button onclick="openValve(\'{valve_code}\');" type="button">Valve Detail</button></th>', '</tr></tpl><tr>', '<td   class="detail_note">{component_name:htmlEncode}</td>', '<td class="component_text" colspan=2>{component_text:htmlEncode}</td>', '</tr>', '</tpl>', '</table>'),
      width: 550,
      useInternalStore: true,
      store: new Ext.data.JsonStore({
        totalProperty: 'count',
        root: 'records',
        fields: ['component_name', 'component_text', 'valve_id', 'valve_component_id', 'valve_code', 'valves_valve_component_id'],
        url: '/valves/related_valve_components',
        method: 'GET',
        autoLoad: false,
        listeners: {
          'load': function () {
            Ext.getCmp(panelId).getEl().unmask();
          }
        }
      })
    },
    {
      fieldLabel: 'Notes',
      xtype: 'textarea',
      name: 'valve_notes',
      readonly: true
    },
    {
      fieldLabel: 'Manufacturers',
      hideLabel: false,
      xtype: 'notesview',
      name: 'manufacturers_valves',
      tpl: new Ext.XTemplate('<table class="popv-notes">', '<tr><th>Manufacturer</th><th>Figure No</th></tr>', '<tpl for=".">', '<tr>', '<td class="detail_note">{name:htmlEncode}</td>', '<td class="detail_note">{figure_no:htmlEncode}</td></tr>', '</tpl>', '</table>'),
      width: 550,
      hidden: false,
      useInternalStore: true,
      store: new Ext.data.JsonStore({
        totalProperty: 'count',
        root: 'records',
        fields: ['name', 'figure_no', 'valve_id', 'manufacturer_id', 'manufacturers_valves_id'],
        url: '/valves/related_manufacturers',
        method: 'GET',
        autoLoad: false
      })
    }]
  };
};
/******************************************************************************
 Valve Comparison Resource
 ******************************************************************************/
//Creates the Valve Comparison Panels
telaeris.resources({
  valve_comparison: {
    //dependentStores: ['valves'],
    title: 'Valve Comparison',


    //Add a panel with a button and the valve_comparison panel in it
    //Standard layout should be fine
    panel: {
      xtype: 'panel',
      region: 'center',
      autoScroll: true,
      items: [{
        xtype: 'panel',
        id: 'valve_comparison',
        layout: 'column',
        //region: 'center',
        border: false,
        autoScroll: true,
        items: [valveComparisonPanelConfig('valve_comparison_1'), valveComparisonPanelConfig('valve_comparison_2')]
      },
      {
        text: 'Download Valves as PDF',
        xtype: 'button',
        style: 'padding: 10px; margin-left: auto; margin-right: auto;',
        handler: function () {
          var valve1 = Ext.getCmp('valve_comparison_1_combo');
          var valve2 = Ext.getCmp('valve_comparison_2_combo');

          if (valve1.getValue() == "") {
            telaeris.util.message("Valve 1 is not selected", 5000);
            return;
          }
          if (valve2.getValue() == "") {
            telaeris.util.message("Valve 2 is not selected", 5000);
            return;
          }
          telaeris.openReportsWindow({
            url: '/valves/comparison_pdf?valve_1_id=' + valve1.getValue() + '&valve_2_id=' + valve2.getValue(),
            report_class: 'PipingClassReport',
            report_method: 'valve_comparison_pdf',
            report_options: {
              valve_1_id: valve1.getValue(),
              valve_2_id: valve2.getValue()
            }
          });
        }
      }]
    }
  }
});

/******************************************************************************
 PDF Emailing Window
 ******************************************************************************/
telaeris.windows({
  'reports': {
    title: "Get Report",
    url: '/email_piping_references',
    baseParams: {
      '_method': 'POST'
    },
    windowFormButtons: false,
    formConfig: {
      bodyStyle: 'padding: 0px;',
      anchor: '100%',
      defaults: {},
      autoHeight: true
    },
    windowConfig: {
      width: 400,
      shadow: false
    },
    formFields: [{
      // Tabpanel
      title: 'Choose Reference',
      xtype: 'tabpanel',
      plain: true,
      id: 'reports_tab_panel',
      activeItem: 0,
      border: false,
      autoHeight: true,
      items: [{
        // First Tab
        title: 'Download Now',
        id: 'reports_download_now_panel',
        xtype: 'panel',
        layout: 'form',
        border: false,
        bodyStyle: 'padding: 10px;',
        buttonAlign: 'center',
        autoHeight: true,
        defaults: {
          anchor: '90%'
        },
        items: [{
          text: 'Download PDF',
          xtype: 'button',
          style: 'padding: 10px; margin-left: auto; margin-right: auto;',
          handler: function () {
            var form = Ext.getCmp('reports_window_form');
            var urlField = form.findById('reports_window_form_report_url');
            var url = urlField.getValue();
            telaeris.openURL(url);
            telaeris.windows.reports.hide();
          }
        },
        {
          id: 'reports_window_form_report_url',
          name: 'report[url]',
          xtype: 'hidden'
        }]
      },
      {
        // Second Tab
        title: 'Email PDF',
        xtype: 'panel',
        layout: 'form',
        border: false,
        bodyStyle: 'padding: 10px;',
        buttonAlign: 'center',
        autoHeight: true,
        labelWidth: 100,
        defaults: {
          anchor: '-5px',
          msgTarget: 'under'
        },
        items: [{
          fieldLabel: 'From',
          name: 'email[from]',
          id: 'reports_window_form_email_from',
          xtype: 'textfield',
          readOnly: true,
          value: currentUser.email
        },
        {
          fieldLabel: 'To',
          name: 'email[to]',
          xtype: 'textfield',
          vtype: 'email'
        },
        {
          fieldLabel: 'Subject',
          name: 'email[subject]',
          xtype: 'textfield',
          allowBlank: false
        },
        {
          fieldLabel: 'Message',
          name: 'email[body]',
          xtype: 'textarea',
          height: 200,
          allowBlank: false
        },
        {
          id: 'reports_window_form_report_id',
          name: 'report[id]',
          xtype: 'hidden'
        },
        {
          id: 'reports_window_form_report_options',
          name: 'report[options]',
          xtype: 'hidden'
        },
        {
          id: 'reports_window_form_report_class',
          name: 'report[class]',
          xtype: 'hidden'
        },
        {
          id: 'reports_window_form_report_method',
          name: 'report[method]',
          xtype: 'hidden'
        }],
        buttons: [{
          // Handles creating and attaching a new Reference
          text: 'Send Email with PDF',
          handler: function () {
            var form = Ext.getCmp('reports_window_form');

            //                                    // If the attachable fields are filled in,
            //                                    // cancel the submission and warn the user.
            //                                    var values = form.getForm().getValues();
            //                                    if (values.attachable_type == '' || values.attachable_id == '') {
            //                                        telaeris.util.message("Error: Please close this window and try again.");
            //                                        return;
            //                                    }
            var submitOpt = {
              waitMsg: 'Saving data ...',
              method: 'POST',
              url: '/reports/email',
              success: function (form, action) {
                var result = action.result;
                telaeris.windows.reports.hide();
                telaeris.util.message("Report successfully emailed.");
              },
              failure: function (form, action) {
                var result = action.result;
                telaeris.util.message("There was an error: " + result.message);
              }
            };
            form.getForm().submit(submitOpt);
          }
        },
        {
          text: 'Cancel',
          handler: function () {
            telaeris.windows.reports.hide();
          }
        }]
      }]
    }],
    listeners: {
      // Resets the form when hidden.
      'show': function () {
        Ext.getCmp('reports_tab_panel').setActiveTab('reports_download_now_panel');
      },
      // Resets the form when hidden.
      'hide': function () {
        Ext.getCmp('reports_window_form').getForm().reset();
      }
    }
  }
});

/******************************************************************************
 Model Loggings Resource
 ******************************************************************************/
//Creates the Piping Notes Grid/Form
telaeris.resources({
  record_changelogs: {
    title: 'Revision History',
    formFields: [{
      xtype: 'hidden',
      name: 'id'
    }, 'record_type', 'record_identifier', 'action',
    {
      xtype: 'textarea',
      fieldName: 'Comment',
      name: 'comment'
    }, 'field_name', 'old_value', 'new_value',
    {
      xtype: 'textfield',
      fieldName: 'Modified By',
      name: 'modified_by',
      disabled: true
    },
    {
      xtype: 'textfield',
      fieldName: 'Modified At',
      name: 'modified_at',
      disabled: true
    },
    {

      xtype:'displayfield',
      name: 'attachment_url'


    },'record_id'],
    formConfig: {
      additionalButtons: [{
        xtype: 'button',
        text: 'CSV',
        iconCls: 'icon-page-excel',
        handler: function () {
          window.open('/record_changelogs/csv_export/' + Ext.getCmp('record_changelogs_form').getForm().getValues(false).id);
        }
      }]
    },
    gridConfig: {
      additionalButtons: [
      {xtype:'tbspacer'},
      {xtype:'tbspacer'},
      {xtype:'tbseparator'},
      {xtype:'tbspacer'},
      {
        xtype:'tbtext',
        text:'Piping Class Filter'
      },{
        xtype:'combo',
        name:'table_select',
        displayField:'class_code',
        valueField:'id',

        mode: 'local',
        triggerAction: 'all',
        editable: true,
        selectOnFocus: true,
        store:telaeris.stores.classes_only_incl_archived,

        listeners:{
          'select':function(combo,record,index){
            Ext.getCmp('record_changelogs_grid').store.searchEnabled = true;
            //add the piping_class_id to the filter for the grid
            Ext.getCmp('record_changelogs_grid').store.load({
              'params':{
              'piping_class_explicit':true,
              'record_identifier': record.data.class_code,
              'action':'',
              'filter': 'true'
              }
            });
          }
        }

      }],

      autoExpandColumn: 'comment',
      cellDoubleClick: function (grid, rowIndex, columnIndex, event) {
        //                var record = grid.getStore().getAt(rowIndex);
        //                if (grid.colModel.config[columnIndex]['id'] == 'valve') {
        //                    openValve(record.data['valve']);
        //                }
        //                else if (grid.colModel.config[columnIndex]['id'] == 'piping_notes') {
        //                    showPipingNotesWindow(record.data['piping_notes_data']);
        //                }
      },
      sortInfo: {
        field: 'modified_at',
        direction: "DESC"
      },
      noAddButton: true,
      viewConfig: {
        autoFill: true,
        forceFit: false
      },
      //                listeners: {
      //                //Right Click menu
      //                'rowdblclick': function(grid, rowIndex, ajaxEvent) {
      //                    // Don't show anything only for popv_viewers
      //                    if (currentUser.admin) {
      //                        var record = grid.getStore().getAt(rowIndex);
      //                        telaeris.addCommentToChangelog(record.data.id);
      //                    }
      //                }
      //            },
      //            additionalButtons: [
      //                {
      //                    xtype: 'tbbutton',
      //                    text: 'Change Comment',
      //                    iconCls: 'icon-note-add',
      //                    hidden: !currentUser.admin,
      //                    handler: function() {
      //                        var grid = Ext.getCmp('record_changelogs_grid');
      //                        var selectedRow = grid.getSelectionModel().getSelected();
      //                        var id = selectedRow.data.id;
      //                        telaeris.addCommentToChangelog(id);
      //                    }
      //                }
      //            ],
      helpText: '<h1>Edit Log</h1>' + '<p>The Edit Log tracks all changes to the following resources: <br/>* Piping Classes<br/>* Piping Class Details<br/>* Piping Components<br/>* Valves<br/>* Valve Components<br/><br/>It tracks record creations, updates, and deletions. For updates, it creates a new Log entry for each field value that has changed.</p>' + '<p><label>Add Comments:</label> Admins can add comments to any changes they make. Simply modify the records you want, and then come to the Edit Log to see the changes recorded. Then click on a row and press the "Change Comment" button at the top of the grid. It will prompt you for a Comment and add it to the Edit Log record for others to see. Additionally, you can double click on an Edit Log record to add a comment.</p>' + '<p><label>BEWARE!</label> Changing the comment for a record WILL overwrite the old one!</p>'
    },
    gridFields: [{
      id: 'action',
      width: 80
    },
    {
      id: 'record_type',
      width: 120
    },
    {
      id: 'record_identifier',
      width: 300
    },
    {
      id: 'comment',
      renderer: Ext.util.Format.nl2br
    },
    {
      id: 'modified_at',
      width: 100
    }]
  }
});


/******************************************************************************
 Search/Replace Resources
 The goal here is for the user to select any given resource and search/replace
 on any field.
 1) Select a table you're doing searches on
 2) Search on any field/set of fields
 3) View the results/selected records
 4)

 We need:
 Search Table
 Search Fields (regex enabled?)
(RESULT TABLE) (SEARCH BUTTON)
 Search/Replace FIELD
(PREVIEW OF CHANGES)
 Actually implement changes

 ******************************************************************************/
//
var bulk_changes_field_store = new Ext.data.JsonStore({
              totalProperty: 'count',
              root: 'records',
              fields: ['field_name', 'field'],
              url: '/bulk_changes/fields',
              baseParams: {
                '_method':'POST',
                table:''
              },
              method: 'POST',
              autoLoad: false
            });

telaeris.resources({
  bulk_changes: {
    title: 'Bulk Search/Replace',

    panel:{
      style:'margin:5px;',
      id:'bulk_changes_panel',
      xtype: 'form',
      region: 'center',
      autoScroll: true,
      items: [
        {
          xtype:'label',
          style:'font-size:140%;',
          text:'Step 1) Select a Table'
        },
      {
        hideLabel:true,
        xtype:'combo',
        id:'bulk_search_table_select_combo',
        name:'table_select',
        displayField:'table_name',
        valueField:'table',
        fieldLabel: 'Table Name',
        allowBlank: false,
        mode: 'local',
        triggerAction: 'all',
        editable: false,
        selectOnFocus: true,
        store:new Ext.data.JsonStore({
          totalProperty: 'count',
          root: 'records',
          baseParams:{
            '_method': 'POST',
            method:'POST'
          },
          fields: ['table_name', 'table'],
          url: '/bulk_changes/tables',
          method: 'POST',
          autoLoad: true
        })
        ,listeners:{
          'select':function(combo,record,index){
            Ext.getCmp('add_search_criteria_panel').show();
            Ext.getCmp('step_2').show();
            clearBulkSearchCriteria();


            Ext.apply(bulk_changes_field_store.baseParams,{'table':record.data.table});


            bulk_changes_field_store.on('load', function () {
             var fields = [];
             var columns = [];
              bulk_changes_field_store.each(function(record){
                fields.push(record.data.field);
                var column = {
                id: record.data.field
              };
              Ext.applyIf(column, {
                header: record.data.field_name,
                sortable: false,
                dataIndex: column.id
              });
              columns.push(column);

              });

            //Destroy the grids if they exist
            if(Ext.getCmp('search_grid')){
               Ext.getCmp('search_grid').destroy();
            }
            if(Ext.getCmp('search_grid_label')){
               Ext.getCmp('search_grid_label').destroy();
            }

            if(Ext.getCmp('replace_grid')){
               Ext.getCmp('replace_grid').destroy();
            }



            var search_grid = new Ext.grid.GridPanel({
              hidden:false,
              hideLabel:true,
              xtype:'grid',
              id: 'search_grid',
              stripeRows: true,
              autoWidth:true,
              fieldLabel:'Search Results',
              store:new Ext.data.JsonStore({
                totalProperty: 'count',
                root: 'records',
                url:'/bulk_changes/search_results/',
                fields: fields,
                autoLoad: false,
                baseParams:{
                  search_criteria:'',
                  table:''
                },
                listeners:{'load':function(this_store, records){
                  Ext.getCmp('search_grid_label').setText(records.length + ' records match search criteria.');
                  Ext.getCmp('search_grid_label').show();
                  if(records.length > 0){
                    //Show the replace panel
                      Ext.getCmp('replace_criteria_panel').show();
                    }
                    else
                    {
                      Ext.getCmp('replace_criteria_panel').hide();
                  }
                }}

              }),
              //frame: true,
              columns: columns,
              height: 250,
              //width:'auto',
              autoScroll: false,
              loadMask: true,
              deferRowRender: false,
              cellDoubleClick: false
            });
            var search_grid_label = new Ext.form.Label(
              {
                hidden:false,
                id:'search_grid_label',
                text:''
              }
            );

            var replace_grid = new Ext.grid.GridPanel({
              hidden:false,
              hideLabel:true,
              xtype:'grid',
              id: 'replace_grid',
              stripeRows: true,
              fieldLabel:'Replace Results',
              store:new Ext.data.JsonStore({
                totalProperty: 'count',
                root: 'records',
                url:'/bulk_changes/replace_results/',
                fields: fields,
                autoLoad: false,
                baseParams:{
                search_criteria:'',
                table:'',
                replace_field:'',
                replace_search:'',
                replace_new_value:''
                },
                listeners:{'load':function(this_store, records){
                  Ext.getCmp('replace_grid_label').setText(records.length + ' records match search AND replace criteria.');
                  Ext.getCmp('replace_grid_label').show();
                  if(records.length > 0){
                    //Show the replace panel
                      Ext.getCmp('finalize_replace_button').show();
                      Ext.getCmp('finalize_replace_button_label').show();

                    }
                    else
                    {
                      Ext.getCmp('finalize_replace_button').hide();
                      Ext.getCmp('finalize_replace_button_label').hide();
                  }
                  Ext.getCmp('bulk_changes_panel').doLayout();
                }}

              }),
              //frame: true,
              columns: columns,
              height: 300,
              //width:500,
              autoScroll: false,
              loadMask: true,
              deferRowRender: false,
              cellDoubleClick: false
            });
            var replace_grid_label = new Ext.form.Label(
              {
                hidden:false,
                id:'replace_grid_label',
                text:''
              }
            );
            var p = Ext.getCmp('bulk_changes_panel');
            p.insert(8,search_grid);
            p.insert(9,search_grid_label);
            p.insert(12,replace_grid);
            p.insert(13,replace_grid_label);


            Ext.getCmp('bulk_changes_panel').doLayout();

            }, bulk_changes_field_store, {
              single: true
            }
            // Bind this only once to the store.
          );
            bulk_changes_field_store.load();


          }
         }
       },
       {
         id:'step_2',
         hidden:false,
          xtype:'label',
          style:'font-size:140%;',
          text:'Step 2) Add Search Criteria'
        },
      {
        hidden:false,
        hideLabel:true,
        id:'add_search_criteria_panel',
        xtype:'panel',
        layout:'column',
        border:false,
        items:[

          {
            xtype:'combo',
            id:'add_search_criteria_combo',
            name:'field_select_combo',
            displayField:'field_name',
            valueField:'field',
            hideLabel:true,
            allowBlank: false,
            mode: 'local',
            width:200,
            triggerAction: 'all',
            editable: false,
            selectOnFocus: true,


            store:bulk_changes_field_store,
            listeners:{
              'select':function(combo,record, index){
                var combo =  Ext.getCmp("search_field_value_combo");
                if(record.data.field == "piping_component_id") {
                  copy_combo_data(telaeris.stores.piping_components, "piping_component", "id",combo.store);
                  combo.show();
                  //Hide the text box
                  Ext.getCmp('search_field_value').hide();
                }
                else if(record.data.field == "piping_class_id") {
                  copy_combo_data(telaeris.stores.classes_only_incl_archived, "class_code", "id",combo.store);
                  combo.show();
                  //Hide the text box
                  Ext.getCmp('search_field_value').hide();
                }
                else if(record.data.field == "valve_id") {
                  copy_combo_data(telaeris.stores.valves, "valve_code", "id",combo.store);
                  combo.show();
                  //Hide the text box
                  Ext.getCmp('search_field_value').hide();
                }
                else{
                  combo.hide();
                  Ext.getCmp('search_field_value').show();
                }
              }
            }
          },
          {
            xtype:'combo',
            id:'search_criteria_compare_type',
            displayField:'type',
            valueField:'type',
            hideLabel:true,
            allowBlank: false,
            mode: 'local',
            width:50,
            triggerAction: 'all',
            editable: false,
            selectOnFocus: true,
            value:'=',
            store:new Ext.data.JsonStore({
              fields: ['type'],
              data: [{
                'type': '='
              },
              {
                'type': 'LIKE'
              }],
              method: 'GET',
              autoLoad: false
            })
          },

          {
            xtype:'field',
            id:'search_field_value',
            name:'search_field_value',
            hideLabel:true,
            listeners: {
              'keypress':function(){

                Ext.getCmp('search_field_value_combo').setValue('');
                Ext.getCmp('search_field_value_combo').store.loadData([], false);
              },
              'specialkey': function (f, e) {
                if (e.getKey() == e.ENTER) {
                  e.preventDefault();
                  addSearchCriteria();
                }
              }
            }
          },
          {
            xtype:'combo',
            id:'search_field_value_combo',
            displayField:'name',
            valueField:'value_id',
            hideLabel:true,
            allowBlank: false,
            mode: 'local',
            width:150,
            triggerAction: 'all',
            editable: false,
            hidden:true,
            selectOnFocus: true,
            store:new Ext.data.JsonStore({
              fields: ['name','value_id'],
              data: [],
              method: 'GET',
              autoLoad: false
            }),
            listeners:{
              'select':function(){
                Ext.getCmp('search_field_value').setValue('');
                addSearchCriteria();
              }

            }
          },
          {
            xtype:'button',
            iconCls: 'icon-plus',
            id:'add_bulk_criteria_field',
            text:'Add Search Criteria',
            handler:function(){addSearchCriteria();}
          }

        ]
      },
      {  hidden:true,
        id:'step_3',
          xtype:'label',
          style:'font-size:140%;',
          text:'Step 3) Search And Review Records'
        },
      {
        hidden:true,
        hideLabel:true,
        xtype: 'listview',
        name: 'actual_search_criteria',
        border:true,
        width:400,
        id:'actual_search_criteria_view',
        xtype: 'listview',
        height:75,
        autoHeight:false,
        mode: 'local',

        multiSelect:false,
        triggerAction: 'all',
        columnSort:false,
        columns:[
          {dataIndex:"field_name", header:'Field',width:.3},
          {dataIndex:"compare_type", header:'Compare',width:.1},

          {dataIndex:"search_value", header:'Value',width:.65}
        ],
        //displayField: 'note_text',
        //valueField: 'id',

        store: new Ext.data.JsonStore({
          data:[],
          fields: ['field_name','compare_type', 'search_value'],
          autoLoad: false
        }),
        listeners:{'dblclick' : function( listview,  index, html_node, e ){
          listview.store.removeAt(index);
          searchCriteriaData();
        }}


        //,        tpl: new Ext.XTemplate(piping_notes_wingow_tpl)

      },

      {
        hidden:true,
        hideLabel:true,
            xtype:'button',
            id:'clear_search_criteria',
            iconCls: 'icon-cancel2',
            text:'Clear Search Criteria',
            handler:function(){clearBulkSearchCriteria();}
      },

    {
        hideLabel:true,
        id:'replace_criteria_panel',
        xtype:'panel',
        layout:'form',
        border:false,
        hidden:true,
        items:[
        {
          xtype:'label',
          style:'font-size:140%;',
          text:'Step 4) Enter Text to Find/Replace'
        },

          {
            xtype:'combo',
            id:'replace_criteria_combo',
            name:'field_select_combo_2',
            displayField:'field_name',
            valueField:'field',
            hideLabel:false,
            fieldLabel:'Replace Column',
            allowBlank: false,
            mode: 'local',
            width:200,
            triggerAction: 'all',
            editable: false,
            selectOnFocus: true,

            store:bulk_changes_field_store
          },
        {
          xtype:'textfield',
          id:'replace_search_value',
          name:'replace_search_value',
          hideLabel:false,
          fieldLabel:'Replace Search Value'
        },
        {
          xtype:'textfield',
          id:'replace_new_value',
          name:'replace_new_value',
          fieldLabel:'Replace New Value'
        },
        {
          xtype:'button',
          iconCls: 'icon-magnifier',
          text:'Test Replace',
          handler:function(){
            replaceSearchHandler();
            //fill the replace grid parameters appropriately
            //
          }
        }
        //Replace Field(from combo)
        //Replace Search Value
        //Replace New Value
        //Button to Test Replace(and thus show replace_grid and Finalize Replacement Button)

        //we also want to lock down previous steps after we do the replace tests.  don't
        //allow any changes to search criteria at this point.
          ]},
        {
            xtype:'button',
            iconCls: 'icon-magnifier',
            text:'Search Data',
            handler:function(){searchCriteriaData();}
      },
      {
         hidden:true,
         id:'finalize_replace_button_label',
          xtype:'label',
          style:'font-size:140%;',
          text:'Step 5) Finalize and Commit your Changes'
        }
      ,{
          hidden:true,
          xtype:'button',
          id:'finalize_replace_button',
          iconCls: 'icon-magnifier',
          text:'Finalize Replace',
          handler:function(){
            finalizeReplaceHandler();
            //fill the replace grid parameters appropriately
            //
          }
        }

     ]
    }

  }
});
var replaceSearchHandler = function(){
var replace_field = Ext.getCmp('replace_criteria_combo').getValue();
var replace_search_value = Ext.getCmp('replace_search_value').getValue();
var replace_new_value = Ext.getCmp('replace_new_value').getValue();

var table = Ext.getCmp('bulk_search_table_select_combo').getValue();
  var store = Ext.getCmp('replace_grid').store;
  var string_search_criteria = '';
  string_search_criteria = getSearchCriteria();
  Ext.apply(store.baseParams,
    {
      'table':table,
      'search_criteria':string_search_criteria,
      'replace_field':replace_field,
      'replace_new_value':replace_new_value,
      'replace_search_value':replace_search_value
    });
  store.load();

};
var getSearchCriteria = function(){
 var search_criteria = [];
 Ext.getCmp('actual_search_criteria_view').store.each(
   function(record){
     search_criteria.push(
       {'field_name':record.data.field_name,
         'compare_type':record.data.compare_type,
       'search_value':record.data.search_value});
   }
 );
 return Ext.util.JSON.encode(search_criteria);
};
var searchCriteriaData = function(){

          var table = Ext.getCmp('bulk_search_table_select_combo').getValue();
           var store = Ext.getCmp('search_grid').store;

           var string_search_criteria = '';
           string_search_criteria = getSearchCriteria();
          Ext.apply(store.baseParams,{'table':table, 'search_criteria':string_search_criteria});
          store.load();
          Ext.getCmp('actual_search_criteria_view').show();
          Ext.getCmp('step_3').show();
          Ext.getCmp('clear_search_criteria').show();
          Ext.getCmp('search_grid').show();
        };
var addSearchCriteria = function () {
      //add the field/value to the search criteria listview
      var field_name = Ext.getCmp('add_search_criteria_combo').getValue();
      var compare_type = Ext.getCmp('search_criteria_compare_type').getValue();
      var search_value = Ext.getCmp('search_field_value').getValue();
      var search_value_combo = Ext.getCmp('search_field_value_combo').getValue();
      if(search_value === ''){
        search_value = search_value_combo;
      }
      if(search_value === ''){
        return;
      }
      var store = Ext.getCmp('actual_search_criteria_view').store;
      var defaultData = {
            field_name: field_name,
            compare_type:compare_type,
            search_value: search_value
          };
        var recId = store.getCount(); // provide unique id
        var p = new store.recordType(defaultData, recId); // create new record

        store.insert(0, p); // insert a new record into the store (also see add)
        searchCriteriaData();
    };
    var clearBulkSearchCriteria = function(){
Ext.getCmp('actual_search_criteria_view').store.loadData([], false);
Ext.getCmp('actual_search_criteria_view').hide();
//Ext.getCmp('clear_search_criteria').hide();
};

var finalizeReplaceHandler = function(){
  var replace_field = Ext.getCmp('replace_criteria_combo').getValue();
var replace_search_value = Ext.getCmp('replace_search_value').getValue();
var replace_new_value = Ext.getCmp('replace_new_value').getValue();

var table = Ext.getCmp('bulk_search_table_select_combo').getValue();
  var baseParams = {};
  var string_search_criteria = '';
  string_search_criteria = getSearchCriteria();
  Ext.apply(baseParams,
    {
      '_method': 'POST',
      'table':table,
      'search_criteria':string_search_criteria,
      'replace_field':replace_field,
      'replace_new_value':replace_new_value,
      'replace_search_value':replace_search_value
    });
  //start retrieving the data
  Ext.Ajax.request({
      method: 'POST',
      url: '/bulk_changes/finalize_replace/',
      params: baseParams,
      success: function (response) {
        //Decode the response
        //Ext.get('valves_valve_components_window').unmask();
        var responseValue = '';
        responseValue = Ext.util.JSON.decode(response.responseText);
        if(responseValue.success == true){
          //Use the success message from the server
          telaeris.util.message(responseValue.errors);
          Ext.Msg.alert('Success', responseValue.errors);
        }
        else{
          telaeris.util.message("Error with Data Replace!" + responseValue.errors);
          Ext.Msg.alert('Alert', "Error with Data Replace!" + responseValue.errors);
        }



      },
      failure:function(response){
        telaeris.util.message("Major Error with Data Replace!");
        Ext.Msg.alert('Alert', "Major Error with Data Replace!");
      }

  });
};
var copy_combo_data = function (source_store, source_name_field, source_id_field, destination_store){
  var data = [];
  source_store.each(function(record){
    //console.log(record.data[source_name_field]);
    data.push({"name": record.data[source_name_field], "value_id":record.data[source_id_field]});
  });
  destination_store.loadData(data,false);
};
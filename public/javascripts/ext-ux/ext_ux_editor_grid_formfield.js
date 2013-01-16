Ext.ux.EditorGridFormField  = Ext.extend(Ext.grid.EditorGridPanel,{
                    doLayout: false,
                    isFormField: true,
                    stripeRows: true,
                    hideLabel: true,
                    isComposite:true,
                    field: this,
                    remoteSort: false,
                    autoWidth: true,
                    autoHeight: true,
                    selModel: new Ext.grid.RowSelectionModel({}),
                   onDestroy: function() {
                      if(this.rendered){
                          var cols = this.colModel.config;
                          for(var i = 0, len = cols.length; i < len; i++){
                              var c = cols[i];
                              //if the editor doesn't have a field, don't worry about it.
                              //if((c.editor) && (c.editor.field)){
                                Ext.destroy(c.editor);
                              //}
                          }
                      }
                      Ext.grid.EditorGridPanel.superclass.onDestroy.call(this);
                  },
                    //Need this for basicForm.load
                    clearInvalid: function(){
                    	return true;
                	},
                  markInvalid: function(){
                      return true;
                  },
                    //    Loads the View from a JSON string representing the Records to put into the Store.
                    setValue: function(val){
                        if (!this.store) {
                            throw "Must must be constructed with a valid Store";
                        }
                        if (!val) {
                        	this.store.removeAll();
                            return;
                        }
                        val = val instanceof Array ? val : val.split(',');
                        this.store.loadData(val);
                    },
                    getName: function(){
                        return this.name;
                    },
                    //    @return {String} a parenthesised list of the ids of the Records in the View.
                    getValue: function(){
                        return this.store.getRange();
                    },
                    reset: function(){
                        return this.store.removeAll();
                    },
                    validate: function(){
                        return true;
                    }
                });
Ext.reg("editorgridformfield", Ext.ux.EditorGridFormField);

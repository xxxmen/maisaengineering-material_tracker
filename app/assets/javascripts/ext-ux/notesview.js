/**
 * @author Chris Stotts
 */
Ext.ux.NotesView = function(config){
        if (!config.itemSelector) {
            config.itemSelector = ".x-combo-list-item";
        }
        if (!config.tpl) {
            /**
             * The template string, or Ext.XTemplate instance to use to display each item in the
             * dropdown list. Use this to create custom UI layouts for items in the list.
             * If you wish to preserve the default visual look of list items, add the CSS
             * class name 'x-combo-list-item' to the template's container element.
             * The template must contain one or more substitution parameters using field
             * names from the Combo's Store. An example of a custom template would be adding an
             * ext:qtip attribute which might display other fields from the Store.
             * The dropdown list is displayed in a DataView. See Ext.DataView for details.
             */
            var cls = 'x-form-text';

            config.tpl = '<tpl for="."><div class="' + cls + '-item">' +
            '{' +
            config.displayField +
            '}</div><br/></tpl>';
        }
        Ext.ux.NotesView.superclass.constructor.call(this, Ext.apply(config, this.config));
        this.addEvents(
          'afterdataload'
        );
    };
	Ext.extend(Ext.ux.NotesView, Ext.DataView, {
	/**    @cfg {String/Array} dragGroup The ddgroup name(s) for the View's DragZone. */
	/**    @cfg {String/Array} dropGroup The ddgroup name(s) for the View's DropZone. */
	/**    @cfg {Boolean} copy Causes drag operations to copy nodes rather than move. */
	/**    @cfg {Boolean} allowCopy Causes ctrl/drag operations to copy nodes rather than move. */

        // Override to 'true' if you want this NotesView's store to load its
        // own data, as opposed to passing it the records for the store.
        useInternalStore: false,
		sortDir: 'ASC',
		border: true,
	    isFormField: true,
	    classRe: /class=(['"])(.*)\1/,
	    tagRe: /(<\w*)(.*?>)/,
	    reset: Ext.emptyFn,
	    autoHeight:true,
	    clearInvalid: Ext.form.Field.prototype.clearInvalid,
	    msgTarget: 'qtip',
      itemSelector:".x-combo-list-item",
      invalid:false,
      markInvalid:function(){
        this.invalid = true;
      },
      clearInvalid:function(){
        this.invalid = false;
      },
    // private


		afterRender: function() {
			Ext.ux.NotesView.superclass.afterRender.call(this);
		    this.isDirtyFlag = false;
		},

	    validate: function() {
	        return true; 
	    },

	    destroy: function() {
	        this.purgeListeners();
	        this.getEl().removeAllListeners();
	        this.getEl().remove();
	    },

	/**    Allows this class to be an Ext.form.Field so it can be found using {@link Ext.form.BasicForm#findField}. */
	    getName: function() {
	        return this.name;
	    },

	/**    Loads the View from a JSON string representing the Records to put into the Store. */
	   setValue: function(val) {
       //alert('setting value in notesview');
	        if (!this.store) {
	            throw "NotesView.setValue(). NotesView must be constructed with a valid Store";
	        }
	        if (this.useInternalStore === true) {
	            this.getEl().up('.x-form-item').setDisplayed(true);
	            return;
	        }
	        else {
	            if (!val || val.length <= 0) {
    				    this.store.removeAll();
              	this.getEl().up('.x-form-item').setDisplayed(false);
                return;
    	        }
    	        else {
    	        	this.getEl().up('.x-form-item').setDisplayed(true);
    	        }
	        }

	        val = val instanceof Array ? val : val.split(',');
  			  this.store.loadData(val);


	    },

	/**    @return {String} a parenthesised list of the ids of the Records in the View. */
	    getValue: function() {
	        var result = '(';
	        this.store.each(function(rec) {
	            result += rec.id + ',';
	        });
	        return result.substr(0, result.length - 1) + ')';
	    },

	    getIds: function() {
	        var i = 0, result = new Array(this.store.getCount());
	        this.store.each(function(rec) {
	            result[i++] = rec.id;
	        });
	        return result;
	    },
		onRender: function(ct, position){
			var fs, cls, tpl;
			Ext.ux.NotesView.superclass.onRender.call(this, ct, position);
		},
		refresh: function(){
			Ext.ux.NotesView.superclass.refresh.call(this);
		},
		reset: function () {
			this.setValue('');
			if (this.useInternalStore) {
				this.store.removeAll();
			}
		}

	});
	Ext.reg("notesview", Ext.ux.NotesView);

/*
    Loads the main ExtJS POPV interface.
*/

Ext.BLANK_IMAGE_URL = '/assets/default/s.gif';

Ext.QuickTips.init();

var findLabel = function(field) {

    var wrapDiv = null;
    var label = null;
    //find form-element and label?
    wrapDiv = field.getEl().up('div.x-form-element');
    if(wrapDiv)
    {
        label = wrapDiv.child('label');
    }
    if(label) {
        return label;
    }

    //find form-item and label
    wrapDiv = field.getEl().up('div.x-form-item');
    if(wrapDiv)
    {
        label = wrapDiv.child('label');
    }
    if(label) {
        return label;
    }
};


var onStoreLoad = function(thisItem, record, options) {
    thisItem.thisItemLoaded = true;
    //We recount each time.
    var totalCount = 0;
    var localCount = 0;
    Ext.StoreMgr.each(function(item, index, length) {
    	totalCount++;
        if (item.thisItemLoaded) {
            localCount++;
        }
    });
    var thisValue = (localCount / (totalCount));
    if (thisValue < 1) {
        Ext.Msg.updateProgress(thisValue,localCount + '/' + (totalCount) + ' Stores Loaded');
    }
    else
    {
        if (currentUser.popv_viewer === false) {
            updateCurrentBom(false);
        }
    	Ext.Msg.updateProgress(1, '  ', '  ');
        Ext.Msg.hide();
        // Instead of opening the saved tabs from the database, just
        // open the piping classes.
        //telaeris.restoreTabs();

        //showOrCreatePipingDetail(493, 'CA');
      	//telaeris.openResource("piping_class_detail_493");
        //telaeris.openResource('piping');
        //telaeris.openResource('valve_comparison');

    }
};

var application = function() {

	// Put a listener on the document to listen for BACKSPACE key press.
	// Pops up a dialog prompting the user to confirm that they want to navigate
	// back or stay.
	// Ref: http://www.webmasterworld.com/javascript/3785986.htm
	// 		http://www.javascriptkit.com/domref/elementproperties.shtml
	var setBackspaceListeners = function () {
		document.onkeydown = function (e) {
			var keyPressed;
			var el;
			var tagName = "";

			if (window.event) { // Only IE 6 uses window.event. It doesn't use the
								// passed in e param... but Firefox does!
				keyPressed = window.event.keyCode; // IE hack
				el = window.event.srcElement;
			}
			else {
				keyPressed = e.which; // standard method
				el = e.target;
			}

			if (keyPressed == 8) { // Checks for BACKSPACE

				tagName = el.tagName ? el.tagName.toUpperCase(): "";
				type = el.type ? e.type.toUpperCase() : "";

				if (tagName == "INPUT" || tagName == "TEXTAREA" || type == 'TEXT' || type == 'CHECKBOX') {
					return true;
				}
				else {
					// Show dialog box
					Ext.Msg.show({
					   	title: 'Backspace Pressed',
					   	msg: 'Navigate away from this page?',
					   	buttons: Ext.Msg.YESNO,
					   	icon: Ext.MessageBox.QUESTION,
					   	fn: function (buttonId, text, opt) {
					   		if (buttonId == 'yes') {
						   		window.history.back(); // Browser "BACK" action
						   	}
					   	}
					});
					return false;
				}
			}
		};
	};

    /* public properties */
    return {
        viewPortRendered: function() {
//            Ext.Msg.progress('Initial Load of Classes and Data');

//            Ext.StoreMgr.each(function(item, index, length) {
//                item.thisItemLoaded = false;
//                console.log(item.storeId);
//                item.on('load', onStoreLoad.createCallback(item), item, {
//                    single: true
//                });
//                item.load();
//            });

        },
        init: function() {

            var resourcesCard = {
                id: 'resources_card',
                layout: 'border',
                region: 'center',
                items: [
                    {
                        id: 'navigation_panel',
                        region: 'west',
                        width: 180,
                        collapsible: true,
                        title: "Navigation",
                        split: true,
                        autoScroll: true,
                        collapsed: false,
                        contentEl: 'resource_navigation'
                    },
                    {
                        id: 'resources_tab_panel',
                        region: 'center',
                        xtype: 'tabpanel',
                        enableTabScroll:true,
                        layoutOnTabChange: true,
                        defaults: {autoScroll:true},
                        activeTab: 0,
                    	minTabWidth : 180,
                        resizeTabs: true,
                        plugins: new Ext.ux.TabCloseMenu()
                    }
                ]
            };

            var cardItems = [resourcesCard];

            viewport = new Ext.Viewport({
            	id:'viewport',
                layout: 'border',
                border: false,
                hideBorders: true,
//                listeners: {
//                    'render': application.viewPortRendered
//                },
                items: [
                {
                    contentEl: 'hd',
                    region: 'north',
                    height: 90,
                    bodyStyle: 'background-color:#333333; background: url(/assets/graphics/background.jpg)'

                },
                {
                    id: 'cards',
                    layout: 'card',
                    activeItem: 0,
                    region: 'center',
                    items: cardItems
                }
                ]
            });

            telaeris.init();
            Ext.get('resource_navigation').show();

            // Initial Resource Openings:
        	telaeris.openResource('piping');


            //telaeris.openResource('record_changelogs');

            //Valves
			//telaeris.openResource('valves');

            //PCD CAH (carson)
            //showOrCreatePipingDetail(3591, 'CAH');
            //telaeris.openResource("piping_class_detail_3591");

            //PCD A2A (cp)
            //showOrCreatePipingDetail(1425, 'A2A');
            //telaeris.openResource("piping_class_detail_1425");


            //This code does NOT have to wait for the piping resource to load.
            if (currentUser.popv_viewer === false) {
        		updateCurrentBom(false);
    		}
            if(true){
                //This code will load ALL of the stores that are defined in telaeris.stores
                for (var store in telaeris.stores) {
                    if (telaeris.stores.hasOwnProperty(store)) {
                        telaeris.stores[store].load();
                    }
                }
            }



            // Listen for BACKSPACE press and intercept it.
	        //setBackspaceListeners();
        }
    };
}();

var Telaeris = {
	skipConfirm: false,
	confirmCancel: Ext.isIE ? function () {
		if (!Telaeris.skipConfirm) {
			Telaeris.skipConfirm = false;
			var message = "";
		    event.returnValue = message;
		    return message;
		}
	} : function (event) {
		if (!Telaeris.skipConfirm) {
			Telaeris.skipConfirm = false;
			var message = "";
		    event.returnValue = message;
		    return message;
		}
	},

	closeNotice: function () {
		Ext.get('notice').hide();
    },
    closeError: function () {
		Ext.get('error').hide();
    }
};


// Starts the POPV application once the page fully loads.
Ext.onReady(application.init, application, true);

window.onbeforeunload = Telaeris.confirmCancel;
//window.onbeforeunload = Telaeris.confirmCancel;http://stackoverflow.com/questions/1325985/referencing-js-object-member-without-the-key/1326128#1326128

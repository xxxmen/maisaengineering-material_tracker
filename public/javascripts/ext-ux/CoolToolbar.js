//This is a tool item, as in the tools from the regular header
//Still needs an overCls, and some other prettyness, but works for now.
/*
Create it with a config something like:

{
	xtype:'tbtool', 
	toolName: 'restore',
	handler: someHandlerFunction
}
It will take regular Button configs also, such as hidden: true 
but shouldn't take the toggle parameters.

*/
Ext.Toolbar.Tool = Ext.extend(Ext.Toolbar.Button, {
	minWidth: 15,
    initComponent: function(config){
    	this.template = new Ext.Template('<span class="x-tool x-tool-', this.toolName,'";',
    				'<em unselectable="on"><button class="x-btn-text" type="{1}">{0}</button></em>',
    				'</span>');
		
    	Ext.Toolbar.Tool.superclass.initComponent.call(this);
    	
	}	
});
Ext.reg('tbtool', Ext.Toolbar.Tool);


Ext.ux.CoolToolbar = Ext.extend(Ext.Toolbar, {
	cls: 'x-panel-header',
	items: [],
	initComponent: function(config){
        	this.items = [
        		{xtype: 'tbtext', text: ("<span style='font-weight: bold;'>" + this.title + "</span>")}
        		
        	].concat(this.items);
        	
        	Ext.ux.CoolToolbar.superclass.initComponent.call(this);
        
	}
});

Ext.reg("cooltoolbar", Ext.ux.CoolToolbar);
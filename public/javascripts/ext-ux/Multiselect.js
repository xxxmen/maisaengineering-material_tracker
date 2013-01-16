//version 3.0
Ext.ux.SearchSelectorField = Ext.extend(Ext.form.TwinTriggerField, {
    initComponent: function(){
        Ext.ux.SearchSelectorField.superclass.initComponent.call(this);
        this.on('specialkey', function(f, e){

            if (e.getKey() == e.ENTER) {
				e.preventDefault();
                this.onTrigger2Click();
            }
        }, this);
    },
    filterFieldName: 'id',
    filterAnyMatch: false,
    validationEvent: false,
    validateOnBlur: false,
    trigger1Class: 'x-form-clear-trigger',
    trigger2Class: 'x-form-search-trigger',
    hideTrigger1: true,
    autoWidth: false,
    height: 20,
    hasSearch: false,
    paramName: 'query',
    onTrigger1Click: function(){
        if (this.hasSearch) {
            //var o = {start: 0};
            //o[this.paramName] = '';
            //this.store.reload({params:o});
            this.store.filter(this.filterFieldName, '');
            this.el.dom.value = '';
            this.triggers[0].hide();
            this.hasSearch = false;
        }
    },

    onTrigger2Click: function(){
        var v = this.getRawValue();
        if (v.length < 1) {
            this.onTrigger1Click();
            return;
        }
        //var o = {start: 0};
        //o[this.paramName] = v;
        //this.store.filter({params:o});
        this.store.filter(this.filterFieldName, v, this.filterAnyMatch);
        this.hasSearch = true;
        this.triggers[0].show();
    }
});

Ext.ux.Multiselect = Ext.extend(Ext.form.Field, {
    autoWidth: false,
    store: null,
    dataFields: [],
    data: [],
    width: 100,
    height: 100,
    displayField: 0,
    valueField: 1,
    allowBlank: true,
    minLength: 0,
    maxLength: Number.MAX_VALUE,
    blankText: Ext.form.TextField.prototype.blankText,
    minLengthText: 'Minimum {0} item(s) required',
    maxLengthText: 'Maximum {0} item(s) allowed',
    copy: false,
    allowDup: false,
    allowTrash: false,
    legend: null,
    focusClass: undefined,
    delimiter: ',',
    view: null,
    dragGroup: null,
    dropGroup: null,
    tbar: null,
    appendOnly: false,
    sortField: null,
    sortDir: 'ASC',
	tpl: null,
    defaultAutoCreate: {
        tag: "div"
    },
    invalid:false,
      markInvalid:function(){
        this.invalid = true;
      },
      clearInvalid:function(){
        this.invalid = false;
      },
      validate: function() {
            return true;
        },
        getName: function() {
            return this.name;
        },

    initComponent: function(){
        Ext.ux.Multiselect.superclass.initComponent.call(this);
        this.addEvents({
            'dblclick': true,
            'click': true,
            'change': true,
            'drop': true
        });
    },
    onRender: function(ct, position){
        var fs, cls, tpl;
        Ext.ux.Multiselect.superclass.onRender.call(this, ct, position);

        cls = 'ux-mselect';

        fs = new Ext.form.FieldSet({
            autoWidth: this.autoWidth,
            renderTo: this.el,
            title: this.legend,
            height: this.legend == null ? this.height : this.height - 10,
            width: this.width,
			bodyStyle: 'padding: 8px;',
            style: "padding:2px;",
            border: false,
            tbar: this.tbar
        });
        if (!this.legend) {
            var e = fs.el.down('.' + fs.headerCls);
            if (e) {
                e.remove();
            }
        }
        fs.body.addClass(cls);
        if (!this.tpl) {
			tpl = '<tpl for="."><div class="' + cls + '-item';
			if (Ext.isIE || Ext.isIE7) {
				tpl += '" unselectable=on';
			}
			else {
				tpl += ' x-unselectable"';
			}
			tpl += '>{' + this.displayField + '}</div></tpl>';
		}
		else {
			tpl = this.tpl;
		}
        if (!this.store) {
            this.store = new Ext.data.SimpleStore({
                fields: this.dataFields,
                data: this.data
            });
        }

        this.view = new Ext.ux.DDView({
			border: true,
            multiSelect: true,
            store: this.store,
            selectedClass: cls + "-selected",
            tpl: tpl,
            allowDup: this.allowDup,
            copy: this.copy,
            allowTrash: this.allowTrash,
            dragGroup: this.dragGroup,
            dropGroup: this.dropGroup,
            itemSelector: "." + cls + "-item",
            isFormField: false,
            applyTo: fs.body,
            appendOnly: this.appendOnly,
            sortField: this.sortField,
            sortDir: this.sortDir
        });

        fs.add(this.view);

        this.view.on('click', this.onViewClick, this);
        this.view.on('beforeClick', this.onViewBeforeClick, this);
        this.view.on('dblclick', this.onViewDblClick, this);
        this.view.on('drop', function(ddView, n, dd, e, data){
            return this.fireEvent("drop", ddView, n, dd, e, data);
        }, this);

        this.hiddenName = this.name;
        var hiddenTag = {
            tag: "input",
            type: "hidden",
            value: "",
            name: this.name
        };
        if (this.isFormField) {
            this.hiddenField = this.el.createChild(hiddenTag);
        }
        else {
            this.hiddenField = Ext.get(document.body).createChild(hiddenTag);
        }
        fs.doLayout();
    },

    initValue: Ext.emptyFn,

    onViewClick: function(vw, index, node, e){
        var arrayIndex = this.preClickSelections.indexOf(index);
        if (arrayIndex != -1) {
            this.preClickSelections.splice(arrayIndex, 1);
            this.view.clearSelections(true);
            this.view.select(this.preClickSelections);
        }
        this.fireEvent('change', this, this.getValue(), this.hiddenField.dom.value);
        this.hiddenField.dom.value = this.getValue();
        this.fireEvent('click', this, e);
        this.validate();
    },

    onViewBeforeClick: function(vw, index, node, e){
        this.preClickSelections = this.view.getSelectedIndexes();
        if (this.disabled) {
            return false;
        }
    },

    onViewDblClick: function(vw, index, node, e){
        return this.fireEvent('dblclick', vw, index, node, e);
    },

    getValue: function(valueField){
        var returnArray = [];
        var selectionsArray = this.view.getSelectedIndexes();
        if (selectionsArray.length == 0) {
            return '';
        }
        for (var i = 0; i < selectionsArray.length; i++) {
            returnArray.push(this.store.getAt(selectionsArray[i]).get(((valueField != null) ? valueField : this.valueField)));
        }
        return returnArray.join(this.delimiter);
    },

    setValue: function(values){
        var index;
        var selections = [];
        this.view.clearSelections();
        this.hiddenField.dom.value = '';

        if (!values || (values == '')) {
            return;
        }

        if (!(values instanceof Array)) {
            values = values.split(this.delimiter);
        }
        for (var i = 0; i < values.length; i++) {
            index = this.view.store.indexOf(this.view.store.query(this.valueField, new RegExp('^' + values[i] + '$', "i")).itemAt(0));
            selections.push(index);
        }
        this.view.select(selections);
        this.hiddenField.dom.value = this.getValue();
        this.validate();
    },

    reset: function(){
        this.setValue('');
    },
    refresh: function(){
        Ext.ux.Multiselect.superclass.refresh.call(this);
    },

    getRawValue: function(valueField){
        var tmp = this.getValue(valueField);
        if (tmp.length) {
            tmp = tmp.split(this.delimiter);
        }
        else {
            tmp = [];
        }
        return tmp;
    },

    setRawValue: function(values){
        setValue(values);
    },

    validateValue: function(value){
        if (value.length < 1) { // if it has no value
            if (this.allowBlank) {
                this.clearInvalid();
                return true;
            }
            else {
                this.markInvalid(this.blankText);
                return false;
            }
        }
        if (value.length < this.minLength) {
            this.markInvalid(String.format(this.minLengthText, this.minLength));
            return false;
        }
        if (value.length > this.maxLength) {
            this.markInvalid(String.format(this.maxLengthText, this.maxLength));
            return false;
        }
        return true;
    }
});

Ext.reg("multiselect", Ext.ux.Multiselect);

Ext.ux.ItemSelector = Ext.extend(Ext.form.Field, {
    height: 300,
    msHeight: 300,
    hideNavIcons: false,
    imagePath: "",
    iconUp: "up2.gif",
    iconDown: "down2.gif",
    iconLeft: "left2.gif",
    iconRight: "right2.gif",
    iconTop: "top2.gif",
    iconBottom: "bottom2.gif",
    drawUpIcon: true,
    drawDownIcon: true,
    drawLeftIcon: true,
    drawRightIcon: true,
    drawTopIcon: true,
    drawBotIcon: true,
    fromStore: null,
    toStore: null,
    fromData: null,
    toData: null,
	fromTpl: null,
	toTpl: null,
    displayField: 0,
    valueField: 1,
    switchToFrom: false,
    allowDup: false,
    focusClass: undefined,
    delimiter: ',',
    readOnly: false,
    toLegend: null,
    fromLegend: null,
    toSortField: null,
    fromSortField: null,
    toSortDir: 'ASC',
    fromSortDir: 'ASC',
    toTBar: null,
    fromTBar: null,
    bodyStyle: null,
    border: false,
    filterField: false,
    defaultAutoCreate: {
        tag: "div"
    },

    initComponent: function(){
        Ext.ux.ItemSelector.superclass.initComponent.call(this);
        this.addEvents({
            'rowdblclick': true,
            'change': true
        });
    },

    onRender: function(ct, position){
        Ext.ux.ItemSelector.superclass.onRender.call(this, ct, position);

        this.fromMultiselect = new Ext.ux.Multiselect({
            legend: this.fromLegend,
            delimiter: this.delimiter,
            allowDup: this.allowDup,
            copy: this.allowDup,
            allowTrash: this.allowDup,
            dragGroup: this.readOnly ? null : "drop2-" + this.el.dom.id,
            dropGroup: this.readOnly ? null : "drop2-" + this.el.dom.id + ",drop1-" + this.el.dom.id,
            width: this.msWidth,
            height: this.msHeight,
            dataFields: this.dataFields,
            data: this.fromData,
            displayField: this.displayField,
            valueField: this.valueField,
            store: this.fromStore,
            isFormField: false,
            tbar: this.fromTBar,
			tpl: this.fromTpl,
            appendOnly: true,
            sortField: this.fromSortField,
            sortDir: this.fromSortDir
        });
        this.fromMultiselect.on('dblclick', this.onRowDblClick, this);

        if (!this.toStore) {
            this.toStore = new Ext.data.SimpleStore({
                fields: this.dataFields,
                data: this.toData
            });
        }
        this.toStore.on('add', this.valueChanged, this);
        this.toStore.on('remove', this.valueChanged, this);
        this.toStore.on('load', this.valueChanged, this);

        this.toMultiselect = new Ext.ux.Multiselect({
            legend: this.toLegend,
            delimiter: this.delimiter,
            allowDup: this.allowDup,
            dragGroup: this.readOnly ? null : "drop1-" + this.el.dom.id,
            dropGroup: this.readOnly ? null : "drop2-" + this.el.dom.id + ",drop1-" + this.el.dom.id,
            width: this.msWidth,
            height: this.msHeight,
            displayField: this.displayField,
            valueField: this.valueField,
            store: this.toStore,
			tpl: this.toTpl,
            isFormField: false,
            tbar: this.toTBar,
            sortField: this.toSortField,
            sortDir: this.toSortDir
        });
        this.toMultiselect.on('dblclick', this.onRowDblClick, this);

        var tempFilterField = null;
        if (this.filterField) {
            tempFilterField = new Ext.ux.SearchSelectorField({
                blankText: 'Filter',
                height: 25,
                store: this.fromStore,
                filterFieldName: this.filterFieldName,
                filterAnyMatch: this.filterAnyMatch,
                paramName: 'search'
            });
        }

        var searchAndFromMultiSelectField = new Ext.Panel({
            border: true,
            width: this.msWidth,
            height: (this.filterField ? this.msHeight + 25 : this.msHeight)
        });

        searchAndFromMultiSelectField.add(this.fromMultiselect);
        if (this.filterField) {
            searchAndFromMultiSelectField.add({
                xtype: 'panel',
                layout: 'fit',
                items: [tempFilterField]
            });
        }

        var icons = new Ext.Panel({
            header: false,
            border: false
        });

        var p = new Ext.form.FieldSet({
            region: 'center',
            width: this.width,
            height: this.height,
            border: this.border,
            bodyStyle: this.bodyStyle,
            items: [{
                xtype: 'panel',
                border: false,
                layout: 'fit',
                items: [{
                    border: false,
                    layout: "column",
                    items: [{
                        columnWidth: 0.48,
                        items: [{
                            xtype: 'panel',
                            border: false,
                            layout: 'fit',
                            items: [(this.switchToFrom ? this.toMultiselect : searchAndFromMultiSelectField)]
                        }]

                    }, {
                        border: false,
                        items: [icons]
                    }, {
                        columnWidth: 0.48,
                        border: false,
                        items: [{
                            xtype: 'panel',
                            layout: 'fit',
                            border: false,
                            items: [(this.switchToFrom ? searchAndFromMultiSelectField : this.toMultiselect)]
                        }]

                    }]
                }]
            }]
        });




        //p.add(this.switchToFrom ? this.toMultiselect : searchAndFromMultiSelectField);

        //p.add(icons);
        //p.add(this.switchToFrom ? searchAndFromMultiSelectField : this.toMultiselect);

        p.render(this.el);

        icons.el.down('.' + icons.bwrapCls).remove();

        if (this.imagePath != "" && this.imagePath.charAt(this.imagePath.length - 1) != "/") {
            this.imagePath += "/";
        }
        this.iconUp = this.imagePath + (this.iconUp || 'up2.gif');
        this.iconDown = this.imagePath + (this.iconDown || 'down2.gif');
        this.iconLeft = this.imagePath + (this.iconLeft || 'left2.gif');
        this.iconRight = this.imagePath + (this.iconRight || 'right2.gif');
        this.iconTop = this.imagePath + (this.iconTop || 'top2.gif');
        this.iconBottom = this.imagePath + (this.iconBottom || 'bottom2.gif');
        var el = icons.getEl();
        if (!this.toSortField) {
            this.toTopIcon = el.createChild({
                tag: 'img',
                src: this.iconTop,
                style: {
                    cursor: 'pointer',
                    margin: '2px'
                }
            });
            el.createChild({
                tag: 'br'
            });

            this.upIcon = el.createChild({
                tag: 'img',
                src: this.iconUp,
                style: {
                    cursor: 'pointer',
                    margin: '2px'
                }
            });
            el.createChild({
                tag: 'br'
            });
        }
        this.addIcon = el.createChild({
            tag: 'img',
            src: this.switchToFrom ? this.iconLeft : this.iconRight,
            style: {
                cursor: 'pointer',
                margin: '2px'
            }
        });
        el.createChild({
            tag: 'br'
        });
        this.removeIcon = el.createChild({
            tag: 'img',
            src: this.switchToFrom ? this.iconRight : this.iconLeft,
            style: {
                cursor: 'pointer',
                margin: '2px'
            }
        });
        el.createChild({
            tag: 'br'
        });
        if (!this.toSortField) {
            this.downIcon = el.createChild({
                tag: 'img',
                src: this.iconDown,
                style: {
                    cursor: 'pointer',
                    margin: '2px'
                }
            });
            el.createChild({
                tag: 'br'
            });
            this.toBottomIcon = el.createChild({
                tag: 'img',
                src: this.iconBottom,
                style: {
                    cursor: 'pointer',
                    margin: '2px'
                }
            });
        }
        if (!this.readOnly) {
            if (!this.toSortField) {
                this.toTopIcon.on('click', this.toTop, this);
                this.upIcon.on('click', this.up, this);
                this.downIcon.on('click', this.down, this);
                this.toBottomIcon.on('click', this.toBottom, this);
            }
            this.addIcon.on('click', this.fromTo, this);
            this.removeIcon.on('click', this.toFrom, this);
        }
        if (!this.drawUpIcon || this.hideNavIcons) {
            this.upIcon.dom.style.display = 'none';
        }
        if (!this.drawDownIcon || this.hideNavIcons) {
            this.downIcon.dom.style.display = 'none';
        }
        if (!this.drawLeftIcon || this.hideNavIcons) {
            this.addIcon.dom.style.display = 'none';
        }
        if (!this.drawRightIcon || this.hideNavIcons) {
            this.removeIcon.dom.style.display = 'none';
        }
        if (!this.drawTopIcon || this.hideNavIcons) {
            this.toTopIcon.dom.style.display = 'none';
        }
        if (!this.drawBotIcon || this.hideNavIcons) {
            this.toBottomIcon.dom.style.display = 'none';
        }

        var tb = p.body.first();
        this.el.setWidth(p.body.first().getWidth());
        p.body.removeClass();

        this.hiddenName = this.name;
        var hiddenTag = {
            tag: "input",
            type: "hidden",
            value: "",
            name: this.name
        };
        this.hiddenField = this.el.createChild(hiddenTag);
        this.valueChanged(this.toStore);
    },

    initValue: Ext.emptyFn,

    toTop: function(){
        var selectionsArray = this.toMultiselect.view.getSelectedIndexes();
        var records = [];
        if (selectionsArray.length > 0) {
            selectionsArray.sort();
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.toMultiselect.view.store.getAt(selectionsArray[i]);
                records.push(record);
            }
            selectionsArray = [];
            for (var i = records.length - 1; i > -1; i--) {
                record = records[i];
                this.toMultiselect.view.store.remove(record);
                this.toMultiselect.view.store.insert(0, record);
                selectionsArray.push(((records.length - 1) - i));
            }
        }
        this.toMultiselect.view.refresh();
        this.toMultiselect.view.select(selectionsArray);
    },

    toBottom: function(){
        var selectionsArray = this.toMultiselect.view.getSelectedIndexes();
        var records = [];
        if (selectionsArray.length > 0) {
            selectionsArray.sort();
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.toMultiselect.view.store.getAt(selectionsArray[i]);
                records.push(record);
            }
            selectionsArray = [];
            for (var i = 0; i < records.length; i++) {
                record = records[i];
                this.toMultiselect.view.store.remove(record);
                this.toMultiselect.view.store.add(record);
                selectionsArray.push((this.toMultiselect.view.store.getCount()) - (records.length - i));
            }
        }
        this.toMultiselect.view.refresh();
        this.toMultiselect.view.select(selectionsArray);
    },

    up: function(){
        var record = null;
        var selectionsArray = this.toMultiselect.view.getSelectedIndexes();
        selectionsArray.sort();
        var newSelectionsArray = [];
        if (selectionsArray.length > 0) {
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.toMultiselect.view.store.getAt(selectionsArray[i]);
                if ((selectionsArray[i] - 1) >= 0) {
                    this.toMultiselect.view.store.remove(record);
                    this.toMultiselect.view.store.insert(selectionsArray[i] - 1, record);
                    newSelectionsArray.push(selectionsArray[i] - 1);
                }
            }
            this.toMultiselect.view.refresh();
            this.toMultiselect.view.select(newSelectionsArray);
        }
    },

    down: function(){
        var record = null;
        var selectionsArray = this.toMultiselect.view.getSelectedIndexes();
        selectionsArray.sort();
        selectionsArray.reverse();
        var newSelectionsArray = [];
        if (selectionsArray.length > 0) {
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.toMultiselect.view.store.getAt(selectionsArray[i]);
                if ((selectionsArray[i] + 1) < this.toMultiselect.view.store.getCount()) {
                    this.toMultiselect.view.store.remove(record);
                    this.toMultiselect.view.store.insert(selectionsArray[i] + 1, record);
                    newSelectionsArray.push(selectionsArray[i] + 1);
                }
            }
            this.toMultiselect.view.refresh();
            this.toMultiselect.view.select(newSelectionsArray);
        }
    },

    fromTo: function(){
        var selectionsArray = this.fromMultiselect.view.getSelectedIndexes();
        var records = [];
        if (selectionsArray.length > 0) {
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.fromMultiselect.view.store.getAt(selectionsArray[i]);
                records.push(record);
            }
            if (!this.allowDup) {
                selectionsArray = [];
            }
            for (var i = 0; i < records.length; i++) {
                record = records[i];
                if (this.allowDup) {
                    var x = new Ext.data.Record();
                    record.id = x.id;
                    delete x;
                    this.toMultiselect.view.store.add(record);
                }
                else {
                    this.fromMultiselect.view.store.remove(record);
                    this.toMultiselect.view.store.add(record);
                    selectionsArray.push((this.toMultiselect.view.store.getCount() - 1));
                }
            }
        }
        this.toMultiselect.view.refresh();
        this.fromMultiselect.view.refresh();
        if (this.toSortField) {
            this.toMultiselect.store.sort(this.toSortField, this.toSortDir);
        }
        if (this.allowDup) {
            this.fromMultiselect.view.select(selectionsArray);
        }
        else {
            this.toMultiselect.view.select(selectionsArray);
        }
    },

    toFrom: function(){
        var selectionsArray = this.toMultiselect.view.getSelectedIndexes();
        var records = [];
        if (selectionsArray.length > 0) {
            for (var i = 0; i < selectionsArray.length; i++) {
                record = this.toMultiselect.view.store.getAt(selectionsArray[i]);
                records.push(record);
            }
            selectionsArray = [];
            for (var i = 0; i < records.length; i++) {
                record = records[i];
                this.toMultiselect.view.store.remove(record);
                if (!this.allowDup) {
                    this.fromMultiselect.view.store.add(record);
                    selectionsArray.push((this.fromMultiselect.view.store.getCount() - 1));
                }
            }
        }
        this.fromMultiselect.view.refresh();
        this.toMultiselect.view.refresh();
        if (this.fromSortField) {
            this.fromMultiselect.store.sort(this.fromSortField, this.fromSortDir);
        }
        this.fromMultiselect.view.select(selectionsArray);
    },

    valueChanged: function(store){
        var record = null;
        var values = [];
        for (var i = 0; i < store.getCount(); i++) {
            record = store.getAt(i);
            values.push(record.get(this.valueField));
        }
        this.hiddenField.dom.value = values.join(this.delimiter);
        this.fireEvent('change', this, this.getValue(), this.hiddenField.dom.value);
    },
    setValue: function(val){
        if (!val) {
            return;
        }
        val = val instanceof Array ? val : val.split(',');
        var rec, i, record_id, rec_index;
        for (i = 0; i < val.length; i++) {
            record_id = val[i];
            //if (this.toStore.getById(id)) {
            //    continue;
            //}

            //Exact match for the id FIELD, not object id
            if (this.toStore.findBy(function(record, id){
                if (record.data['id'] == record_id) {
                    return true;
                }
                else {
                    return false;
                }
            }) != -1) {
                continue;
            }

            rec_index = this.fromStore.findBy(function(record, id){
                if (record.data['id'] == record_id) {
                    return true;
                }
                else {
                    return false;
                }
	        });
            if (rec_index != -1) {
                rec = this.fromStore.getAt(rec_index);
                this.toStore.add(rec);
                this.fromStore.remove(rec);
            }
        }
    },

    getValue: function(){
        return this.hiddenField.dom.value;
    },

    onRowDblClick: function(vw, index, node, e){
        return this.fireEvent('rowdblclick', vw, index, node, e);
    },

    reset: function(){
        range = this.toMultiselect.store.getRange();
        this.toMultiselect.store.removeAll();
        if (!this.allowDup) {
            this.fromMultiselect.store.add(range);
            this.fromMultiselect.store.sort(this.displayField, 'ASC');
        }
        this.valueChanged(this.toMultiselect.store);
    }
});



Ext.reg("itemselector", Ext.ux.ItemSelector);

var BrowserDetect = {
    init: function () {
        this.browser = this.searchString(this.dataBrowser) || "An unknown browser";
        this.version = this.searchVersion(navigator.userAgent) ||
            this.searchVersion(navigator.appVersion) ||
            "an unknown version";
        this.OS = this.searchString(this.dataOS) || "an unknown OS";
    },
    searchString: function (data) {
        for (var i=0;i<data.length;i++)	{
            var dataString = data[i].string;
            var dataProp = data[i].prop;
            this.versionSearchString = data[i].versionSearch || data[i].identity;
            if (dataString) {
                if (dataString.indexOf(data[i].subString) != -1) {
                    return data[i].identity;
                }
            }
            else if (dataProp) {
                return data[i].identity;
            }
        }
    },
    searchVersion: function (dataString) {
        var index = dataString.indexOf(this.versionSearchString);
        if (index == -1) { return; }
        return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
    },
    dataBrowser: [{ string: navigator.userAgent,subString: "OmniWeb",versionSearch: "OmniWeb/",identity: "OmniWeb"},
        {string: navigator.vendor,subString: "Apple",identity: "Safari" },
        {prop: window.opera,identity: "Opera"},
        {string: navigator.vendor,subString: "iCab",identity: "iCab"},
        {string: navigator.vendor,subString: "KDE",identity: "Konqueror"},
        {string: navigator.userAgent,subString: "Firefox",identity: "Firefox"},
        {string: navigator.vendor,subString: "Camino",identity: "Camino"},
        {string: navigator.userAgent,subString: "Netscape",identity: "Netscape" },
        {string: navigator.userAgent,subString: "MSIE",identity: "Explorer",versionSearch: "MSIE"},
        {string: navigator.userAgent,subString: "Gecko",identity: "Mozilla",versionSearch: "rv"},
        {string: navigator.userAgent,subString: "Mozilla",identity: "Netscape",versionSearch: "Mozilla"}
    ],
    dataOS : [
        {string: navigator.platform,subString: "Win",identity: "Windows"},
        {string: navigator.platform,subString: "Mac",identity: "Mac"},
        {string: navigator.platform,subString: "Linux",identity: "Linux"}
    ]

};
BrowserDetect.init();

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function setup_calendar_for(array_of_dom_ids) {
    array_of_dom_ids.each(function(dom_id) {
        var el = $(dom_id);
        if (!el) {
            return;
        }
        var value = el.value;
        var month, day, year;
        if(value.match(/(\d\d\d\d)-(\d\d)-(\d\d)/)) {
            year = RegExp.$1;
            month = RegExp.$2;
            day = RegExp.$3;
            $(dom_id).value = month + "/" + day + "/" + year;
        }
        Calendar.setup({
            inputField     :    dom_id,      // id of the input field
            ifFormat       :    "%m/%d/%Y",       // format of the input field
            showsTime      :    false,            // will display a time selector
            button         :    dom_id,   // trigger for the calendar (button ID)
            singleClick    :    true,           // double-click mode
            step           :    1
        }); // end calendar setup
        $(dom_id).onkeydown = function(event){
            var key = event.keyCode;
            var BACKSPACE = 8;
            var TAB = 9;
            if(key == 9) {
                return true;
            }
            else if(key == 8) {
                $(dom_id).value = '';
                return true;
            }
            else {
                return false;
            }
        };
    }); //end enumerable each
}

function changeDateFormat(dom_id) {
    var month, day, year;
    var value = $F(dom_id);
    if(value.match(/(\d\d\d\d)-(\d\d)-(\d\d)/)) {
        year = RegExp.$1;
        month = RegExp.$2;
        day = RegExp.$3;
        $(dom_id).value = month + "/" + day + "/" + year;
    }
}

function addOption(selectObject,optionText,optionValue) {
    var optionObject = new Option(optionText,optionValue);
    var optionRank = selectObject.options.length;
    selectObject.options[optionRank]=optionObject;
}

function deleteOption(selectObject,optionRank) {
    if (selectObject.options.length !== 0)
    {
        selectObject.options[optionRank]=null;
        return true;
    }
    else
    {
        return false;
    }
}

function woAdd() {
    var elWorkOrder = document.getElementById("order_wo_no");
    var elWorkOrderList = document.getElementById("order_wo_list");
    if(elWorkOrder.value !== "")
    {
        addOption(elWorkOrderList,elWorkOrder.value,elWorkOrder.value);
        elWorkOrder.value = "";
    }
    else
    {
        alert("No Work Order to Add");
    }

}

function woDelete() {
    var elWorkOrder = document.getElementById("order_wo_no");
    var elWorkOrderList = document.getElementById("order_wo_list");

    if (elWorkOrderList.selectedIndex!=-1) {
        if(deleteOption(elWorkOrderList,elWorkOrderList.selectedIndex))
        {
            elWorkOrder.value = "";
        } else {
            alert("Could not delete entry");
        }

    } else {
        alert("Please Select a Work Order to Delete");
    }
}

//*****************************************************************************
// This copies a work order selected from the drop-down list to the text field.
//*****************************************************************************
function setWorkOrder()
{
    var elWorkOrderList = document.getElementById('order_wo_list');
    var elWorkOrder = document.getElementById('order_wo_no');

    // Copy the work order from the drop-down list to the text work order code field.
    var n = elWorkOrderList.selectedIndex;
    elWorkOrder.value = elWorkOrderList.options[n].value;

    // Clear the current selection.
    //elWorkOrderList.selectedIndex = -1;
}

function loadingReq(image, button) {
    $(image).show();
    if(button !== undefined) { $(button).disable(); }
}

function completeReq(image, button) {
    if($(image)) { $(image).hide(); }
    if($(button)) { $(button).enable(); }
}


Object.extend(Form, {
    serializeThese: function(args) {
        var elems = $A(args).map(function(e) { return $(e); });
        var serializedForms = elems.select(function(e) { return e.tagName == 'FORM'; }).map(function(f) { return Form.serialize(f); }).join("&");
        return Form.serializeElements(elems) + serializedForms;
    }
});

function switchIt(field) {
    var select = $(field + '_select');
    var text = $(field + '_text');
    var link = $(field + '_anchor');

    if (select.disabled == true) {
        select.style.display = "inline";
        select.disabled = false;

        text.style.display = "none";
        text.disabled = true;
    }
    else {
        text.style.display = "inline";
        text.disabled = false;

        select.style.display = "none";
        select.disabled = true;
    }

    if(link.innerHTML == "(Manually Enter In)") {
        link.update("(Select From List)");
    }
    else {
        link.update("(Manually Enter In)");
    }
}

PipeBuilder = {
    build: function(valveCode) {
        var radio;
        $$('input[type="radio"][name="pipe_builder"]').each(function(r) {
            if(r.checked) { radio = r; }
        });
        if(radio == null) { return; }
        var desc = radio.up('tr').down('textarea[id$="description"]');
        var notes = radio.up('tr').down('textarea[id$="notes"]');
        if(!desc) { return; }
        var piping_class = $('piping_class').options[$('piping_class').selectedIndex].innerHTML;
        var details = $('piping_class_detail');
        var sizes = "";
        var component = $('piping_component');
        valveCode = valveCode || "";
        component = component.options[component.selectedIndex].innerHTML.unescapeHTML();
        if($F('piping_subcomponent') != "") {
            component = $F('piping_subcomponent');
        }

        if($F('piping_size_1') == "" || $F('piping_size_1') == null) {
            if($F('piping_size_2') == "" || $F('piping_size_2') == null) {
                sizes = "";
            }
            else {
                sizes = $F('piping_size_2') + " ";
            }
        }
        else {
            if($F('piping_size_2') == "" || $F('piping_size_2') == null) {
                sizes = $F('piping_size_1') + " ";
            }
            else {
                sizes = $F('piping_size_1') + " x " + $F('piping_size_2') + " ";
            }
        }

        $(desc).value = component + ", " + sizes + $(details.options[details.selectedIndex]).innerHTML.split(" -- ")[1].unescapeHTML() + " (" + piping_class.unescapeHTML() + ")";
        $(notes).value = valveCode;
    },

    next: function(id) {
        $(id).show();
    },

    showNote: function(note) {
        $(note).addClassName("active_note");
        $$('.active_note').invoke("removeClassName", "active_note");

        var noteText = $(note).innerHTML + ": " + $(note).title;
        $('note_text_cell').update(noteText);
    },

    reset: function(id) {
        $(id).selectedIndex = 0;
        if(id == "piping_class") {
            this.reset("piping_component");
        } else if (id == "piping_component") {
            this.reset("piping_class_detail");
        } else if (id == "piping_class_detail") {
            this.reset("piping_size_1");
        } else if (id == "piping_size_1") {
            this.reset("piping_size_2");
        }
    }
};

function checkSelection() {
    var message = "";
    var checked = false;

    $$("table.items tr td input[type=checkbox]").each(function(c){
        if(c.checked == true) { checked = true; }
    });

    if(checked == false) {
        message += "At least one line item must be selected\n";
    }

    if(message == "") {
        return true;
    }
    else {
        alert(message);
        return false;
    }
}

Telaeris = {};



Telaeris.formChanged = false;
Telaeris.skipConfirm = false;
Telaeris.confirmCancel = function(event, t1, t2) {
    var element;
    var imgButton;
    var formElement;
    if(event == undefined){

        imgButton = false;
        formElement = false;
    }
    else{
        element = Event.element(event);
        imgButton = (element.tagName == "A" && $(element).readAttribute('href')[0] == "#");
        formElement = (element.tagName == "FORM" || element.tagName == "INPUT" || element.tagName == "BUTTON");
    }
    // doesn't work in safari unfortunately
    if(!Telaeris.skipConfirm && Telaeris.formChanged && !imgButton && !formElement && BrowserDetect.browser != "Safari") {
        var message = "Navigating away will lose unsaved changes.";
        if(event != undefined){
            event.returnValue = message;
        }

        return message;
    }
};

// Close handlers to the flash notice and error div links.
Telaeris.closeNotice = function () {
    jQuery('#notice').hide('normal');
};

Telaeris.closeError = function () {
    jQuery('#error').hide('normal');
};


Telaeris.checkNotAssigned = function() {
    $$('table.items td input[type=checkbox]').each(function(e){
        var tr = e.up('tr');
        var trID = '#' + tr.identify();
        var td = $$(trID + ' td').last();
        if(td.innerHTML.match(/^\s*$/)) {
            e.checked = true;
            $(tr).addClassName('selected');
        } else {
            e.checked = false;
            $(tr).removeClassName('selected');
        }
    });
    return false;
};

Telaeris.formChange = function() {
    Telaeris.formChanged = true;
    $$('.save-button').each(function(button){
        $(button).setStyle({backgroundColor: 'yellow'});
    });
};

Telaeris.checkAll = function(main) {
    main = main || { checked: true }; // simulate checkbox
    $$('table.items td input[type=checkbox]').each(function(e){
        if(e.checked != main.checked) { e.onclick(); }
        e.checked = main.checked;
    });
    Telaeris.enableCheckedButtons();
};

function removeLineItems() {
    if($$('table.items td input[type=checkbox]').length <= 1) {
        alert("Can't delete any items because a Material Request must have at least one line item");
        return false;
    }
    var confirmation = confirm("Are you sure you want to delete selected line item(s)?");
    if(confirmation) {
        $$('table.items td input[type=checkbox]').each(function(e){
            if(e.checked) {
                var tr = e.up('tr');
                tr.replace("");
            }
        });
    }
    return false;
}

Telaeris.enableCheckedButtons = function() {
    var isChecked = false;
    $$('table.items td input[type=checkbox]').each(function(e){
        if(e.checked) { isChecked = true; throw $break; }
    });

    if(isChecked) {
        $('delete_button').disabled = false;
        if($('assign_to_button') && ($('partially_authorized').checked || $('authorized').checked)) {
            $('assign_to_button').disabled = false;
        }
        else if($('assign_to_button')) {
            $('assign_to_button').disabled = true;
        }
    }
    else {
        $('delete_button').disabled = true;
        if($('assign_to_button')) { $('assign_to_button').disabled = true; }
    }
};

Telaeris.parseMoney = function(args) {
    $A(arguments).each(function(input){
        input = $(input);
        var val = $F(input);
        input.value = val.gsub(/[^\d\.]/, '');
    });
};

Telaeris.validateForm = function(form) {
    var invalids = $A([]);
    var message = "<h2>There were some error(s):</h2><br /><ul>";

    $$('input.required', 'textarea.required', 'select.required').each(function(input) {
        if(!input.descendantOf(form)) { return; }
        if($F(input) == "" || $F(input) == null) {
            invalids.push(input.title);
            if(!input.hasClassName('error')) {
                // input.insert({ after : "<p class='formError'>can't be blank</p>" });
                input.addClassName('error');
            }
        }
        else if(input.hasClassName('error')) {
            input.removeClassName('error');
            if(input.next('.formError')) { input.next('.formError').replace(''); }
        }
    });

    $$('input.numbers_only', 'textarea.numbers_only', 'select.numbers_only').each(function(input){
        if(!input.descendantOf(form)) { return; }
        if(!Telaeris.numbersOnly(input)) {
            invalids.push(input.title);
            if(!input.hasClassName('error')) {
                // if(input.type != "checkbox")
                // input.insert({ after : "<p class='formError'>only accepts numbers</p>" });
                input.addClassName('error');
            }
        }
        else if(input.hasClassName('error')) {
            input.removeClassName('error');
            if(input.next('.formError')) { input.next('.formError').replace(''); }
        }
    });

    $$('input.validate_quantity').each(function(input){
        if(!input.descendantOf(form)) { return; }
        var qty_avail = parseFloat(input.up('tr').down('td.quantity_available').innerHTML);
        var qty = parseFloat($F(input));
        if (qty > qty_avail) {
            invalids.push(input.title);
            if(!input.hasClassName('error')) { input.addClassName('error'); }
        }
    });

    invalids.each(function(error){
        message += "<li>" + error + "</li>";
    });

    message += "</ul>";

    if(invalids.length > 0) {
        Telaeris.skipConfirm = false;
        if($('errorExplanation')) { $('errorExplanation').update(message); $('errorExplanation').show(); }
        new Effect.Highlight('errorExplanation');
        return false;
    }
    else {
        Telaeris.skipConfirm = true;
        $('errorExplanation').hide();
        return true;
    }
};

Telaeris.numbersOnly = function(field) {
    return !$F(field).match(/[^0-9]/);
};

Telaeris.checkClassDetail = function() {
    if($F('piping_class_detail') != "") {
        $('new_pipe_button').enable();
    }
    else {
        $('new_pipe_button').disable();
    }
};

Telaeris.checkAcknowledged = function(elem) {
    elem = $(elem);
    if(elem.checked) {
        $('acknowledged').checked = true;
        if(elem.id == "partially_authorized") {
            $('authorized').checked = false;
            $('declined').checked = false;
        }
        else if(elem.id == "authorized") {
            $('partially_authorized').checked = false;
            $('declined').checked = false;
        }
        else if(elem.id == "declined") {
            $('authorized').checked = false;
            $('partially_authorized').checked = false;
        }
    }

    Telaeris.enableCheckedButtons();
};

Telaeris.validateNumbers = function(form) {
    var hasNoError = true;

    if($F('cart_unit_id') == "" || $F('cart_unit_id') == null){
        hasNoError = false;
        $('cart_unit_id').addClassName("error");
    }
    else {
        $('cart_unit_id').removeClassName("error");
    }

    $$("#" + form.id + " input[type=text]").each(function(field) {
        if($F(field).match(/^[0-9]*$/)) {
            $(field).removeClassName("error");
        } else {
            $(field).addClassName("error");
            hasNoError = false;
        }
    });

    if(!hasNoError) {
        alert("Your request had some errors.");
    }

    return hasNoError;
};

Telaeris.changeEmail = function(id, email){
    if(email == '' || email == null) {
        $(id).value = email;
        $(id).focus();
    }
    else if($F(id) == null || $F(id) == '') {
        $(id).value = email;
    }
    else {
        $(id).value = $(id).value + ", " + email;
    }
    return false;
};

Telaeris.addCartItem = function(id){
    var qty_field = $('inventory_item_' + id + '_quantity');
    var quantity = $F('inventory_item_' + id + '_quantity');
    if(!quantity.match(/^[0-9]*$/) || quantity == "0") {
        alert("Quantity must be numeric and greater than 0");
        return false;
    }
    new Ajax.Request("/cart_items", {
        method: "post",
        parameters: "cart_item[inventory_item_id]=" + id + "&cart_item[quantity]=" + quantity
    });

    qty_field.value = '1';
    new Effect.Highlight(qty_field.id, {startcolor:'00ff00'});
};

Telaeris.addBasketItem = function(id){
    var qty_field = $('inventory_item_' + id + '_quantity');
    var quantity = $F('inventory_item_' + id + '_quantity');
    if(!quantity.match(/^[0-9]*$/) || quantity == "0") {
        alert("Quantity must be numeric and greater than 0");
        return false;
    }
    new Ajax.Request("/baskets/add_item/", {
        method: "post",
        parameters: "basket_item[inventory_item_id]=" + id + "&basket_item[quantity]=" + quantity
    });

    qty_field.value = '1';
    new Effect.Highlight(qty_field.id, {startcolor:'00ff00'});
};

Telaeris.validateEmails = function(elem){
    elem = $(elem);
    //take out spaces and semicolons, replcae with commas, replace multiple commas with a single comma
    var emails = $F(elem).gsub(/;| +/, ',').gsub(/,+/, ',').split(",");
    var invalids = [];
    var valids = [];

    emails.each(function(email){
        if(email.match(/^ *$/)) { return; }

        if(Telaeris.isValidEmail(email)) {
            valids.push(email);
        }
        else {
            invalids.push(email);
        }
    });

    if(invalids.length > 0) {
        var message = '';
        invalids.each(function(email){
            message += "* '" + email + "' is an invalid email address\n";
        });
        alert(message);
        return false;
    }
    else {
        $(elem).value = valids.join(", ");
        return true;
    }
};

Telaeris.isValidEmail = function(email){
    var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    if (filter.test(email)) { return true; }
    else { return false; }
};

Telaeris.submitMainForm = function(url){
    var form = $$('form.main_form')[0];
    var action = $(form).readAttribute('action');
    var jsMethod;
    if(action.match(/new/)) { jsMethod = 'post'; }
    else { jsMethod = 'put'; }

    if(url) {
        var callback = function() { window.location = url; };
    } else {
        var callback = null;
    }

    new Ajax.Request(action, {
        parameters: $(form).serialize(),
        method: jsMethod,
        onSuccess: callback
    });
};

Telaeris.submitThenGoTo = function(event){
    if(!Telaeris.formChanged) { return; }

    var confirmation = confirm("You're about to leave this page that has some unsaved changes, click CANCEL to remove changes or click OK to save changes.");
    if(confirmation) { Event.stop(event); }
    else { return; }

    var link = Event.element(event);
    var url = $(link).readAttribute('href');
    Telaeris.submitMainForm(url);
};

Telaeris.Event = {
    validateForm: function(event) {
        var form = Event.element(event);
        var validForm = false;

        validForm = Telaeris.validateForm(form);
        if(!validForm) { // if we have some invalid stuff, don't submit the form!
            Event.stop(event);
        }
    }
};

function clearTextArea(element) {
    if($(element).value == "Enter Description") { element.value = ""; }
}

function getContactTelephone(employee, telephone) {
    employee = $(employee);
    telephone = $(telephone);
    var nameID = $F(employee);
    if(nameID && $F(telephone).match(/^\s*$/)) {
        new Ajax.Request('/employees/telephone/' + nameID, {
            method: 'get',
            parameters: 'id=' + nameID,
            onComplete: function(transport){
                telephone.value = transport.responseText;
            }
        });
    }
}

Telaeris.isCtrlDown = function(event) {
    return event.ctrlKey || (event.modifiers & Event.CONTROL_MASK);
};

Event.observe(window, 'load', function() {
    $$('form.validate').each(function(form){
        Event.observe(form, 'submit', Telaeris.Event.validateForm);
    });

    Ajax.Responders.register({
        onCreate: function() {
            $('ajax_loading').show();
        },
        onComplete: function() {
            if(Ajax.activeRequestCount == 0) { $('ajax_loading').hide(); }
        }
    });

    if($('search') && $('search').down('form')) {
        Event.observe($('search').down('form'), 'submit', function(event){
            var input = $('search').down('input[name=q]');
            var query = $F(input);

            if(query.match(/^[#,\/]+$/)) {
                alert("Pound signs, commas, and slashes are special characters that are removed.\n\nPlease enter another term.");
                Event.stop(event);
                input.focus();
                return;
            }
            else if(query == '' || query == null) {
                alert("Please enter a search term");
                Event.stop(event);
                input.focus();
                return;
            }

        });
    }

    Event.observe(window, 'keydown', function(event){
        if(event.keyCode == 27) { // ESC
            $$('input').invoke('blur');
        } else if(String.fromCharCode(event.keyCode) == "S" && Telaeris.isCtrlDown(event)) {
            var li = $$('.save-button');
            if(li.length == 0) { return; }

            var saveButton = $(li[0]).down('a');
            saveButton.onclick();
            Event.stop(event);
        }
    });
});

Telaeris.enterToTab = function(element) {
    element = $(element);
    Event.observe(element, 'keydown', function(event){
        if(event.keyCode == 13 && element.readAttribute('type') != 'submit' && element.readAttribute('type') != "button"){
            Event.stop(event);
            var inputs = $A($(element).up('form').descendants()).select(function(elem){
                return $A(["INPUT", "SELECT", "TEXTAREA"]).include(elem.tagName) && $(elem).visible();
            });
            var index = inputs.indexOf(element) + 1;
            if(index && index < inputs.length) {
                inputs[index].focus();
            }
        }
    });
};


// Monitors a link with id='add-file-link' for the click event.
// When clicked, creates a new file input field for adding more files.
Telaeris.monitorAddFileLink = function (field_name) {
    jQuery('#add-file-link').click( function (event) {
        event.preventDefault();
        var fileFieldsContainer = jQuery("#file-upload-fields");
        var elementToAppend = "<p class=\"menu\"><label>Attach a File (Ex: Engineering Drawings):</label><input type=\"file\" name=\"" + field_name + "[]\"/></p>";
        // Append the new element to the bottom of the div below the other fields.
        fileFieldsContainer.append(elementToAppend);
    });
};

Telaeris.updateGroupFromPurchaser = function () {
    var purchaserCombo = jQuery('#material_request_purchaser_id');
    var purchaserId = purchaserCombo.val();
    var callback = function (data) {
        var groupId = data.group_id;
        jQuery('#material_request_group_id').val(groupId);
        jQuery('#material_request_group_id').animate({backgroundColor: '#FF3'}, 800);
        jQuery('#material_request_group_id').animate({backgroundColor: '#FFF'}, 1200);
    };
    jQuery.get("/material_requests/get_purchaser_group/" + purchaserId, {}, callback, 'json');

};
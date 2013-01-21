Splash = function () {
	var getId = function (el) {
		if (typeof el === 'string') {
			return el;
		}
		return $(el).attr('id');
	};
	return {
		buttonClick: function () {
			var id = getId(this);
			$('#' + id).blur();
			$('#right-col > div').hide();
			$('#info-' + id).show();
			$('#left-col a').removeClass('cool-button-selected');
			$('#' + id).addClass('cool-button-selected');
			$('#info-' + id + ' input.focus').focus();
			return false;
		},
		addHoverClass: function (id) {
			$('#' + id).addClass('cool-button-hover');
		},
		removeHoverClass: function (id) {
			$('#' + id).removeClass('cool-button-hover');
		},
		addSelectedClass: function (id) {
			$('#' + id).addClass('cool-button-selected');
		},
		removeSelectedClass: function (id) {
		},
		showForm: function () {
		
		},
		getId: function (el) {
			return getId(el);
		}
	
	}
}();

$(document).ready(function () {
	$.each(['material-tracker', 'job-track', 'vehicle-track', 'xp-track'], function () {
			$('#' + this).click(Splash.buttonClick);
			$('#' + this).hover(function () {
					var id = Splash.getId($(this));
			        Splash.addHoverClass(id);
      			}, 
      			function () {
					var id = Splash.getId($(this));
			        Splash.removeHoverClass(id);
      			}
    		);

		});

});


$(document).ready(function() {

	$('#default_css').change(function(){
	    if (this.checked) {
	    	$('#css_file').removeAttr('required').attr('disabled', '');
	    } else {
	    	$('#css_file').attr('required', '').removeAttr('disabled');
	    }
	});

	$('input[type=radio]').change(function(){
		gameExist();
	});


})

function postGame() {

	var name = $('#name').val();
	var operator = $('input[name=operator]:checked').val();
	var gamerange = $('input[name=gamerange]:checked').val();
	var gametype = $('input[name=gametype]:checked').val();

	
	alert("hi");
}


function gameExist() {
	var query = '/games/find?';
	if ($('input[name=operator]').prop('checked')) {
		console.log(jQuery.type($('input[name=operator]:checked').val()));
		console.log($('input[name=operator]:checked').val());
		query = query + 'operator=' + $('input[name=operator]:checked').val() + "&";
	}
	if ($('input[name=gamerange]').prop('checked')) {
		console.log(jQuery.type($('input[name=gamerange]:checked').val()));
		console.log($('input[name=gamerange]:checked').val());
		query = query + 'gamerange=' + $('input[name=gamerange]:checked').val() + "&";
	}
	if ($('input[name=gametype]').prop('checked')) {
		console.log(jQuery.type($('input[name=gametype]:checked').val()));
		console.log($('input[name=gametype]:checked').val());
		query = query + 'gametype_name=' + $('input[name=gametype]:checked').val() + "&";
	}


	console.log(jQuery.type(query));
	console.log(query);

	$.ajax({
		url: query,
		success: function(data) {
			if (data.length > 0) {
				$('#existWarning').show();
				$('#overwriteBox').show();
				$('#overwrite').attr('required', '');
			}
			else {
				$('#existWarning').hide();
				$('#overwriteBox').hide();
				$('#overwrite').removeAttr('required');
			}
		}
	});
}











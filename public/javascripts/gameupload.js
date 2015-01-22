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
	console.log("gameExist()");
	var query = '/games/find?';
	if ($('input[name=operator]:checked').val()) {
		console.log("operator checked");
		console.log($('input[name=operator]:checked').val());
		query = query + 'operator=' + $('input[name=operator]:checked').val() + "&";
	}
	if ($('input[name=gamerange]:checked').val()) {
		console.log("gamerange checked");
		console.log($('input[name=gamerange]:checked').val());
		query = query + 'gamerange=' + $('input[name=gamerange]:checked').val() + "&";
	}
	if ($('input[name=gametype]:checked').val()) {
		console.log("gametype checked");
		console.log($('input[name=gametype]:checked').val());
		query = query + 'gametype_name=' + $('input[name=gametype]:checked').val() + "&";
	}

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











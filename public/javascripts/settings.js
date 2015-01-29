function changeField(field) {
	switch(field) {
		case "firstname":
			$('#firstnameCol').html('<input type="text" placeholder="Neuer Name"  class="input-lg" id="firstnameInput" name="firstname"/>');
			$('#firstnameBtn').attr('onclick', 'changeUser("firstname");').attr('value', 'Speichern');
			break;
		case "email":
			$('#emailCol').html('<input type="text" placeholder="Neue Email" class="input-lg" id="emailInput" name="email"/>');
			$('#emailBtn').attr('onclick', 'changeUser("email");').attr('value', 'Speichern');
			break;
		case "password":
			$('#passwordCol').html('<input type="password" placeholder="Neues Passwort" name="newpassword" class="input-lg" id="newpwInput"/>').show();
            $('#oldpwInput').show();
			$('#passwordBtn').attr('onclick', 'changeUser("password");').attr('value', 'Speichern');
			break;
		default:
			break;
	}
}

function changeUser(field) {

	$.ajax({
		url: "/users/"+$("#myProfil").attr("user"),
		type: "PUT",
		data: {
			firstname: $('#firstnameInput').val(),
			email: $('#emailInput').val(),
			oldpassword: $('#oldpwInput').val(),
			newpassword: $('#newpwInput').val(),
		},
		success: function() {
			if (field == "password") {
				alert("Passwort wurde geändert.");
			}
			location.reload();
		},
		error: function(xhr, status, text) {
			if (xhr.status == 401) {
				alert("Du hast dein altes Passwort falsch eingegeben, es wurde nicht geändert.");
			}
			else { 
				alert("Es ist etwas schief gelaufen, bitte versuch es später noch einmal");
			}
			location.reload();
		}
	});
}


function deleteUser(u_id) {
	var r = confirm("Willst du wirklich dein Profil löschen? Dein ganzer Spielstand geht dann verloren.");
	if (r == true) {
		$.ajax({
			url: "/users/"+u_id,
			type: "DELETE",
			error: function() {
				alert("Es ist etwas schief gelaufen, bitte versuch es später noch einmal");
				location.reload();
			},
			success: function() {
				window.location.assign("/logout");
			}
		})
	} else {
		location.reload();
	}
}
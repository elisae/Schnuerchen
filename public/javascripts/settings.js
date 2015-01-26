function changeField(field) {
	switch(field) {
		case "firstname":
			$('#firstnameCol').html('Neuer Name: <input type="text" id="firstnameInput" name="firstname"></input>');
			$('#firstnameBtn').attr('onclick', 'changeUser("firstname");').attr('value', 'Speichern');
			break;
		case "email":
			$('#emailCol').html('Neue Adresse: <input type="text" id="emailInput" name="email"></input>');
			$('#emailBtn').attr('onclick', 'changeUser("email");').attr('value', 'Speichern');
			break;
		case "password":
			$('#passwordCol').html('<p>Altes Passwort: <input type="password" name="oldpassword" id="oldpwInput"></input></p><p>Neues Passwort: <input type="password" name="newpassword" id="newpwInput"></input></p>');
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
			location.reload();
		},
		error: function() {
			alert("Es ist etwas schief gelaufen, bitte versuch es später noch einmal");
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
				window.location.assign("/");
			}
		})
	} else {
		location.reload();
	}
}
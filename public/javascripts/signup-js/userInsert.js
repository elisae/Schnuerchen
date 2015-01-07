$(function() {

    var letsGo = $("#letsGo");
    letsGo.hide();

    $("input,textarea").jqBootstrapValidation({
        preventSubmit: true,
        submitError: function($form, event, errors) {
            // additional error messages or events
        },
        submitSuccess: function($form, event) {
            event.preventDefault(); // prevent default submit behaviour
            // get values from FORM

            var username = $("input#username").val();
            var firstname = $("input#firstname").val();
            var password = $("input#password").val();
            var email = $("input#email").val();


/* ---------------------------------kann man das so machen?------------------*/
            $.ajax({
                url: "/api/user",
                type: "POST",
                data: {
                    username: username,
                    firstname: firstname,
                    email: email,
                    password: password
                },
                cache: false,
                success: function() {
                    // Success message
                    $('#success').html("<div class='alert alert-success'>");
                    $('#success > .alert-success').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;")
                        .append("</button>");
                    $('#success > .alert-success')
                        .append("<strong>Jetzt bist du registriert und kannst spielen. </strong>");
                    $('#success > .alert-success')
                        .append('</div>');
                    letsGo.show();
                    //clear all fields
                    $('#contactForm').trigger("reset");
                },
                error: function() {
                    // Fail message
                    $('#success').html("<div class='alert alert-danger'>");
                    $('#success > .alert-danger').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;")
                        .append("</button>");
                    $('#success > .alert-danger').append("<strong>Sorry " + firstname + ", die Registrierung hat leider nicht funktioniert</strong>");
                    $('#success > .alert-danger').append('</div>');

                    //clear all fields
                    $('#contactForm').trigger("reset");
                }
            });


/*------------------------------------------------------------------------------*/

        },
        filter: function() {
            return $(this).is(":visible");
        }
    });

    $("a[data-toggle=\"tab\"]").click(function(e) {
        e.preventDefault();
        $(this).tab("show");
    });

    var username;
    var password;

    $("#registerButton").click(function(){
        username = $("input#username").val();
        password = $("input#password").val();
    });


    letsGo.click(function(){
        $.ajax({
            url: "/login",
            type: "POST",
            data: {
                username: username,
                password: password
            },
            cache: false,
            success: function() {
                window.location = "/games";
            }
        });
    });


});


/*When clicking on Full hide fail/success boxes */
$('#name').focus(function() {
    $('#success').html('');
});


/**
 * Created by manuelneufeld on 17/11/14.
 */

var answerResponse = $("#answerResponse");

answerResponse.hide();

function feedbackRight(){
    answerResponse.css("backgroundColor", "#00E676");
    answerResponse.fadeIn("fast", function(){
        $(this).fadeOut("fast");
    });
    console.log("richtige antwort");
}

function feedbackWrong(){
    answerResponse.css("backgroundColor", "#FF5252");
    answerResponse.fadeIn("fast", function(){
       $(this).fadeOut("fast");
    });
    console.log("falsche antwort");
}



$(document).ready(function(){

    var start_div = $("#start_div");
    var pause_div = $("#pause_div");
    var game_div = $("#game_div");
    var end_game_div = $("#end_game_div");

    $("html, body").animate({ scrollTop: $("#game").scrollTop() }, 500);

    $("#button_start").click(function(){
        $(pause_div).hide();
        $(start_div).slideUp("slow");
    });

    $("#button_to_start").click(function(){
        $(start_div).slideDown("slow");

    });

    $("#button_leave").click(function(){
        //game_div.hide();
        end_game_div.show();
    });

});

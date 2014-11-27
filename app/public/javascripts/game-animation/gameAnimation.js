/**
 * Created by manuelneufeld on 17/11/14.
 */
$(document).ready(function(){
/*
   var leave = $(".end");
   var game_div = $("#game_div");
   var selection = $("#selection");
   var start_div = $("#start_div");

    $(leave).hide();
    $(game_div).hide();
    $(selection).hide();

    $(".start").click(function(){
       $(start_div).hide();
       $(game_div).slideDown("slow");
       $(game_div).css("background", "white");
       $(".end").fadeIn("slow");
    });

    $(leave).click(function(){
       $(game_div).fadeOut("slow", function(){
           $(start_div).fadeIn("slow");
       })
    });
    */

    var start_div = $("#start_div");
    var pause_div = $("#pause_div");
    var game_div = $("#game_div");
    var end_game_div = $("#end_game_div");



    $("#button_start").click(function(){
       $(pause_div).hide();
       $(start_div).slideUp("slow");
    });
/*
    $("#button_pause").click(function(){
        $(pause_div).fadeIn("1500");
    });

    $("#button_continue").click(function(){
        $(pause_div).fadeOut("fast");
    });
*/
    $("#button_to_start").click(function(){
        $(start_div).slideDown("slow");

    });

    $("#button_leave").click(function(){
       //game_div.hide();
       end_game_div.show();
    });

    //set_visibility('end_game_div', true);



});
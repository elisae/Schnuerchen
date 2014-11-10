
$(document).ready(function(){

    var operators = $(".operators");
    var range = $(".range");

    var numberrange = $("#numberrange");
    var game = $("#game");

    var operatorClick = false;
    var numberrangeClick = false;

    $(operators).click(function(){
        if(operatorClick){
            $(game).slideUp("slow");
            $(numberrange).slideUp("slow");
            $(numberrange).slideDown("slow");
        }else{
            operatorClick = true;
           $(numberrange).slideDown("slow");
           $(game).slideUp("slow");
        }
    });

    $(range).click(function(){
        if(numberrangeClick){
            $(game).slideUp("slow");
            $(game).slideDown("slow");
        }else{
            numberrangeClick = true;

            $(game).slideDown("slow");
        }
    });
});
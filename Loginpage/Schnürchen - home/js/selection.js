
$(document).ready(function(){

    var operators = $(".operators");
    var range = $(".range");
    var games = $(".games");

    var numberrange = $("#numberrange");
    var game = $("#game");

    var operatorClick = false;
    var numberrangeClick = false;

    var info = $("#selection-info");

    $(operators).click(function(event){
        if(operatorClick){
            $(game).slideUp("slow");
            $(numberrange).slideUp("slow",
                function callback(){
                    operatorCheck(event);
                });

            $(numberrange).slideDown("slow");
        }else{
            operatorClick = true;
            operatorCheck(event);
            $(numberrange).slideDown("slow");
            $(game).slideUp("slow");
        }
    });

    $(range).click(function(event){
        if(numberrangeClick){
            $(game).slideUp("slow",
                function callback(){
                    rangeCheck(event);
                });
            $(game).slideDown("slow");
        }else{
            numberrangeClick = true;
            rangeCheck(event);
            $(game).slideDown("slow");
        }
    });

    operators.hover(function(event){
        switch(event.target.id){
            case "plus":
                info.html("Mit Plus rechnen");break;
            case "minus":
                info.html("Mit Minus rechnen");break;
            case "multi":
                info.html("Mit Mal rechnen");break;
            case "division":
                info.html("Mit Geteilt rechnen");break;
            case "all-operators":
                info.html("Mit mehreren Rechenzeichen rechnen");break;
        }
    });

    range.hover(function(event){
        switch(event.target.id){
            case "range-ten":
                info.html("Zahlenbereich 1-10");break;
            case "range-twenty":
                info.html("Zahlenbereich 1-20");break;
            case "range-hundred":
                info.html("Zahlenbereich 1-100");break;
        }
    });

    games.hover(function(event){
        switch(event.target.id){
            case "onTime":
                info.html("Auf Zeit spielen");break;
            case "onScale":
                info.html("Mit der Waage spielen");break;
            case "onScore":
                info.html("Erziele möglichst viele Punkte");break;
        }
    });
});

function operatorCheck(event){
    if(event.target.id == "multi" || event.target.id == "division"){
        $("#range-hundred").hide();
    }else{
        $("#range-hundred").show();
    }
}

function rangeCheck(event){
    if(event.target.id == "range-hundred"){
        $("#onScale").hide();
    }else{
        $("#onScale").show();
    }
}
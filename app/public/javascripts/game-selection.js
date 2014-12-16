$(document).ready(function(){

    var operators = $(".operators");
    var range = $(".range");
    var games = $(".games");

    var selectionBtn = $(".selection-button");

    var firstParentId = null;
    var secondParentId = null;

    var operatorsShown = false;
    var rangeShown = false;

    var reqUrl = null;

    var slideTime = 500;


    operators.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").slideUp(slideTime);
        }
        if(operatorsShown){
            $("#"+firstParentId+"range").slideUp(slideTime,function(){
                firstParentId = event.target.id;
                $("#"+firstParentId+"range").slideDown(slideTime);
            });
        }else{
            firstParentId = event.target.id;
            $("#"+firstParentId+"range").slideDown(slideTime);
            operatorsShown = true;
        }
    });

    range.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").slideUp(slideTime,function(){
                secondParentId = event.target.id;
                $("#"+secondParentId+"games").slideDown(slideTime);
            });
        }else{
            secondParentId = event.target.id;
            $("#"+secondParentId+"games").slideDown(slideTime);
            rangeShown = true;
        }

    });

    selectionBtn.hover(function(event){
        var info = $("#selection-info");
        var target = $("#"+event.target.id);
        info.html(target.attr("long_descr"));

    });
});
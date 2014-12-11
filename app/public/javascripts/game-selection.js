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


    operators.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").slideUp('slow');
        }
        if(operatorsShown){
            $("#"+firstParentId+"range").slideUp('slow',function(){
                firstParentId = event.target.id;
                $("#"+firstParentId+"range").slideDown('slow');
            });
        }else{
            firstParentId = event.target.id;
            $("#"+firstParentId+"range").slideDown('slow');
            operatorsShown = true;
        }
    });

    range.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").slideUp('slow',function(){
                secondParentId = event.target.id;
                $("#"+secondParentId+"games").slideDown('slow');
            });
        }else{
            secondParentId = event.target.id;
            $("#"+secondParentId+"games").slideDown('slow');
            rangeShown = true;
        }

    });

    selectionBtn.hover(function(event){
        var info = $("#selection-info");
        var target = $("#"+event.target.id);
        info.html(target.attr("long_descr"));

    });
});
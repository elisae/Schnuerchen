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

    var indicatorOperation = $("#indicatorOperation");
    var indicatorRange = $("#indicatorRange");

    indicatorOperation.hide();
    indicatorRange.hide();


    operators.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").fadeOut(slideTime);
        }
        if(operatorsShown){
            $("#"+firstParentId+"range").fadeOut(slideTime,function(){
                firstParentId = event.target.id;
                $("#"+firstParentId+"range").fadeIn(slideTime);
                indicatorRange.hide();
            });
        }else{
            firstParentId = event.target.id;
            $("#"+firstParentId+"range").fadeIn(slideTime);
            operatorsShown = true;
        }

        $(this).append(indicatorOperation);
        indicatorOperation.show(slideTime);
    });

    range.click(function(event){
        if(rangeShown){
            $("#"+secondParentId+"games").fadeOut(slideTime,function(){
                secondParentId = event.target.id;
                $("#"+secondParentId+"games").fadeIn(slideTime);

            });
        }else{
            secondParentId = event.target.id;
            $("#"+secondParentId+"games").fadeIn(slideTime);
            rangeShown = true;

        }

        $(this).append(indicatorRange);
        indicatorRange.show();

    });

    selectionBtn.hover(function(event){
        var info = $("#selection-info");
        var target = $("#"+event.target.id);
        info.html(target.attr("long_descr"));

    });
});
/**
 * Created by manuelneufeld on 10/12/14 and kenny.
 */



/* ----------------------------TROPHIES---------------------------- */




/* ----------------------------Ende Trophies---------------------------- */



var colours = ['hovered'];
var friends = $('#friendlist ul li');
var friendProfil = $("#friendProfil");


/* ----------------------------Freundessuche---------------------------- */

var input = $("#friendsearch");
var responseList = $("#responseList");
var friendResponse = $("#friendResponse");

function searchFriend(){
    var query = input.val();

    if(query.length==0){
        responseList.html("");
        friendResponse.hide();
    }else{
        $.get(
            "/search",
            {query:query},
            function(res){
                var resultString = "";
                if(res.length != 0){
                    for(i=0;i<res.length;i++){
                        var str =  res[i]["username"];
                        resultString = resultString + "<a href='/users/"+res[i]["id"]+"/profil'><li><b>"+ str.substring(0,query.length) + "</b>" + str.substring(query.length,str.length)+"</li></a>"
                    }
                }else{
                    resultString = "<h4>Leider können wir nichts finden</h4>";
                }
                friendResponse.show();
                responseList.html(resultString);
            }
        );
    }
}




$(document).ready(function() {

    friendProfil.hide();

    friends.hover(function() {
        $(this).addClass(colours[0]);
    }, function() {
        $(this).removeClass(colours[0]);
    });

    $("#hideFriendProfil").click(function(){
        friendProfil.fadeOut("slow");
    });

    /* This function gets called when you add a Friend */

    var addBtn = $(".addBtn");

    addBtn.click(function(event){
        $.post(
            "/add",
            {f_id:event.target.id},
            function(){
                location.reload();
            }
        )
    });

    /* This function gets called when you remove a Friend */

    var unfriendBtn = $(".unfriendBtn");

    unfriendBtn.click(function(event){
        $.post(
            "/unfriend",
            {f_id:event.target.id},
            function(){
                location.reload();
            }
        )
    });

    /* This function gets called when you hover over a Trophy */

    var gametrophies = $(".gametrophies > .trophy");
    var timeout = null;

    gametrophies.hover(function(event){

        var target = $(event.target);
        var targetClass = target.attr("class");
        var targetMinScore = target.attr("min_score");
        var targetPod = Number(target.attr("data-pod"));

        timeout = setTimeout(function(){
            $.get(
                "/userscores",
                {g_id: target.parent().attr("id"),
                 u_id: $("#myProfil").attr("user")},
                function (res,statusText,xhr) {
                    if(xhr.status == 200){
                        if(target.hasClass("won")){
                            switch(targetPod){
                                case 1:
                                    console.log("Goldmedaille! Gibts ab " + targetMinScore + " Punkten. Dein Punkte:" + res[0]["score"]);
                                    break;
                                case 2:
                                    target.append("<div> Silbermedaille! Gibts ab " + targetMinScore + " Punkten.<br> Deine Punkte " +  res[0]["score"] + "<br>Für Gold brauchst:" + target.next().attr("min_score") + "</div>")
                                    break;
                                case 3:
                                    target.append("<div> Bronzemedaille! Gibts ab " + targetMinScore + " Punkten.<br> Deine Punkte " +  res[0]["score"] + "<br>Für Silber brauchst:" + target.next().attr("min_score") + "</div>")
                                    console.log();
                                    break;
                            }
                        }else if(target.hasClass("notwon")){
                            switch(targetPod){
                                case 1:
                                    console.log("Du hast diese Medaille noch nicht. Du brauchst:" + targetMinScore );
                                    break;
                                case 2:
                                    console.log("Du hast diese Medaille noch nicht. Du brauchst:" + targetMinScore );
                                    break;
                                case 3:
                                    console.log("Du hast diese Medaille noch nicht. Du brauchst:" + targetMinScore );
                                    break;
                            }
                        }
                    }else if(xhr.status == 204){
                        console.log("(͡° ͜ʖ ͡°)");
                    }
                }
            )
        },100);
    },function(){
        clearTimeout(timeout);
        $(".trophy > div").hide();
    });
});

/* ---------------------------- ENDE Freundessuche---------------------------- */
/*
 * Created by manuelneufeld on 10/12/14 and kenny.
 */


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
        // $.post(
        //     "/friendships",
        //     {f_id:event.target.id},
        //     function(){
        //         location.reload();
        //     }
        // )
        $.ajax({
            url: "/friendships",
            type: "POST",
            data: {
                f_id: event.target.id
            },
            success: function(){
                location.reload();
            }});
    });

    /* This function gets called when you remove a Friend */

    var unfriendBtn = $(".unfriendBtn");

    unfriendBtn.click(function(event){
        // $.post(
        //     "/unfriend",
        //     {f_id:event.target.id},
        //     function(){
        //         location.reload();
        //     }
        // )
        $.ajax({
            url: "/friendships/" + event.target.id,
            type: "DELETE",
            data: {
                f_id: event.target.id
            },
            success: function(){
                location.reload();
            }});
    });

    /* Diese Funktion wird gerufen, wenn über eine Trophae auf der eigenen Profilseite gehovert wird. */

    var gametrophiesuser = $(".gametrophiesuser > .trophy");
    var timeout = null;

    gametrophiesuser.hover(function(event){

        var target = $(event.target);
        var targetScore = target.attr("with_score");
        var targetMinScore = target.attr("min_score");
        var targetPod = Number(target.attr("data-pod"));
        var cache = target.children("div");

        if(!cache.length){ //Überprüft, ob das target bereits ein aufgebautes Kind Div hat. Wenn ja muss kein Request mehr gesendet werden.
                timeout = setTimeout(function(){
                    $.get(
                        "/userscore",
                        {g_id: target.parent().attr("id"),
                         u_id: $("#myProfil").attr("user"),
                         pod: targetPod},
                        function (res,statusText,xhr) {
                            console.log(res.length);
                                if (xhr.status == 200) {
                                    var str = (res[0]["score"] == 0) ? "Du hast die Medaille nicht." :"Deine Punkte " + res[0]["score"];
                                    switch (targetPod) {
                                            case 1:
                                                target.append("<div class='scoreWindow' id='profilHover'> Goldmedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten. <br>" + str +" </div>");
                                                break;
                                            case 2:
                                                target.append("<div class='scoreWindow' id='profilHover'> Silbermedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten.<br> "+ str + "</div>")
                                                break;
                                            case 3:
                                                target.append("<div class='scoreWindow' id='profilHover'> Bronzemedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten.<br>" + str +"</div>")
                                                break;
                                        }
                                }
                        }
                    )
                },100);
        }else{
            cache.show();
        }
    },function(){
        clearTimeout(timeout);
        $(".trophy > div").hide();
    });

    /* Diese Funktion wird gerufen, beim hovern über eine Trophae auf einer Freundesseite. */

    var gametrophiesfriend = $(".gametrophiesfriend > .trophy");

    gametrophiesfriend.hover(function(event){

        var target = $(event.target);
        var targetScore = target.parent().attr("with_score");
        var targetMinScore = target.attr("min_score");
        var targetPod = Number(target.attr("data-pod"));
        var cache = target.children("div");


        if(!cache.length){ //Überprüft, ob das target bereits ein aufgebautes Kind Div hat. Wenn ja muss kein Request mehr gesendet werden.
            timeout = setTimeout(function(){
                $.get(
                    "/userscore",
                    {g_id: target.parent().attr("id"),
                     u_id: $("#myProfil").attr("user"),
                     pod: targetPod},
                    function (res,statusText,xhr) {
                        console.log(res.length);
                        if (xhr.status == 200) {
                            var friendName = "<span id='usernameHover'>" + $("#userName").html() + "</span>";
                            var str = (targetScore == 0) ? friendName + "  hat die Medaille noch nicht." : friendName + "hat " + targetScore + "Punkte in dem Spiel.";
                            var str2 = (res[0]["score"] == 0) ? "Du hast die Medaille noch nicht." : "Deine Punkte in dem Spiel: " + res[0]["score"];
                            switch (targetPod) {
                                case 1:
                                    target.append("<div class='scoreWindow' id='userHover'> Goldmedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten.<br> "+ str + "  <br> Deine Punkte: " + res[0]["score"] + "</div>");
                                    break;
                                case 2:
                                    target.append("<div class='scoreWindow' id='userHover'> Silbermedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten.<br> " + str + "<br> Deine Punkte " + res[0]["score"] + "</div>")
                                    break;
                                case 3:
                                    target.append("<div class='scoreWindow' id='userHover'> Bronzemedaille!<br> Gibts ab " + res[1]["min_score"] + " Punkten.<br> "+ str +" <br> Deine Punkte " + res[0]["score"] + "</div>")
                                break;
                            }
                        }
                    }
                )
            },100);
        }else{
            cache.show();
        }
    },function(){
        clearTimeout(timeout);
        $(".trophy > div").hide();
    });
});

// ---------------------------- ENDE Freundessuche---------------------------- 
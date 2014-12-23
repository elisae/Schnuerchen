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


        /*----------------------------------keine ahnung welche die richtige is--------------------------*/
        $.get(
            "/search/",
            {query:query},
            function(msg){
                var resultString = "";
                if(msg.length != 0){
                    for(i=0;i<msg.length;i++){
                        var str =  msg[i]["username"];
                        resultString = resultString + "<a href='/users/"+msg[i]["id"]+"/profil'><li><b>"+ str.substring(0,query.length) + "</b>" + str.substring(query.length,str.length)+"</li></a>"
                    }
                }else{
                    resultString = "<h4>Leider können wir nichts finden</h4>";
                }
                friendResponse.show();
                responseList.html(resultString);

            }
        );
    }


    $.get(
        "/search/"+query,
        function(msg){
            var resultString = "";

            for(i=0;i<msg.length;i++){
                var str =  msg[i]["username"];
            resultString = resultString + "<a href='/users/"+msg[i]["id"]+"/profil'><li class='shownFriends hovered'><b>"+ str.substring(0,query.length) + "</b>" + str.substring(query.length,str.length)+"</li></a>"
            }
            friendResponse.show();
            responseList.html(resultString);
            var listElements = document.getElementsByClassName("addFriend");
            for(i=0;i<listElements.length;i++){
                listElements[i].onclick = "addFriend()";
            }

        }
    );
}   /*---------------------------------------kenny muss das fixen :DD --------------------------*/




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
            "/add/"+event.target.id,
            function(){
                location.reload();
            }
        )
    });

    /* This function gets called when you remove a Friend */

    var unfriendBtn = $(".unfriendBtn");

    unfriendBtn.click(function(event){
        $.post(
            "/unfriend/"+event.target.id,
            function(){
                location.reload();
            }
        )
    });
});

/* ---------------------------- ENDE Freundessuche---------------------------- */
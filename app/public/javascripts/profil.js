/**
 * Created by manuelneufeld on 10/12/14 and kenny.
 */


var colours = ['hovered'];
var friends = $('#friendlist ul li');
var friendProfil = $("#friendProfil");


/* Freundessuche */

var input = $("#friendsearchinput");
var responseList = $("#responseList");
var friendResponse = $("#friendResponse");

function searchFriend(){
    var query = input.val();

    if(query.length==0){
        responseList.html("");
        friendResponse.hide();
    }

    $.get(
        "/search/"+query,
        function(msg){
            var resultString = "";

            for(i=0;i<msg.length;i++){
                var str =  msg[i]["username"];

                resultString = resultString + "<li><a href='/users/"+msg[i]["id"]+"/profil'><b>"+ str.substring(0,query.length) + "</b>" + str.substring(query.length,str.length)+"</a></li>"
            }
            responseList.html(resultString);
        }
    );
};



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

    /* This function gets called if you add a Friend */

    var addBtn = $(".addBtn");

    addBtn.click(function(event){
        $.post(
                "/add/"+event.target.id,
            function(){
                alert("Anfrage geschickt");
            }
        )
    });

});
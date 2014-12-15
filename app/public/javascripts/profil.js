/**
 * Created by manuelneufeld on 10/12/14 and kenny.
 */


var colours = ['hovered'];
var friends = $('#friendlist ul li');
var friendProfil = $("#friendProfil");


/* Freundessuche */

var input = $("#friendsearchinput");

function searchFriend(){
    var query = input.val();

    $.get(
        "/search/"+query,
        function(msg){
            console.log("lol");
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

    friends.click(function(){
       friendProfil.fadeIn("slow");
    });

    $("#hideFriendProfil").click(function(){
        friendProfil.fadeOut("slow");
    });


});
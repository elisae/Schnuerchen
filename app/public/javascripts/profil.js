/**
 * Created by manuelneufeld on 10/12/14.
 */


var colours = ['hovered'];
var friends = $('#friendlist ul li');
var friendProfil = $("#friendProfil");

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
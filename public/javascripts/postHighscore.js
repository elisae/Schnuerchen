/**
 * Created by manuelneufeld on 11/12/14.
 */


var trophy = document.createElement("div");

var end_game_div = document.getElementById("end_game_div");


function postScore(score, g_id){
    $.ajax({
        url: "/score",
        type: "POST",
        data: {
            score: score,
            g_id: g_id
        },
        cache: false,
        success: function (data) {
            console.log("Highscore posted");
            if(data.pod =! 0){
                console.log("got trophy");
                trophy.id = "trophyWon";
            }else{
                trophy.id = "noTrophy";
                console.log("got no trophy");
            }
        },
        error: function () {
            console.log("Highscore not posted");
            trophy.id = "noTrophy";
        }
    });

    end_game_div.appendChild(trophy);
}

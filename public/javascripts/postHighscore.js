/**
 * Created by manuelneufeld on 11/12/14.
 */

function postScore(score, g_id){

    var trophy_id = "noTrophy";
    var trophy_pod = "0";
    var newScore;

        $.ajax({
        url: "/scores",
        type: "POST",
        data: {
            score: score,
            g_id: g_id
        },
        cache: false,
        dataType: 'json',
        success: function (data) {
            if (data.pod > 0) {
                trophy_id = "trophyWon";
            }
            trophy_pod = data.pod;

            if(data.new_high == true){
                newScore = document.createElement("h3");
                newScore.innerText = "Neuer Highscore!";
            }
        },
        error: function () {
            console.log("Highscore not posted");
        }
    }).done( function() {
        $('#end_game_stats h1').after('<div id="'+trophy_id+'" data-pod="'+trophy_pod+'"></div>').after(newScore);
    });
}

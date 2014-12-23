/**
 * Created by manuelneufeld on 11/12/14.
 */


function postScore(score, g_id){
    $.ajax({
        url: "/score",
        type: "POST",
        data: {
            score: score,
            g_id: g_id
        },
        cache: false,
        success: function () {
            console.log("hat funktioniert");
        },
        error: function () {
            console.log("hat nicht funktioniert");
        },
    })
}

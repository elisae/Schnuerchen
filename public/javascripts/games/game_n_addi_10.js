/**
 * Created with JetBrains WebStorm.
 * User: Willi.Minet
 * Date: 18.11.14
 * Time: 22:55
 * Version: 1.6
 * To change this template use File | Settings | File Templates.
 *
 *
 * -------------------------------------------
 * * 1.3
 * button_start in start_div
 * button_continue in pause_div
 * game in game_div
 * button_back_to_start in end_game_div
 *1.4
 *show() - hide() works
 * can't go to the next task when tip-field is empty
 * random() bug fixed
 * 1.5
 * better fake results
 * countdown before the gme starts
 *1.6
 *better stop_watch
 *fixed end_game_stats
 * red and green flashes in the game
 */


//-------------------------------------SETTINGS----------------------------------\\
var quantity = 20;                  //How many tasks are there
var lower_bound = 1;                //lower number bound
var upper_bound = 5;  //100       //upper number bound

var score_right = 10;               //Points for a right answer
var score_wrong = 5;                //Points for a wrong answer
var score_time_influence = 7000;    //score-formula: counter_right * score_right - counter_wrong * score_wrong - time_needed/score_time_influence
//-----------------------------------END SETTINGS----------------------------------\\


//---------------------------------------HTML STRUCTURE-----------------------------
/*
 *       // if your game div has another id: change id at the begin of the init-function and it should work ;)
 *   <div id='game_div'>
 *       <input type="button" id='button_start' value="Spiel starten" onclick="javascript:run_game()"/>
 *       <input type="button" id='button_leave' value="Spiel beenden" onclick="javascript:leave_game()"/>
 *       <input type="button" id='button_pause' value="Pause" onclick="javascript:pause_game()"/>
 *       <table id='stat_table'>
 *           <tr>
 *               <td style='border: double'>Anz. Richtig</td>
 *               <td style='border: double'>Anz. Falsch</td>
 *               <td id='score1' style='border: double'>Punkte</td>
 *           </tr>
 *           <tr>
 *               <td id='c_r' style='border: double'>"+counter_right+"</td>
 *               <td id='c_w' style='border: double'>"+counter_wrong+"</td>
 *               <td id='score' style='border: double'>"+score+"</td>
 *           </tr>"
 *       <table>
 *
 *       <p id="game_line">
 *           <span id='z1'></span> +
 *           <span id='z2'></span> =
 *           <input type="text" id='tip' onkeyup="javascript:clean()" onkeydown="javascript:clean()"/>
 *       </p>
 *
 *       <p id='result_line'>
 *           Los Geht's
 *       </p>
 *
 *       <p id='stop_watch'>
 *           <span id='sw_min'></span>:
 *           <span id='sw_s'></span>:
 *           <span id='sw_ms'></span>
 *       </p>
 *
 *   </div>
 *
 *
 *
 */
//-----------------------------------END HTML STRUCTURE-----------------------------



//-----------------------------------DECLARATIONS-----------------------------------\\
var game_is_running = false;
var game_is_paused = false;
var game_left = false;

var score = 0;
var counter = 0;
var counter_right = 0;
var counter_wrong = 0;
var progress = 0;
var step = 100 / quantity;

var pause_time = 0;
var pause_start = 0;
var score_just_updated = false;
var score_update_cooler;

var start = new Date();
var start_time = start.getTime();
var time_needed;

var z1_n = 0;
var z2_n = 0;
var result = 0;


//----------------------------------END DECLARATIONS----------------------------------\\


$(document).ready(function(){
    init_game();

});

function create_numbers(){
    z1_n = Math.floor(Math.random() * (upper_bound - lower_bound + 1)) + lower_bound;
    z2_n = Math.floor(Math.random() * (upper_bound - lower_bound + 1)) + lower_bound;
    result = z1_n + z2_n;
}


//var stopwatch_interval = setInterval('stopwatch()',95);


function init_game(){
    //-----------------------change id here-----------------------------------------|
    var game = document.getElementById("game");
    var game_div = document.getElementById('game_div');//<--------------------------|
    var start_div = document.getElementById('start_div');//<------------------------|
    var pause_div = document.getElementById('pause_div');//<------------------------|
    var end_game_div = document.getElementById('end_game_div');//<------------------|




    end_game_div.innerHTML="<div id ='end_game_stats'>" +
        "<h1>Du hast <span id='results_right'></span> richtig</h1><p>leider auch <span id='results_wrong'></span> falsch</p>" +
    "                   <p>Zeit: <span id='results_time'></span> Sekunden</p>" +
    "                   <p>Punkte: <span id='results_score'></span></p> " +
    "                   <p id='result_message'></p></div>";

        <!-- Start Stuff -->

    var button_start = document.createElement("div");
    button_start.id ='button_start';
    button_start.className = "btn btn-lg btn-xl btn-outline start";
    button_start.innerHTML = "Spiel starten";
    //button_start.onclick=run_game;
    button_start.onclick = countdown;
    start_div.appendChild(button_start);



        <!-- CountDown Stuff -->

    var countdown_div = document.createElement("div");
    countdown_div.id = "countdown_div";

    var countdown_text = document.createElement("h1");
    countdown_text.id = "countdown_text";
    countdown_text.innerHTML = "Los gehts in";
    countdown_div.appendChild(countdown_text);

    var countdown_info = document.createElement("h1");
    countdown_info.id = "countdown_info";

    countdown_div.appendChild(countdown_info);
    game.appendChild(countdown_div);



        <!-- Game Stuff -->

/*    var points = document.createElement('h2');
    points.id = 'Punkte';
    points.className = 'game-elements';
    points.innerHTML = 'Punkte: ' + score;
    game_div.appendChild(points);*/

    var result_line = document.createElement('h3');
    result_line.id='result_line';
    result_line.className = "game-elements";
    result_line.innerHTML="Los Gehts!";
    document.getElementById('game_div').appendChild(result_line);

    var score_line = document.createElement('p');
    score_line.id='score_line';
    score_line.innerHTML="Punkte: <span id='score_a'>"+score+"</span>";
    game_div.appendChild(score_line);

    var game_line = document.createElement('h1');
    game_line.id = 'game_line';
    game_line.className = "game-elements";
    game_line.innerHTML = "<span id='z1'></span><span id='operator'> + </span><span id='z2'></span> = ";
    game_div.appendChild(game_line);

    var user_tip = document.createElement('input');
    user_tip.type = "text";
    user_tip.id = 'tip';
    user_tip.className = "game-elements";
    user_tip.className = "input-lg";
    user_tip.placeholder = "Ergebnis";
    user_tip.onkeydown = clean;
    user_tip.onkeyup = clean;
    game_line.appendChild(user_tip);
    user_tip.focus();

   /* game_div.appendChild("<img src='/images/games/return-symbol.png' id='return'/>");*/

    var progress_bar = document.createElement('div');
    progress_bar.id='progress_bar';
    var bar = document.createElement('div');
    bar.id='bar';
    var percent = document.createElement('div');
    percent.id='percent';


    bar.appendChild(percent);
    progress_bar.appendChild(bar);
    game_div.appendChild(progress_bar);

    step.toFixed(3);
    document.getElementById('bar').style.width = progress.toFixed(1) + "%";
    document.getElementById('percent').innerHTML = progress.toFixed(1) + "%";

    var stop_watch = document.createElement('h2');
    stop_watch.id='stop_watch';
    stop_watch.className = "game-elements";
    stop_watch.innerHTML = "<span id='sw_min'>0</span>:<span id='sw_s'>00</span>";
    game_div.appendChild(stop_watch);


    /*var points = document.createElement('h2');
    points.id = 'Punkte';
    points.className = 'game-elements';
    points.innerHTML = 'Punkte: ' + score;
    game_div.appendChild(points); */


     var stat_table = document.createElement('table');
     stat_table.id='stat_table';
     stat_table.className = "table game-elements";
     stat_table.innerHTML="<tr>" +
         "<td>Richtig</td>" +
         "<td>Falsch</td>" +
         "<td id='score1' >Punkte</td>" +
         "</tr>" +
         "<tr>" +
         "<td id='c_r' >"+counter_right+"</td>" +
         "<td id='c_w' >"+counter_wrong+"</td>" +
         "<td id='score' >"+score+"</td>" +
         "</tr>";
     game_div.appendChild(stat_table);





    var button_leave = document.createElement('div');
    button_leave.id = 'button_leave';
    button_leave.className = "btn btn-lg btn-xl btn-outline leave-buttons";
    button_leave.innerHTML = "Spiel verlassen";

    button_leave.onclick=leave_game;
    game_div.appendChild(button_leave);

    var button_pause = document.createElement('div');
    button_pause.id = 'button_pause';
    button_pause.className = "btn btn-lg btn-xl btn-outline leave-buttons";
    button_pause.innerHTML = "Pause";

    button_pause.onclick=pause_game;
    game_div.appendChild(button_pause);

    <!-- Pause Stuff -->

    var pause_info = document.createElement("h3");
    pause_info.id = "pause_info";
    pause_info.innerHTML = "<span id='phead'>Pause</span><br><br>Drücke  P  oder den Knopf um fortzufahren";
    pause_div.appendChild(pause_info);

    var button_continue = document.createElement('div');
    button_continue.id = 'button_continue';
    button_continue.className = "btn btn-lg btn-xl btn-outline leave-buttons";
    button_continue.innerHTML= "Weiter";
    button_continue.onclick=pause_game;
    pause_div.appendChild(button_continue);

    <!-- END GAME STUFf -->

    var button_main_menu = document.createElement('div');
    button_main_menu.id = 'button_main_menu';
    button_main_menu.className = "btn btn-lg btn-xl btn-outline leave-buttons";
    button_main_menu.innerHTML = "Hauptmenü";
    button_main_menu.onclick=back_to_mainmenu;
    end_game_div.appendChild(button_main_menu);

    var button_to_start = document.createElement('div');
    button_to_start.id = 'button_to_start';
    button_to_start.className = "btn btn-lg btn-xl btn-outline leave-buttons";
    button_to_start.innerHTML = "Noch eine Runde";
    button_to_start.onclick=back_to_start;
    end_game_div.appendChild(button_to_start);
    /*
    set_visibility('game_div', false);
    set_visibility('pause_div', false);
    set_visibility('end_game_div', false);
   */
}



function run_game(){

    game_is_running = true;

    start_time = new Date();

    stopwatch();

}


function reset_game(){

    game_is_running = false;
    game_is_paused = false;

    //score = (counter_right * score_right - counter_wrong * score_wrong)- Math.round((new Date().getTime() - start_time)/score_time_influence);
    score_control();

    document.getElementById('tip').value = "";
    document.getElementById('score').innerHTML = score;
    document.getElementById('result_line').innerHTML = "Los Gehts!";
    document.getElementById('button_pause').value="Pause";

    progress = 0;
    document.getElementById('bar').style.width = progress.toFixed(1) + "%";
    document.getElementById('percent').innerHTML = progress.toFixed(1) + "%";

    if(counter_wrong == 0){
        document.getElementById('end_game_stats').innerHTML = "<h1>Du hast alle <span id='results_right'></span> Aufgaben richtig</h1>" +
        "                   <p>Super Leistung! <span id='results_wrong'></span></p>" +
        "                   <p>Zeit: <span id='results_time'></span> Sekunden</p>" +
        "                   <p>Punkte: <span id='results_score'></span></p> " +
        "                   <p id='result_message'></p>";

        document.getElementById('results_right').innerHTML = counter_right;
    }else if(counter_wrong == quantity){
        document.getElementById('end_game_stats').innerHTML = "<h1>Du hast keine der <span id='results_wrong'></span> Aufgaben richtig</h1>" +
            "                   <p>Es ist noch kein Meister vom Himmel gefallen.</p>" +
            "                   <p>Zeit: <span id='results_time'></span> Sekunden</p>" +
            "                   <p>Punkte: <span id='results_score'></span></p> " +
            "                   <p id='result_message'></p>";
        document.getElementById('results_wrong').innerHTML = counter_wrong;
    }else{
        document.getElementById('end_game_stats').innerHTML = "<h1>Du hast <span id='results_right'></span> richtig</h1>" +
        "                   <p>leider auch <span id='results_wrong'></span> falsch</p>" +
        "                   <p>Zeit: <span id='results_time'></span> Sekunden</p>" +
        "                   <p>Punkte: <span id='results_score'></span></p> " +
        "                   <p id='result_message'></p>";
        document.getElementById('results_wrong').innerHTML = counter_wrong;
        document.getElementById('results_right').innerHTML = counter_right;
    }


    document.getElementById('results_time').innerHTML = Math.round(time_needed/1000);
    document.getElementById('results_score').innerHTML = score;

    if(game_left == false){
        postScore(score, $('#game').data('g_id'));
    }


    //-------------------------------------------------------------------
    // Score into DB
    //
    //
    //
    //-------------------------------------------------------------------

    counter = 0;
    score = 0;
    counter_right = 0;
    counter_wrong = 0;
    pause_time = 0;
    score_update_cooler = 0;
    game_left = false;

    document.getElementById('sw_min').innerHTML="0";
    document.getElementById('sw_s').innerHTML="00";

    $("#game_div").hide();

}


function leave_game(){
    game_left = true;
    reset_game();
    document.getElementById('result_message').innerHTML="Spiel nicht zu Ende gespielt. Der Punktestand wird nicht gespeichert!";

    $('#game_div').hide();
}

function back_to_mainmenu(){
    window.location.href = "/games";
}

function back_to_start(){


}


function pause_game(){

    if(game_is_paused == false){
        game_is_paused = true;
    }else if(game_is_paused == true){
        game_is_paused = false;
    }

    if(game_is_paused == true){
        pause_start = new Date();

            $("#pause_div").fadeIn("1500");


    }else{
        pause_time = pause_time + new Date().getTime() - pause_start.getTime();
        //alert(pause_time/1000 +'Sekunden Pause gemacht');

        $("#pause_div").fadeOut("fast");


        document.getElementById('result_line').innerHTML = "Weiter gehts!";

        stopwatch();
    }


}

document.onkeydown = function (event) {
    //var key_press = String.fromCharCode(event.keyCode);
    var key_code = event.keyCode;

    if(key_code == 80 && game_is_running){

        pause_game();
    }


    if (game_is_running == true && key_code == 13 && game_is_paused == false && (document.getElementById('tip').value !== "")) {


        var user_input = document.getElementById('tip');
        var user_tip = parseInt(user_input.value);
        var result_line = document.getElementById('result_line');


        if (user_tip == result) {
            result_line.innerHTML = "Richtig!";
            user_input.value = "";
            counter_right++;
            counter++;
            score = score + score_right;
            feedbackRight();
        } else {
            result_line.innerHTML = "Falsch! Richtig wäre: " + result;
            user_input.value = "";
            counter_wrong++;
            counter++;
            score = score - score_wrong;
            feedbackWrong();
        }

        progress = progress + step;
        if(progress <= quantity * step){
            document.getElementById('bar').style.width = progress.toFixed(1) + "%";
            document.getElementById('percent').innerHTML = progress.toFixed(1) + "%";
        }

        score_control();
        document.getElementById('score').innerHTML = score;
        document.getElementById('score_a').innerHTML = score;

        create_numbers();

        document.getElementById('z1').innerHTML = z1_n;
        document.getElementById('z2').innerHTML = z2_n;

        document.getElementById('c_r').innerHTML = counter_right;
        document.getElementById('c_w').innerHTML = counter_wrong;


        if (counter >= quantity) {

            reset_game();

            $("#end_game_div").show();


        }

    }


};

function stopwatch(){

    if(game_is_running && game_is_paused == false){



        var actual = new Date();

        time_needed = (actual.getTime() - start_time) - pause_time;

        if(score_just_updated == true && score_update_cooler < Math.round(time_needed/1000)){
            score_just_updated = false;
        }

        document.getElementById('sw_min').innerHTML = Math.floor(time_needed/60000);

        if(Math.round(time_needed/1000)%60 < 10){
            document.getElementById('sw_s').innerHTML ="0" + Math.round(time_needed/1000)%60;
        }else{
            document.getElementById('sw_s').innerHTML = Math.round(time_needed/1000)%60;
        }




        if((Math.round(time_needed/1000) % (score_time_influence/1000)) == 0 && score_just_updated == false){
            score--;
            score_control();
            score_just_updated = true;
            score_update_cooler = (Math.round(time_needed/1000) + 5);
            document.getElementById('score').innerHTML = score;
            document.getElementById('score_a').innerHTML = score;
        }


        setTimeout('stopwatch()',100);
    }

}


function set_visibility(id, v_bool){

    if(v_bool){
        document.getElementById(id).style.visibility="visible";
    }else{
        document.getElementById(id).style.visibility="hidden";
    }

}

function clean(){

    var input_field = document.getElementById('tip');
    var regex = /[^0-9]/gi;
    input_field.value = input_field.value.replace(regex, "");

}

function score_control(){
    if(score < 0){
        score = 0;
    }
}

function correct_order(){

    if(z2_n > z1_n){
        var tmp = z1_n;
        z1_n = z2_n;
        z2_n = tmp;
    }


}

var first_c = true;

function countdown(c){


    if(first_c){
        c = 3;

        create_numbers();

        document.getElementById('z1').innerHTML = z1_n;
        document.getElementById('z2').innerHTML = z2_n;

        document.getElementById('c_r').innerHTML = counter_right;
        document.getElementById('c_w').innerHTML = counter_wrong;
        document.getElementById('score').innerHTML = score;
        document.getElementById('score_a').innerHTML = score;

        $("#game_div").show();
        $("#countdown_div").show();
        $("#end_game_div").hide();

        //$(start_div).hide();
        //$(game_div).show();
        first_c = false;
    }


    if(c >= 0){
        document.getElementById('countdown_info').innerHTML="" + c;
        c = c - 1;
        setTimeout('countdown('+c+')', 1000);
    }else{
        first_c = true;
        $("#countdown_div").hide();
        run_game();
    }

}


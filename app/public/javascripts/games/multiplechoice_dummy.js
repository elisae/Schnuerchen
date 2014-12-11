/**
 * Created with JetBrains WebStorm.
 * User: Willi.Minet
 * Date: 24.11.14
 * Time: 17:19
 * To change this template use File | Settings | File Templates.
 */


/**
 * Created with JetBrains WebStorm.
 * User: Willi.Minet
 * Date: 18.11.14
 * Time: 22:55
 * Version: 1.4
 * To change this template use File | Settings | File Templates.
 *
 *Version
 * -------------------------------------------
 * 1.3
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
 *
 */


//-------------------------------------SETTINGS----------------------------------\\
var quantity = 10;                  //How many tasks are there
var lower_bound = 1;                //lower number bound
var upper_bound = 50;  //100       //upper number bound

var score_right = 10;               //Points for a right answer
var score_wrong = 5;                //Points for a wrong answer
var score_time_influence = 7000;    //score-formula: counter_right * score_right - counter_wrong * score_wrong - time_needed/score_time_influence
//-----------------------------------END SETTINGS----------------------------------\\




//-----------------------------------DECLARATIONS-----------------------------------\\
var game_is_running = false;
var game_is_paused = false;

var score = 0;
var counter = 0;
var counter_right = 0;
var counter_wrong = 0;

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

function create_results(){

    var fake_plus = (Math.floor(Math.random() * (7 - 2 + 1)) + 2);
    var fake_minus = (Math.floor(Math.random() * (7 - 2 + 1)) + 2);

    var fake_res_1 = result + fake_plus;
    var fake_res_2 = result - fake_minus;
    var fake_res_3;

    if(Math.random() <  0.5){
        fake_res_3 = result + 10;
    }else{
        fake_res_3 = result -10;
    }

    if(fake_res_2 < 0){
        fake_res_2 = fake_res_2 + 17;
    }
    if(fake_res_3 < 0){
        fake_res_3 = fake_res_3 + 17;
    }

    var result_button_random = Math.random();
    var result_button_random2 = Math.random();

    if(result_button_random < 0.25){
        document.getElementById('button_res1').value = result;
        if(result_button_random2 < 0.33){
            document.getElementById('button_res2').value = fake_res_1;
            document.getElementById('button_res3').value = fake_res_2;
            document.getElementById('button_res4').value = fake_res_3;
        }else if(result_button_random2 < 0.66){
            document.getElementById('button_res2').value = fake_res_3;
            document.getElementById('button_res3').value = fake_res_1;
            document.getElementById('button_res4').value = fake_res_2;
        }else{
            document.getElementById('button_res2').value = fake_res_2;
            document.getElementById('button_res3').value = fake_res_3;
            document.getElementById('button_res4').value = fake_res_1;
        }
    }else if(result_button_random < 0.5){
        document.getElementById('button_res2').value = result;
        if(result_button_random2 < 0.33){
            document.getElementById('button_res1').value = fake_res_1;
            document.getElementById('button_res3').value = fake_res_2;
            document.getElementById('button_res4').value = fake_res_3;
        }else if(result_button_random2 < 0.66){
            document.getElementById('button_res1').value = fake_res_3;
            document.getElementById('button_res3').value = fake_res_1;
            document.getElementById('button_res4').value = fake_res_2;
        }else{
            document.getElementById('button_res1').value = fake_res_2;
            document.getElementById('button_res3').value = fake_res_3;
            document.getElementById('button_res4').value = fake_res_1;
        }
    }else if(result_button_random < 0.75){
        document.getElementById('button_res3').value = result;
        if(result_button_random2 < 0.33){
            document.getElementById('button_res2').value = fake_res_1;
            document.getElementById('button_res1').value = fake_res_2;
            document.getElementById('button_res4').value = fake_res_3;
        }else if(result_button_random2 < 0.66){
            document.getElementById('button_res2').value = fake_res_3;
            document.getElementById('button_res1').value = fake_res_1;
            document.getElementById('button_res4').value = fake_res_2;
        }else{
            document.getElementById('button_res2').value = fake_res_2;
            document.getElementById('button_res1').value = fake_res_3;
            document.getElementById('button_res4').value = fake_res_1;
        }
    }else{
        document.getElementById('button_res4').value = result;
        if(result_button_random2 < 0.33){
            document.getElementById('button_res2').value = fake_res_1;
            document.getElementById('button_res3').value = fake_res_2;
            document.getElementById('button_res1').value = fake_res_3;
        }else if(result_button_random2 < 0.66){
            document.getElementById('button_res2').value = fake_res_3;
            document.getElementById('button_res3').value = fake_res_1;
            document.getElementById('button_res1').value = fake_res_2;
        }else{
            document.getElementById('button_res2').value = fake_res_2;
            document.getElementById('button_res3').value = fake_res_3;
            document.getElementById('button_res1').value = fake_res_1;
        }
    }
    /*
     document.getElementById('button_res1').value = result;
     document.getElementById('button_res2').value = "" + fake_res_1;
     document.getElementById('button_res3').value = "" + fake_res_2;
     document.getElementById('button_res4').value = "" + fake_res_3;
     */


}

function res_1_click(){
    resolute(document.getElementById('button_res1').value);
}
function res_2_click(){
    resolute(document.getElementById('button_res2').value);
}
function res_3_click(){
    resolute(document.getElementById('button_res3').value);
}
function res_4_click(){
    resolute(document.getElementById('button_res4').value);
}

function init_game(){
    //-----------------------change id here-----------------------------------------|
    var game_div = document.getElementById('game_div');//<--------------------------|
    var start_div = document.getElementById('start_div');//<------------------------|
    var pause_div = document.getElementById('pause_div');//<------------------------|
    var end_game_div = document.getElementById('end_game_div');//<------------------|

   /* //--------Start Div
    var button_start = document.createElement('input');
    button_start.id ='button_start';
    button_start.type="button";
    button_start.value = "Spiel starten";
    button_start.onclick=countdown;
    start_div.appendChild(button_start);
    //-----------------------------------------------------------------------

    //--------------------------------Game Div-------------------------------
    var button_leave = document.createElement('input');
    button_leave.id = 'button_leave';
    button_leave.type="button";
    button_leave.value= "Spiel beenden";
    button_leave.onclick=leave_game;
    game_div.appendChild(button_leave);

    var button_pause = document.createElement('input');
    button_pause.id = 'button_pause';
    button_pause.type = "button";
    button_pause.value = "Pause";
    button_pause.onclick=pause_game;
    game_div.appendChild(button_pause);


    var stat_table = document.createElement('table');
    stat_table.id='stat_table';
    stat_table.innerHTML="<tr><td style='border: double'>Anz. Richtig</td><td style='border: double'>Anz. Falsch</td><td id='score1' style='border: double'>Punkte</td></tr><tr><td id='c_r' style='border: double'>"+counter_right+"</td><td id='c_w' style='border: double'>"+counter_wrong+"</td><td id='score' style='border: double'>"+score+"</td></tr>";
    stat_table.style.border="double";
    game_div.appendChild(stat_table);

    var game_line = document.createElement('p');
    game_line.id = 'game_line';
    game_line.innerHTML = "<span id='z1'></span> + <span id='z2'></span> = <br> ";
    game_div.appendChild(game_line);
*/
    /*-------------- ANZUPASSEN ------------*/

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

    var result_line = document.createElement('h2');
    result_line.id='result_line';
    result_line.className = "game-elements";
    result_line.innerHTML="Los Gehts!";

    document.getElementById('game_div').appendChild(result_line);

    var game_line = document.createElement('h1');
    game_line.id = 'game_line';
    game_line.className = "game-elements";
    game_line.innerHTML = "<span id='z1'></span><span id='operator'> + </span><span id='z2'></span>";

    game_div.appendChild(game_line);

   /* var user_tip = document.createElement('input');
    user_tip.type = "text";
    user_tip.id = 'tip';
    user_tip.className = "game-elements";
    user_tip.className = "input-lg";
    user_tip.placeholder = "Hier kommt das Ergebnis rein";
    user_tip.onkeydown = clean;
    user_tip.onkeyup = clean;
    game_div.appendChild(user_tip);
    user_tip.focus();*/

    var button_res1 = document.createElement('input');
    button_res1.id = 'button_res1';
    button_res1.type = "button";
    button_res1.value = "res1";
    button_res1.className = "btn btn-lg btn-outline res";
    button_res1.onclick=res_1_click;
    button_res1.disabled = true;
    game_div.appendChild(button_res1);

    var button_res2 = document.createElement('input');
    button_res2.id = 'button_res2';
    button_res2.type = "button";
    button_res2.value = "res2";
    button_res2.className = "btn btn-lg btn-outline res";
    button_res2.onclick=res_2_click;
    button_res2.disabled = true;
    game_div.appendChild(button_res2);

    var button_res3 = document.createElement('input');
    button_res3.id = 'button_res3';
    button_res3.type = "button";
    button_res3.value = "res3";
    button_res3.className = "btn btn-lg btn-outline res";
    button_res3.onclick=res_3_click;
    button_res3.disabled = true;
    game_div.appendChild(button_res3);

    var button_res4 = document.createElement('input');
    button_res4.id = 'button_res4';
    button_res4.type = "button";
    button_res4.value = "res4";
    button_res4.className = "btn btn-lg btn-outline res";
    button_res4.onclick=res_4_click;
    button_res4.disabled = true;
    game_div.appendChild(button_res4);

    var stop_watch = document.createElement('h2');
    stop_watch.id='stop_watch';
    stop_watch.className = "game-elements";
    stop_watch.innerHTML = "<span id='sw_min'>00</span>:<span id='sw_s'>00</span>:<span id='sw_ms'>00</span>";
    game_div.appendChild(stop_watch);


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

    /* ---------ENDE ANZUPASSEN -----------*/

/*
    var result_line = document.createElement('p');
    result_line.id='result_line';
    result_line.innerHTML="Los Gehts!";
    game_div.appendChild(result_line);


    var stop_watch = document.createElement('p');
    stop_watch.id='stop_watch';
    stop_watch.innerHTML = "<span id='sw_min'>00</span>:<span id='sw_s'>00</span>:<span id='sw_ms'>00</span>";
    game_div.appendChild(stop_watch);
    //-------------------------End Game Div------------------------------------------


    //----------------------------Pause Div--------------------------
    var button_continue = document.createElement('input');
    button_continue.id = 'button_continue';
    button_continue.type="button";
    button_continue.value= "Weiter";
    button_continue.onclick=pause_game;
    pause_div.appendChild(button_continue);
    //-------------------------End Pause div---------------------------------------

    //------------------------End_game_div------------------------------------------
    end_game_div.innerHTML="<p>Richtige: <span id='results_right'></span> Falsche: <span id='results_wrong'></span></p>" +
        "                   <p>Zeit: <span id='results_time'></span> Sekunden</p>" +
        "                   <p>Punkte: <span id='results_score'></span></p> " +
        "                   <p id='result_message'></p>";

    var button_main_menu = document.createElement('input');
    button_main_menu.id = 'button_main_menu';
    button_main_menu.type = "button";
    button_main_menu.value = "Auswahl";
    button_main_menu.onclick=back_to_mainmenu;
    end_game_div.appendChild(button_main_menu);

    var button_to_start = document.createElement('input');
    button_to_start.id = 'button_to_start';
    button_to_start.type = "button";
    button_to_start.value = "Noch eine Runde";
    button_to_start.onclick=back_to_start;
    end_game_div.appendChild(button_to_start);




    //------------------ENd End_Game_div-------------------------------------------------

    $(game_div).hide();
    $(pause_div).hide();
    $(end_game_div).hide();
*/

}

function run_game(){

    console.log("start");

    document.getElementById('button_res1').disabled = false;
    document.getElementById('button_res2').disabled = false;
    document.getElementById('button_res3').disabled = false;
    document.getElementById('button_res4').disabled = false;
    document.getElementById('result_line').innerHTML = "Los Gehts!";

    game_is_running = true;
    start_time = new Date();
    stopwatch();

}

function reset_game(){

    game_is_running = false;
    game_is_paused = false;

    //score = (counter_right * score_right - counter_wrong * score_wrong)- Math.round((new Date().getTime() - start_time)/score_time_influence);
    score_control();

    document.getElementById('button_res1').value = "";
    document.getElementById('button_res2').value = "";
    document.getElementById('button_res3').value = "";
    document.getElementById('button_res4').value = 0;

    document.getElementById('button_res1').disabled = true;
    document.getElementById('button_res2').disabled = true;
    document.getElementById('button_res3').disabled = true;
    document.getElementById('button_res4').disabled = true;

    document.getElementById('sw_min').innerHTML = "00";
    document.getElementById('sw_s').innerHTML = "00";
    document.getElementById('sw_ms').innerHTML = "00";

    document.getElementById('score').innerHTML = score;
    document.getElementById('result_line').innerHTML = "Los Gehts!";
    document.getElementById('button_pause').value="Pause";

    document.getElementById('results_right').innerHTML = counter_right;
    document.getElementById('results_wrong').innerHTML = counter_wrong;
    document.getElementById('results_time').innerHTML = Math.round(time_needed/1000);
    document.getElementById('results_score').innerHTML = score;

    postScore(score, $('#game').data('g_id'));

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

    $(game_div).hide();

}

function leave_game(){
    reset_game();
    document.getElementById('result_message').innerHTML="Spiel nicht zu Ende gespielt. Der Punktestand wird nicht gespeichert!";
    $(end_game_div).show();

}

function back_to_mainmenu(){
    window.location.href = "/games";
}

function back_to_start(){

    /*$(game_div).hide();
    $(pause_div).hide();
    $(end_game_div).hide();
    $(start_div).show();
    */
}

function pause_game(){

    if(game_is_paused == false){
        game_is_paused = true;
    }else if(game_is_paused == true){
        game_is_paused = false;
    }

    if(game_is_paused == true){
        pause_start = new Date();

        //$(game_div).hide();
        $(pause_div).show();

        document.getElementById('button_pause').value = "Weiter";
        document.getElementById('result_line').innerHTML = "Spiel pausiert: Drücken sie p oder den Button um fortzufahren";
    }else{
        pause_time = pause_time + new Date().getTime() - pause_start.getTime();
        //alert(pause_time/1000 +'Sekunden Pause gemacht');
        //$(game_div).show();
        $(pause_div).hide();

        document.getElementById('button_pause').value = "Pause";
        document.getElementById('result_line').innerHTML = "Weiter gehts!";
        stopwatch();
    }


}

function resolute(user_tip){

    var result_line = document.getElementById('result_line');

    if (user_tip == result) {
        result_line.innerHTML = "Richtig!";
        counter_right++;
        counter++;
        score = score + score_right;
        feedbackRight();
    } else {
        result_line.innerHTML = "Falsch! Richtig wäre: " + result;
        counter_wrong++;
        counter++;
        score = score - score_wrong;
        feedbackWrong();
    }
    score_control();
    document.getElementById('score').innerHTML = score;


    create_numbers();
    create_results();

    document.getElementById('z1').innerHTML = z1_n;
    document.getElementById('z2').innerHTML = z2_n;

    document.getElementById('c_r').innerHTML = counter_right;
    document.getElementById('c_w').innerHTML = counter_wrong;


    if (counter >= quantity) {
        game_is_running = false;
        reset_game();
        document.getElementById('result_message').innerHTML="";

        $(end_game_div).show();

    }
}

document.onkeydown = function (event) {
    //var key_press = String.fromCharCode(event.keyCode);
    var key_code = event.keyCode;

    if(key_code == 80 && game_is_running){
        pause_game();
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
        document.getElementById('sw_s').innerHTML = Math.round(time_needed/1000)%60;
        document.getElementById('sw_ms').innerHTML = Math.round(time_needed)%100;

        if((Math.round(time_needed/1000) % (score_time_influence/1000)) == 0 && score_just_updated == false){
            score--;
            score_control();
            score_just_updated = true;
            score_update_cooler = (Math.round(time_needed/1000) + 5);
            document.getElementById('score').innerHTML = score;
        }


        setTimeout('stopwatch()',101);
    }

}

var first_c = true;

function countdown(c){


    if(first_c){
        c = 3;

        create_numbers();
        create_results();

        document.getElementById('z1').innerHTML = z1_n;
        document.getElementById('z2').innerHTML = z2_n;

        document.getElementById('c_r').innerHTML = counter_right;
        document.getElementById('c_w').innerHTML = counter_wrong;
        document.getElementById('score').innerHTML = score;

        $("#game_div").show();
        $("#countdown_div").show();
        $("#end_game_div").hide();

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
/**
 * Created with JetBrains WebStorm.
 * User: Willi.Minet
 * Date: 07.11.14
 * Time: 18:19
 * To change this template use File | Settings | File Templates.
 */



//-------------------------------------SETTINGS----------------------------------\\
var quantity = 10;                  //How many tasks are there
var lower_bound = 1;                //lower number bound
var upper_bound = 50;  //100        //upper number bound (Remember to take the half)

var score_right = 10;               //Points for a right answer
var score_wrong = 5;                //Points for a wrong answer
var score_time_influence = 7000;    //score-formula: counter_right * score_right - counter_wrong * score_wrong - time_needed/score_time_influence
//-----------------------------------END SETTINGS----------------------------------\\


//---------------------------------------HTML STRUCTURE-----------------------------
/*
*       // if your game div has another id: change id at the begin of the init-function and it should work ;)
*   <div id='game_div'>
*       <input type="button" id='button_start' value="Start Game" onclick="javascript:run_game()"/>
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


var game_is_running = false;
var game_is_paused = false;

var score = 0;
var counter = 0;
var counter_right = 0;
var counter_wrong = 0;

var pause_time = 0;
var pause_start = 0;

var start = new Date();
var start_time = start.getTime();
var time_needed;

var z1_n = Math.floor((Math.random() * upper_bound) + lower_bound);
var z2_n = Math.floor((Math.random() * upper_bound) + lower_bound);

var result = z1_n + z2_n;

function clean(){

    var input_field = document.getElementById('tip');
    var regex = /[^0-9]/gi;
    input_field.value = input_field.value.replace(regex, "");

}



document.onkeydown = function (event) {
    //var key_press = String.fromCharCode(event.keyCode);
    var key_code = event.keyCode;

    if(key_code == 80 && game_is_paused == false){
        game_is_paused = true;
        pause_game();
        //alert('Pause');
    }else if(key_code == 80 && game_is_paused == true){
        game_is_paused = false;
        pause_game();
        //alert('Pause rum');
    }




    if (game_is_running == true && key_code == 13 && game_is_paused == false) {


        var user_input = document.getElementById('tip');
        var user_tip = parseInt(user_input.value);
        var result_line = document.getElementById('result_line');


        if (user_tip == result) {
            result_line.innerHTML = "Richtig!";
            user_input.value = "";
            counter_right++;
            counter++;
        } else {
            result_line.innerHTML = "Falsch! Richtig wäre: " + result;
            user_input.value = "";
            counter_wrong++;
            counter++;
        }


        z1_n = Math.floor((Math.random() * upper_bound) + lower_bound);
        z2_n = Math.floor((Math.random() * upper_bound) + lower_bound);
        result = z1_n + z2_n;

        var span_z1 = document.getElementById('z1');
        var span_z2 = document.getElementById('z2');

        span_z1.innerHTML = z1_n;
        span_z2.innerHTML = z2_n;

        document.getElementById('c_r').innerHTML = counter_right;
        document.getElementById('c_w').innerHTML = counter_wrong;


        if (counter >= quantity) {

            reset_game();

            document.getElementById('score1').style.visibility = "visible";
            document.getElementById('score').style.visibility = "visible";
            document.getElementById('stop_watch').style.visibility="visible";
            document.getElementById('stat_table').style.visibility="visible";


        }

    }


};


init();

function init(){
    //-----------------------change id here-----------------------------------------|
    var game_div = document.getElementById('game_div');//<--------------------------|

    var button_start = document.createElement('input');
    button_start.id ='button_start';
    button_start.type="button";
    button_start.value = "Start Game";
    button_start.onclick=run_game;
    game_div.appendChild(button_start);


    var user_tip = document.createElement('input');
    user_tip.type = "text";
    user_tip.id = 'tip';
    user_tip.onkeydown = clean;
    user_tip.onkeyup = clean;

    var stat_table = document.createElement('table');
    stat_table.id='stat_table';
    stat_table.innerHTML="<tr><td style='border: double'>Anz. Richtig</td><td style='border: double'>Anz. Falsch</td><td id='score1' style='border: double'>Punkte</td></tr><tr><td id='c_r' style='border: double'>"+counter_right+"</td><td id='c_w' style='border: double'>"+counter_wrong+"</td><td id='score' style='border: double'>"+score+"</td></tr>";
    stat_table.style.border="double";
    stat_table.style.visibility="hidden";

    game_div.appendChild(stat_table);

    var game_line = document.createElement('p');
    game_line.id = 'game_line';
    game_line.innerHTML = "<span id='z1'></span> + <span id='z2'></span> = ";
    game_line.appendChild(user_tip);
    game_line.style.visibility="hidden";
    game_div.appendChild(game_line);




    var result_line = document.createElement('p');
    result_line.id='result_line';
    result_line.innerHTML="Los Gehts!";
    result_line.style.visibility="hidden";
    document.getElementById('game_div').appendChild(result_line);


    var stop_watch = document.createElement('p');
    stop_watch.id='stop_watch';
    stop_watch.innerHTML = "<span id='sw_min'></span>:<span id='sw_s'></span>:<span id='sw_ms'></span>";
    stop_watch.style.visibility="hidden";
    game_div.appendChild(stop_watch);






}

function stopwatch(){

    if(game_is_running && game_is_paused == false){

        var actual = new Date();

        time_needed = (actual.getTime() - start_time) - pause_time;

        document.getElementById('sw_min').innerHTML = Math.floor(time_needed/60000);
        document.getElementById('sw_s').innerHTML = Math.round(time_needed/1000)%60;
        document.getElementById('sw_ms').innerHTML = Math.round(time_needed)%100;


        setTimeout('stopwatch()',95);
    }

}

function run_game(){

    //document.getElementById('game_div').style.visibility="hidden";


    var span_z1 = document.getElementById('z1');
    var span_z2 = document.getElementById('z2');

    span_z1.innerHTML = z1_n;
    span_z2.innerHTML = z2_n;

    var stat_table = document.getElementById('stat_table');
    document.getElementById('c_r').innerHTML = counter_right;
    document.getElementById('c_w').innerHTML = counter_wrong;
    stat_table.style.visibility="visible";

    document.getElementById('result_line').style.visibility="visible";
    document.getElementById('stop_watch').style.visibility="true";

    var button_start = document.getElementById('button_start');
    button_start.value = "leave Game";
    button_start.onclick = leave_game;

    var g1 = document.getElementById('game_line');
    g1.style.visibility="visible";

    document.getElementById('score1').style.visibility="hidden";
    document.getElementById('score').style.visibility="hidden";
    document.getElementById('stop_watch').style.visibility="visible";

    game_is_running = true;
    start_time = new Date();

    stopwatch();

}


function reset_game(){

    game_is_running = false;

    score = (counter_right * score_right - counter_wrong * score_wrong)- Math.round((new Date().getTime() - start_time)/score_time_influence);

    if(score < 0){
        score = 0;
    }
    document.getElementById('score').innerHTML = score;

    document.getElementById('stop_watch').style.visibility="hidden";
    document.getElementById('stat_table').style.visibility="hidden";

    document.getElementById('tip').value ="";
    document.getElementById('score').innerHTML = score;

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

    document.getElementById('game_line').style.visibility="hidden";
    document.getElementById('result_line').style.visibility="hidden";
    document.getElementById('result_line').innerHTML="Los Gehts!";
    var button_start = document.getElementById('button_start');
    button_start.style.visibility = "visible";
    button_start.value = "Start Game";
    button_start.onclick = run_game;



}


function leave_game(){

    document.getElementById('score1').style.visibility="hidden";
    document.getElementById('score').style.visibility="hidden";
    reset_game();

}


function pause_game(){

    if(game_is_paused == true){
        pause_start = new Date();
        document.getElementById('game_line').style.visibility="hidden";
        document.getElementById('result_line').innerHTML="Spiel pausiert: p drücken um fortzufahren";
    }else{
        pause_time = new Date().getTime() - pause_start.getTime();
        //alert(pause_time/1000 +'Sekunden Pause gemacht');
        document.getElementById('game_line').style.visibility="visible";
        document.getElementById('result_line').innerHTML="Weiter gehts! Pausendauer: " + Math.round(pause_time/1000)+"s";
        stopwatch();
    }


}



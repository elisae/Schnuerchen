var version = '0.0.1';

var is_playing = false;

init();
function init(){
	
	background_canvas = document.getElementById('background_canvas');
	background_ctx = background_canvas.getContext('2d');
	
	main_canvas = document.getElementById('main_canvas');
	main_ctx = main_canvas.getContext('2d');
	
	document.addEventListener("keydown", key_down, false);
	document.addEventListener("keyup", key_up, false);
	
	request_a_frame = (function(){ // Browser kann selber entscheiden wie viele Frames er kann
		
		return	window.requestAnimationFrame			||
			window.webkitRequestAnimationFrame		||
			window.mozRequestAnimationFrame			||
			window.oRequestAnimationFrame			||
			window.msRequestAnimationFrame			||
			function(callback){
				window.setTimeout(callback, 1000 / 60)
			};
	})();
	
	player = new Player();
	load_media();
}

function mouse(e){
	var x = e.pageX - document.getElementById('game_object').offsetLeft;
	var y = e.pageY - document.getElementById('game_object').offsetTop;
	document.getElementById('x').innerHTML = x;
	document.getElementById('y').innerHTML = y;
	

}


function load_media(){
	
	background_img = new Image();
	background_img.src = 'images/background2.png';
	
	player_img = new Image();
	player_img.src = 'images/player1.png';

}

function Player(){
	
	this.drawX = 0;
	this.drawY = 570 - 50;
	
	this.speed = 5;
	this.is_downkey = false;
	this.is_upkey = false;
	this.is_leftkey = false;
	this.is_rightkey = false;

}

Player.prototype.draw = function(){
	this.check_keys();
	main_ctx.drawImage(player_img, this.drawX, this.drawY);

};

Player.prototype.check_keys = function(){
	if (this.is_downkey == true){
		this.drawY+= this.speed;
	}
	if (this.is_upkey == true){
		this.drawY-= this.speed;
	}
	if (this.is_leftkey == true){
		this.drawX-= this.speed;
	}
	if (this.is_rightkey == true){
		this.drawX+= this.speed;
	}
};

function loop(){
	clear_main_canvas();
	
	player.draw();

	if (is_playing)
		window.setTimeout(loop, request_a_frame);
}

function start_loop(){
	is_playing = true;
	loop();
	background_ctx.drawImage(background_img,0,0);
}
function stop_loop(){
	is_playing = false;
}


function clear_main_canvas(){
	main_ctx.clearRect(0,0,800,600);
}

function key_down(e){
	
	var key_id = e.keyCode || e.which;
	
	if(key_id == 40){  //down key
		player.is_downkey = true;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 38){  //up key
		player.is_upkey = true;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 37){  //left key
		player.is_leftkey = true;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 39){  //upkey
		player.is_rightkey = true;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 

	//alert("Taste gedrückt!");
}

function key_up(e){
	
	var key_id = e.keyCode || e.which;
	
	if(key_id == 40){  //down key
		player.is_downkey = false;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 38){  //up key
		player.is_upkey = false;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 37){  //left key
		player.is_leftkey = false;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 
	if(key_id == 39){  //upkey
		player.is_rightkey = false;
		e.preventDefault(); //deaktiviere normale Browsersction
	} 

	//alert("Taste gedrückt!");
}



















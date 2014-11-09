$(document).ready(function(){
    $(".con").hide();
    $(['button2', 'button3', 'btn3']).each(function(){
        var btn = this;
        var con = $("#"+btn).children('.con');
        $("#"+btn).hover(
            function(){
                $(this).addClass('hover');
               var cache = $(con).children('img');
                //check to see if content was loaded previously
                if(cache.size()){
                   con.show();
                }
                else {
                    $(con).show();
                    //$(con).html('<img src="/img/loader.gif" alt="Loading..." />');
                    var flickerAPI = "http://api.flickr.com/services/feeds/photos_public.gne?jsoncallback=?";
                    $.getJSON( flickerAPI, {
                        tags: "puppy",
                        tagmode: "any",
                        format: "json"
                    }).done(function( data ) {
                        $.each( data.items, function( i, item ) {
                            $( "<img>" ).attr( "src", item.media.m ).appendTo( con );
                            if ( i === 0 ) {
                                return false;
                            }
                        });
                    });
                }
            },
            //mouseout
            function(){

                    $(con).fadeOut(250);


                $(this).removeClass('hover');
            }
        );
    });
});
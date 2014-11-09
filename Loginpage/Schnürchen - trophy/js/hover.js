
$(document).ready(function(){

    $(".con").hide();

    $("#1").each(function(){

        var trophy = this;
        var con = $("#"+trophy).children('.con');

        $("#"+trophy).hover(

            function(){

                $(".hover").mouseout();
                $(this).addClass('hover');
                var cache = $(con).children('p');

                if(cache.size()){
                    con.show();
                }else{
                    $(con).show();
                    $(con).html('<img src="/img/loader.gif" alt="Loading..." />');
                    (function() {
                        var flickerAPI = "http://api.flickr.com/services/feeds/photos_public.gne?jsoncallback=?";
                        $.getJSON( flickerAPI, {
                            tags: "mount rainier",
                            tagmode: "any",
                            format: "json"
                        })
                            .done(function( data ) {
                              $(con).html(data);
                            });
                    })();
                }
            },

            function(){
                if($.browser.msie){
                    $(con).hide();
                }
                else {
                    $(con).fadeOut("slow");
                }
                $(this).removeClass('hover');
            }
        );
    });
});

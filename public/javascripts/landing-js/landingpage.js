/*!
 * Start Bootstrap - Grayscale Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

function parallax() {
    var b1 = document.getElementById('intro-bulb');
    b1.style.top = -(window.pageYOffset * 1.9) + 'px';

}


window.addEventListener("scroll", parallax, false);

// jQuery to collapse the navbar on scroll
$(window).scroll(function () {
    if ($(".navbar").offset().top > 50) {
        $(".navbar-fixed-top").addClass("top-nav-collapse");
    } else {
        $(".navbar-fixed-top").removeClass("top-nav-collapse");
    }
});

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function () {
    $('a.page-scroll').bind('click', function (event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 2500, 'easeInOutExpo');
        event.preventDefault();
    });
});

// Closes the Responsive Menu on Menu Item Click
$('.navbar-collapse ul li a').click(function () {
    $('.navbar-toggle:visible').click();
});

var explanation = $("#explanation");
var backToSteps = $(".backToSteps");

$("#step1").click(function () {
    explanation.show();
    $("#step1Explanation").show();
});

$("#step2").click(function () {
    explanation.show();
    $("#step2Explanation").show();
});

$("#step3").click(function () {
    explanation.show();
    $("#step3Explanation").show();
});

backToSteps.click(function () {
    explanation.hide();
    $(".stepExplanation").hide();
});

$("#step1Forward").click(function () {
    $("#step1Explanation").hide();
    $("#step2Explanation").show();
});

$("#step2Backward").click(function () {
    $("#step1Explanation").show();
    $("#step2Explanation").hide();
});

$("#step2Forward").click(function () {
    $("#step2Explanation").hide();
    $("#step3Explanation").show();
});

$("#step3Backward").click(function () {
    $("#step2Explanation").show();
    $("#step3Explanation").hide();
});
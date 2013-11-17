$(document).ready(function(){

	var container  = $('<div id="index"><h2>Index</h2></div>');
	var list       = $('<ul id="list"></ul>');

	// Create the list.
	$("h2 .symbol").each(function(){
		var target = $(this);
		var item   = $('<li class="item"><a href="#">' + target.text() + '</a></li>');
		item.on("click", function() {
			$.scrollTo(target, 200);
		});
		list.append(item);
	});

	list.appendTo(container);
	container.prependTo("body");

	// Handle page scrolling.
	var indexTop = $('#index').offset().top;
	$(window).scroll(function(){

		var windowTop = $(window).scrollTop();

		if (indexTop < windowTop) {
			$("#index").css({position:"fixed", top:0, left:0});
		}
		else {
			$("#index").css({position:"absolute"});
		}
	 });
});

$(document).ready(function(){

	var container  = $('<div id="index"><h2>Index</h2></div>');
	var list       = $('<ul id="list"></ul>');
	var urlPattern = new RegExp("^(.*)html", "ig");
	url            = urlPattern.exec(window.location.href)[1];

	// Create the list.
	var anchorIteration = 0;
	$("h2 .symbol").each(function(){
		var text = $(this).text();
		$(this).before('<a name="' + text + anchorIteration + '"></a>');
		list.append('<li class="item"><a href="' + url + '#' + text + anchorIteration + '">' + text + '</li>');
		anchorIteration++;
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

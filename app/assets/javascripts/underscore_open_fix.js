$(window).load(function(){
	_.templateSettings = {
	    interpolate: /\<\@\=(.+?)\@\>/gim,
	    evaluate: /\<\@([\s\S]+?)\@\>/gim,
	    escape: /\<\@\-(.+?)\@\>/gim
	};
});
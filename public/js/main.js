(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.home .cover').height(winH).width(winW);
	$('.members .cover').height(winH).width(winW);
	$('#page-bg').anystretch();


	
	
	// var $homeP = $('.home-books-block');
	
	// $homeP.waypoint(function(direction) {
	// 	if (direction == "down") {
	// 		clearInterval(timeout);
	// 	}
	// }, { offset: '25%' });
	
	// $homeP.waypoint(function(direction) {
	// 	if (direction == "up") {
	// 		runCarousel();
	// 	}
	// }, { offset: '25%' });
	
	// setTimeout(function() {
	// 	$('body').addClass('loaded');
	// 	$car.find('li').not('.left').addClass('animated');
		
	// 	runCarousel();
	// }, 5000)
	
	// $('.scrollto').click(function() {
	// 	var id = $(this).attr('href');
		
	// 	$.scrollTo(id, 1200);
	// 	return false;
	// });
	
	// $sesProd = $('.previously-viewed');
	// $prodCart = $('#books-cart');
	// $sesProd.find('li').click(function() {
	// 	var val = $(this).text();
	// 	var prodVal = $prodCart.val();
	// 	$prodCart.val(prodVal + ', ' + val);
		
	// 	$(this).remove();
		
	// 	return false;
	// });
	
	// var $prodGrid = $('#book-grid');
	
	// $prodGrid.find('li').click(function() {
	// 	var url = $(this).find('h3 a').attr('href');
		
	// 	window.location.href = url;
	// });
	
	// $('.file-inputs').bootstrapFileInput();
	
	var $delBtn = $('.delete-btn');
	var $delModal = $('.delete-modal');
	
	$delBtn.click(function() {
		var prodID = $(this).attr('data-book-id');
		var prodName = $(this).attr('data-book-name');
		var dataType = $(this).attr('data-type');

		$delModal.find('form').attr('action', dataType + '/destroy/' + prodID);
		$delModal.find('h4.modal-title span').text(dataType + ": " +prodName);
		
		$delModal.modal();
		
		return false;
	});
	
});

$(window).load(function() {

	$('body').addClass('loaded');
	
	
	
});
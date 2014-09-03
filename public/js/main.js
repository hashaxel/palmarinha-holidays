(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.home .cover').height(winH).width(winW);
	$('.members .cover').height(winH).width(winW);
	$('#page-bg').anystretch();
	
	$('.home-controls').css({
		top: ((winH - 260) / 2) + 160
	});
		
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
	
	var locBlockCount = $('#loc-blocks li').length;
	
	$('#loc-blocks').width(295 * locBlockCount);
	
});

$(window).load(function() {

	$('body').addClass('loaded');
	
});
(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.gallery-items').cycle({
		speed: 800,
		sync: false
	});

	var $car = $('#carousel-viewport');
	var cWidth = $('.content-wrap').width();
	
	var timeout;

	function runCarousel() {
		var $active = $car.find('li.active');
		var $prev = $car.find('li.prev');
		var $next = $car.find('li.next');
		var $left = $car.find('li.left');
		var $right = $car.find('li.right');
		
		$active.css({
			'left' : (0 - $active.width()) / 2 
		}).removeClass('active').addClass('prev');
		
		$prev.css({
			'left' : (0 - cWidth) 
		}).removeClass('prev');
		
		$next.css({
			'left' : (cWidth - $next.width()) / 2 
		}).removeClass('next').addClass('active');
		
		$right.css({
			'left' : (cWidth + $right.width()) / 2 
		}).removeClass('right').addClass('next');
		
		$left.css({
			'left' : cWidth + 100
		});
		
		setTimeout(function() {
			$prev.removeClass('animated').addClass('left');
			$left.removeClass('left').addClass('right').addClass('animated');
		}, 800);
		
		timeout = setTimeout(runCarousel, 4000);
	}
	
	
	
	var $homeP = $('.home-books-block');
	
	$homeP.waypoint(function(direction) {
		if (direction == "down") {
			clearInterval(timeout);
		}
	}, { offset: '25%' });
	
	$homeP.waypoint(function(direction) {
		if (direction == "up") {
			runCarousel();
		}
	}, { offset: '25%' });
	
	setTimeout(function() {
		$('body').addClass('loaded');
		$car.find('li').not('.left').addClass('animated');
		
		runCarousel();
	}, 5000)
	
	$('.scrollto').click(function() {
		var id = $(this).attr('href');
		
		$.scrollTo(id, 1200);
		return false;
	});
	
	$sesProd = $('.previously-viewed');
	$prodCart = $('#books-cart');
	$sesProd.find('li').click(function() {
		var val = $(this).text();
		var prodVal = $prodCart.val();
		$prodCart.val(prodVal + ', ' + val);
		
		$(this).remove();
		
		return false;
	});
	
	var $prodGrid = $('#book-grid');
	
	$prodGrid.find('li').click(function() {
		var url = $(this).find('h3 a').attr('href');
		
		window.location.href = url;
	});
	
	$('.file-inputs').bootstrapFileInput();
	
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
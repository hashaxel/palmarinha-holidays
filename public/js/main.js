(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.home .cover').height(winH).width(winW);
	$('.members-page .cover').height(winH).width(winW);
	$('#page-bg').anystretch();


	//email validation code starts
	var form = $('#memberenroll');
	var bookform = $('#book');
	var email = $('#eadd');
	var emailInfo = $('#emailInfo');
	var eaddgrp = $('#eaddgrp');
	

	$('#home-controls').css({
		top: ((winH - 260) / 2) + 160
	});
	form.submit(function() {
		if (validateEmail()) {
			return true;
		} else {
			return false;
		}
	});

	$('#faqs li').not('.active').find('p').hide();
	
	$('#faqs li').click(function() {
		$('#faqs li.active').removeClass('active').find('p').slideUp();
		$(this).addClass('active');
		$(this).find('p').slideDown();
	});
			
	// Delete Modal for Hotel and Specials
	var $delBtn = $('.delete-btn');
	var $delModal = $('.delete-modal');
	
	$delBtn.click(function() {
		var dataID = $(this).attr('data-id');
		var dataName = $(this).attr('data-name');
		var dataType = $(this).attr('data-type');

		$delModal.find('form').attr('action', "/" + dataType + '/' + dataID);
		$delModal.find('h4.modal-title span').text(dataType.substr(0, 1).toUpperCase() + dataType.substr(1) + ": " + dataName);
		
		$delModal.modal();
		
		return false;
	});

	// Book Modal
	var $bookBtn = $('.book-btn');
	var $bookModal = $('.book-modal');
	
	$bookBtn.click(function() {
		var hotel_id = $(this).attr('data-id');
		$('#hotel_id').val(hotel_id);
		
		$bookModal.modal();
		
		return false;
	});

	//check-in check-out datepickers
	$('#checkinpicker').datepicker({
		format: "dd/mm/yyyy",
		pickTime: false,
		startDate: "today",
		endDate: "+3m",
		todayBtn: "linked",
		autoclose: true
	});

	$('#checkoutpicker').datepicker({
		format: "dd/mm/yyyy",
		pickTime: false,
		endDate: "+3m",
		autoclose: true,
	});

	//Past and dependent date disabling for check-out.
	var nowTemp = new Date();
	var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

	var checkin = $('#checkinpicker').datepicker({
		beforeShowDay: function(date) {
			return date.valueOf() >= now.valueOf();
		}
	}).on('changeDate', function(ev) {
		var coutdate = $('#checkoutpicker').datepicker("getDate").valueOf();
		var newDate = new Date(ev.date)
		newDate.setDate(newDate.getDate() + 2);
		if (ev.date.valueOf() > coutdate || isNaN(coutdate)) {
			checkout.setValue(newDate);
			checkout.setStartDate(newDate);
			checkout.setDate(newDate);
			checkout.update();
		}
		else {
			checkout.setStartDate(newDate);
			checkout.update();
		}
		checkin.hide();
		$('#check_out').focus();
	}).data('datepicker');
	
	var checkout = $('#checkoutpicker').datepicker({
		beforeShowDay: function(date) {
			return date.valueOf() > checkin.date.valueOf();
		}
	}).on('changeDate', function(ev) {
		checkout.hide();
	}).data('datepicker');
	//Past and dependent date disabling for check-out ends here.

	
	var locBlockCount = $('#loc-blocks li').length;
	
	var fullWidthHeight;
	
	if (winH > winW) {
		fullWidthHeight = winW * 0.8;
	} else {
		fullWidthHeight = winH * 0.9;
	}
	
	$('#resort-img').height(fullWidthHeight);
	
	// is_active checkbox
	$('.btn-checkbox').click(function() {
		var $this = $(this);
		
		if ($this.hasClass('btn-active')) {
			$this.removeClass('btn-active').addClass('btn-disabled');
			$this.prev().val('false');
			$this.find('.glyphicon').removeClass('glyphicon-ok').addClass('glyphicon-remove');
		} else {
			$this.find('.glyphicon').removeClass('glyphicon-remove').addClass('glyphicon-ok');
			$this.removeClass('btn-disabled').addClass('btn-active');
			$this.prev().val('true');
		}
		
		return false;
	});

	//admin controls
	$('a#new-special').click(function() {
		$('#hidden-form').slideToggle(500);
		return false;
	});

	$('a#hotels').click(function() {
		$.scrollTo(0, 800);
		return false;
	});

	$('a#specials').click(function() {
		$.scrollTo('#special-section', 800);
		return false;
	});

});

$(window).load(function() {

	$('body').addClass('loaded');
	
});
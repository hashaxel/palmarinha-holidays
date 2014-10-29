(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.home .cover').height(winH).width(winW);
	$('.members-page .cover').height(winH).width(winW);
	$('#page-bg').anystretch();


	//email validation code starts
	var form = $('#memberenroll');
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

	function validateEmail() {
        //validation for empty emails
        if (email.val() == '') {
            email.addClass('has-error');
            eaddgrp.addClass('has-error');
            emailInfo.addClass('has-error');
            emailInfo.text('Email cannot be empty!');
            return false;
        } else {
            email.removeClass('has-error');
            eaddgrp.removeClass('has-error');
            emailInfo.removeClass('has-error');
            emailInfo.text('');
        }
 
        //validation for proper email formats
        //testing regular expression
        var a = email.val();

        var filter = /^[a-zA-Z0-9]+[a-zA-Z0-9_.-]+[a-zA-Z0-9_-]+@[a-zA-Z0-9]+[a-zA-Z0-9.-]+[a-zA-Z0-9]+.[a-z]{2,4}$/;
        //if it's valid email
        if (filter.test(a)) {
            email.removeClass('has-error');
            eaddgrp.removeClass('has-error');
            emailInfo.removeClass('has-error');
            emailInfo.text('');
            return true;
        }
        //if it's NOT valid
        else {
            email.addClass('has-error');
            emailInfo.addClass('has-error');
            eaddgrp.addClass('has-error');
            emailInfo.text('Enter Valid E-mail please..!');
            return false;
        }
    }
		
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
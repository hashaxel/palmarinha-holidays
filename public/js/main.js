(function($){})(window.jQuery);

var winH = $(window).height();
var winW = $(window).width();

$(document).ready(function() {
	$('.home .cover').height(winH).width(winW);
	$('.members .cover').height(winH).width(winW);
	$('#page-bg').anystretch();


	//email validation code starts
	var form = $('#memberenroll');
	var email = $('#eadd');
	var emailInfo = $('#emailInfo');
	var eaddgrp = $('#eaddgrp');
	

	$('.home-controls').css({
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
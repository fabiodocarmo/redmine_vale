$(document).ready(function() {
    $('input#user_firstname').prop('disabled', true);
    $('input#user_lastname').prop('disabled', true);
    $('input#user_mail').prop('disabled', true);
    $('.contextual .icon-email-add').remove();
    $('.contextual .icon-passwd').remove();
});

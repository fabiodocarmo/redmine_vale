$(document).ready(function() {
    $('input#user_login').prop('disabled', true);
    $('input#user_firstname').prop('disabled', true);
    $('input#user_lastname').prop('disabled', true);
    $('input#user_mail').prop('disabled', true);
    $('#password_fields').parent().remove();
    $('li > #tab-groups').parent().remove();
    $('li > #tab-memberships').parent().remove();
    $('.contextual .icon-email-add').remove();
    $('.contextual .icon-unlock').remove();
    $('.contextual .icon-lock').remove();
    $('.contextual .icon-del').remove();
});

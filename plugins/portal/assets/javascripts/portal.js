$(document).ready(function() {
  $.each($('#projects-index > .projects .projects'), function(index, projects) {
    var a = $('<a href="javascript:void(0);" class="more"></a>');
    a.text('');

    a.click(function() {
      $(projects).toggleClass("show");
      $(a).toggleClass("more");
      $(a).toggleClass("less");
    });

    $(a).insertAfter($(projects).parent().find('.project:first'));
  });
});

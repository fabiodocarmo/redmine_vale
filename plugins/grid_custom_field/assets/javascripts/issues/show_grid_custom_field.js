$(document).ready(function() {
  $("#grid_custom_field_show_tables").find("p[id^=p_grid_custom_field]").each(function(){
  	$(".attributes").find("."+$(this).attr('class')).remove();
  });
});

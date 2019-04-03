$(document).ready(function() {
  var set_achive_configs_visibility = function(){
    var enable_archive = $('#settings_enable_archive_issue').find(":selected").attr('value');
    if(enable_archive == "true"){
      $('#settings_archive_after_days').closest('tr').show();
      $('#settings_archive_with_comments_after_closed').closest('tr').show();
    }else{
      $('#settings_archive_after_days').closest('tr').hide();
      $('#settings_archive_with_comments_after_closed').closest('tr').hide();
    }
  }

  $('#settings_enable_archive_issue').change(function(){
    set_achive_configs_visibility();
  });

  set_achive_configs_visibility();

});

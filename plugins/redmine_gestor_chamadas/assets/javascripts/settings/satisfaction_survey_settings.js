$(document).ready(function() {
  var set_reopen_option_visibility = function(){
    var enable_satisfaction_survey = $('#settings_enable_satisfaction_survey').find(":selected").attr('value');
    if(enable_satisfaction_survey == "true"){
      $('#settings_reopen_status_to').closest('tr').show();
    }else{
      $('#settings_reopen_status_to').closest('tr').hide();
    }
  }

  $('#settings_enable_satisfaction_survey').change(function(){
    set_reopen_option_visibility();
  });

  set_reopen_option_visibility();

});

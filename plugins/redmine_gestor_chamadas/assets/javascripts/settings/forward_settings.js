$(document).ready(function() {
  var set_reopen_option_visibility = function(){
    var enable_priority_changes = $('#settings_copy_issue_when_forward').find(":selected").attr('value');
    if(enable_priority_changes == "true"){
      $('#settings_mistaken_notify').closest('tr').show();
      $('#settings_increase_priority_forwarded').closest('tr').show();
    }else{
      $('#settings_mistaken_notify').closest('tr').hide();
      $('#settings_increase_priority_forwarded').closest('tr').hide();
    }
  }

  $('#settings_copy_issue_when_forward').change(function(){
    set_reopen_option_visibility();
  });

  set_reopen_option_visibility();

  var set_forwarding_config_visibility = function(){
    var enable_rollback_when_mistaken = $('#settings_mistaken_change_assigned').find(":selected").attr('value');
    if(enable_rollback_when_mistaken == "true"){
      $('#settings_rollback_forwarding_config').show();
    }else{
      $('#settings_rollback_forwarding_config').hide();
    }
  }

  $('#settings_mistaken_change_assigned').change(function(){
    set_forwarding_config_visibility();
  });

  set_forwarding_config_visibility();
});

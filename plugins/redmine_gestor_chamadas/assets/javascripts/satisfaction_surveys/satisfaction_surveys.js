$('input[name="satisfaction_survey[satisfaction]"]').change(function(){
   set_reopen_visibility(this);
 });

 set_reopen_visibility($('input[name="satisfaction_survey[satisfaction]"]'));

function set_reopen_visibility(combo){
  var cb_reopen = $('#cb_reopen');

  $('input[name="satisfaction_survey[satisfaction]"]').click(function(evt) {
    if(($(this).val()).split(" ",1) == "satisfeito")  {
      cb_reopen.hide();
    } else {
      cb_reopen.show();
    }
  });
};

$('input[name="satisfaction_survey[enable_reopen]"]').change(function(){
   set_reopen_checkbox(this);
 });

 set_reopen_checkbox($('input[name="satisfaction_survey[enable_reopen]"]'));

function set_reopen_checkbox(combo){
  var reopen_issue = $('#reopen_issue');

  $('input[name="satisfaction_survey[enable_reopen]"]').click(function(evt) {
    if(($(this).val()).split(" ",1) == "false") {
      reopen_issue.hide();
    } else {
      reopen_issue.show();
    }
  });
};

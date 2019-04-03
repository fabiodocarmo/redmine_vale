$( document ).ready(function() {
  var success = function( data ) {
    var options = {
      scaleOverride: true,
      // ** Required if scaleOverride is true **
      // Number - The number of steps in a hard coded scale
      scaleSteps: data[0]/86400 + 2,
      // Number - The value jump in the hard coded scale
      scaleStepWidth: 86400,
      // Number - The scale starting value
      scaleStartValue: 0,
      scaleLabel: "<%= value.toString().toDays() %>",
      multiTooltipTemplate: "<%if (datasetLabel){%><%=datasetLabel%>: <% } %><%= value.toString().toHHMMSS() %>"
    };

    new Chart(document.getElementById("average_answer_time_per_projectChart").getContext("2d")).Bar(data[1], options);
    legend(document.getElementById("average_answer_time_per_project_legend"), data[1]);
  };


  var ajaxCallaverage_answer_time_per_project = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/project_average_answer_time/",
      dataType: 'json',
      data: {
        project_id: project_id,
        widget_id: 'average_answer_time_per_project'
      },
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(success)
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallaverage_answer_time_per_project();}, 86400000);
    });
  };

  ajaxCallaverage_answer_time_per_project();
});

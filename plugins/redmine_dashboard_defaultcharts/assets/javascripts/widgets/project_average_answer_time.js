$( document ).ready(function() {

  var ajaxCallProjects = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/projects_list",
      data: {
        project_id: project_id,
        widget_id: 'project_average_answer_time'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      container = $("#project_average_answer_time").parent();
      $("#wrong_issues_per_project").remove();

      for(var i=0; i < data.length; i++) {
        if (data[i].project == undefined) {
          var project_id = data[i].id;
          var project_name = data[i].name;
        } else {
          var project_id = data[i].project.id;
          var project_name = data[i].project.name;
        }


        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>"+project_name+"</h2>");
        var canvas = $("<canvas id='project_average_answer_timeChart_"+project_id+"' ></canvas>");
        var legend = $("<div  id='project_average_answer_time_legend"+project_id+"' class='legend' style='float: right;' width='50' ></div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallproject_average_answer_time(project_id);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  var ajaxCallproject_average_answer_time = function(project_id) {
    $.ajax({
      url: "../../dashboard/gestor_chamados/project_average_answer_time/"+project_id,
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      success(data, project_id);
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  ajaxCallProjects();

  var success = function(data, project_id) {
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
    var grafico = new Chart(document.getElementById("project_average_answer_timeChart_"+project_id).getContext("2d")).Bar(data[1], options);
    window.html_legend = grafico.generateLegend();
    legend(document.getElementById("project_average_answer_time_legend"+project_id), data[1]);
  };
});

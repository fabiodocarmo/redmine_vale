$( document ).ready(function() {

  var successTracker = function(project_id, data) {
    new Chart(document.getElementById("aging_trackerChart_"+project_id).getContext("2d")).StackedBar(data, {});
    legend(document.getElementById("aging_tracker_"+project_id+"_legend"), data);
  };

  var ajaxCallaging_tracker = function(project_id) {
    $.ajax({
      url: "../../dashboard/gestor_chamados/aging_tracker",
      dataType: 'json',
      data: {
        project_id: project_id,
        widget_id: 'aging_per_project'
      },
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) { successTracker(project_id, data); })
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  var ajaxCallProjectsList = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/projects_list",
      data: {
        project_id: project_id,
        widget_id: 'aging_per_project'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      container = $("#aging_per_project").parent();
      $("#aging_per_project").remove();

      for(var i=0; i < data.length; i++) {

        if (data[i].project == undefined) {
          var project_id = data[i].id;
          var project_name = data[i].name;
        } else {
          var project_id = data[i].project.id;
          var project_name = data[i].project.name;
        }

        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>Aging - Tipos de Problema - "+project_name+"</h2>");
        var canvas = $("<canvas id='aging_trackerChart_"+project_id+"' ></canvas>");
        var legend = $("<div  id='aging_tracker_"+project_id+"_legend' class='legend' style='float: right;' width='50' ></div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallaging_tracker(project_id);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  ajaxCallProjectsList();
});

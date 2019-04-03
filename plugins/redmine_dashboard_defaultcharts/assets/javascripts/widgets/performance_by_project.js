$( document ).ready(function() {
  var success = function(project_id, data) {
    var options = {
      bezierCurve : false,
      datasetFill : false
    };
    new Chart(document.getElementById("performance_by_projectChart"+project_id).getContext("2d")).Overlay(data, options);
    legend(document.getElementById("performance_by_project_legend"+project_id), data);
  };

  var ajaxCallperformance_per_fte = function(project_id) {
    $.ajax({
      url: "../../dashboard/gestor_chamados/performance_by_project",
      data: {
        project_id: project_id,
        widget_id: 'performance_by_project'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) {
      success(project_id, data);
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallperformance_per_fte();}, 86400000);
    });
  };

  //ajaxCallperformance_per_fte('');

  var ajaxCallperformance_list = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/projects_list",
      data: {
        project_id: project_id,
        widget_id: 'performance_by_project'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) {

      container = $("#performance_by_project").parent();
      for(var i=0; i < data.length; i++) {
        if (data[i].project == undefined) {
          var project_id = data[i].id;
          var project_name = data[i].name;
        } else {
          var project_id = data[i].project.id;
          var project_name = data[i].project.name;
        }

        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>Produtividade - "+project_name+"</h2>");
        var canvas = $("<canvas id='performance_by_projectChart"+project_id+"'></canvas>");
        var legend = $("<div  id='performance_by_project_legend"+project_id+"' style='float: right;' width='50'> </div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallperformance_per_fte(project_id);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
    });
  };
  ajaxCallperformance_list();
});

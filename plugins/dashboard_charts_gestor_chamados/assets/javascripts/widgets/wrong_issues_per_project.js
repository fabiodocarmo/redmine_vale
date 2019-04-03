$( document ).ready(function() {
  var success = function(data, project_id) {
    new Chart(document.getElementById("wrong_issues_per_projectChart_"+project_id).getContext("2d")).StackedBar(data, {});
    legend(document.getElementById("wrong_issues_per_project_"+project_id+"_legend"), data);
  };

  var ajaxCallResolverAreas = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/resolver_areas",
      data: {
        project_id: project_id,
        widget_id: 'wrong_issues_per_project'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      container = $("#wrong_issues_per_project").parent();
      $("#wrong_issues_per_project").remove();

      for(var i=0; i < data.length; i++) {
        var project_id = data[i].project.id;

        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>"+data[i].project.name+"</h2>");
        var canvas = $("<canvas id='wrong_issues_per_projectChart_"+project_id+"' width='450' height='400'></canvas>");
        var legend = $("<div  id='wrong_issues_per_project_"+project_id+"_legend' class='legend' style='float: right;' width='50'> </div>");
        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallwrong_issues_per_project(project_id);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  var ajaxCallwrong_issues_per_project = function(project_id) {
    $.ajax({
      url: "../../dashboard/gestor_chamados/wrong_issues_per_project/",
      data: {
        project_id: project_id,
        widget_id: 'wrong_issues_per_project'
      },
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

  ajaxCallResolverAreas();
});

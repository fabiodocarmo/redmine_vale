$( document ).ready(function() {
  var success = function(assigned_to_id, data) {
    var options = {
      bezierCurve : false,
      datasetFill : false
    };
    var sum_opened = 0;
    for (var j = 0; j < data['datasets'][1]['data'].length; j++){
      sum_opened += data['datasets'][1]['data'][j];
    }
    for (var j = 0; j < data['datasets'][2]['data'].length; j++){
      sum_opened += data['datasets'][2]['data'][j];
    }
    var div = $("#performance_per_fte_container"+assigned_to_id);
    if (sum_opened > 0) {
      div.show();
      window.msnry.appended(div);
      window.msnry.layout();
      window.fixCanvas();

      new Chart(document.getElementById("performance_per_fteChart"+assigned_to_id).getContext("2d")).Overlay(data, options);
      legend(document.getElementById("performance_per_fte_legend"+assigned_to_id), data);
    }
    else {
      div.remove()
    }
  };

  var ajaxCallperformance_per_fte = function(assigned_to_id, date_from, date_to) {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/performance_per_fte",
      data: {
        date_from: date_from,
        date_to: date_to,
        assigned_to_id: assigned_to_id,
        project_id: project_id,
        widget_id: 'performance_per_fte'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) {
      success(assigned_to_id, data);
    }).error(function(xhr, status, error) {
      if(assigned_to_id == ""){
        $("#performance_per_fte_containerAverage").parent().parent().append("<p> O seu usuário não tem permissão de acesso a nenhum usuário que tem chamados atribuídos no período selecionado.</p>");
        $("#performance_per_fte_containerAverage").parent().remove();
      }
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallperformance_per_fte();}, 86400000);
    });
  };

  var ajaxCallperformance_list = function(date_from, date_to) {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/assigned_list_per_group",
      dataType: 'json',
      data: {
        project_id: project_id,
        widget_id: 'performance_per_fte'
      },
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) {

      container = $("#widget_performance_per_fte_container");
      for(var i=0; i < data.length; i++) {
        if (data[i].user == undefined) {
          var assigned_to_id = data[i].id;
          var assigned_to_firstname = data[i].firstname;
          var assigned_to_lastname = data[i].lastname;
        } else {
          var assigned_to_id = data[i].user.id;
          var assigned_to_firstname = data[i].user.firstname;
          var assigned_to_lastname = data[i].user.lastname;
        }

        $("#performance_per_fte_container"+assigned_to_id).remove()

        var div    = $("<div class='redimine-widget' id='performance_per_fte_container"+assigned_to_id+"'></div>");
        var title  = $("<h2>Produtividade - "+assigned_to_firstname+" "+assigned_to_lastname+"</h2>");
        var canvas = $("<canvas id='performance_per_fteChart"+assigned_to_id+"' ></canvas>");
        var legend = $("<div  id='performance_per_fte_legend"+assigned_to_id+"' class='legend' style='float: right;' width='50'> </div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);
        container.append(div);
        div.hide();

        ajaxCallperformance_per_fte(assigned_to_id, date_from, date_to);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
    });
  };

  var load_performance_per_fte = function() {
    var date_from = $('#filter_range_date_from')[0].value;
    var date_to = $('#filter_range_date_to')[0].value;

    char_average = $("#performance_per_fte_container");
    char_average.find("#performance_per_fteChart").remove();
    char_average.find("#performance_per_fte_legend").remove();
    var canvas = $("<canvas id='performance_per_fteChart' ></canvas>");
    var legend = $("<div  id='performance_per_fte_legend' class='legend' style='float: right;' width='50'> </div>");
    char_average.append(canvas);
    char_average.append(legend);

    ajaxCallperformance_per_fte('', date_from, date_to);
    ajaxCallperformance_list(date_from, date_to);
  }

  $('#redmine-dashboard-refresh-filters-button').on('click', load_performance_per_fte);

  load_performance_per_fte();
});

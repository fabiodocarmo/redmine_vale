$( document ).ready(function() {

  var chart_on_time_percentage;
  var chart_on_time;

  var success_closed = function( data ) {
    var options = {
      bezierCurve : false,
      datasetFill : false

      //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
      // scaleBeginAtZero : true,

      //Boolean - Whether grid lines are shown across the chart
      // scaleShowGridLines : true,

      //String - Colour of the grid lines
      // scaleGridLineColor : "rgba(0,0,0,.05)",

      //Number - Width of the grid lines
      // scaleGridLineWidth : 1,

      //Boolean - If there is a stroke on each bar
      // barShowStroke : true,

      //Number - Pixel width of the bar stroke
      // barStrokeWidth : 2,

      //Number - Spacing between each of the X value sets
      // barValueSpacing : 5,

      //Boolean - Whether bars should be rendered on a percentage base
      // relativeBars : false,

      //String - A legend template
      // legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    };
    if(chart_on_time_percentage != null){
      chart_on_time_percentage.destroy();
    }
    chart_on_time_percentage = new Chart(document.getElementById("answered_by_level_sla_on_time_percentage_chart").getContext("2d")).Overlay(data['on_time_percentage'], options);
    legend(document.getElementById("answered_by_level_sla_on_time_percentage_legend"), data['on_time_percentage']);

    if(chart_on_time != null){
      chart_on_time.destroy();
    }
    n1 = data['on_time'].datasets[0].data.pop();
    n2 = data['on_time'].datasets[1].data.pop();
    $("#answered_by_level_sla_on_time_accumulated_n1").text(n1.toString());
    $("#answered_by_level_sla_on_time_accumulated_n2").text(n2.toString());
    $("#answered_by_level_sla_on_time_accumulated_total").text((n1 + n2).toString());
    chart_on_time = new Chart(document.getElementById("answered_by_level_sla_on_time_chart").getContext("2d")).StackedBar(data['on_time']);
    legend(document.getElementById("answered_by_level_sla_on_time_legend"), data['on_time']);
  };


  var ajaxCallanswered_by_level_sla = function(tracker_id, date_from, date_to) {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/answered_by_level_sla",
      data: {
        widget_id: 'answered_by_level_sla',
        project_id: project_id,
        tracker_id: tracker_id,
        date_from: date_from,
        date_to: date_to
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(success_closed)
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    });
  };

  var reload_chart_with_filter= function() {
    var tracker_id = $('#filter_tracker_id')[0].value;
    var date_from = $('#filter_range_date_from')[0].value;
    var date_to = $('#filter_range_date_to')[0].value;

    ajaxCallanswered_by_level_sla(tracker_id, date_from, date_to);
  }

  $('#redmine-dashboard-refresh-filters-button').on('click', reload_chart_with_filter);

  ajaxCallanswered_by_level_sla();

});

$( document ).ready(function() {

  var chart_closed;

  var success_closed = function( data ) {
    var options = {
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
    if(chart_closed != null){
      chart_closed.destroy();
    }
    chart_closed = new Chart(document.getElementById("answered_by_projectChart").getContext("2d")).StackedBar(data, options);
    legend(document.getElementById("answered_by_project_legend"), data);
  };


  var ajaxCallanswered_by_project = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/answered_by_project",
      data: {
        project_id: project_id,
        widget_id: 'answered_by_project'
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
    }).done(function( data ) {
      setTimeout(function(){ajaxCallanswered_by_project();}, 86400000);
    });
  };

  ajaxCallanswered_by_project();

});

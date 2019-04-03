$( document ).ready(function() {
  var ctx = document.getElementById("aging_per_atendentChart").getContext("2d");

  var myChart;
  var success = function( data ) {
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

    myChart = new Chart(ctx).StackedBar(data, options);
    legend(document.getElementById("aging_per_atendent_legend"), data);
  };


  var ajaxCallaging_per_atendent = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/aging_per_atendent",
      dataType: 'json',
      data: {
        project_id: project_id,
        widget_id:'aging_per_atendent'
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
      setTimeout(function(){ajaxCallaging_per_atendent();}, 86400000);
    });
  };

  ajaxCallaging_per_atendent();

});

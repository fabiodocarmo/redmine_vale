$( document ).ready(function() {

  var chart_weekly;

  var success_weekly = function( data ) {
    var options = {
      //Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
      //scaleBeginAtZero : true,

      //Boolean - Whether grid lines are shown across the chart
      //scaleShowGridLines : true,

      //String - Colour of the grid lines
      //scaleGridLineColor : "rgba(0,0,0,.05)",

      //Number - Width of the grid lines
      //scaleGridLineWidth : 1,

      //Boolean - Whether to show horizontal lines (except X axis)
      //scaleShowHorizontalLines: true,

      //Boolean - Whether to show vertical lines (except Y axis)
      //scaleShowVerticalLines: true,

      //Boolean - If there is a stroke on each bar
      //barShowStroke : true,

      //Number - Pixel width of the bar stroke
      //barStrokeWidth : 2,

      //Number - Spacing between each of the X value sets
      //barValueSpacing : 5,

      //Number - Spacing between data sets within X values
      //barDatasetSpacing : 1,

      //String - A legend template
      // legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    };
    if(chart_weekly != null){
      chart_weekly.destroy();
    }
    //console.log(document.getElementById("weekly_by_fornecChart"));
    chart_weekly = new Chart(document.getElementById("weekly_progress_by_contactChart").getContext("2d")).Bar(data, options);
    legend(document.getElementById("weekly_progress_by_contact_legend"), data);
  };


  var ajaxCallweekly_progress = function(date_from, date_to, customer) {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados/weekly_progress_by_contact",
      data: {
        customer: customer,
        date_from: date_from,
        date_to: date_to,
        project_id: project_id,
        widget_id: 'weekly_progress_by_contact'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(success_weekly)
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallweekly_progress(customer);}, 86400000);
    });
  };

  var load_weekly_progress_by_contact_chart = function() {
    var customer = $("#suppliers").val();
    var date_from = $('#filter_range_date_from')[0].value;
    var date_to = $('#filter_range_date_to')[0].value;
    if(customer != ""){
      ajaxCallweekly_progress(date_from, date_to, customer);
    }
    else{
      ajaxCallweekly_progress(date_from, date_to);
    }
  }

  $("#suppliers").change(load_weekly_progress_by_contact_chart);

  $('#redmine-dashboard-refresh-filters-button').on('click', load_weekly_progress_by_contact_chart);

  ajaxCallweekly_progress();
});

$( document ).ready(function() {
  // MAIN CHART

  var chartReopenedIssues;

  var success = function( data ) {
    var options = {};

    if(chartReopenedIssues != null){
      chartReopenedIssues.destroy();
    }
    chartReopenedIssues = new Chart(document.getElementById("customer_by_reopened_issuesChart").getContext("2d")).Bar(data, options);
    legend(document.getElementById("customer_by_reopened_issues_legend"), data);

    $("#customer_by_reopened_issues_start_date").text(data.range_date_from);
    $("#customer_by_reopened_issues_end_date").text(data.range_date_to);
    $("#customer_by_reopened_issuesChart_total").text(data.total);
  };

  var ajaxCallcustomer_by_reopened_issues = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    var date_from = $('#filter_range_date_from')[0].value;
    var date_to = $('#filter_range_date_to')[0].value;
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_reopened_issues",
      dataType: 'json',
      type: 'GET',
      data: {
        project_id: project_id,
        widget_id: 'customer_by_reopened_issues',
        date_from: date_from,
        date_to: date_to
      },
      xhrFields: { 'withCredentials': true },
      crossDomain: true
    }).success(success)
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallcustomer_by_reopened_issues();}, 86400000);
    });
  };

  $('#redmine-dashboard-refresh-filters-button').on('click', ajaxCallcustomer_by_reopened_issues);

  ajaxCallcustomer_by_reopened_issues();
});

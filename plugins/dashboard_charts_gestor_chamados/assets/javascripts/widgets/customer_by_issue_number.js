$( document ).ready(function() {
  // MAIN CHART
  var success = function( data ) {
    var options = {};
    new Chart(document.getElementById("customer_by_issue_numberChart").getContext("2d")).StackedBar(data, options);
    legend(document.getElementById("customer_by_issue_number_legend"), data);
  };

  var ajaxCallcustomer_by_issue_number = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_number",
      dataType: 'json',
      type: 'GET',
      xhrFields: { 'withCredentials': true },
      crossDomain: true
    }).success(success)
    .error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallcustomer_by_issue_number();}, 86400000);
    });
  };

  ajaxCallcustomer_by_issue_number();

  // TOTAL

  var ajaxCallTotalIssueNumberByCustomers = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_number_total",
      dataType: 'json',
      type: 'GET',
      xhrFields: { 'withCredentials': true },
      crossDomain: true
    }).success(function(data) {
      $("#customer_by_issue_numberChart_total_nf").text(data[1]);
      $("#customer_by_issue_numberChart_total_snf").text(data[0]);
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallcustomer_by_issue_number();}, 86400000);
    });
  };

  ajaxCallTotalIssueNumberByCustomers();
  // OTHER CHARTS

  var customerSuccess = function(data, customer_number) {
    new Chart(document.getElementById("customer_by_issue_numberChart_"+customer_number).getContext("2d")).Bar(data, {});
    legend(document.getElementById("customer_by_issue_number_"+customer_number+"_legend"), data);
  };

  var ajaxCallCustomersByIssueNumber = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_number_list",
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      container = $("#customer_by_issue_number").parent();

      for(var i=0; i < data.length; i++) {
        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>"+data[i]["social_name"]+"</h2>");
        var canvas = $("<canvas id='customer_by_issue_numberChart_"+i+"' width='1000' height='400'></canvas>");
        var legend = $("<div  id='customer_by_issue_number_"+i+"_legend' class='legend' style='float: right;' width='50' ></div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallcustomer_by_issue_number_monthly_progress(data[i], i);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  var ajaxCallcustomer_by_issue_number_monthly_progress = function(customer, customer_number) {
    var project_id = getUrlParameter('project_id');
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_number_monthly_progress/",
      data: {
        customer: customer,
        project_id: project_id,
        widget_id: 'customer_by_issue_value'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      customerSuccess(data, customer_number);
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  ajaxCallCustomersByIssueNumber();
});

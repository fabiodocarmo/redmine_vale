$( document ).ready(function() {
  // MAIN CHART
  var success = function( data ) {
    var options = {
      scaleLabel : "<%= value.toString().toCurrency() %>",
      multiTooltipTemplate: "<%if (datasetLabel){%><%=datasetLabel%>: <% } %><%= value.toString().toCurrency() %>"
    };
    new Chart(document.getElementById("customer_by_issue_valueChart").getContext("2d")).StackedBar(data, options);
    legend(document.getElementById("customer_by_issue_value_legend"), data);
  };

  var ajaxCallcustomer_by_issue_value = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_value",
      dataType: 'json',
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
      setTimeout(function(){ajaxCallcustomer_by_issue_value();}, 86400000);
    });
  };

  ajaxCallcustomer_by_issue_value();

  // TOTAL
  var ajaxCallTotalIssueNumberByCustomers = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_value_total",
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data) {
      $("#customer_by_issue_valueChart_total_nf").text(data[1].toString().toCurrency());
      $("#customer_by_issue_valueChart_total_snf").text(data[0].toString().toCurrency());
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallcustomer_by_issue_value();}, 86400000);
    });
  };

  ajaxCallTotalIssueNumberByCustomers();

  // OTHER CHARTS
  var customerSuccess = function(data, customer_value) {
    var options = {
      scaleLabel : "<%= value.toString().toCurrency() %>",
      multiTooltipTemplate: "<%if (datasetLabel){%><%=datasetLabel%>: <% } %><%= value.toString().toCurrency() %>"
    }
    new Chart(document.getElementById("customer_by_issue_valueChart_"+customer_value).getContext("2d")).Bar(data, options);
    legend(document.getElementById("customer_by_issue_value_"+customer_value+"_legend"), data);
  };

  var ajaxCallCustomersByIssueNumber = function() {
    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_value_list",
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(function(data){
      container = $("#customer_by_issue_value").parent();

      for(var i=0; i < data.length; i++) {
        var div    = $("<div class='redimine-widget'></div>");
        var title  = $("<h2>"+data[i]+"</h2>");
        var canvas = $("<canvas id='customer_by_issue_valueChart_"+i+"' width='1000' height='400'></canvas>");
        var legend = $("<div  id='customer_by_issue_value_"+i+"_legend' class='legend' style='float: right;' width='50' ></div>");

        div.append(title);
        div.append(canvas);
        div.append(legend);

        container.append(div);
        window.msnry.appended(div);
        window.msnry.layout();
        window.fixCanvas();

        ajaxCallcustomer_by_issue_value_monthly_progress(data[i], i);
      }
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  var ajaxCallcustomer_by_issue_value_monthly_progress = function(customer, customer_value) {
    var project_id = getUrlParameter('project_id');

    $.ajax({
      url: "../../dashboard/gestor_chamados/customer_by_issue_value_monthly_progress/",
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
      customerSuccess(data, customer_value);
    }).error(function(xhr, status, error) {
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {});
  };

  ajaxCallCustomersByIssueNumber();

});

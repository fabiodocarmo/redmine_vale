$( document ).ready(function() {
  var success = function( data ) {
    var options = {
      scaleLabel : "<%= value.toString().toCurrency() %>",
      multiTooltipTemplate: "<%if (datasetLabel){%><%=datasetLabel%>: <% } %><%= value.toString().toCurrency() %>"
    };
    new Chart(document.getElementById("free_moneyChart").getContext("2d")).StackedBar(data, options);
    legend(document.getElementById("free_money_legend"), data);
  };


  var ajaxCallfree_money = function() {
    var project_id = window.location.search.split("&")[1].split("=")[1];
    $.ajax({
      url: "../../dashboard/gestor_chamados_vale/free_money",
      data: {
        project_id: project_id,
        widget_id: 'free_money'
      },
      dataType: 'json',
      type: 'GET',
      xhrFields: {
        'withCredentials': true
      },
      crossDomain: true
    }).success(success)
    .error(function(xhr, status, error) {
      $("#free_moneyChart").parent().parent().append("<p> O seu usuário não tem permissão de acesso.</p>");
      $("#free_moneyChart").parent().remove();
      console.log(error);
      console.log(xhr);
    }).done(function( data ) {
      setTimeout(function(){ajaxCallfree_money();}, 86400000);
    });
  };

  ajaxCallfree_money();
});

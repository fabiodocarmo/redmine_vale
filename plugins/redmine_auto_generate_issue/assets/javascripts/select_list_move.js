function moveOptions(theSelFrom, theSelTo) {
  $(theSelFrom).find('option:selected').detach().prop("selected", false).appendTo($(theSelTo));
}
function selectAllOptions(id) {
  $('#'+id).find('option').prop('selected', true);
}

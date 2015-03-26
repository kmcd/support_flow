$(function() {
  $('a[data-form]').click( function(){
    $( $(this).data('form') ).submit()
  })
  
  $('form.add-label button.cancel').click( function(){
    $('form.add-label').addClass('hide')
  })
  
  $('button.add-label').click( function() {
    $('form.add-label').removeClass('hide')
    $("form.add-label input#request-label").focus()
  })
  
  $('button.name-edit').click( function() {
      $(".request.row .name").toggle()
      $("form.name-edit").removeClass('hide')
  })
  
  $('form.name-edit button.cancel').click( function() {
      $(".request.row .name").toggle()
      $(".request.row form.name-edit").addClass('hide')
  })
});

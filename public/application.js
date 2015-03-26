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
});


$('button.add-label').click( function() {
    console.log( $(this) )
})

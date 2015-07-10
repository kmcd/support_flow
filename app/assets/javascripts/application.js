// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require bootstrap.min
//= require rails
//= require jquery.remotipart
//= require admin_lte.min
//= require redactor
//= require jquery.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require_tree .

$(function() {
  $('.search .filter a').click( function() {
    facet = $(this).data('facet')
    $("form#search input#query").attr('value', facet )
    $("form#search").submit()
  })
  
  $('.reply.dropdown-menu a').click( function() {
    email = $(this).data('email')
    recipient_list = $("#email_outbound_recipients").val()
    
    if ( !recipient_list.match( email ) ) {
      recipient_list +=  ' '
      recipient_list += email
      recipient_list +=  ' '
    }
    
    $("#email_outbound_recipients").val(recipient_list)
    $('#new_email_outbound').removeClass('hidden')
    $('#new_email_outbound').fadeIn(125)
  })
  
  $('#email_outbound_message_content').redactor({
    focus: false,
    minHeight: 250,
    replaceDivs: false,
    deniedTags: [],
    removeEmpty: false,
    replaceTags: [],
    pastePlainText: true,
    plugins: ['table', 'imagemanager', 'filemanager', 'definedlinks']
  })

  $("#email_outbound_attachments").change( function() {
    $("#new_email_outbound").submit()
  })
  
  $('#new_email_outbound button.cancel').click( function() {
     $('#new_email_outbound').addClass('hidden')
     $('#new_email_outbound').trigger("reset")
  })
});

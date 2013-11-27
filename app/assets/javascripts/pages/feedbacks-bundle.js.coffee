$(document).on(
  "click"
  ".openFeedback"
  ->
    title = $(this).data('title')
    content = $(this).data('content')
    email = $(this).data('email')
    $(".modal-header h3").text( title );
    $(".modal-body .content").text( content );
    $(".modal-body .email").text( email );
)

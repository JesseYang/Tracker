#= require bootstrap-datetimepicker.js
#= require bootstrap-datetimepicker.zh-CN.js

$ ->

  $(".check-data").click ->
    $("#showDataModal").modal("show")
    $("#showDataModal .show-folder").html($(this).closest("tr").find(" .folder").html())
    $("#showDataModal .show-filename").html($(this).closest("tr").find(" .filename").html())
    $("#showDataModal .show-data").html($(this).closest("tr").attr("data-data"))

  $(".form_datetime").datetimepicker
    language:  'zh-CN',
    weekStart: 1
    todayBtn: 1
    autoclose: 1
    todayHighlight: 1
    startView: 2
    forceParse: 0
    showMeridian: 1
  $("#start_input_shown").val(window.start_str)
  $("#end_input_shown").val(window.end_str)

  $(document).on(
    "click"
    ".bs_detail_td a"
    ->
      $.get(
        '/logs/' + $(this).data("log-id") + '/bs_detail',
        {},
        (retval) ->
          $("#bs_detail .modal-content").html(retval)
      )
  )

//= require 'utility/ajax'

$ ->
  $("[name='enable-checkbox']").bootstrapSwitch()

  $(".enable-checkbox").on "switch-change", (e, data) ->
    value = data.value
    fence_id = $(this).data("fence-id")
    device_id = $(this).data("device-id")
    $.postJSON(
      '/devices/' + device_id + '/fences/' + fence_id + '/enable',
      { enabled: value },
      (retval) ->
    )
    console.log fence_id
    console.log value

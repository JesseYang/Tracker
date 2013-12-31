#= require utility/ajax
$ ->
  map = null
  size = new soso.maps.Size(42, 68)
  origin = new soso.maps.Point(0, 0)
  # anchor = new soso.maps.Point(0, 39)
  anchor = new soso.maps.Point(10, 30)
  end_marker = null
  start_marker = null
  interval = 1000
  demo_log_index = 2
  log_length = 0
  updateLog = -> 
    # use ajax to get the logs and refresh the map
    $.getJSON(
      '/devices/' + window.device_id + '/show_map.json',
      { demo: window.demo,
      log_index: demo_log_index,
      start_time: $("#start_input").val(),
      end_time: $("#end_input").val() },
      (retval) ->
        if window.demo == "true"
          demo_log_index += 1
        path = []
        for log in retval.logs
          path.push(new soso.maps.LatLng(log.lat_offset, log.lng_offset))
        if log_length != retval.logs.length
          polyline = new soso.maps.Polyline({
            path: path,
            strokeColor: '#000000',
            strokeWeight: 5,
            editable:false,
            map: map
          })

          end_marker.setVisible(false) # hide the previous marker
          end_log = retval.logs[retval.logs.length-1]
          end_p = new soso.maps.LatLng(end_log.lat_offset, end_log.lng_offset);
          end_marker = new soso.maps.Marker({
            position: end_p,
            map: map
          });
          end_icon =  new soso.maps.MarkerImage(
            "/assets/end.png", 
            size,
            origin,
            anchor
          );
          end_marker.setIcon(end_icon);
        log_length = retval.logs.length
    ) 
    setTimeout(updateLog, interval)

  initialize = ->
    center = new soso.maps.LatLng(window.center[0], window.center[1])
    map = new soso.maps.Map(document.getElementById('container'),{
      center: center,
      zoom: window.zoom})

    if window.start != ""
      start = window.start.split(',')
      start_p = new soso.maps.LatLng(start[0], start[1])
      start_marker = new soso.maps.Marker({
        position: start_p,
        map: map
      });
      start_icon =  new soso.maps.MarkerImage(
        "/assets/start.png", 
        size,
        origin,
        anchor
      );
      start_marker.setIcon(start_icon);
    end

    if window.end != ""
      end = window.end.split(',')
      end_p = new soso.maps.LatLng(end[0], end[1]);
      end_marker = new soso.maps.Marker({
        position: end_p,
        map: map
      });
      end_icon =  new soso.maps.MarkerImage(
        "/assets/end.png", 
        size,
        origin,
        anchor
      );
      end_marker.setIcon(end_icon);
    end

    path = []
    logs = window.logs.split('-')
    for log in logs
      log = log.split(',')
      path.push(new soso.maps.LatLng(log[0], log[1]))
    polyline = new soso.maps.Polyline({
      path: path,
      strokeColor: '#000000',
      strokeWeight: 5,
      editable:false,
      map: map
    })

    setTimeout(updateLog, interval)

  initialize()

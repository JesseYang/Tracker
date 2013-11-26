$ ->
  center = new soso.maps.LatLng(window.center[0], window.center[1])
  map = new soso.maps.Map(document.getElementById('container'),{
    center: center,
    zoom: window.zoom})

  size = new soso.maps.Size(42, 68)
  origin = new soso.maps.Point(0, 0)
  anchor = new soso.maps.Point(0, 39)

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

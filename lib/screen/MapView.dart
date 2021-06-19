import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:map/map.dart';
import 'package:latlng/latlng.dart';

class MapView extends StatefulWidget {
  const MapView({ Key? key }) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final controller = MapController(
    location: LatLng(40.95960999543293, 29.186246694478328)
  );

  Offset? _dragStart;
  double _scaleStart = 1.0;
  double lat = 40.95960999543293, long = 29.186246694478328;
  String address = ""; 
  bool loading = false;
  void _onScaleStart(ScaleStartDetails details){
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details){
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0)
      controller.zoom += 0.02;
    else if (scaleDiff < 0)
      controller.zoom -= 0.02;
    else{
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      controller.drag(diff.dx, diff.dy);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) async{
    try{
      setState(() {loading = true;});
      lat = controller.center.latitude;
      long = controller.center.longitude;
      GeoCode geocode = GeoCode();
      Address add = await geocode.reverseGeocoding(latitude: lat, longitude: long);
      address = (add.countryName ?? '')+' - '+(add.region ?? '')+' - '+(add.city ?? '')+' - '+(add.streetAddress ?? '');
    }
    finally{
      setState(() {loading = false;});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: Map(
                controller: controller,
                builder: (context, x, y, z){
                  final url = 'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                  );
                }, 
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                    height: 50,
                    minWidth: 50,
                    color: Colors.blue,
                    child: Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: ()=>controller.zoom += 0.2
                  ),
                  SizedBox(height: 3),
                  MaterialButton(
                    height: 50,
                    minWidth: 50,
                    color: Colors.blue,
                    child: Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: ()=>controller.zoom -= 0.2
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Icon(Icons.location_on_outlined, size: 38, color: Colors.red,),
          ),
          Positioned(
            bottom: 10,
            left: (MediaQuery.of(context).size.width * 0.5) - (MediaQuery.of(context).size.width * 0.37),
            child: Card(
              elevation: 12,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 75,
                padding: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Lat: $lat , Long: $long'),
                    loading
                      ? CupertinoActivityIndicator()
                      : Text('$address')
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
part of three;

class CSS3DObject extends Object3D {

  Element element;

  CSS3DObject( this.element ) : super() {
    element.style.position = "absolute";
    element.style.transformStyle = "preserve-3d";
  }
}

class CSS3DRenderer implements Renderer {
  Projector _projector;
  Element domElement;
  Element cameraElement;
  num _width, _height, _widthHalf, _heightHalf;

  CSS3DRenderer() {

     _projector = new Projector();

    domElement = new Element.tag( 'div' )
    ..style.overflow = 'hidden'
    ..style.transformStyle = 'preserve-3d'
    ..style.perspectiveOrigin = '50% 50%';

    // TODO: Shouldn't it be possible to remove cameraElement?

    cameraElement = new Element.tag( 'div' )
    ..style.transformStyle = 'preserve-3d';

    domElement.children.add( cameraElement );
  }

  setSize( num width, num height ) {

    _width = width;
    _height = height;

    _widthHalf = _width / 2;
    _heightHalf = _height / 2;

    domElement.style
    ..width = '${width}px'
    ..height = '${height}px';

    cameraElement.style
    ..width = '${width}px'
    ..height = '${height}px';

  }

  epsilon( num value ) => ( value.abs() < 0.000001 ) ? 0 : value;

  getCameraCSSMatrix( matrix ) {

    return 'matrix3d('
          '${epsilon( matrix[ 0 ] )},'
          '${epsilon( - matrix[ 1 ] )},'
          '${epsilon( matrix[ 2 ] )},'
          '${epsilon( matrix[ 3 ] )},'
          '${epsilon( matrix[ 4 ] )},'
          '${epsilon( - matrix[ 5 ] )},'
          '${epsilon( matrix[ 6 ] )},'
          '${epsilon( matrix[ 7 ] )},'
          '${epsilon( matrix[ 8 ] )},'
          '${epsilon( - matrix[ 9 ] )},'
          '${epsilon( matrix[ 10 ] )},'
          '${epsilon( matrix[ 11 ] )},'
          '${epsilon( matrix[ 12 ] )},'
          '${epsilon( - matrix[ 13 ] )},'
          '${epsilon( matrix[ 14 ] )},'
          '${epsilon( matrix[ 15 ] )}'
          ')';
  }

  static bool _isIE ;
  
  static bool isIE() {
    if ( _isIE == null ) {
      String s = window.navigator.userAgent ;
      
      if ( s.contains('MSIE') ) {
        _isIE = true ;
      }
      else {
        _isIE = s.indexOf(new RegExp(r'Trident/7')) >= 0 && s.indexOf(new RegExp(r'rv:\d+')) >= 0 ;
      }
    }
    return _isIE ;
  }
  
  bool _fixIEPerspective = isIE() ;
  
  static int perspCount = 0 ;
  
  static void incrementPerspCount() {
    perspCount++ ;
    if (perspCount > 10) perspCount = 0 ;
  }
  
  getObjectCSSMatrix( matrix , Vector3 camTrans , Element element ) {
    
    if (_fixIEPerspective && matrix is Matrix4) {
      
      int w = element.clientWidth ;
      int h = element.clientHeight ;
      
      double tXr = ( ( (_widthHalf+camTrans.x) / _width) * 200 ) -100 ;
      double tYr = ( ( (_heightHalf+camTrans.y) / _height) * 200 ) -100 ;
      
      String perspTrans = ' translate3d(${tXr}%,${tYr}%,0px) ';
      
      perspTrans = ' translate3d(${ ( (perspCount*20)-100 ) }%,0px,0px) ';
      
      return ' perspective(1500px) $perspTrans matrix3d('
          '${epsilon( matrix[ 0 ] )},'
          '${epsilon( matrix[ 1 ] )},'
          '${epsilon( matrix[ 2 ] )},'
          '${epsilon( matrix[ 3 ] )},'
          '${epsilon( matrix[ 4 ] )},'
          '${epsilon( matrix[ 5 ] )},'
          '${epsilon( matrix[ 6 ] )},'
          '${epsilon( matrix[ 7 ] )},'
          '${epsilon( matrix[ 8 ] )},'
          '${epsilon( matrix[ 9 ] )},'
          '${epsilon( matrix[ 10 ] )},'
          '${epsilon( matrix[ 11 ] )},'
          '${epsilon( matrix[ 12 ] )},'
          '${epsilon( matrix[ 13 ] )},'
          '${epsilon( matrix[ 14 ] )},'
          '${epsilon( matrix[ 15 ] )}'
          ') scale3d(1,-1,1) '; 
    }
    
    return 'translate3d(-50%,-50%,0px) matrix3d('
          '${epsilon( matrix[ 0 ] )},'
          '${epsilon( matrix[ 1 ] )},'
          '${epsilon( matrix[ 2 ] )},'
          '${epsilon( matrix[ 3 ] )},'
          '${epsilon( matrix[ 4 ] )},'
          '${epsilon( matrix[ 5 ] )},'
          '${epsilon( matrix[ 6 ] )},'
          '${epsilon( matrix[ 7 ] )},'
          '${epsilon( matrix[ 8 ] )},'
          '${epsilon( matrix[ 9 ] )},'
          '${epsilon( matrix[ 10 ] )},'
          '${epsilon( matrix[ 11 ] )},'
          '${epsilon( matrix[ 12 ] )},'
          '${epsilon( matrix[ 13 ] )},'
          '${epsilon( matrix[ 14 ] )},'
          '${epsilon( matrix[ 15 ] )}'
          ') scale3d(1,-1,1)';

  }

  
  render( scene, camera ) {

    var fov = 0.5 / Math.tan( camera.fov * Math.PI / 360 ) * _height;

    
  
    var style ;
    
    if (_fixIEPerspective) {
      domElement.style.perspective = "${fov}px";
      style = "translate3d(0px,0px,${fov}px) ${getCameraCSSMatrix( camera.matrixWorldInverse )} translate3d(50%, 50%, 0px) ";
    }
    else {
      domElement.style.perspective = "${fov}px";
      style = "translate3d(0px,0px,${fov}px) ${getCameraCSSMatrix( camera.matrixWorldInverse )} translate3d(${_widthHalf}px,${_heightHalf}px, 0px)";
    }
    
    cameraElement.style.transform = style ;
    
    Matrix4 camM = camera.matrixWorldInverse ;
    
    Vector3 camTrans = camM.getTranslation() ;
    
    var objects = _projector.projectScene( scene, camera, false ).objects;

    var il = objects.length;

    for ( var i = 0; i < il; i ++ ) {

      var object = objects[ i ].object;

      if ( object is CSS3DObject ) {

        var element = object.element;

        style = getObjectCSSMatrix( object.matrixWorld , camTrans , object.element );
        
        element.style.transform = style;
        
        if ( element.parent != cameraElement ) {
          cameraElement.children.add( element );
        }
      }
    }
  }

}

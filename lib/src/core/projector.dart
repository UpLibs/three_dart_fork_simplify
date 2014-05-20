part of three;

/**
 * @author mr.doob / http://mrdoob.com/
 * @author supereggbert / http://www.paulbrunt.co.uk/
 * @author julianwa / https://github.com/julianwa
 *
 * Ported to Dart from JS by:
 * @author rob silverton / http://www.unwrong.com/
 * @author nelson silva / http://www.inevo.pt
 *
 * updated to 81ef5c3b32 - Made Projector.projectObject more open for custom rendererers.
 */

class Projector {
  List<RenderableObject>_objectPool;
  List<RenderableVertex> _vertexPool;

  int _objectCount, _vertexCount, _face3Count, _face4Count, _lineCount, _particleCount;

  RenderableObject _object;
  RenderableVertex _vertex;

  Vector3 _vector3;
  Vector4 _vector4;

  Vector4 _clippedVertex1PositionScreen;
  Vector4 _clippedVertex2PositionScreen;

  ProjectorRenderData _renderData;

  Matrix4 _viewProjectionMatrix, _modelViewProjectionMatrix;

  Frustum _frustum;

  Projector()
      : _objectPool = [],
        _vertexPool = [],

        //_renderData = { "objects": [], "sprites": [], "lights": [], "elements": [] };
        _renderData = new ProjectorRenderData(),

        _vector3 = new Vector3.zero(),
        _vector4 = new Vector4(0.0, 0.0, 0.0, 1.0),

        _viewProjectionMatrix = new Matrix4.identity(),
        _modelViewProjectionMatrix = new Matrix4.identity(),

        _frustum = new Frustum(),

        _clippedVertex1PositionScreen = new Vector4(0.0, 0.0, 0.0, 1.0),
        _clippedVertex2PositionScreen = new Vector4(0.0, 0.0, 0.0, 1.0);

  Vector3 projectVector( Vector3 vector, Camera camera ) {
    camera.matrixWorldInverse.copyInverse(camera.matrixWorld);

    _viewProjectionMatrix = camera.projectionMatrix * camera.matrixWorldInverse;

    return vector.applyProjection(_viewProjectionMatrix);
  }

  Vector3 unprojectVector( Vector3 vector, Camera camera ) {
    camera.projectionMatrixInverse.copyInverse(camera.projectionMatrix);

    _viewProjectionMatrix = camera.matrixWorld * camera.projectionMatrixInverse;

    return vector.applyProjection(_viewProjectionMatrix);
  }

  _projectObject( Object3D parent ) {
    var cl = parent.children.length;
    for ( var c = 0; c < cl; c ++ ) {

      var object = parent.children[ c ];

      if ( !object.visible ) continue;

      {

        _object = getNextObjectInPool();
        _object.object = object;

        if ( object.renderDepth != null ) {

          _object.z = object.renderDepth;

        } else {

          _vector3 = object.matrixWorld.getTranslation();
          _vector3.applyProjection(_viewProjectionMatrix);
          _object.z = _vector3.z;

        }

        _renderData.objects.add( _object );

      }

      _projectObject( object );
    }
  }

  ProjectorRenderData projectGraph( Object3D root, bool sort ) {
    _objectCount = 0;

    _renderData.objects = [];
    _renderData.sprites = [];
    _renderData.lights = [];

    _projectObject( root );

    //TODO: assuming this is a form of 'if' statement.
    //sort && _renderData.objects.sort( painterSort );

    if (sort) {
      _renderData.objects.sort( painterSort );
    }

    return _renderData;
  }


  ProjectorRenderData projectScene( Scene scene, Camera camera, bool sort ) {
    num near = camera.near, far = camera.far;
    bool visible = false;
    int o, ol, v, vl, f, fl, n, nl, c, cl, u, ul;
    Object3D object;
    Matrix4 modelMatrix, rotationMatrix;
    List<Vector3> vertices;
    Vector3 vertex;
    Vector3 vertexPositionScreen, normal;
    RenderableVertex v1, v2, v3, v4;
    bool isFaceMaterial;
    int side;

    _face3Count = 0;
    _face4Count = 0;
    _lineCount = 0;
    _particleCount = 0;

    _renderData.elements = [];

    scene.updateMatrixWorld();

    if ( camera.parent == null ) {
      // console.warn( 'DEPRECATED: Camera hasn\'t been added to a Scene. Adding it...' );
      // scene.add( camera );
      camera.updateMatrixWorld();
    }

    camera.matrixWorldInverse.copyInverse(camera.matrixWorld);

    _viewProjectionMatrix = camera.projectionMatrix * camera.matrixWorldInverse;

    _frustum.setFromMatrix( _viewProjectionMatrix );

    _renderData = projectGraph( scene, false );

    if ( sort ) {
      _renderData.elements.sort( painterSort );
    }

    return _renderData;
  }

  // Pools
  RenderableObject getNextObjectInPool() {
    //TODO: make sure I've interpreted this logic correctly
    // RenderableObject object = _objectPool[ _objectCount ] = _objectPool[ _objectCount ] || new RenderableObject();

    RenderableObject object;
    if ( _objectCount < _objectPool.length ) {
      object = ( _objectPool[ _objectCount ] != null ) ? _objectPool[ _objectCount ] : new RenderableObject();
    } else {
      object = new RenderableObject();
      _objectPool.add(object);
    }

    _objectCount ++;

    return object;
  }

  RenderableVertex getNextVertexInPool() {
    //TODO: make sure I've interpreted this logic correctly
    // var vertex = _vertexPool[ _vertexCount ] = _vertexPool[ _vertexCount ] || new THREE.RenderableVertex();
    RenderableVertex vertex;

    // Vertex is already within List
    if ( _vertexCount < _vertexPool.length ) {
      vertex = ( _vertexPool[ _vertexCount ] != null ) ? _vertexPool[ _vertexCount ] : new RenderableVertex();
    } else {
      vertex = new RenderableVertex();
      _vertexPool.add(vertex);
    }

    _vertexCount ++;

    return vertex;
  }

  int painterSort( a, b ) => b.z.compareTo(a.z);

  bool clipLine( Vector4 s1, Vector4 s2 ) {
    double alpha1 = 0.0, alpha2 = 1.0,

    // Calculate the boundary coordinate of each vertex for the near and far clip planes,
    // Z = -1 and Z = +1, respectively.
    bc1near =  s1.z + s1.w,
    bc2near =  s2.z + s2.w,
    bc1far =  - s1.z + s1.w,
    bc2far =  - s2.z + s2.w;

    if ( bc1near >= 0 && bc2near >= 0 && bc1far >= 0 && bc2far >= 0 ) {
      // Both vertices lie entirely within all clip planes.
      return true;
    } else if ( ( bc1near < 0 && bc2near < 0) || (bc1far < 0 && bc2far < 0 ) ) {
      // Both vertices lie entirely outside one of the clip planes.
      return false;
    } else {
      // The line segment spans at least one clip plane.
      if ( bc1near < 0 ) {
        // v1 lies outside the near plane, v2 inside
        alpha1 = Math.max( alpha1, bc1near / ( bc1near - bc2near ) );
      } else if ( bc2near < 0 ) {
        // v2 lies outside the near plane, v1 inside
        alpha2 = Math.min( alpha2, bc1near / ( bc1near - bc2near ) );
      }

      if ( bc1far < 0 ) {
        // v1 lies outside the far plane, v2 inside
        alpha1 = Math.max( alpha1, bc1far / ( bc1far - bc2far ) );
      } else if ( bc2far < 0 ) {
        // v2 lies outside the far plane, v2 inside
        alpha2 = Math.min( alpha2, bc1far / ( bc1far - bc2far ) );
      }

      if ( alpha2 < alpha1 ) {
        // The line segment spans two boundaries, but is outside both of them.
        // (This can't happen when we're only clipping against just near/far but good
        //  to leave the check here for future usage if other clip planes are added.)
        return false;
      } else {
        // Update the s1 and s2 vertices to match the clipped line segment.
        s1 = lerp4(s1, s2, alpha1 );
        s2 = lerp4(s2, s1, 1.0 - alpha2 );

        return true;
      }
    }
  }
}

// _renderData = { "objects": [], "sprites": [], "lights": [], "elements": [] };
class ProjectorRenderData {
  List objects, sprites, lights, elements;

  ProjectorRenderData()
      : objects = [],
        sprites = [],
        lights = [],
        elements = [];
}







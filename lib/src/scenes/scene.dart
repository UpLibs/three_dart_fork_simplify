part of three;

/**
 * @author mr.doob / http://mrdoob.com/
 *
 * Ported to Dart from JS by:
 * @author rob silverton / http://www.unwrong.com/
 */

class Scene extends Object3D {
  //bool matrixAutoUpdate;
  List<Object3D> objects;
  List __objectsAdded;
  List __objectsRemoved;

  Scene() {
    // TODO: check how to call super constructor
    // super();

    matrixAutoUpdate = false;

    objects = [];

    __objectsAdded = [];
    __objectsRemoved = [];
  }

  void addObject( Object3D object ) {
    if ( !( object is Camera ) ) {
      if ( objects.indexOf( object ) == - 1 ) {
        objects.add( object );
        __objectsAdded.add( object );

        // check if previously removed
        int i = __objectsRemoved.indexOf( object );

        if ( i != -1 ) {
          __objectsRemoved.removeAt(i);
        }
      }
    }

    for ( int c = 0; c < object.children.length; c ++ ) {
      addObject( object.children[ c ] );
    }
  }

  void removeObject( Object3D object ) {
    //TODO: "instanceof" replaced by "is"?
    if ( !( object is Camera ) ) {
      int i = objects.indexOf( object );

      if( i != -1 ) {
        objects.removeAt(i);
        __objectsRemoved.add( object );

        // check if previously added
        var ai = __objectsAdded.indexOf( object );

        if ( ai != -1 ) {
          __objectsAdded.removeAt(ai);
        }
      }
    }

    for ( int c = 0; c < object.children.length; c ++ ) {
      removeObject( object.children[ c ] );
    }
  }
}

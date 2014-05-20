library three;

import 'dart:async';
import 'dart:html' hide Path;
import 'dart:typed_data';
import 'dart:web_gl' as gl;
import 'dart:math' as Math;
import 'dart:convert' show JSON;

import 'src/core/three_math.dart' as ThreeMath;
export 'src/core/three_math.dart';

import 'package:vector_math/vector_math.dart';

part 'src/cameras/camera.dart';
part 'src/cameras/perspective_camera.dart';
part 'src/cameras/orthographic_camera.dart';

part 'src/core/vector_utils.dart';
part 'src/core/matrix_utils.dart';
part 'src/core/object3d.dart';
part 'src/core/color.dart';
part 'src/core/frustum.dart';
part 'src/core/morph_colors.dart';
part 'src/core/morph_target.dart';
part 'src/core/projector.dart';
part 'src/core/uv.dart';
part 'src/core/rectangle.dart';
part 'src/core/event_emitter.dart';

part 'extras/core/gyroscope.dart';

part 'extras/objects/lens_flare.dart';
part 'extras/objects/immediate_render_object.dart';

part 'src/renderers/renderables/renderable_object.dart';
part 'src/renderers/renderables/renderable_vertex.dart';

part 'src/renderers/renderer.dart';
part 'src/renderers/css3d_renderer.dart';

part 'src/renderers/renderables/irenderable.dart';

part 'src/scenes/scene.dart';
part 'src/scenes/fog.dart';
part 'src/scenes/fog_linear.dart';
part 'src/scenes/fog_exp2.dart';

part 'src/uv_mapping.dart';

// from _geometry
int GeometryCount = 0;

// from Object3D
int Object3DCount = 0;

// from _material
int MaterialCount = 0;

// GL STATE CONSTANTS

const int CullFaceNone = 0;
const int CullFaceBack = 1;
const int CullFaceFront = 2;
const int CullFaceFrontBack = 3;

const int FrontFaceDirectionCW = 0;
const int FrontFaceDirectionCCW = 1;

// SHADOWING TYPES

const int BasicShadowMap = 0;
const int PCFShadowMap = 1;
const int PCFSoftShadowMap = 2;


// MATERIAL CONSTANTS

// side
const int FrontSide = 0;
const int BackSide = 1;
const int DoubleSide = 2;

const int NoShading = 0;
const int FlatShading = 1;
const int SmoothShading = 2;

const int NoColors = 0;
const int FaceColors = 1;
const int VertexColors = 2;

// blending modes

const int NoBlending = 0;
const int NormalBlending = 1;
const int AdditiveBlending = 2;
const int SubtractiveBlending = 3;
const int MultiplyBlending = 4;
const int CustomBlending = 5;

// custom blending equations
// (numbers start from 100 not to clash with other
//  mappings to OpenGL constants defined in Texture.js)

const int AddEquation = 100;
const int SubtractEquation = 101;
const int ReverseSubtractEquation = 102;

// custom blending destination factors

const int ZeroFactor = 200;
const int OneFactor = 201;
const int SrcColorFactor = 202;
const int OneMinusSrcColorFactor = 203;
const int SrcAlphaFactor = 204;
const int OneMinusSrcAlphaFactor = 205;
const int DstAlphaFactor = 206;
const int OneMinusDstAlphaFactor = 207;

// custom blending source factors

const int DstColorFactor = 208;
const int OneMinusDstColorFactor = 209;
const int SrcAlphaSaturateFactor = 210;

// from MeshBasic_material

// from Texture
int TextureCount = 0;

const int MultiplyOperation = 0;
const int MixOperation = 1;

// Wrapping modes
const int RepeatWrapping = 0;
const int ClampToEdgeWrapping = 1;
const int MirroredRepeatWrapping = 2;

// Filters
const int NearestFilter = 3;
const int NearestMipMapNearestFilter = 4;
const int NearestMipMapLinearFilter = 5;
const int LinearFilter = 6;
const int LinearMipMapNearestFilter = 7;
const int LinearMipMapLinearFilter = 8;

// Data Types
const int ByteType = 9;
const int UnsignedByteType = 10;
const int ShortType = 11;
const int UnsignedShortType = 12;
const int IntType = 13;
const int UnsignedIntType = 14;
const int FloatType = 15;

// Pixel types
const int UnsignedShort4444Type = 1016;
const int UnsignedShort5551Type = 1017;
const int UnsignedShort565Type = 1018;

// Pixel Formats
const int AlphaFormat = 16;
const int RGBFormat = 17;
const int RGBAFormat = 18;
const int LuminanceFormat = 19;
const int LuminanceAlphaFormat = 20;

// Compressed texture formats
const int RGB_S3TC_DXT1_Format = 2001;
const int RGBA_S3TC_DXT1_Format = 2002;
const int RGBA_S3TC_DXT3_Format = 2003;
const int RGBA_S3TC_DXT5_Format = 2004;

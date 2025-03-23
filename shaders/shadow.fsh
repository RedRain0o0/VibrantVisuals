#version 460 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

/* DRAWBUFFERS:0 */

layout(location = 0) out vec4 outColor0;

in vec4 tangent;
in vec3 geoNormal;
in vec3 foliageColor;
in vec3 viewSpacePosition;
in vec2 texCoord;
in vec2 lightMapCoords;

mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
  vec3 bitangent = cross(tangent, normal);
  return mat3(tangent, bitangent, normal);
}

void main() {

  // Output prep
  vec4 outputColorData = pow(texture(gtexture, texCoord), vec4(2.2));
  vec3 outputColor = outputColorData.rgb * pow(foliageColor, vec3(2.2));
  float transparency = outputColorData.a;

  // Discard transparent fragments
  if (transparency < .1) {
    discard;
  }

  // Output
  outColor0 = vec4(pow(outputColor, vec3(1/2.2)), transparency);

}
#version 460

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

  vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

  vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

  vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

  vec4 normalData = texture(normals, texCoord)*2.0-1.0;

  vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0 - dot(normalData.xy, normalData.xy)));

  mat3 TBN = tbnNormalTangent(worldGeoNormal, worldTangent);

  vec3 normalWorldSpace = TBN * normalNormalSpace;

  vec4 specularData = texture(specular, texCoord);

  float perpetualSmoothness = specularData.r;

  float roughness = pow(1.0 - perpetualSmoothness, 2.0);
  
  vec3 reflectionDirection = reflect(shadowLightDirection,normalWorldSpace);

  vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;

  vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;

  vec3 viewDirection = normalize(cameraPosition - fragWorldSpace);

  float lightBrighness = clamp(dot(shadowLightDirection, normalWorldSpace),0.2,1.0);

  vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

  vec4 outputColorData = pow(texture(gtexture, texCoord), vec4(2.2));
  vec3 outputColor = outputColorData.rgb * pow(foliageColor, vec3(2.2)) * lightColor;
  float transparency = outputColorData.a;

  if (transparency < .1) {
    discard;
  }
  outputColor *= lightBrighness;
  outColor0 = vec4(pow(outputColor, vec3(1/2.2)), transparency);

}
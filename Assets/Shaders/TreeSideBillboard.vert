/* Copyright 2012-2020 Matthew Reid
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#version 420 core
#pragma import_defines ( ENABLE_CLOUDS )

#include "AtmosphericScattering.h"
#include "CloudShadows.h"
#include "DepthPrecision.h"
#include "GlobalDefines.h"
#include "Noise/FastRandom.h"

in vec4 osg_Vertex;

out vec2 texCoord;
out float perTreeUnitRandom;
out vec3 normal;
out float logZ;
out vec3 irradiance;
out vec3 transmittance;
out vec3 skyRadianceToPoint;

uniform mat4 osg_ModelViewProjectionMatrix;
uniform mat4 modelMatrix;
uniform float maxVisibilityRange;
uniform vec3 cameraPosition;
uniform vec3 lightDirection;

uniform samplerBuffer treeParamsSampler;
uniform sampler2D cloudSampler;

void main()
{
	vec4 pos = osg_Vertex;
	vec4 worldPos = modelMatrix * pos;
	
	vec3 posRelCamera = vec3(worldPos.xyz - cameraPosition);
	vec3 posRelCameraH = vec3(posRelCamera.x, posRelCamera.y, 0.0f);
	vec3 forwardDirH = normalize(posRelCameraH);
	
	vec3 upDir = vec3(0,0,-1);
	vec3 rightDir = cross(forwardDirH, upDir);
	float x = ((gl_VertexID + 1) % 4) > 1 ? 1.0f : 0.0f;
	float y = (gl_VertexID % 4) / 2;

	int id = gl_VertexID / 4;
	vec4 data = texelFetch(treeParamsSampler, id);
	float type = data.r;
	float height = data.g;
	float yawIndex = floor(7.999f * data.b * M_RCP_2PI);
	vec2 billboardSize = vec2(height * 0.5f, height);
	
	//float visibility = float(length(posRelCamera) < maxVisibilityRange);
	float visibility = clamp((maxVisibilityRange*1.1 - length(posRelCamera))*0.001, 0.0f, 1.0f);
	
	vec3 posOffset = rightDir * (x - 0.5) * billboardSize.x + upDir * y * billboardSize.y * visibility;
	pos.xyz += posOffset;
	
	gl_Position = osg_ModelViewProjectionMatrix * pos;
	texCoord = vec2(x, y);

	texCoord.x = (texCoord.x + yawIndex) / 8.0f;
	texCoord.y = (texCoord.y + type) / 4.0f;
	
	perTreeUnitRandom = randomFast1d(float(id));

	float horizontalNormalScale = 2.5; // scale normal so that it reaches 1 at the edge of the tree. This accounts for wasted texture space around the tree texture.
	normal = rightDir * 2.5 * (x - 0.5) + upDir * y;
	normal.xy -= forwardDirH.xy * sqrt(max(0.0, (1.0 - dot(normal,normal))));
	
	float occlusion = y;
	
	// Atmospheric scattering
	vec3 positionRelPlanet = worldPos.xyz - planetCenter;
	vec3 cameraPositionRelPlanet = cameraPosition - planetCenter;
	skyRadianceToPoint = GetSkyRadianceToPoint(cameraPositionRelPlanet, positionRelPlanet, 0, lightDirection, transmittance);
	vec3 skyIrradiance;
	vec3 sunIrradiance = GetSunAndSkyIrradiance(positionRelPlanet, lightDirection, skyIrradiance);
	
#ifdef ENABLE_CLOUDS
	sunIrradiance *= sampleCloudShadowMaskAtPositionRelPlanet(cloudSampler, positionRelPlanet, lightDirection);
#endif
	
	irradiance = (sunIrradiance + skyIrradiance) * occlusion;
	
	gl_Position.z = logarithmicZ(gl_Position.w);
	logZ = z_logarithmic(gl_Position.w);
}
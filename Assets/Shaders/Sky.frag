/* Copyright 2012-2020 Matthew Reid
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#version 440 core

#include "AtmosphericScattering.h"

in vec3 scattering;
in vec3 singleScattering;
in vec3 fragPosRelCamera;

uniform vec3 lightDirection;

void main(void)
{
	vec3 viewDir = normalize(fragPosRelCamera);
	gl_FragColor.rgb = GetSkyRadianceFromScattering(scattering, singleScattering, viewDir, lightDirection);
	gl_FragColor.a = 1.0;
}
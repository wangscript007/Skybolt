/* Copyright 2012-2020 Matthew Reid
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#include "UpdateLoop.h"

#include <SkyboltEngine/SimVisBinding/SimVisBinding.h>
#include <SkyboltCommon/Exception.h>

#include <osg/Stats>

#include <chrono>
#include <thread>

namespace skybolt {

UpdateLoop::UpdateLoop(float minFrameDuration) :
	mMinFrameDuration(minFrameDuration)
{
}

void UpdateLoop::exec(Updatable updatable, ShouldExit shouldExit)
{
	typedef std::chrono::duration<double> seconds;
	float prevElapsedTime = 0;

	while (!shouldExit())
	{
		// Get time delta
		float elapsed;
		while (true) // this loop enforces max frame rate
		{
			elapsed = seconds(std::chrono::high_resolution_clock::now().time_since_epoch()).count();
			if (elapsed - prevElapsedTime > mMinFrameDuration)
				break;
			std::this_thread::sleep_for(std::chrono::milliseconds(1));
		}

		float dtWallClock = elapsed - prevElapsedTime;
		prevElapsedTime = elapsed;

		if (!updatable(dtWallClock))
		{
			return;
		}
	}
}

} // namespace skybolt
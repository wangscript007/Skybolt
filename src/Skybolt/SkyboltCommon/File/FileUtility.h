/* Copyright 2012-2020 Matthew Reid
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#pragma once

#include <boost/filesystem.hpp>

#include <string>
#include <vector>

namespace skybolt {
namespace file {

using Path = boost::filesystem::path;

typedef std::vector<Path> Paths;

//! @returns paths of files with a specified extension in a directory
Paths findFilenamesInDirectory(const std::string &dir, const std::string &extension);

//! @returns paths of files with a specified extension in a directory and child directories.
//! @param depth is the depth to recursively search. A depth of 1 will traverse down one level below the given directory.
Paths findFilenamesInDirectoryRecursive(const std::string &dir, const std::string &extension, int depth = 10);

//! @returns paths of folders in a directory
Paths findFoldersInDirectory(const std::string &dir);

} // namespace file
} // namespace skybolt

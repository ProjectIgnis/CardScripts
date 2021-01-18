# Project Ignis card scripts for EDOPro

The canonical card script collection for EDOPro.

This is home to our official card script project, with the fastest prerelease card script delivery and the most accurate rulings and mechanics, including pre-errata variants. This is also home to our unofficial card script project, documenting anime, manga, and video-game-exclusive cards as their display text is written.

The root folder here contains base scripts, constants and utilities, such as summon procedures.

Card scripts are written in Lua 5.3, targeting the embedded interpreter in [our ocgcore](https://github.com/edo9300/ygopro-core).
They are automatically synchronized with servers.

## Contributing

Please keep all bug reports and questions on Discord; do NOT open an issue or pull request for this purpose.

Reach out to us on Discord to learn how to contribute and start scripting! Before opening a pull request, please speak with a member of staff in `#card-scripting-101` first and read [`CONTRIBUTING.md`](https://github.com/ProjectIgnis/CardScripts/blob/master/CONTRIBUTING.md).

Notes for maintainers: pull requests containing one or very few commits should generally be **squash-merged** to keep history clean

## Travis CI

* A basic Lua syntax check is done on scripts on pushes and pull requests. It loads `constant.lua` and `utility.lua` into ocgcore. Then it searches through one subfolder level for files of the form `cX.lua`, where `X` is an integer, loading them into the core as a dummy card with the same passcode. Three-digit passcodes and 151000000 are skipped.

* The syntax checker will catch basic Lua syntax errors like missing `end` statements and runtime errors in `initial_effect` (or a lack of `initial_effect` in a card script). It will not catch runtime errors in other functions declared within a script unless they are called by `initial_effect` of some other script.

* This is not a static analyzer and it will not catch incorrect parameters for calls outside of `initial_effect` or any other runtime error.

* If a pushed HEAD commit title contains `[ci skip]`, `[skip ci]`, `[travis skip]`, or `[skip travis]`, this is skipped.

## GitHub Actions

* Scripts that have been added or changed since the last tag are committed directly to the [delta repository](https://github.com/ProjectIgnis/DeltaHopeHarbinger) to sync with clients.
* Scripts that were deleted since the last Actions run are deleted from the delta repository.
* If a pushed HEAD commit title contains `[ci skip]`, `[skip ci]`, `[actions skip]`, or `[skip actions]`, this is skipped.

## Copyright notice and license

Copyright (C) 2020  Project Ignis contributors. See version history and author credit line for each file.
```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

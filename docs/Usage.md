# Usage

## help

Example: `sae help` or you can simply write `sae` or any unspecified command

This gives you a brief overview of `sae`'s commands

## new

Example: `sae new project-name`

Create a basic project with next files:

* Eq.yml
* src/Main.idr
* .gitignore

## build

Example: `sae build`

Installs dependencies and builds project

## release

Example: `sae release`

Compiles project into a file that, by default, will be placed at `./build/exec/`

For js targets, it produces `build/exec/index.js`, for others, it produces `build/exec/project-name` 

## run

Example: `sae run` or `sae run arg1 arg2`

Runs the compiled file, to use this command you need to run `sae release` first

## repl

Example: `sae repl`

Opens project in a repl session

## install-deps

Example: `sae install-deps`

Fetches, builds and installs dependencies, this is a step that automatically runs before build

## reinstall-deps

Example: `sae reinstall-deps`

Doest the same as `sae install-deps` but forcibly reinstalls every package. This feature is rarely needed

## install

Example: `sae install`

Installs package in the system, this is also rarely needed since you are supposed to install packages through `sae`'s `sources` field

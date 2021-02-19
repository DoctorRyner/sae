# SAE (Solver of All Equations)

A build tool for Idris 2 that allows you to manage dependencies and projects

# Install

1. Download `sae` for your operating system. At the moment, Windows isn't supported, for some reason, `sae.exe` throws an error if you try to use such commands as `sae build`, further research is required
   https://github.com/DoctorRyner/sae/releases/download/v0.0.2/sae-linux.zip
   https://github.com/DoctorRyner/sae/releases/download/v0.0.2/sae-mac.zip

2. Unzip the archive and place the `sae` executable in your PATH, for example, like this: `sudo cp sae /usr/local/bin `

3. Well done, now you can type `sae help` to see usage info or you can read the explanation below

# Examples

I made 2 example packages that target javascript:
* https://github.com/DoctorRyner/idris-js-example
* https://github.com/DoctorRyner/idris-react-example

Also, in this repo there is folder examples/ with a project that uses these packages

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

### Eq.yml structure

Eq.yml has all of the fields of ipkg config format except for `modules` and `name`, it also has a few new fields. We will overview only these changes and required fields. If you need information about all config fields, you can see them here https://github.com/DoctorRyner/sae/blob/d529ac2dfe8d1ae79d25798e819839d49a735bb6/src/Sae/Types.idr#L45

* package — the same as `name`
* modules — no need to specify modules manually, they are all generated automatically
* target — the same as `--codegen` or `--cg` for `idris2` executable, by default `chez` is used
* sources — a list of external dependencies in the format:

```yaml
name: package-name
url: https://github.com/SomeAuthor/repo-name
version: v0.0.1
```

Where:

* name — is used for distinguishing packages
* url — can be any url, including a local file path such as `./path/to/package`
* version — is a commit or a release tag

Required fields:

* package — the package name
* version — the package version, should be in the format `0.0.1`

To add a dependency from a source, you need to specify a `package name` and a `version` like this:

```yaml
depends:
- contrib
- package-name-0.0.1
```

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

# Development

Requirements:

* idris2
* git
* npm + yarn, for linux users, you can avoid issues if you install `npm` through `nvm`

Then clone the project `git clone https://github.com/DoctorRyner/sae` and run `yarn install-mac` or `yarn install-linux`, it'll compile `sae` and install the executable into `/usr/local/bin/sae`, now you can run `yarn install-${your-os}` after every change and test your changes

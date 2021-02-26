# SAE (Solver of All Equations)

A build tool for Idris 2 that allows you to manage dependencies and projects

##### Table of Contents
- [Install](#install)
- [Examples](#examples)
- [Development](#development)
- [Eq.yml structure](docs/Eq.yml-Structure.md)
- [Usage](docs/Usage.md)

# Install

1. Download `sae` 
   https://github.com/DoctorRyner/sae/releases/download/v0.0.2-fix1/sae-linux.zip
   https://github.com/DoctorRyner/sae/releases/download/v0.0.2-fix1/sae-mac.zip

2. Unzip the archive and place the `sae` executable in your PATH, for example, like this: `sudo cp sae /usr/local/bin `

3. Well done, now you can type `sae help` to see usage info or you can read the explanation below

# Examples

I made 2 example packages that target javascript:
* https://github.com/DoctorRyner/idris-js-example
* https://github.com/DoctorRyner/idris-react-example

Also, in this repo, there is folder `examples/` with a project that uses these packages

# Development

Requirements:

* idris2
* git
* npm + yarn, for linux users, you can avoid issues if you install `npm` through `nvm`

Clone the project `git clone https://github.com/DoctorRyner/sae` and run `yarn install-mac` or `yarn install-linux`, it'll compile `sae` and install the executable into `/usr/local/bin/sae`, now you can run `yarn install-${your-os}` after every change and test your changes

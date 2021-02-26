# SAE (Solver of All Equations)

Idris 2 build tool, manage packages and projects with ease!

##### Table of Contents
- [Install](#install)
- [Examples](#examples)
- [Development](#development)
- [Eq.yml structure](docs/Eq.yml-Structure.md)
- [Usage](docs/Usage.md)

# Install

Execute in terminal `sh -c "$(curl https://raw.githubusercontent.com/DoctorRyner/sae/master/scripts/install.sh)"`

Or go to [releases](https://github.com/DoctorRyner/sae/releases) and place an executable in your path manually

Then you can type `sae help` to see short usage info, for more information on sae checkout [Eq.yml structure](docs/Eq.yml-Structure.md) and [Usage](docs/Usage.md)

# Examples

I made 2 example packages that target javascript:
* https://github.com/DoctorRyner/idris-js-example
* https://github.com/DoctorRyner/idris-react-example

You can see how to use them in [examples](https://github.com/DoctorRyner/sae/tree/master/example)

# Development

Requirements:
* sae
* idris2
* git
* npm + yarn, for linux users, you can avoid issues if you install `npm` through `nvm`

1. Clone the project `git clone https://github.com/DoctorRyner/sae`
2. Type `sae build` to build the project
3. Make changes
4. Run `yarn install-mac` or `yarn install-linux` to test your newly acquired executable at `/usr/local/bin/sae`

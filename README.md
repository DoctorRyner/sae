# SAE (Solver of All Equations)

Idris 2 build tool, manage packages and projects with ease!

sae tested with — `Idris 2, version 0.3.0-40fa9b43a`, it may not work on previous versions due to idris' compiler changes

##### Table of Contents
- [Install](#install)
- [Examples](#examples)
- [Development](#development)
- [Eq.yml structure](docs/Eq.yml-Structure.md)
- [Usage](docs/Usage.md)

# Install

Execute this
```bash
sh -c "$(curl https://raw.githubusercontent.com/DoctorRyner/sae/master/scripts/install.sh)"
```

Or go to [releases](https://github.com/DoctorRyner/sae/releases) and place an executable in your path manually

Then you can type `sae help` to see a brief usage info, for more information on `sae` check out [Eq.yml structure](docs/Eq.yml-Structure.md) and [Usage](docs/Usage.md)

If you develop for JS backends then you need to have `yarn` installed, you can do it with this command
```bash
npm i -g yarn
```

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

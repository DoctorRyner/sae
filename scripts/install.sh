#!/bin/bash
set -u -e

# Installator

OS="$(uname)"

if [ "$OS" != "Linux" ] && [ "$OS" != "Darwin" ]; then
    echo "This sae installer works only on macOS and Linux"
    exit 1
fi

SAE_URL=$([ "$OS" == "Darwin" ] \
            && echo "https://github.com/DoctorRyner/sae/releases/download/v0.0.2-fix1/sae-mac.zip" \
            || echo "https://github.com/DoctorRyner/sae/releases/download/v0.0.2-fix1/sae-linux.zip")

curl -L "$SAE_URL" > sae.zip
unzip sae.zip
rm sae.zip

if [ "$OS" == "Darwin" ]; then
    mv sae /usr/local/bin/sae
else
    sudo mv sae /usr/local/bin/sae
fi

printf "\nSuccess! Type 'sae help' to get started"
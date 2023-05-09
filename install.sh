#!/bin/sh

NDE_APP_NAME=nvim-pde
NDE_APP_CONFIG=~/.config/$NDE_APP_NAME
export NDE_APP_NAME NDE_APP_CONFIG

rm -rf $NDE_APP_CONFIG && mkdir -p $NDE_APP_CONFIG

stow --restow --target=$NDE_APP_CONFIG .

alias nde="NVIM_APPNAME=$NDE_APP_NAME nvim"

#!/bin/sh

# Builds C02 with ACME.

acme -v3 main.s > build.log
cat build.log

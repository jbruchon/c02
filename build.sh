#!/bin/sh

# Builds C02 with ACME.

acme -v3 main.s | tee build.log

#!/bin/bash
# Stand-in for ldd when cross compiling. g-ir-scanner runs ldd on the helper
# binary it just linked, only to learn which SONAMEs that binary depends on,
# and the build machine's ldd cannot read a target-architecture ELF.
set -e
${READELF:-readelf} -d "$1" | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p'

#!/usr/bin/env bash

die() {
	echo "$1" 1>&2
	exit
}

carch="$1"
karch="$2"
ksrc="$3"
config_path="$(dirname "$0")/../"

[ "$carch" ] || die "No architecture specified"
[ "$karch" ] || die "Kernel-flavour architecture not specified"
[ "$ksrc" ] || die "Kernel soruce directory not specified"
[ -d "$config_path/$carch" ] || die "Unknown architecture $carch"

mergedconfig="$(mktemp)"

for _conf in "$config_path"/*.config "$config_path/$carch"/*.config; do
	cat "$_conf" >> "$mergedconfig"
done

cd "$ksrc"

make LLVM=1 LLVM_IAS=1 ARCH="$karch" defconfig
scripts/kconfig/merge_config.sh -m .config "$mergedconfig"
make LLVM=1 LLVM_IAS=1 ARCH="$karch" olddefconfig

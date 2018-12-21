#!/bin/bash
set -xeuo pipefail

BAZEL_ROOT="$HOME/bazels/"
# BAZEL_ROOT="/usr/bin"

# versions="bazel-0.13.1-darwin-x86_64 bazel-0.14.1-darwin-x86_64  bazel-0.15.2-darwin-x86_64 bazel-0.16.0rc1-darwin-x86_64"
# versions="dev-dynamic 0.18.0"

# for version in $versions; do
#   benchmark_version $version
# done

function benchmark_version() {
  local version=$1; shift;
  local build_flags=$@;
  select_version $version
  sed "s/%build_flags%/$build_flags/g" \
    performance.scenarios.tpl > performance.scenarios
  ./benchmark.sh $version
  "$BAZEL_ROOT/bazel" clean --expunge
}

function select_version() {
  version=$1; shift
  rm -f $BAZEL_ROOT/bazel
  filename=$(ls -1 $BAZEL_ROOT | grep $version)
  ln -s $BAZEL_ROOT/$filename $BAZEL_ROOT/bazel
  echo "Selected Bazel version: $version"
}

# ManifestMerger, AndroidResourceMerger, AndroidCompiledResourceMerger
# experiment_flags='"--config=remote", "--android_aapt=aapt2"'
experiment_flags='"--config=dynamic_android", "--android_aapt=aapt2"'
control_flags='"--android_aapt=aapt2", "--persistent_android_resource_processor"'

benchmark_version bazel $experiment_flags
# benchmark_version dev-dynamic $experiment_flags
# benchmark_version "0.19.0" $control_flags

# benchmark_version dev-rpbb-worker $experiment_flags
# benchmark_version "0.15.2" $control_flags
# benchmark_version "0.16.0rc4" $control_flags

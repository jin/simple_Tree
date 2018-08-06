#!/bin/bash
set -xeuo pipefail

BAZEL_ROOT="/opt/bazel"

# versions="bazel-0.13.1-darwin-x86_64 bazel-0.14.1-darwin-x86_64  bazel-0.15.2-darwin-x86_64 bazel-0.16.0rc1-darwin-x86_64"
# versions="dev-rpbb-worker 0.15.2 0.16.0rc4"

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
experiment_flags='"--strategy=AaptPackage=worker", "--strategy=AndroidResourceParser=worker", "--strategy=AndroidResourceValidator=worker", "--strategy=AndroidResourceCompiler=worker", "--strategy=RClassGenerator=worker", "--strategy=AndroidAssetMerger=worker", "--strategy=AndroidResourceLink=worker", "--android_aapt=aapt2", "--strategy=AndroidAapt2=worker", "--worker_max_instances=2", "--strategy=DexBuilder=worker", "--spawn_strategy=standalone"' 
control_flags='"--spawn_strategy=standalone"'

benchmark_version dev-rpbb-worker $experiment_flags
# benchmark_version "0.15.2" $control_flags
# benchmark_version "0.16.0rc4" $control_flags

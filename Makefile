target=//androidAppModule0
bazel=$$HOME/bazels/github/bazel-bin/src/bazel

common_flags=--profile=$@.prof
dump_raw_profile=analyze-profile $@.prof --dump=raw > $@.prof.raw
analyze_profile=./analyze-profile.py --mode duration_by_action_type $@.prof.raw > $@.prof.csv

clean: FORCE
	$(bazel) clean

analysis: clean
	$(bazel) build $(target) --nobuild

control: clean
	$(bazel) build $(target) $(common_flags)

aapt2: clean
	$(bazel) build $(target) --android_aapt=aapt2 $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-with-dexbuilder-workers: clean
	$(bazel) build $(target) --android_aapt=aapt2 --worker_max_instances=2 --strategy=DexBuilder=worker $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-with-all-workers: clean
	$(bazel) build $(target) --android_aapt=aapt2 --experimental_persistent_android_resource_processor --worker_max_instances=2 --strategy=DexBuilder=worker $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-with-monolithic-workers: clean
	$(bazel) build $(target) --android_aapt=aapt2 --experimental_persistent_monolithic_android_resource_processor --worker_max_instances=DexBuilder=2 --worker_max_instances=ResourceProcessorBusyBox=4 --strategy=DexBuilder=worker $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

FORCE: ;

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

android_sdk_repository(name = "androidsdk")

# Google Maven Repository
GMAVEN_TAG = "0.1.0"

http_archive(
    name = "gmaven_rules",
    strip_prefix = "gmaven_rules-%s" % GMAVEN_TAG,
    urls = ["https://github.com/bazelbuild/gmaven_rules/archive/%s.tar.gz" % GMAVEN_TAG],
)

load("@gmaven_rules//:gmaven.bzl", "gmaven_rules")

gmaven_rules()

http_archive(
    name = "bazel_toolchains",
    sha256 = "7e85a14821536bc24e04610d309002056f278113c6cc82f1059a609361812431",
    strip_prefix = "bazel-toolchains-bc0091adceaf4642192a8dcfc46e3ae3e4560ea7",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/bc0091adceaf4642192a8dcfc46e3ae3e4560ea7.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/bc0091adceaf4642192a8dcfc46e3ae3e4560ea7.tar.gz",
    ],
)

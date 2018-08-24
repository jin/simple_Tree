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
    sha256 = "cefb6ccf86ca592baaa029bcef04148593c0efe8f734542f10293ea58f170715",
    strip_prefix = "bazel-toolchains-cdea5b8675914d0a354d89f108de5d28e54e0edc",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/cdea5b8675914d0a354d89f108de5d28e54e0edc.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/cdea5b8675914d0a354d89f108de5d28e54e0edc.tar.gz",
    ],
)

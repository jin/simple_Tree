#!/usr/bin/env python3
"""Script for analyzing raw data `bazel analyze-profile --dump=raw`

Usage:

    First obtain the raw profile data of your build.

        $ bazel build --profile=my_profile.dat //some:target
        $ bazel analyze-profile my_profile.dat --dump=raw > my_profile.raw

    Run the script to analyze the raw data:

        $ ./analyze-profile.py --mode slowest_actions my_profile.raw
        $ ./analyze-profile.py --mode duration_by_action_type my_profile.raw

    Show the help menu:

        $ ./analyze-profile.py --help

"""

import os
import sys
import argparse
import csv
import itertools

ANALYSIS_MODES = [
    "slowest_actions",
    "duration_by_action_type"
]

def key_by_action_type(action):
    partitions = action['description'].split()
    first_word = partitions[0]
    if first_word == "Building":
        if partitions[1] == "deploy":
            return " ".join(partitions[:3])
        else:
            return "Building jar with javac/JavaBuilder"
    elif first_word == "Extracting":
        if partitions[1] == "classes.jar":
            return " ".join(partitions[:4])
        elif partitions[1] == "Java":
            return " ".join(partitions[:6])
        elif partitions[1] in ["interface", "AndroidManifest.xml"]:
            return " ".join(partitions[:2])
        else:
            raise Exception("unknown action %s" % partitions)
    elif first_word == "Converting":
        return "Converting to dex format"
    elif first_word == "Merging":
        if partitions[1] == "manifest":
            return "Merging manifest"
        elif partitions[1] == "AAR":
            return "Merging AAR embedded jars"
        elif partitions[1] == "Android":
            return "Merging Android resources"
        else:
            raise Exception("unknown action %s" % partitions)
    elif first_word in ["Symlinking", "AarResourcesExtractor", "Desugaring", "Dexing", "Zipaligning"]:
        return first_word
    elif first_word in ["Writing", "Expanding", "Executing"]:
        return " ".join(partitions[:2])
    elif first_word in ["Merging", "Validating", "Processing", "Creating", "Parsing", "Compiling", "Generating", "Assembling"]:
        return " ".join(partitions[:3])
    elif first_word in ["Sharding", "Linking"]:
        return " ".join(partitions[:4])
    elif first_word in ["Checking"]:
        return " ".join(partitions[:6])
    else:
        return " ".join(partitions)


def read_raw_dump(infile):
    fieldnames = [
        "thread_id",
        "id",
        "parent_id",
        "start_time",
        "duration_nanos",
        "aggregate_string",
        "type",
        "description"
    ]
    profiled_data = list(csv.DictReader(infile, delimiter='|', fieldnames=fieldnames))
    actions = [data for data in profiled_data if data['type'] == 'ACTION']
    return actions

def compute_duration_by_action_types(actions):
    grouped_actions = []
    action_types = []

    data = sorted(actions, key=key_by_action_type)
    for action_type, group in itertools.groupby(data, key_by_action_type):
        grouped_actions.append(list(group))
        action_types.append(action_type)

    results = {}
    for group in grouped_actions:
        action_type = key_by_action_type(group[0])
        total_nanos = 0
        for action in group:
            total_nanos += int(action['duration_nanos'])
        results[action_type] = float(total_nanos) * 1e-9

    csv_rows = [
        "%s, %s" % (key, value)
        for key, value
        in sorted(
            results.items(),
            key=lambda kv: (kv[1], kv[0]),
            reverse=True
        )
    ]
    return csv_rows

def compute_slowest_actions(actions):
    sort_by_duration = lambda key: int(key['duration_nanos'])
    slowest_actions = sorted(actions, key=sort_by_duration, reverse=True)[:30]
    csv_rows = [
        "%s, %s" % (float(row['duration_nanos']) * 1e-9, row['description'])
        for row
        in slowest_actions
    ]
    return csv_rows

def main(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('infile',
                        help="Raw profile data file",
                        type=argparse.FileType('r'))
    parser.add_argument('-m', '--mode',
                        help="Analysis mode to execute",
                        type=str,
                        choices=ANALYSIS_MODES,
                        required=True)
    parser.add_argument('-o', '--outfile', help="Output file",
                        default=sys.stdout, type=argparse.FileType('w'))

    args = parser.parse_args(arguments)
    actions = read_raw_dump(args.infile)
    csv_rows = []

    if args.mode == "slowest_actions":
        csv_rows = compute_slowest_actions(actions)
    elif args.mode == "duration_by_action_type":
        csv_rows = compute_duration_by_action_types(actions)

    args.outfile.write("\n".join(csv_rows) + "\n")

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))

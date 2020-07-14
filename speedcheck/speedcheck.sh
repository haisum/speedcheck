#!/usr/bin/env bash
set -e
set -o pipefail

speedCheck(){
    echo "Checking speed"
    ndt7-client -format json > output.json || true
    if grep -q Failure output.json; then
        cat <<EOF | curl --data-binary @- http://pushgateway:9091/metrics/job/internet_speed
            # TYPE download_speed gauge
            download_speed 0
            # TYPE upload_speed gauge
            upload_speed 0
EOF
    else
        local uploadSpeed downloadSpeed latency
        uploadSpeed=$(grep -v Key output.json | jq .Upload.Value)
        downloadSpeed=$(grep -v Key output.json | jq .Download.Value)
        latency=$(grep -v Key output.json | jq .MinRTT.Value)
        echo "downloadSpeed: $downloadSpeed; uploadSpeed: $uploadSpeed; latency: $latency"
        cat <<EOF | curl --data-binary @- http://pushgateway:9091/metrics/job/internet_speed
            # TYPE download_speed gauge
            download_speed $downloadSpeed
            # TYPE upload_speed gauge
            upload_speed $uploadSpeed
            # TYPE latency gauge
            latency $latency
EOF
    fi
}

main(){
    which ndt7-client > /dev/null 2>&1 || {
        echo "ndt7-client is required";
        return 1;
    }
    which jq > /dev/null 2>&1 || {
        echo "jq is required";
        return 1;
    }
    while true; do
        speedCheck;
        echo "Waiting"
        sleep 60s;
    done;
}

main
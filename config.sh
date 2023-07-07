#!/bin/bash

# Default values for the variables
name="strfry default"
description="This is a strfry instance."
pubkey="unset"
contact="unset"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --name)
            name="$2"
            shift # past argument
            shift # past value
            ;;
        --description)
            description="$2"
            shift # past argument
            shift # past value
            ;;
        --pubkey)
            pubkey="$2"
            shift # past argument
            shift # past value
            ;;
        --contact)
            contact="$2"
            shift # past argument
            shift # past value
            ;;
        *) # unknown option
            shift # past argument
            ;;
    esac
done

# Generate the configuration file content
config_content=$(cat <<EOM
##
## Default strfry config
##

# Directory that contains the strfry LMDB database (restart required)
db = "./strfry-db/"

dbParams {
    # Maximum number of threads/processes that can simultaneously have LMDB transactions open (restart required)
    maxreaders = 256

    # Size of mmap() to use when loading LMDB (default is 10TB, does *not* correspond to disk-space used) (restart required)
    mapsize = 10995116277760
}

events {
    # Maximum size of normalised JSON, in bytes
    maxEventSize = 65536

    # Events newer than this will be rejected
    rejectEventsNewerThanSeconds = 900

    # Events older than this will be rejected
    rejectEventsOlderThanSeconds = 94608000

    # Ephemeral events older than this will be rejected
    rejectEphemeralEventsOlderThanSeconds = 60

    # Ephemeral events will be deleted from the DB when older than this
    ephemeralEventsLifetimeSeconds = 300

    # Maximum number of tags allowed
    maxNumTags = 2000

    # Maximum size for tag values, in bytes
    maxTagValSize = 1024
}

relay {
    # Interface to listen on. Use 0.0.0.0 to listen on all interfaces (restart required)
    bind = "0.0.0.0"

    # Port to open for the nostr websocket protocol (restart required)
    port = 80

    # Set OS-limit on maximum number of open files/sockets (if 0, don't attempt to set) (restart required)
    nofiles = 1000000

    # HTTP header that contains the client's real IP, before reverse proxying (ie x-real-ip) (MUST be all lower-case)
    realIpHeader = ""

    info {
        # NIP-11: Name of this server. Short/descriptive (< 30 characters)
        name = "$name"

        # NIP-11: Detailed information about relay, free-form
        description = "$description"

        # NIP-11: Administrative nostr pubkey, for contact purposes
        pubkey = "$pubkey"

        # NIP-11: Alternative administrative contact (email, website, etc)
        contact = "$contact"
    }

    # Maximum accepted incoming websocket frame size (should be larger than max event) (restart required)
    maxWebsocketPayloadSize = 131072

    # Websocket-level PING message frequency (should be less than any reverse proxy idle timeouts) (restart required)
    autoPingSeconds = 55

    # If TCP keep-alive should be enabled (detect dropped connections to upstream reverse proxy)
    enableTcpKeepalive = false

    # How much uninterrupted CPU time a REQ query should get during its DB scan
    queryTimesliceBudgetMicroseconds = 10000

    # Maximum records that can be returned per filter
    maxFilterLimit = 500

    # Maximum number of subscriptions (concurrent REQs) a connection can have open at any time
    maxSubsPerConnection = 20

    writePolicy {
        # If non-empty, path to an executable script that implements the writePolicy plugin logic
        plugin = "./whitelist.js"

        # Number of seconds to search backwards for lookback events when starting the writePolicy plugin (0 for no lookback)
        lookbackSeconds = 0
    }

    compression {
        # Use permessage-deflate compression if supported by client. Reduces bandwidth, but slight increase in CPU (restart required)
        enabled = true

        # Maintain a sliding window buffer for each connection. Improves compression, but uses more memory (restart required)
        slidingWindow = true
    }

    logging {
        # Dump all incoming messages
        dumpInAll = false

        # Dump all incoming EVENT messages
        dumpInEvents = false

        # Dump all incoming REQ/CLOSE messages
        dumpInReqs = false

        # Log performance metrics for initial REQ database scans
        dbScanPerf = false
    }

    numThreads {
        # Ingester threads: route incoming requests, validate events/sigs (restart required)
        ingester = 3

        # reqWorker threads: Handle initial DB scan for events (restart required)
        reqWorker = 3

        # reqMonitor threads: Handle filtering of new events (restart required)
        reqMonitor = 3

        # negentropy threads: Handle negentropy protocol messages (restart required)
        negentropy = 2
    }
}
EOM
)

# Output the configuration file
echo "$config_content" > /tmp/strfry.conf

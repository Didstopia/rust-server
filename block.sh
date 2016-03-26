#!/bin/bash

if [ ! -z ${RUST_SERVER_BLOCK_RUSTIO+x} ]; then
	# Block playrust.io (RustIO)
	echo "Blocking RustIO..";
	if [ -n "$(grep playrust.io /etc/hosts)" ]
	then
	    echo "Already blocking RustIO, skipping..";
	else
	    sudo -- sh -c -e "echo '127.0.0.1 playrust.io map.playrust.io' >> /etc/hosts";
	fi
fi

if [ ! -z ${RUST_SERVER_BLOCK_PLAYRUSTHQ+x} ]; then
	# Block playrusthq.com
	echo "Blocking PLAYRUSTHQ..";
	if [ -n "$(grep playrusthq.com /etc/hosts)" ]
	then
	    echo "Already blocking PLAYRUSTHQ, skipping..";
	else
	    sudo -- sh -c -e "echo '127.0.0.1 playrusthq.com' >> /etc/hosts";
	fi
fi

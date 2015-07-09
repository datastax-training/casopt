#!/bin/bash

set -v

ssh node5_ext "sed '/^broadcast_address/ d'

ssh node5_ext service cassandra restart


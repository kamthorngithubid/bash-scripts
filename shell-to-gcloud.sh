#!/bin/bash

gcloud compute ssh --zone "asia-southeast1-b" "sre-cenoper-gov-nonprd-script-01"  --tunnel-through-iap --project "sre-cenoper-gov-nonprd"

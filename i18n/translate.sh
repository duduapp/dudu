#!/bin/bash
set -e

# This example translates an english ARB-file into spanish and german. It uses Google Cloud Translate.
BASE_DIR=../lib/l10n
SERVICE_ACCOUNT_KEY="./google.json"
COMMON_ARGS=( "--srcFile=$BASE_DIR/app_en.arb" "--srcLng=en" "--srcFormat=arb" "--targetFormat=arb" "--service=google-translate" "--serviceConfig=$SERVICE_ACCOUNT_KEY" "--cacheDir=./" )

# Run "npm install --global attranslate" before you try this example.
attranslate "${COMMON_ARGS[@]}" --targetFile=../lib/l10n/app_fr_generated.arb --targetLng=fr --manualReview=true
attranslate "${COMMON_ARGS[@]}" --targetFile=../lib/l10n/app_ru_generated.arb --targetLng=ru --manualReview=true
attranslate "${COMMON_ARGS[@]}" --targetFile=../lib/l10n/app_ar_generated.arb --targetLng=ar --manualReview=true
attranslate "${COMMON_ARGS[@]}" --targetFile=../lib/l10n/app_es_generated.arb --targetLng=es --manualReview=true
attranslate "${COMMON_ARGS[@]}" --targetFile=../lib/l10n/app_ja_generated.arb --targetLng=ja --manualReview=true
#attranslate "${COMMON_ARGS[@]}" --targetFile=$BASE_DIR/intl_de.arb --targetLng=de
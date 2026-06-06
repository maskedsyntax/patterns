#!/bin/sh
# Re-sign embedded frameworks with the app team identity.
# Fixes invalid signature (0xe8008014) on objective_c.framework from Flutter native assets.

set -e

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  exit 0
fi

FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks"
if [ ! -d "${FRAMEWORKS_DIR}" ]; then
  exit 0
fi

find "${FRAMEWORKS_DIR}" -maxdepth 1 -name '*.framework' -type d | while read -r framework; do
  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
    --preserve-metadata=identifier,entitlements,flags \
    --timestamp=none "${framework}"
done

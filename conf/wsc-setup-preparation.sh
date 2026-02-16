#!/bin/sh

: "${WSC_SETUP_ENABLED:="0"}"          # enable for download and unpack WSC (from https://www.woltlab.com/en/woltlab-suite-download/)
: "${WSC_VERSION:="6.2"}"              # example: 6.1 or 6.2
: "${WSC_DEV_INSTALL_ENABLED:="0"}"    # for an almost unattended installation (need variables_order=EGPCS in PHP config and WCFSETUP_* ENVs)
: "${DOCUMENT_ROOT:="/var/www/html"}"  # default: /var/www/html

if [ "$WSC_SETUP_ENABLED" -eq "1" -a -n "$WSC_VERSION" ]; then
  
  TMP_DIR="$(mktemp -d)"
  #echo ">> DIR=$TMP_DIR"
  
  TAGS=$(
    curl -sL https://api.github.com/repos/WoltLab/WCF/tags |
    grep '"name"' |
    cut -d'"' -f4 |
    sed 's/_/-/g' |
    grep -Ev '(dev|Alpha)' |
    tr '[:upper:]' '[:lower:]' |
    sort -rV
  )
  
  STABLE=$(echo "$TAGS" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | head -n1)
  LATEST=$(echo "$TAGS" | head -n1)
  echo ">> Info (WSC Versions): stable=${STABLE} ; latest=${LATEST}"
  VERSION=$(echo "$TAGS" | grep -E "^${WSC_VERSION}" | head -n1)
  echo ">> Selected Version: ${VERSION}"
  
  #if [ -z "$(ls -A "$DOCUMENT_ROOT")" ]; then
  if [ ! -f "$DOCUMENT_ROOT/index.php" ]; then
    FILENAME="wsc-${VERSION}.zip"
    echo ">> Downloading Installer-Archive (.zip)..."
    curl -sL -o "/${TMP_DIR}/${FILENAME}" "https://assets.woltlab.com/release/woltlab-suite-${VERSION}.zip"
    #echo ">> List content of Archive ..."
    #unzip -l "/${TMP_DIR}/${FILENAME}" | head
    echo ">> Unpack Archive File to ${DOCUMENT_ROOT} ..."
    unzip -q -j -o "/${TMP_DIR}/${FILENAME}" "upload/*" -d "${DOCUMENT_ROOT}"
    if [ "$WSC_DEV_INSTALL_ENABLED" -eq "1" ] ; then
      echo ">> set dev as install mode (unattended installation) ..."
      sed -i 's|href="install.php"|href="install.php?dev=1"|g' "${DOCUMENT_ROOT}/test.php"
    fi 
  else
    echo ">> Target Folder ${DOCUMENT_ROOT} is not empty. Download & Unpacking canceled!"
    #ls -A ${DOCUMENT_ROOT}
  fi
  #ls -lah $TMP_DIR
  rm -rf "$TMP_DIR"
  
fi
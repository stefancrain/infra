#!/bin/bash
# If SOPS configuration is changed, force update
GIT_SOPS_CHANGED=$(git status -s | grep ".sops.yaml")
FORCE=0
if [ -n "$GIT_SOPS_CHANGED" ] || [ "$#" -eq 1 ] || [ "$1" = "-f" -o "$1" = "--forced" ]; then
  FORCE=1
fi
echo $FORCE
# Find all encrypted files
ENCRYPTED_FILES=$(find . -type f -regex ".*\.enc\.tfvars\$")
echo $ENCRYPTED_FILES
for FILE in ${ENCRYPTED_FILES}; do
  DECRYPTED_FILE=$(echo "$FILE" | sed 's/.enc././g')
  if [ ! -f "$DECRYPTED_FILE" ]; then
    # Decrypt file if none exists
    echo "Decrypted file does not exist. Decrypt and re-encrypt: $FILE"
    sops --decrypt "$FILE" >"$DECRYPTED_FILE"
  fi
  # Check if secret is changed
  SECRET_CHANGED=$(sops -d "$FILE" | diff "$DECRYPTED_FILE" - -q)
  if [ "$FORCE" -eq 1 ]; then
    echo "what"
  fi
  if [ "$FORCE" -eq 1 ] || [ -n "$SECRET_CHANGED" ]; then
    echo "Secret has changed or update is forced. Update: $FILE"
    # Replace old encrypted file with a new one
    cp "$DECRYPTED_FILE" "$FILE"
    sops --encrypt --in-place "$FILE"
    if [ -n "$(git status -s $FILE)" ]; then
      # Add encrypted file to commit.
      git add "$FILE"
    fi
  fi
done

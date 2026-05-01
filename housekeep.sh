#!/bin/bash

# Usage: ./var_housekeep.sh [dryrun|zip|delete]

ACTION=$1
LOG_FILE="/tmp/${ACTION}_housekeep.log"
WORK_DIR="/var"
DEST_DIR="/var/crash"

# Protected directories (NO ACTION)
EXCLUDE_DIRS=(
    "/var/lib"
    "/var/lib/docker"
    "/var/lib/containers"
)

# Validate input
if [[ "$ACTION" != "dryrun" && "$ACTION" != "zip" && "$ACTION" != "delete" ]]; then
    echo "Usage: $0 [dryrun|zip|delete]"
    exit 1
fi

echo "===== ACTION: $ACTION =====" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "check df -h /var before activity"
df -hTP /var
# Ensure destination exists for zip
mkdir -p "$DEST_DIR"

# Get top 3 directories (by size)
TOP_DIRS=$(du -B1 --max-depth=1 "$WORK_DIR" 2>/dev/null \
    | sort -rn \
    | tail -n +2 \
    | head -n 3 \
    | awk '{print $2}')

ACTION_DONE=0

for DIR in $TOP_DIRS; do
    echo "Directory: $DIR" | tee -a "$LOG_FILE"

    # Check if directory is excluded
    SKIP=false
    for EX in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$DIR" == "$EX"* ]]; then
            echo "    (Skipping protected path: $DIR)" | tee -a "$LOG_FILE"
            SKIP=true
            break
        fi
    done

    # Get top 3 files anyway (for visibility)
    FILES=$(find "$DIR" -type f 2>/dev/null \
        -exec du -h {} + | sort -hr | head -n 3 | awk '{print $2}')

    for FILE in $FILES; do
        SIZE=$(du -h "$FILE" 2>/dev/null | awk '{print $1}')
        echo "  File: $FILE | Size: $SIZE" | tee -a "$LOG_FILE"

        # Decide if action should be applied
        if [[ "$SKIP" == true ]]; then
            echo "    (No action - protected directory)" | tee -a "$LOG_FILE"
            continue
        fi

        if [[ $ACTION_DONE -eq 0 ]]; then
            case $ACTION in
                dryrun)
                    ;;
                zip)
                    BASENAME=$(basename "$FILE")
                    ZIP_FILE="${DEST_DIR}/${BASENAME}.gz"

                    echo "    Zipping -> $ZIP_FILE" | tee -a "$LOG_FILE"
                    gzip -c "$FILE" > "$ZIP_FILE"

                    if [[ $? -eq 0 ]]; then
                        echo "    Zip successful" | tee -a "$LOG_FILE"
                    else
                        echo "    Zip failed" | tee -a "$LOG_FILE"
                    fi
                    ;;
                delete)
                    echo "    Deleting -> $FILE" | tee -a "$LOG_FILE"
                    rm -f "$FILE"

                    if [[ $? -eq 0 ]]; then
                        echo "    Delete successful" | tee -a "$LOG_FILE"
                    else
                        echo "    Delete failed" | tee -a "$LOG_FILE"
                    fi
                    ;;
            esac
        else
            echo "    (No action - already applied to top eligible directory)" | tee -a "$LOG_FILE"
        fi
    done

    # Mark action done only if this dir was eligible
    if [[ "$SKIP" == false && $ACTION_DONE -eq 0 ]]; then
        ACTION_DONE=1
    fi
	echo "display df -hTP /var post activity"
	df -hPT /var
    echo "" | tee -a "$LOG_FILE"
done

echo "===== COMPLETED =====" | tee -a "$LOG_FILE"
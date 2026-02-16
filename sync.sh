#!/bin/sh


# --- Setup ---

SYNC_REMOTE_TO_LOCAL=0
DEBUG_MODE=0
DRYRUN=0

while getopts "rvd" opt
do
	case "$opt" in
		r) SYNC_REMOTE_TO_LOCAL=1 ;;
		v) DEBUG_MODE=1 ;;
		d) DRYRUN=1 ;;
		*) exit 1 ;;
	esac
done

debug() {
	if [ "${DEBUG_MODE?}" -eq 1 ];	then
		printf '[DEBUG] %s\n' "$1" > /dev/stderr
	fi
}

INVOKER_PATH=$(pwd)
SCRIPT_ABS_PATH="${INVOKER_PATH?}/$0"
SCRIPT_DIR_ABS_PATH="$(dirname ${SCRIPT_ABS_PATH})"
debug "Script absolute path: ${SCRIPT_ABS_PATH?} (dir: ${SCRIPT_DIR_ABS_PATH?})"


# --- Core logic ---

DOT_LOCAL_BIN_FILES="tmux-sessionizer"
DOT_CONFIG_DIRS=$(find .config -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

LOCAL_DOT_LOCAL_PATH="${HOME}/.local/bin"
LOCAL_DOT_CONFIG_PATH="${HOME}/.config"
REMOTE_DOT_LOCAL_PATH="${SCRIPT_DIR_ABS_PATH?}/.local/bin"
REMOTE_DOT_CONFIG_PATH="${SCRIPT_DIR_ABS_PATH?}/.config"

if [ ${SYNC_REMOTE_TO_LOCAL} -eq 1 ]; then
	debug "Syncing repository configuration to local configuration"

	DOT_LOCAL_SRC_PATH="${REMOTE_DOT_LOCAL_PATH?}"
	DOT_LOCAL_DEST_PATH="${LOCAL_DOT_LOCAL_PATH?}"

	DOT_CONFIG_SRC_PATH="${REMOTE_DOT_CONFIG_PATH?}"
	DOT_CONFIG_DEST_PATH="${LOCAL_DOT_CONFIG_PATH?}"
else
	debug "Syncing local configuration to repository configuration"

	DOT_LOCAL_SRC_PATH="${LOCAL_DOT_LOCAL_PATH?}"
	DOT_LOCAL_DEST_PATH="${REMOTE_DOT_LOCAL_PATH?}"

	DOT_CONFIG_SRC_PATH="${LOCAL_DOT_CONFIG_PATH?}"
	DOT_CONFIG_DEST_PATH="${REMOTE_DOT_CONFIG_PATH?}"
fi

debug ".local source path: ${DOT_LOCAL_SRC_PATH}"
debug ".local destination path: ${DOT_LOCAL_DEST_PATH}"
debug ".config source path: ${DOT_CONFIG_SRC_PATH}"
debug ".config destination path: ${DOT_CONFIG_DEST_PATH}"


# --- Syncing .local/bin files ---

for file in "${DOT_LOCAL_BIN_FILES?}"
do
	SRC_PATH="${DOT_LOCAL_SRC_PATH}/${file}"
	DEST_PATH="${DOT_LOCAL_DEST_PATH}"

	printf 'Copying file "%s" from "%s" to "%s"\n' "${file}" "${SRC_PATH}" "${DEST_PATH}"
	if [ "${DRYRUN}" -eq 1 ]; then continue; fi
	cp "${SRC_PATH}" "${DEST_PATH}"
done


# --- Syncing .config directories ---

for dir in ${DOT_CONFIG_DIRS}
do
	SRC_PATH="${DOT_CONFIG_SRC_PATH}/${dir}"
	DEST_PATH="${DOT_CONFIG_DEST_PATH}"
	printf 'Copying directory "%s" from "%s" to "%s"\n' "${dir}" "${SRC_PATH}" "${DEST_PATH}"
	if [ "${DRYRUN}" -eq 1 ]; then continue; fi
	cp -r "${SRC_PATH}" "${DEST_PATH}"
done

#!/bin/zsh
readlink /proc/$$/exe | grep zsh > /dev/null
IS_ZSH="$?"
if [ ! "$IS_ZSH" ]; then
  echo "You must use zsh, exiting..."
  exit 1
fi;
CHECKPOINT_DIR="../export/checkpoint/"

if [ ! "$TEST_FILES" ]; then
  TEST_FILES="../NST/dev.csv"
fi;

if [ ! "$LR" ]; then
  LR="0.0001"
fi;

if [ ! "$DROPOUT" ]; then
  DROPOUT="0.20"
fi;

if [ ! "$BATCH_SIZE" ]; then
  BATCH_SIZE=64
fi;

if [ ! $MODEL_NAME ] || [ ! $LM_NAME ]; then
  echo '$MODEL_NAME and $LM_NAME must be specified'
  exit 1
fi;

CHECKPOINT_DIR="${CHECKPOINT_DIR}${MODEL_NAME}/"
LM_BINARY="../lm/${LM_NAME}.binary"
LM_TRIE="../lm/${LM_NAME}.trie"


if [ $NO_LM ]; then
  LM_BINARY=""
  LM_TRIE=""
fi;

echo "Testing using:"
echo "  Test files:            $TEST_FILES"
echo "  Checkpoint dir:        $CHECKPOINT_DIR"
echo "  Language model binary: $LM_BINARY"
echo "  Language model trie:   $LM_TRIE"
echo "  Learning rate:         $LR"
echo "  Dropout:               $DROPOUT"

read "?Continue? "
if [[ ! "$REPLY" =~ ^[Yy]$ ]]
then
    echo "exiting"
    exit 0
fi

python -u DeepSpeech.py \
--test_files "$TEST_FILES" \
--test_batch_size "$BATCH_SIZE" \
--n_hidden 2048 \
--epochs 30 \
--noearly_stop \
--dropout_rate "$DROPOUT" \
--learning_rate "$LR" \
--report_count 100 \
--checkpoint_dir "$CHECKPOINT_DIR" \
--alphabet_config_path ../NST/alphabet.txt \
--lm_binary_path "$LM_BINARY" \
--lm_trie_path "$LM_TRIE" \
--export_language sv \
--use_cudnn_rnn "$@"

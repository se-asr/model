#!/bin/sh

EXPORT_DIR='/mnt/ssd/exjobb/export/'
CHECKPOINT_DIR="${EXPORT_DIR}checkpoint/"
MODEL_DIR="${EXPORT_DIR}model/"
SUMMARY_DIR="${EXPORT_DIR}tensorboard/"

TRAIN_FILES="../NST/train.csv"
DEV_FILES="../NST/dev.csv"
#TEST_FILE="../NST/test.csv"
TEST_FILES="../NST/dev.csv"

if [ ! -f DeepSpeech.py ]; then
    echo "Please make sure you run this from DeepSpeech's top level directory."
    exit 1
fi;

if [ ! $UUID ] && [ ! $CONTINUE ]; then
  UUID=$(python name.py)
  if [ $? -eq 0 ]; then
    echo "Creating new model with name: $UUID"
  else
    echo "No names left"
    exit 1
  fi;
fi;

if [ -d "${MODEL_DIR}${UUID}" ] && [ ! $CONTINUE ]; then
  echo "Model ${UUID} already exist"
  exit 1
fi;

MODEL_DIR="${MODEL_DIR}${UUID}"


if [ -d "${CHECKPOINT_DIR}${UUID}" ] && [ ! $CONTINUE ] ; then
  echo "Checkpoint ${UUID} already exist"
  exit 1
fi;

CHECKPOINT_DIR="${CHECKPOINT_DIR}${UUID}"


if [ -d "${SUMMARY_DIR}${UUID}" ] && [ ! $CONTINUE ]; then
  echo "Summary ${UUID} already exist"
  exit 1
fi;

SUMMARY_DIR="${SUMMARY_DIR}${UUID}"

mkdir "${MODEL_DIR}"
mkdir "${CHECKPOINT_DIR}"
mkdir "${SUMMARY_DIR}"

echo "Running model ${UUID}"

python -u DeepSpeech.py \
  --train_files "$TRAIN_FILES" \
  --dev_files "$DEV_FILES" \
  --test_files "$TEST_FILES" \
  --train_batch_size 64 \
  --dev_batch_size 64 \
  --test_batch_size 64 \
  --test_output_file "${MODEL_DIR}/test-output" \
  --n_hidden 2048 \
  --epochs 75 \
  --early_stop True \
  --dropout_rate 0.20 \
  --learning_rate 0.0001 \
  --report_count 100 \
  --export_dir "$MODEL_DIR" \
  --checkpoint_dir "$CHECKPOINT_DIR" \
  --summary_dir "$SUMMARY_DIR" \
  --alphabet_config_path ../NST/alphabet.txt \
  --lm_binary_path ../lm/wikilm5gramtrie.binary \
  --lm_trie_path ../lm/wikilm5gramtrie.trie \
  --export_language sv \
  --use_cudnn_rnn \
  --automatic_mixed_precision=True \
  "$@"

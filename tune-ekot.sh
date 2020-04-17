#!/bin/sh

EXPORT_DIR='/mnt/ssd/exjobb/export/'
PRE_DIR='/mnt/ssd/exjobb/ekot-base-checkpoint/'
CHECKPOINT_DIR="${EXPORT_DIR}checkpoint/"
MODEL_DIR="${EXPORT_DIR}model/"
SUMMARY_DIR="${EXPORT_DIR}tensorboard/"

TRAIN_FILES="../ekot/ekot-train.csv"
DEV_FILES="../ekot/ekot-dev.csv"
#TEST_FILE="../NST/test.csv"
TEST_FILES="../ekot/ekot-dev.csv"

if [ ! -f DeepSpeech.py ]; then
    echo "Please make sure you run this from DeepSpeech's top level directory."
    exit 1
fi;

if [ ! $UUID ] && [ ! $CONTINUE ]; then
  if [ ! $MODEL_NAME ]; then
    UUID=$(python name.py)
  else
    UUID="$MODEL_NAME"
  fi;
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
else
  echo "Copying pre-trained-checkpoint..."
  cp -R "$PRE_DIR" "${CHECKPOINT_DIR}${UUID}"
fi;

CHECKPOINT_DIR="${CHECKPOINT_DIR}${UUID}"


if [ -d "${SUMMARY_DIR}${UUID}" ] && [ ! $CONTINUE ]; then
  echo "Summary ${UUID} already exist"
  exit 1
fi;

SUMMARY_DIR="${SUMMARY_DIR}${UUID}"

mkdir "${MODEL_DIR}"
mkdir "${CHECKPOINT_DIR}" > /dev/null 2>&1
mkdir "${SUMMARY_DIR}"

echo "Running model ${UUID}"

if [ ! $MODEL_LR ]; then
  MODEL_LR=0.0001
fi;

if [ ! $MODEL_BATCH_SIZE ]; then
  MODEL_BATCH_SIZE=64
fi;

if [ ! $MODEL_DROPOUT ]; then
  MODEL_DROPOUT=0.30
fi;

echo "LR: ${MODEL_LR}"
echo "Batch size: ${MODEL_BATCH_SIZE}"
echo "Dropout: ${MODEL_DROPOUT}"

python -u DeepSpeech.py \
  --train_files "$TRAIN_FILES" \
  --dev_files "$DEV_FILES" \
  --test_files "$TEST_FILES" \
  --train_batch_size "$MODEL_BATCH_SIZE" \
  --dev_batch_size 64 \
  --test_batch_size 64 \
  --n_hidden 2048 \
  --epochs 100 \
  --dropout_rate "$MODEL_DROPOUT" \
  --learning_rate "$MODEL_LR" \
  --max_to_keep 2 \
  --report_count 100 \
  --export_dir "$MODEL_DIR" \
  --checkpoint_dir "$CHECKPOINT_DIR" \
  --summary_dir "$SUMMARY_DIR" \
  --alphabet_config_path ../NST/alphabet.txt \
  --lm_binary_path ../lm/all-nst-5.binary \
  --lm_trie_path ../lm/all-nst-5.trie \
  --export_language sv \
  --use_cudnn_rnn \
  "$@"

#!/bin/sh

EXPORT_DIR='/mnt/ssd/exjobb/export/'
PRE_DIR='/mnt/ssd/exjobb/transferred-checkpoint/'
CHECKPOINT_DIR="${EXPORT_DIR}checkpoint/"
MODEL_DIR="${EXPORT_DIR}model/"
SUMMARY_DIR="${EXPORT_DIR}tensorboard/"

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

python -u DeepSpeech.py \
  --train_files ../NST/train.csv \
  --dev_files ../NST/dev.csv \
  --test_files ../NST/dev.csv \
  --train_batch_size 64 \
  --dev_batch_size 64 \
  --test_batch_size 64 \
  --n_hidden 2048 \
  --epochs 30 \
  --noearly_stop \
  --dropout_rate 0.20 \
  --learning_rate 0.0001 \
  --report_count 100 \
  --export_dir "$MODEL_DIR" \
  --checkpoint_dir "$CHECKPOINT_DIR" \
  --summary_dir "$SUMMARY_DIR" \
  --alphabet_config_path ../NST/alphabet.txt \
  --lm_binary_path ../lm/normwiki5.binary \
  --lm_trie_path ../lm/normwiki5.trie \
  --export_language sv \
  --use_cudnn_rnn \
  "$@"

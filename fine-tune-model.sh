#!/bin/sh

EXPORT_DIR='/mnt/ssd/exjobb/export/'
PRE_DIR='/mnt/ssd/exjobb/deepspeech-0.6.1-checkpoint/'
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
  --test_files ../NST/test.csv \
  --train_batch_size 32 \
  --dev_batch_size 32 \
  --test_batch_size 32 \
  --n_hidden 2048 \
  --epochs 75 \
  --early_stop True \
  --es_steps 6 \
  --es_mean_th 0.1 \
  --es_std_th 0.1 \
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

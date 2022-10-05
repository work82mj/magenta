# Set up Environment
## Docker
- build
```bash
docker build -t musicvae --rm .
```
- run
```bash
docker run -it --name musicvae --gpus all musicvae
```

## Local
```bash
# crate conda env
conda create --name magenta python=3.7
conda acitvate magneta

pip install -r ./requirements.txt
pip install -e .
```
   

# Tutorial
Check [Notebook](https://github.com/work82mj/magenta/blob/music-vae/musicvae_with_magenta.ipynb)

# CLI
Train model with cli  
  

## Preporcess datasets
- Convert raw datasets to tfrecord(note sequences)  
Output path should be tfrecord
```bash
python ./magenta/scripts/convert_dir_to_note_sequences.py --input_dir=$YOUR_DATASET_PATH \
--output_file=.$OUTPUT_PATH \
--recursive=True \
--log=INFO
```

## Train model
### Add your own config
Add your own configmap to ./magenta/models/music_vae/configs.py
```python
CONFIG_MAP['musicvae_groove_4bar'] = Config(
    model=MusicVAE(
        lstm_models.BidirectionalLstmEncoder(),
        lstm_models.HierarchicalLstmDecoder(
            lstm_models.CategoricalLstmDecoder(),
            level_lengths=[4, 4])
        ),
    hparams=merge_hparams(
        lstm_models.get_default_hparams(),
        HParams(
            batch_size=512,
            max_seq_len=4 * 4,
            z_size=512,
            enc_rnn_size=[2048],
            dec_rnn_size=[1024, 1024],
            max_beta=0.2,
            free_bits=48,
            dropout_keep_prob=0.3,
        )),
    note_sequence_augmenter=None,
    data_converter=data.DrumsConverter(
        max_bars=100,  # Truncate long drum sequences before slicing.
        slice_bars=4,
        steps_per_quarter=4,
        roll_input=True),
    train_examples_path="",  # the tfrecord file path
    eval_examples_path="" # the eval tfrecord file path
)
```
If you use tfds, add **tfds_name** instead **examples_path**

### Start to train
```bash
cd magenta/models/music_vae

python music_vae_train.py --config=musicvae_groove_4bar \
--run_dir=$OUTPUT_DIR \
--mode=train \
--num_steps=50000 \
--cache_dataset \
--log=INFO
```

## Generate Samples
```bash
cd magenta/models/music_vae

python music_vae_generate.py --config=musicvae_groove_4bar \
--checkpoint_file=$CHECKPOINT_PATH \
--mode=sample \
--num_outputs=5 \
--output_dir=$OUTPUT_DIR
```
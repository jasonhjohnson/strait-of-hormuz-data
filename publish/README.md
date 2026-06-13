# Publishing to dataset registries

Each registry is an independent, searched, high-authority home for the same
data, and each links back to straits.live. Submit once; the GitHub Action keeps
the canonical repo fresh, and you re-push to the registries when you want them
current (commands below).

Before you start, replace the placeholders:

- `REPLACE_WITH_GH_USERNAME` in `huggingface/README.md`
- `REPLACE_WITH_HF_USERNAME` in `huggingface/README.md`
- `REPLACE_WITH_KAGGLE_USERNAME` in `kaggle/dataset-metadata.json`

All commands are run from the repository root.

## HuggingFace Datasets

The card is `publish/huggingface/README.md`; it becomes the dataset repo's
root `README.md`.

```bash
pip install -U huggingface_hub
huggingface-cli login                       # paste a write token from hf.co/settings/tokens

HF=YOUR_HF_USERNAME/strait-of-hormuz-crisis-data
huggingface-cli repo create "$HF" --type dataset -y
huggingface-cli upload "$HF" publish/huggingface/README.md README.md --repo-type dataset
huggingface-cli upload "$HF" data data --repo-type dataset
```

To refresh later, re-run the two `upload` commands (they overwrite in place).

## Kaggle

Put your API token at `~/.kaggle/kaggle.json` (from kaggle.com → Settings → API).
Kaggle wants the data files and `dataset-metadata.json` flat in one folder, so
stage them:

```bash
pip install kaggle
STAGE=$(mktemp -d)
cp data/transits.csv data/hormuz-index.csv data/hormuz-index-daily.csv \
   data/oil.csv data/events.csv data/status.csv "$STAGE"/
cp publish/kaggle/dataset-metadata.json "$STAGE"/    # edit the id first

kaggle datasets create -p "$STAGE"                   # first publish
# kaggle datasets version -p "$STAGE" -m "refresh"   # subsequent updates
```

## data.world

data.world reads the Frictionless `datapackage.json` at the repo root.

- Easiest: create a new dataset at data.world, then either upload
  `datapackage.json` together with the `data/` files, or add the repo's raw
  `datapackage.json` URL as a file source so data.world syncs it.
- The `datapackage.json` already declares the per-resource schema and licensing,
  so data.world will render typed column tables automatically.

## Notes

- Licensing is per-series (see each card). The Hormuz Index and status snapshot
  are CC0; the transit series must credit IMF PortWatch. Registries that allow
  only one license get CC0 with the IMF caveat stated in the file description.
- Keep the registry copies pointing back to <https://straits.live/data> and the
  GitHub repo; the inbound links are the point.

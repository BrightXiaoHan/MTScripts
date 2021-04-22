# mask 指定的数据集文件夹，使得接下来的命令不会作用在该文件夹
FOLDER_NAMES=$@

mkdir -p $DATASET_DIR/.mask_folder
for name in $FOLDER_NAMES; do
  if [ -d "$DATASET_DIR/$name" ]; then
    mv $DATASET_DIR/$name $DATASET_DIR/.mask_folder
  fi
done

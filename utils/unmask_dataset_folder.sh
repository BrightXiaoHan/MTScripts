# 使得指定的被mask的文件夹还原
FOLDER_NAMES=$@

for name in $FOLDER_NAMES; do
  if [ -d "$DATASET_DIR/.mask_folder/$name" ]; then
    mv $DATASET_DIR/.mask_folder/$name $DATASET_DIR
  fi
done

# 通过对数据集文件夹进行分组，分离出train, dev, test
# 这里使用带名字的参数

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            TRAIN)  TRAIN=${VALUE} ;;
            DEV)    DEV=${VALUE} ;;     
            TEST)   TEST=${VALUE} ;;     
            *)   
    esac    
done

merge () {
  OUTPUT_PREFIX=$1
  SUBSET_FOLDERS=${@: 2}
  REFERENCE=$(echo $SUBSET_FOLDERS | cut -d' ' -f1)

  for file in $(find $DATASET_DIR/$REFERENCE -maxdepth 1 -type f)
  do
      allFileNames+=" $(basename $file)"
  done

  for name in $allFileNames
  do
      input_files=""
      for folder in $SUBSET_FOLDERS 
      do
          input_files+=" $DATASET_DIR/$folder/$name"
      done
      cat $input_files > $OUTPUT_PREFIX.$name
  done
}

echo "Merging train dataset for this project..."
merge "$DATASET_DIR/train" $TRAIN
echo "Merging dev dataset for this project..."
merge "$DATASET_DIR/dev" $DEV
echo "Merging test dataset for this project..."
merge "$DATASET_DIR/test" $TEST

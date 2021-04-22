# 将数据集分为训练、开发、测试集
# 分割比例原则上按照 0.8，0.1, 0.1的比例分割，如果数据集数量大于2w，则开发集和测试集各预留2k条，不再按照比例进行分割


removeEmptyLines() {
    # 清除文件开头和结尾的空行
    echo "remove empty lines of file $1"
    sed -i -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' $1
}

splitFile() {
    # 将指定文件分为训练集、开发集、测试集
    filename=$1
    removeEmptyLines ${filename}
    numLines=$(wc -l ${filename} | cut -d" " -f1)
    if [ $numLines -gt 20000 ]; then
        split -l $(($numLines - 4000)) ${filename} ${filename}
    else
        split -l $(($numLines * 80 / 100)) ${filename} ${filename}
    fi
    mv ${filename}aa ${filename}.train
    mv ${filename}ab ${filename}.dev_test
    split -l $(($(wc -l ${filename}.dev_test | cut -d" " -f1) * 1 / 2 + 1)) ${filename}.dev_test ${filename}
    mv ${filename}aa ${filename}.dev
    mv ${filename}ab ${filename}.test
    rm ${filename}.dev_test
}

ALL_FILES=$(find ${DATASET_DIR} -maxdepth 2 -mindepth 2 -type f ! -name "*.*")

for file in ${ALL_FILES}; do
    splitFile ${file}
    rm ${file}
done

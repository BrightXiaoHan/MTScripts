# 评价第三方引擎在测试集上翻译结果的bleu值
REFERENCE=$1 # 参考译文路径
FOLDER=$2    # 第三方引擎对测试集的翻译结果存放的目录路径
LANG_PAIR=$3 # sacrebleu 测评需要指定语言对，如en-zh, zh-en
SUFFIX=$4    # 需要测评的文件后缀，默认为.translation

if [ !$SUFFIX ]; then
    SUFFIX=".translation"
fi

for file in ${FOLDER}/*${SUFFIX}
do
    echo "Calculating bleu result for file $file..."
    sacrebleu -l $LANG_PAIR $REFERENCE < $file > $file.bleu
done


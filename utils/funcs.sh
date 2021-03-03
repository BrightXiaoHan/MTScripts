# util functions for projects
get_all_files_by_lang () {
  # 给定语言类型，从$DATASET_DIR 中获得所有该语言类型的文件
  # Note: 为了保证不同语言类型获取的文件顺序一一对应，使用sort命令对查找到的文件进行排序
  # 由于子数据集中的文件都是按照$lang*的方式来命名，并且原文译文一一对应，所以可以保证合并后的原文译文一一对应。
  lang=$1
  all_files=$(find $DATASET_DIR -mindepth 2 -maxdepth 2 -type f -name "$lang*" ! -name ".*" | sort)
  echo $all_files
}

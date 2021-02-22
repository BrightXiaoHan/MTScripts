"""
从excel表格中抽取列，每一列数据单独输出为一个文件
"""
import argparse
import os

import pandas


def parse_args():
    """
    解析脚本参数
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("excel_file", type=str, help="excel文件的路径")
    parser.add_argument("output_folder", type=str,
                        help="将生成的文件输出到该参数指定的目录中。每个文件以excel每一列的title命名。")
    parser.add_argument("--suffix", type=str,
                        default=".translation", help="在输出的文件后加的后缀")
    args = parser.parse_args()
    return args


def extract_from_excel(excel_file):
    """
    从excel中抽取数据，数据将以字典的形式返回。
    """
    dataframe = pandas.read_excel(excel_file)
    return dataframe.to_dict()


def main():
    """
    脚本入口函数
    """
    args = parse_args()
    data = extract_from_excel(args.excel_file)

    for name, lines in data.items():
        file_name = os.path.join(args.output_folder, name) + args.suffix
        with open(file_name, "w") as output_file:
            for line in lines.values():
                if isinstance(line, str):
                    output_file.write(line.strip().replace("\r", "").replace("\n", "") + "\n")
                else:
                    output_file.write("\n")


if __name__ == "__main__":
    main()

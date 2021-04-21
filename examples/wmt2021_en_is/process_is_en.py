"""
preprocess en-is wmt2021 datasets
"""
import glob
import os
import subprocess

from tqdm import tqdm
from joblib import Parallel, delayed
    
import mtcorpus
from translate.storage.tmx import tmxfile

wmt2021_en_is_parallel = {
    "ParIce": "http://parice.arnastofnun.is/data/parice_filtered.zip",
    "ParaCrawl v7.1": "https://s3.amazonaws.com/web-language-models/paracrawl/release7.1/en-is.txt.gz",
    "Wiki Titles v3": "http://data.statmt.org/wikititles/v3/wikititles-v3.is-en.tsv",
    "WikiMatrix": "http://data.statmt.org/wmt21/translation-task/WikiMatrix/WikiMatrix.v1.en-is.langid.tsv.gz",

    # Dataset from http://parice.arnastofnun.is/
    "UD Icelandic PUD": "https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-3424/ud-treebanks-v2.7.tgz",
    "En-Is Semi-Synthetic Parallel Name Robustness Corpus": "https://repository.clarin.is/repository/xmlui/bitstream/handle/20.500.12537/74/parice-name-corpus.post-substitution.v2.tsv",
    "EN-IS Synthetic Parallel Corpus": "https://repository.clarin.is/repository/xmlui/bitstream/handle/20.500.12537/70/eng-isl-synthetic-corpus-v1.0.tar.gz"
}


wmt2021_is_monolingual = {
    "News crawl": "http://data.statmt.org/news-crawl/is/news.2020.is.shuffled.deduped.gz",
    "Common Crawl": "http://web-language-models.s3-website-us-east-1.amazonaws.com/ngrams/is/deduped/is.deduped.xz",
    "Icelandic Gigaword Part1": "https://repository.clarin.is/repository/xmlui/bitstream/handle/20.500.12537/41/IGC1.20.05.zip",
    "Icelandic Gigaword Part2": "https://repository.clarin.is/repository/xmlui/bitstream/handle/20.500.12537/33/IGC2.20.05.zip"
}

wmt2021_en_is_dev = "http://data.statmt.org/wmt21/translation-task/dev.tgz"


@mtcorpus.download_warpper(wmt2021_en_is_parallel["ParIce"], "is-en/raw/parice1.1.zip", "is-en/raw/ParIce1.1")
def get_parice_corpus():
    print("Processing ParIce...")
    all_files = glob.glob("is-en/raw/ParIce1.1/tmx/*.tmx")
    corpus = mtcorpus.tmx_file_parser(all_files, "en", "is")
    mtcorpus.write_corpus("is-en/parallel/ParIce1.1", corpus, "en", "is")
    print("Processing ParIce done.")


@mtcorpus.download_warpper(wmt2021_en_is_parallel["ParaCrawl v7.1"], "is-en/raw/en-is.txt.gz", "is-en/raw/en-is.txt")
def get_paracral_corpus():
    print("Processing ParaCrawl...")
    corpus = mtcorpus.tsv_file_parser("is-en/raw/en-is.txt")
    mtcorpus.write_corpus("is-en/parallel/ParaCrawl", corpus, "en", "is")
    print("Processing ParaCrawl done.")


@mtcorpus.download_warpper(wmt2021_en_is_parallel["Wiki Titles v3"], "is-en/raw/wikititles-v3.is-en.tsv", "is-en/raw/wikititles-v3.is-en.tsv")
def get_wikititles_corpus():
    print("Processing Wiki Titles v3...")
    corpus = mtcorpus.tsv_file_parser("is-en/raw/wikititles-v3.is-en.tsv")
    mtcorpus.write_corpus("is-en/parallel/wikititle", corpus, "is", "en")
    print("Processing Wiki Titles v3 done.")


@mtcorpus.download_warpper(wmt2021_en_is_parallel["WikiMatrix"], "is-en/raw/WikiMatrix.v1.en-is.langid.tsv", "is-en/raw/WikiMatrix.v1.en-is.langid.tsv")
def get_wikimatrix_corpus():
    print("Processing Wiki Matrix...")
    corpus = mtcorpus.tsv_file_parser(
        "is-en/raw/WikiMatrix.v1.en-is.langid.tsv", 1, 2)
    mtcorpus.write_corpus("is-en/parallel/wikimatrix", corpus, "en", "is")
    print("Processing Wiki Matrix done.")


@mtcorpus.download_warpper(wmt2021_en_is_parallel["En-Is Semi-Synthetic Parallel Name Robustness Corpus"], "is-en/raw/parice-name-corpus.post-substitution.v2.tsv", "is-en/raw/parice-name-corpus.post-substitution.v2.tsv")
def get_paricename_corpus():
    print("Processing En-is Semi-Synthetic Parallel Name Robustness Corpus...")
    corpus = mtcorpus.tsv_file_parser(
        "is-en/raw/parice-name-corpus.post-substitution.v2.tsv")
    mtcorpus.write_corpus("is-en/parallel/paricename", corpus, "en", "is")
    print("Processing En-is Semi-Synthetic Parallel Name Robustness Corpus done.")


@mtcorpus.download_warpper(wmt2021_en_is_parallel["EN-IS Synthetic Parallel Corpus"], "is-en/raw/eng-isl-synthetic-corpus-v1.0.tar.gz", "is-en/raw/eng-isl-synthetic-corpus-v1.0")
def get_paricesynthetic_corpus():
    print("Processing EN-IS Synthetic Parallel Corpus...")
    all_files = glob.glob(
        "is-en/raw/eng-isl-synthetic-corpus-v1.0/monolingual-isl/*/*.tsv")
    corpus = mtcorpus.tsv_file_parser(all_files)
    mtcorpus.write_corpus(
        "is-en/parallel/parices-synthetic", corpus, "en", "is")
    print("Processing EN-IS Synthetic Parallel Corpus done.")


@mtcorpus.download_warpper(wmt2021_en_is_dev, "is-en/raw/dev.tgz", "is-en/raw/dev")
def get_dev_corpus():
    print("Processing dev data ...")
    subprocess.call(
        "python is-en/raw/dev/dev/xml/extract.py is-en/raw/dev/dev/xml/newsdev2021.en-is.xml -o is-en/raw/dev/dev/newsdev2021.en-is", shell=True)
    src_files = ["is-en/raw/dev/dev/newsdev2021.en-is.en"]
    tgt_files = ["is-en/raw/dev/dev/newsdev2021.en-is.is"]
    corpus = mtcorpus.seperate_file_parser(src_files, tgt_files)
    mtcorpus.write_corpus("is-en/parallel/dev", corpus, "en", "is")
    print("Process dev data done.")


def main():
    get_parice_corpus()
    get_paracral_corpus()
    # skip wikititles and wikimatrix for quality reason
    # get_wikititles_corpus()
    # get_wikimatrix_corpus()
    get_paricename_corpus()
    get_paricesynthetic_corpus()
    get_dev_corpus()


if __name__ == "__main__":
    main()

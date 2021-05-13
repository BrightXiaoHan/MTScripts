LIBRARY_NAME=$1

SCRIPTS_SOURCE_ROOT=$(dirname $0)/..

prepare_fast_align () {
  FAST_ALIGN_HOME="$SCRIPTS_SOURCE_ROOT/.fast_align"
  if [[ ! -d $FAST_ALIGN_HOME ]]; then
    git clone https://gitee.com/brightxiaohan/fast_align.git $FAST_ALIGN_HOME
    pushd $FAST_ALIGN_HOME
    mkdir build
    cd build
    cmake ..
    make
    popd
  fi
  echo $FAST_ALIGN_HOME/build/fast_align
}

prepare_mgiza () {
  # clone and build
  MGIZA_HOME="$SCRIPTS_SOURCE_ROOT/.mgiza"
  if [[ ! -d $MGIZA_HOME ]]; then
    git clone https://gitee.com/brightxiaohan/mgiza.git .mgiza
    pushd $MGIZA_HOME
    cd .mgiza/mgizapp
    cmake .
    make
    popd
  fi
  mgiza_bin=$MGIZA_HOME/mgizapp/bin
  wget https://pastebin.com/raw/b1ksHtUy -O $mgiza_bin/config
  echo $mgiza_bin
}

prepare_fairseq () {
  FAIRSEQ_HOME="$SCRIPTS_SOURCE_ROOT/.fairseq"
  if [ ! -d $FAIRSEQ_HOME ]; then
    git clone https://gitee.com/brightxiaohan/fairseq.git $FAIRSEQ_HOME -b v0.10.1
    pushd $FAIRSEQ_HOME
    python setup.py build_ext --inplace
    popd
  fi
  echo $FAIRSEQ_HOME
}

prepare_moses () {
  MOSES_HOME="$SCRIPTS_SOURCE_ROOT/.mosesdecoder"
  if [ ! -d $MOSES_HOME ]; then
    git clone https://gitee.com/brightxiaohan/mosesdecoder.git $MOSES_HOME
  fi
  echo $MOSES_HOME/scripts
}

prepare_sentencepiece () {
  SENTENCEPIECE_HOME="$SCRIPTS_SOURCE_ROOT/.sentencepiece"
  if [ ! -d $SENTENCEPIECE_HOME ]; then
    git clone https://gitee.com/brightxiaohan/sentencepiece.git $SENTENCEPIECE_HOME
    pushd $SENTENCEPIECE_HOME
    mkdir build
    cmake -H. -Bbuild -G "Unix Makefiles"
    cmake --build build
    popd
  fi
  echo $SENTENCEPIECE_HOME/build/src
}

prepare_$LIBRARY_NAME

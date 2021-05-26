LIBRARY_NAME=$1

SCRIPTS_SOURCE_ROOT=$(dirname $0)/..
PWD=$(pwd)

prepare_fast_align () {
  FAST_ALIGN_HOME="$SCRIPTS_SOURCE_ROOT/.fast_align"
  if [[ ! -d $FAST_ALIGN_HOME ]]; then
    git clone https://gitee.com/brightxiaohan/fast_align.git $FAST_ALIGN_HOME
    cd $FAST_ALIGN_HOME
    mkdir build
    cd build
    cmake ..
    make
    cd $PWD
  fi
  echo $FAST_ALIGN_HOME/build/fast_align
}

prepare_mgiza () {
  # clone and build
  MGIZA_HOME="$SCRIPTS_SOURCE_ROOT/.mgiza"
  if [[ ! -d $MGIZA_HOME ]]; then
    git clone https://gitee.com/brightxiaohan/mgiza.git .mgiza
    cd $MGIZA_HOME
    cd .mgiza/mgizapp
    cmake .
    make
    cd $PWD
  fi
  mgiza_bin=$MGIZA_HOME/mgizapp/bin
  wget https://pastebin.com/raw/b1ksHtUy -O $mgiza_bin/config
  echo $mgiza_bin
}

prepare_fairseq () {
  FAIRSEQ_HOME="$SCRIPTS_SOURCE_ROOT/.fairseq"
  if [ ! -d $FAIRSEQ_HOME ]; then
    git clone -q https://gitee.com/brightxiaohan/fairseq.git $FAIRSEQ_HOME
    cd $FAIRSEQ_HOME
    python setup.py build_ext --inplace
    cd $PWD
  fi
  if [ ! -n "$FRAMEWORK_VERSION" ]; then
    FRAMEWORK_VERSION="v0.10.2"
  fi
  cd $FAIRSEQ_HOME
  git checkout -q $FRAMEWORK_VERSION
  cd $PWD
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
    cd $SENTENCEPIECE_HOME
    mkdir build
    cmake -H. -Bbuild -G "Unix Makefiles"
    cmake --build build
    cd $PWD
  fi
  echo $SENTENCEPIECE_HOME/build/src
}

prepare_$LIBRARY_NAME

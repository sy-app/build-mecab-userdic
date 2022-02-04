FROM python:3.8

USER root

RUN apt-get update
RUN apt-get -y install locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

# install build libs
RUN yum groupinstall -y "Development Tools" \
    && yum install -y which openssl

# install python library
COPY ./requirements.txt /opt/
RUN pip install --upgrade pip && pip install -r /opt/requirements.txt

# install mecab, ipadic, ipadic-neologd
WORKDIR /tmp
RUN  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" -o mecab-0.996.tar.gz \
    && tar xzf mecab-0.996.tar.gz \
    && cd mecab-0.996 \
    && ./configure \
    && make \
    && make check \
    && make install \
    && cd .. \
    && rm -rf mecab-0.996*

WORKDIR /tmp
RUN curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" -o mecab-ipadic-2.7.0-20070801.tar.gz \
    && tar -zxvf mecab-ipadic-2.7.0-20070801.tar.gz \
    && cd mecab-ipadic-2.7.0-20070801 \
    && ./configure --with-charset=utf8 \
    && make \
    && make install \
    && cd .. \
    && rm -rf mecab-ipadic-2.7.0-20070801

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && cd mecab-ipadic-neologd \
    && ./bin/install-mecab-ipadic-neologd -n -a -y \
    && rm -rf mecab-ipadic-neologd

# setup python
COPY ./requirements.txt /opt/
RUN pip install --upgrade pip && pip install -r /opt/requirements.txt

# download userdic(.csv)
CMD ["python", "src/download_userdic_csv.py"]

# compile userdic
RUN /usr/lib/mecab/mecab-dict-index -d /usr/local/lib/mecab/dic/mecab-ipadic-neologd -u lovelive_word_dic.dic -f utf-8 -t utf-8 /tmp/lovelive_word_dic.csv

# upload compiled userdic(.dic) to s3
CMD ["python", "src/upload_userdic_compiled.py"]

import boto3


bucket_name = 'll-now-material'


def main():
    # コンパイル済みのユーザ辞書をs3にアップロード
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    dic_path = 'lovelive_word_dic.dic'
    dic_key = 'lovelive_word_dic.dic'
    bucket.upload_file(dic_path, dic_key)


if __name__ == "__main__":
    main()

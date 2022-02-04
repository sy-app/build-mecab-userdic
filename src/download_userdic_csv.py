import boto3


def main():
    # ユーザ辞書をs3からダウンロード
    s3 = boto3.resource('s3')
    bucket = s3.Bucket('ll-now-material')
    file_key = 'lovelive_word_dic.csv'
    file_path = '/tmp/lovelive_word_dic.csv'
    bucket.download_file(file_key, file_path)


if __name__ == "__main__":
    main()

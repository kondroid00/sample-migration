#!/bin/sh

host=localhost
port=3306
execute=false

#----------------------------------------------
#   オプションのチェック
#----------------------------------------------
while getopts :h:p:d:f:e:-: opt; do
    case $opt in
        h) host=$OPTARG
            ;;
        p) port=$OPTARG
            ;;
        d) database=$OPTARG
            ;;
        f) filepath=$OPTARG
            ;;
        e) env=$OPTARG
            ;;
        -)
            case "${OPTARG}" in
                execute)
                    execute=true
                    ;;
            esac
            ;;
    esac
done

#----------------------------------------------
#   実行関数を定義
#----------------------------------------------
dry_run () {
    /go/bin/mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} --dry-run < ${sql_file}
}

execute () {
    /go/bin/mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} < ${sql_file}
}


#----------------------------------------------
#   ファイル名とディレクトリ名をスキャンして実行
#----------------------------------------------
migration_dir=db/migrations
for search_dir in $migration_dir/*; do
    # ディレクトリ名からDB名を取得
    dir=${search_dir##*/}

    # sqlファイルを取得
    list=`find ${search_dir} -type f -name \*.sql | sort`

    # 各ファイルを結合したsqlファイルを作成
    sql_file=${search_dir}/${dir}.sql
    cat ${list} > ${sql_file}

    # 環境変数を考慮したDB名をつける
    if [ -n "${env}" ]; then
        database=${dir}_${env}
    fi

    # dryrun
    dry_run

    # 実行フラグがついていれば実行
    if "${execute}"; then
        echo "start migration"
        execute
        echo "end migration"
    fi

    # 結合したsqlファイルを削除
    rm -f ${sql_file}
done

exit;
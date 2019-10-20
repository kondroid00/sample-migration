#!/bin/sh

host=localhost
port=3306
execute=false
test=false

#----------------------------------------------
#   オプションのチェック
#----------------------------------------------
while getopts :h:p:d:f:-: opt; do
    case $opt in
        h) host=$OPTARG
            ;;
        p) port=$OPTARG
            ;;
        d) database=$OPTARG
            ;;
        f) filepath=$OPTARG
            ;;
        -)
            case "${OPTARG}" in
                execute)
                    execute=true
                    ;;
                test)
                    test=true
                    ;;
            esac
            ;;
    esac
done

#----------------------------------------------
#   実行関数を定義
#----------------------------------------------
dry_run () {
    /go/bin/mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} --dry-run < ${filepath}
}

execute () {
    /go/bin/mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} < ${filepath}
}


#----------------------------------------------
#   ファイル名とディレクトリ名をスキャンして実行
#----------------------------------------------
migration_dir=db/migrations
list=`find ${migration_dir} -type f -name \*.sql`
for filepath in ${list} ; do
    database=`basename ${filepath} .sql`
    if "${test}"; then
        database=${database}_test
    fi
    dry_run
    if "${execute}"; then
        echo "start migration"
        execute
        echo "end migration"
    fi
done

exit;


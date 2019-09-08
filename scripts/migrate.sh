#!/bin/sh

host=localhost
port=3306
execute=false

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
            esac
            ;;
    esac
done

if [ "${database}" = "" ]; then
    echo "no database selected"
    exit 1
fi

if [ "${filepath}" = "" ]; then
    echo "no filepath selected"
    exit 1
fi

dry_run () {
    mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} --dry-run < ${filepath}
}

execute () {
    mysqldef -u${DB_USER} -p${DB_PASSWORD} -h${host} -P${port} ${database} < ${filepath}
}

dry_run

if "${execute}"; then
    echo "start migration"
    execute
    echo "end migration"
fi

exit;

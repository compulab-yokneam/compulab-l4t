export PSQL="psql -h pg-production -d clstock -U atp_engineers"
CLOG_CLERP=${CLOG_CLERP:-"yes"}
export VPD_DATA=""

function clog_log() {
    rc=${rc:-$?} debug_trace ${ATP_STATUS}
    SERIAL=${SERIAL:-"CAFE-ERROR-CAFE"};

    if [[ -z ${SERIAL} ]];then
        echo "Empty SERIAL exit ..."
        return 0
    fi

    PRODUCT=${PRODUCT:-'empty'};
    CONFIG=${CONFIG:-'empty'};
    STATION=${STATION:-'100'};
    VPD=${VPD_DATA}
    command -v psql &>/dev/null && ${PSQL} -c "INSERT INTO atp_log(serial_number, atp_status, vpd, station, product, config, error) VALUES('${SERIAL}', '${ATP_STATUS}', '${VPD}', '${STATION}', '${PRODUCT}', '${CONFIG}', '${ATP_ERROR}');"
}

function clog_get() {
    local _serial=${1:-'empty'}
    local _fields=${2:-'*'}
    if [ ${_serial} != 'empty' ];then
        command -v psql &>/dev/null && ${PSQL} -c "select ${_fields} from atp_log where serial_number LIKE '${_serial}'"
    fi
}

function get_status() {
    local _serial=${1:-'empty'}
    local _atp_status=${2:-'*'}
    if [ ${_serial} != 'empty' ];then
        command -v psql &>/dev/null && ${PSQL} -c "select * from atp_log where serial_number LIKE '${_serial}' AND atp_status LIKE '${_atp_status}'"
    fi
}

function get_last_status() {
    local _serial=${1:-'empty'}
    if [ ${_serial} != 'empty' ];then
        command -v psql &>/dev/null && ${PSQL} -c "select atp_status from atp_log where serial_number LIKE '${_serial}' ORDER BY date DESC LIMIT 1"
    fi
}

function set_status() {
	SERIAL=${1:-""}
	STATUS=${2:-""}
	
	if [[ -z ${SERIAL} ]];then
		echo "Empty SERIAL exit ..."
		return 0
	fi
	if [[ -z ${STATUS} ]];then
	        echo "Empty STATUS exit ..."
	        return 0
	fi

	PRODUCT=${PRODUCT:-'empty'};
	CONFIG=${CONFIG:-'empty'};
        STATION=${STATION:-'100'};
	ATP_ERROR=${ATP_ERROR:-'empty'};
	command -v psql &>/dev/null && ${PSQL} -c "INSERT INTO atp_log(serial_number, atp_status, station, product, config, error) VALUES('${SERIAL}', '${STATUS}', '${STATION}', '${PRODUCT}', '${CONFIG}', '${ATP_ERROR}');"
}
							
function clog_del() {
    local _serial=${1:-'empty'}
    if [ ${_serial} != 'empty' ];then
        command -v psql &>/dev/null && ${PSQL} -c "delete from atp_log where serial_number LIKE '${_serial}'"
    fi
}

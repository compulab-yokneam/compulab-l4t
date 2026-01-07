############################################################################
# void config_init_sql(const char *sn)
#
# @sn	- the serial number returned by the barcode scanner
#
# Retrieves the correct values directly from the CLERP database.
# Returns 0 on success, 1 on failure (meaning the serial number has not been
# found).
############################################################################
function get_config() {
    local SN=$(echo ${1:-} | sed 's/\(5[aA]\)0*/\1/')
    local PROD=""
    local PG_HOST="pg-production"
    local PG_DB="clstock"
    local PG_USERNAME="atp_engineers"
    local sfield="product_name,assembly_name,pcb_rev"

    for dfield in serial_number_embedded serial_number_enclosed; do

        eval $(psql -h ${PG_HOST} -d ${PG_DB} -U ${PG_USERNAME} -c "select ${dfield}","${sfield} from stock.atp_serials where ${dfield} LIKE '${SN}'" |
            awk -v SN=${SN} -F"|" '$0 ~ SN { gsub(/ /,"",$1);gsub(/ /,"",$2);gsub(/ /,"",$3);gsub(/ /,"",$4);gsub($2"-","",$3); $0="C_SERIAL="$1"; PROD="$2"; CONFIG="$3"; REVISION="$4 ; print }')

        [[ -n ${PROD} ]] && break

    done

    if [[ -z ${PROD} ]];then
        cat <<< "Serial # ${SERIAL}: configuration error"
        return 1
    fi

    export PRODUCT=${PROD}
    export CONFIG=${CONFIG}
    export REVISION=${REVISION}
    return 0;
}

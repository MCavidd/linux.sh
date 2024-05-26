
script_name="$0"
log_message="$1"
log_file="$2"

log_date=`date +"%d-%m-%Y %H:%M:%S"`

echo "[$log_date] $log_message" >> $log_file
error_exit()
{
    printf '%s\n' "$1" 1>&2;
    exit 1;
}

check_http_status_code()
{
    json_response_with_status="$1"
    
    # The status was included as the last 3 characters of the response string
    # The status is extracted using the method outlined here:
    # https://stackoverflow.com/questions/19858600/accessing-last-x-characters-of-a-string-in-bash
    # This version works with responses of less than 3 characters
    # rather than the simpler ${json_response_with_status:(-3)}
    
    status=${json_response_with_status:${#json_response_with_status}<3?0:-3}
    
    if [ "$status" != "200" ]; then
          error_exit "A *""$status""* response was received from the server.";
    fi;
}


process_query()
{
    if [ "$#" -ne 3 ]; then
        error_exit "Usage: process_query service_endpoint query expected_output";
    fi;

    query="$2"
    expected="$3"
    
    if [ "$DEBUG" = true ]; then
        echo "curl -sSLN -w "%{http_code}"  \"${ENDPOINT}\" --tls-max 1.2 --tlsv1.2  --ciphers DEFAULT@SECLEVEL=1 -H \"Content-type: application/json\" -H \"cache-control: no-cache\" -X POST --data \"${query}\""
    fi
    
    data=$(curl -sSLN -w "%{http_code}" "${ENDPOINT}" --tls-max 1.2 --tlsv1.2  --ciphers DEFAULT@SECLEVEL=1 -H "Content-type: application/json" -H "cache-control: no-cache" -X POST --data "${query}")
    check_http_status_code "$data"
    
    # Remove the 200 status code from the end of the response and process
    json=${data%200}
    if [ "$json" != "$expected" ]; then
    	echo "** Failed **"
        error_exit "The result: $json does not match the expected_output $expected";
    else
    	echo "Passed"
    fi
    
    printf '\n'

}

run_test()
{
    if [ "$#" -ne 2 ]; then
        error_exit "Usage: run_test query expected_output";
    fi;
    process_query "$ENDPOINT" "$1" "$2"
}


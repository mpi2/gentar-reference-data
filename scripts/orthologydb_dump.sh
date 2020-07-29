#!/bin/bash
set -e

ENDPOINT="https://www.gentar.org/orthology-dev/v1alpha1/pg_dump"
EBI_PROXY="http://hx-wwwcache.ebi.ac.uk:3128"

error_exit()
{
    printf '%s\n' "$1" 1>&2;
    exit 1;
}

set_schema_filename()
{
	OUTPUT='orthologydb_schema.sql'
}

set_schema_payload()
{
	PAYLOAD='{ "opts": ["-O", "-x", "--schema-only", "--schema", "public"],
              "clean_output": true 
            }'
}

set_table_data_payload()
{
    if [ "$#" -ne 1 ]; then
        error_exit "Usage: set_table_data_payload table";
    fi;

    table="$1"
    
	PAYLOAD='{ "opts": ["-O", "-x", "--encoding=UTF8", "--data-only", 
	                    "--schema", "public", 
	                    "--disable-triggers",  
	                    "--table='"$table"'"],
              "clean_output": true 
            }'
}

set_table_dump_options()
{
    if [ "$#" -ne 1 ]; then
        error_exit "Usage: set_table_dump_options table";
    fi;

    table="$1"
    
	DUMPOPTIONS='-O -x --encoding=UTF8 --data-only --schema public --disable-triggers --table='"$table"
	
}

set_table_filename()
{
    if [ "$#" -ne 1 ]; then
        error_exit "Usage: set_table_filename table";
    fi;

    table="$1"
	OUTPUT='orthologydb_'"$table"'.sql'
}


fetch_data()
{
    if [ "$#" -ne 2 ]; then
        error_exit "Usage: fetch_data request_payload output_file";
    fi;

    request_payload="$1"
    output_file="$2"

    curl "$ENDPOINT" -X -x "$EBI_PROXY" POST --data "$request_payload" \
          -H "Content-Type: application/json" \
          -H "X-Hasura-Role: admin" > "$output_file"
}


pg_dump_data()
{
    if [ "$#" -ne 2 ]; then
        error_exit "Usage: pg_dump_data dump_options output_file";
    fi;

    dump_options="$1"
    output_file="$2"

    pg_dump $dump_options \
    -h $DATABASE_HOST \
    -p $DATABASE_PORT \
    -U $ORTHOLOGY_POSTGRES_USER \
    -d $ORTHOLOGY_POSTGRES_DB > $output_file
}

dump_the_schema()
{
	printf 'schema:\n'
	set_schema_filename
	set_schema_payload
	fetch_data "$PAYLOAD" "$OUTPUT"
	printf '\n'
}

dump_table_data()
{
    for table in ortholog hgnc_gene mouse_gene mouse_gene_synonym mouse_gene_synonym_relation mouse_mapping_filter human_gene human_mapping_filter human_gene_synonym human_gene_synonym_relation; do
		printf '%s:\n' "$table"
		set_table_filename "$table"
		set_table_dump_options "$table"
		pg_dump_data "$DUMPOPTIONS" "$OUTPUT"
		printf '\n'
	done;
}


main()
{
	dump_the_schema
	dump_table_data
}


main



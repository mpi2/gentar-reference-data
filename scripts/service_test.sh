#!/bin/bash
set -e

DEBUG=false

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR"/helper_functions.sh


ENDPOINT='https://www.gentar.org/refdata-dev/v1/graphql'

for i in "$@"
do
case $i in
    -p|--production)
    ENDPOINT='https://www.gentar.org/refdata/v1/graphql'
    shift # past argument
    ;;
    -d|--dev)
    ENDPOINT='https://www.gentar.org/refdata-dev/v1/graphql'
    shift # past argument
    ;;
    -s=*|--service=*)
    ENDPOINT="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
done




mouse_gene_test()
{
    echo "Mouse Gene Test"
    
    symbol="Tbx20"
    mgi_gene_acc_id="MGI:1888496"
    query='{ "query": "{mouse_gene(where: {symbol: {_eq: \"'"$symbol"'\" }}) {mgi_gene_acc_id}}" }'    
    expected_result='{"data":{"mouse_gene":[{"mgi_gene_acc_id":"'"$mgi_gene_acc_id"'"}]}}'
    run_test "$query" "$expected_result"
    
}

mouse_gene_synonym_test()
{
    echo "Mouse Gene Synonym Test"
    
    synonym="Fgf-8"
    mgi_gene_acc_id="MGI:99604"
    query='{ "query": "{mouse_gene_synonym(where: {synonym: {_eq: \"'"$synonym"'\" }}) {mgi_gene_acc_id}}" }'    
    expected_result='{"data":{"mouse_gene_synonym":[{"mgi_gene_acc_id":"'"$mgi_gene_acc_id"'"}]}}'
    run_test "$query" "$expected_result"
    
}

mouse_mapping_filter_test()
{
    echo "Mouse Mapping Filter Test"
    
    query='{ "query": "{mouse_mapping_filter(distinct_on: category_for_threshold, order_by: {category_for_threshold: asc}) {category_for_threshold}}" }'    
    expected_result='{"data":{"mouse_mapping_filter":[{"category_for_threshold":"no-ortholog"}, {"category_for_threshold":"one-to-many"}, {"category_for_threshold":"one-to-one"}]}}'
    run_test "$query" "$expected_result"
    
}


human_gene_test()
{
    echo "Human Gene Test"
    
    symbol="TBX20"
    query='{ "query": "{human_gene(where: {symbol: {_eq: \"'"$symbol"'\" }}) {hgnc_acc_id}}" }'    
    expected_result='{"data":{"human_gene":[{"hgnc_acc_id":"HGNC:11598"}]}}'
    run_test "$query" "$expected_result"
    
}

human_gene_synonym_test()
{
    echo "Human Gene Synonym Test"
    
    synonym="AIGF"
    hgnc_acc_id="HGNC:3686"
    query='{ "query": "{human_gene_synonym(where: {synonym: {_eq: \"'"$synonym"'\" }}) {hgnc_acc_id}}" }'    
    expected_result='{"data":{"human_gene_synonym":[{"hgnc_acc_id":"'"$hgnc_acc_id"'"}]}}'
    run_test "$query" "$expected_result"
    
}

human_mapping_filter_test()
{
    echo "Human Mapping Filter Test"
    
    query='{ "query": "{human_mapping_filter(distinct_on: category_for_threshold, order_by: {category_for_threshold: asc}) {category_for_threshold}}" }'    
    expected_result='{"data":{"human_mapping_filter":[{"category_for_threshold":"no-ortholog"}, {"category_for_threshold":"one-to-many"}, {"category_for_threshold":"one-to-one"}]}}'
    run_test "$query" "$expected_result"
    
}

hgnc_gene_test()
{
    echo "HGNC Gene Test"
    
    symbol="TBX20"
    query='{ "query": "{hgnc_gene(where: {symbol: {_eq: \"'"$symbol"'\" }}) {locus_group}}" }'    
    expected_result='{"data":{"hgnc_gene":[{"locus_group":"protein-coding gene"}]}}'
    run_test "$query" "$expected_result"
    
}

ortholog_support_count_test()
{
    echo "Ortholog Support Count Test"
    
    query='{ "query": "{ortholog_aggregate{aggregate{max {support_count}}}}" }'    
    expected_result='{"data":{"ortholog_aggregate":{"aggregate" : {"max" : {"support_count" : 12}}}}}'
    run_test "$query" "$expected_result"
    
}

ortholog_is_max_human_to_mouse_test()
{
    echo "Ortholog is_max_human_to_mouse Test"
    
    query='{ "query": "{ortholog(distinct_on: is_max_human_to_mouse, order_by: {is_max_human_to_mouse: asc}) {is_max_human_to_mouse}}" }'    
    expected_result='{"data":{"ortholog":[{"is_max_human_to_mouse":"dup_max"}, {"is_max_human_to_mouse":"max"}, {"is_max_human_to_mouse":"no_max"}]}}'
    run_test "$query" "$expected_result"
    
}

ortholog_is_max_mouse_to_human_test()
{
    echo "Ortholog is_max_mouse_to_human Test"
    
    query='{ "query": "{ortholog(distinct_on: is_max_mouse_to_human, order_by: {is_max_mouse_to_human: asc}) {is_max_mouse_to_human}}" }'    
    expected_result='{"data":{"ortholog":[{"is_max_mouse_to_human":"dup_max"}, {"is_max_mouse_to_human":"max"}, {"is_max_mouse_to_human":"no_max"}]}}'
    run_test "$query" "$expected_result"
    
}


mouse_tests()
{
    mouse_gene_test
    mouse_gene_synonym_test
    mouse_mapping_filter_test
}

human_tests()
{
    human_gene_test
    human_gene_synonym_test
    human_mapping_filter_test
    hgnc_gene_test
}

ortholog_tests()
{
    ortholog_support_count_test
    ortholog_is_max_human_to_mouse_test
    ortholog_is_max_mouse_to_human_test
}

main()
{
    printf '\nService Tested:\n%s\n\n' "$ENDPOINT"
    mouse_tests
    human_tests
    ortholog_tests
}

main
#!/bin/bash
set -e

# see: https://docs.docker.com/samples/library/postgres/

# The initialization files in /docker-entrypoint-initdb.d will be executed in sorted name 
# order as defined by the current locale, which defaults to en_US.utf8. Hence the name 
# stock_db.sh to follow the sql file containing the schema.

# scripts in /docker-entrypoint-initdb.d are only run if you start the container with a 
# data directory that is empty; any pre-existing database will be left untouched on 
# container startup. One common problem is that if one of your /docker-entrypoint-initdb.d 
# scripts fails (which will cause the entrypoint script to exit) and your orchestrator 
# restarts the container with the already initialized data directory, it will not continue 
# on with your scripts.


# It is recommended that any psql commands that are run inside of a *.sh script be 
# executed as POSTGRES_USER by using the --username "$POSTGRES_USER" flag. This user will 
# be able to connect without a password due to the presence of trust authentication for 
# Unix socket connections made inside the container.


printf '#! /usr/bin/bash\nstart=%s\n' $(date +"%s") > /usr/local/data/postgres_processing_time.sh


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /mnt/orthologydb_schema.sql

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /mnt/refdata_schema_additions.sql

# Load the orthology data
for i in ortholog hgnc_gene mouse_gene mouse_gene_synonym mouse_gene_synonym_relation mouse_mapping_filter human_gene human_mapping_filter human_gene_synonym human_gene_synonym_relation; do
	psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /mnt/orthologydb_"$i".sql
done;




# MGI_Strain_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy strain (mgi_strain_acc_id,name,type) FROM '/mnt/MGI_Strain_test.rpt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"



# MGI_Allele_data_load.txt

tail -n +14 /mnt/NorCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/EUCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/KOMP_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +8 /mnt/MGI_PhenotypicAllele.rpt.test.txt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_phenotypic_allele_tmp (mgi_allele_acc_id,allele_symbol,allele_name,type,allele_attribute,pubmed_acc_id,mgi_marker_acc_id,gene_symbol,refseq_acc_id,ensembl_acc_id,mp_acc_ids,synonyms,gene_name) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_allele (allele_symbol,mgi_allele_acc_id,name) select a.allele_symbol,a.mgi_allele_acc_id, a.allele_name 
from 
mgi_allele_tmp a, mouse_gene m where a.mgi_marker_acc_id=m.mgi_gene_acc_id 
UNION 
select p.allele_symbol,p.mgi_allele_acc_id, p.allele_name from mgi_phenotypic_allele_tmp p, mouse_gene m2 where p.mgi_marker_acc_id=m2.mgi_gene_acc_id"

# Create the production version of the mgi_allele table
# Note: there is a one-to-many relationship between mouse_allele and mgi_allele for MGI:5013777

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mgi_allele (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids,mouse_allele_id,mouse_gene_id)
select x.project_acc_id,x.db_name,x.mgi_allele_acc_id,x.allele_symbol,x.allele_name,x.mgi_marker_acc_id,x.gene_symbol,x.cell_line_acc_ids,x.mouse_allele_id, mouse_gene.id
FROM
(select ma.project_acc_id,ma.db_name,ma.mgi_allele_acc_id,ma.allele_symbol,ma.allele_name,ma.mgi_marker_acc_id,ma.gene_symbol,ma.cell_line_acc_ids, mouse_allele.id as \"mouse_allele_id\" FROM 
mgi_allele_tmp ma left outer join mouse_allele ON ma.mgi_allele_acc_id = mouse_allele.mgi_allele_acc_id) x
left outer join mouse_gene
ON x.mgi_marker_acc_id = mouse_gene.mgi_gene_acc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP table mgi_allele_tmp"


# Create the production version of the mgi_phenotypic_allele table 
# - NOTE: there are different column names compared to mgi_phenotypic_allele_tmp

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mgi_phenotypic_allele (mgi_allele_acc_id,allele_symbol,allele_name,type,allele_attribute,pubmed_acc_id,mgi_marker_acc_id,gene_symbol,refseq_acc_id,ensembl_acc_id,mp_acc_ids,synonyms,gene_name,mouse_allele_id,mouse_gene_id)
select x.mgi_allele_acc_id,x.allele_symbol,x.allele_name,x.type,x.allele_attribute,x.pubmed_acc_id,x.mgi_marker_acc_id,x.gene_symbol,x.refseq_acc_id,x.ensembl_acc_id,x.mp_acc_ids,x.synonyms,x.gene_name,x.mouse_allele_id, mouse_gene.id
FROM
(select mp.mgi_allele_acc_id,mp.allele_symbol,mp.allele_name,mp.type,mp.allele_attribute,mp.pubmed_acc_id,mp.mgi_marker_acc_id,mp.gene_symbol,mp.refseq_acc_id,mp.ensembl_acc_id,mp.mp_acc_ids,mp.synonyms,mp.gene_name, mouse_allele.id as \"mouse_allele_id\" FROM 
mgi_phenotypic_allele_tmp mp left outer join mouse_allele ON mp.mgi_allele_acc_id = mouse_allele.mgi_allele_acc_id) x 
left outer join mouse_gene 
ON x.mgi_marker_acc_id = mouse_gene.mgi_gene_acc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP table mgi_phenotypic_allele_tmp"



psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene_allele (mouse_gene_id,mouse_allele_id)
select m.id, aa.id from mgi_allele a, mouse_gene m, mouse_allele aa where a.mgi_marker_acc_id=m.mgi_gene_acc_id and a.mgi_allele_acc_id=aa.mgi_allele_acc_id
UNION select m2.id,aa2.id from mgi_phenotypic_allele p, mouse_gene m2, mouse_allele aa2 where p.mgi_marker_acc_id=m2.mgi_gene_acc_id and p.mgi_allele_acc_id=aa2.mgi_allele_acc_id"



# MGI_Disease_data_load.txt

cat /mnt/MGI_DO.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_disease (do_acc_id,disease_name,omim_acc_ids,organism_name,taxon_acc_id,symbol,entrez_acc_id,mgi_gene_acc_id) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease (do_acc_id,name,mgi_disease_id)
select do_acc_id,disease_name,id from mgi_disease group by do_acc_id,disease_name,id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO omim_table (omim_acc_id)
select distinct(unnest(string_to_array(omim_acc_ids, '|'))) from mgi_disease where omim_acc_ids is not null"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease_omim (human_disease_id,omim_table_id)
select hd.id, ot.id from human_disease hd, omim_table ot, mgi_disease m, (select m2.id, unnest(string_to_array(m2.omim_acc_ids, '|')) from mgi_disease m2 where m2.omim_acc_ids is not null) mm where hd.do_acc_id = m.do_acc_id and m.id = mm.id and mm.unnest = ot.omim_acc_id group by hd.id, ot.id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "WITH a AS (select h.id as \"gene_id\", hd.id as \"disease_id\" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_acc_id = hg.entrez_acc_id and hg.hgnc_acc_id = h.hgnc_acc_id and m.taxon_acc_id=9606 and m.do_acc_id = hd.do_acc_id),
b AS (select h.id as \"gene_id\", hd.id as \"disease_id\", m.mgi_gene_acc_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_gene_acc_id = mg.mgi_gene_acc_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_acc_id=10090 and m.do_acc_id = hd.do_acc_id)
INSERT INTO human_gene_disease (human_gene_id, human_disease_id, human_evidence, mgi_gene_acc_id, mouse_evidence)
(select a.gene_id,a.disease_id,True,mgi_gene_acc_id, True from a INNER JOIN b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id)
UNION 
(select a.gene_id,a.disease_id,True,NULL as mgi_gene_acc_id, False from a LEFT OUTER JOIN b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE b.gene_id IS NULL and b.disease_id IS NULL)
UNION
(select b.gene_id,b.disease_id,False,mgi_gene_acc_id, True from a RIGHT OUTER JOIN b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE a.gene_id IS NULL and a.disease_id IS NULL)"


printf 'end=%s\n' $(date +"%s") >> /usr/local/data/postgres_processing_time.sh
printf "echo -n 'Postgresql processing time: '\n" >> /usr/local/data/postgres_processing_time.sh
echo 'printf "'"%d s\n"'" $(( $end - $start ))'   >> /usr/local/data/postgres_processing_time.sh
chmod 755 /usr/local/data/postgres_processing_time.sh

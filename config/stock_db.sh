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



# HGNC_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hgnc_gene (hgnc_id,symbol,name,locus_group,locus_type,status,location,location_sortable,alias_symbol,alias_name,prev_symbol,prev_name,gene_family,gene_family_id,date_approved_reserved,date_symbol_changed,date_name_changed,date_modified,entrez_id,ensembl_gene_id,vega_id,ucsc_id,ena,refseq_accession,ccds_id,uniprot_ids,pubmed_id,mgd_id,rgd_id,lsdb,cosmic,omim_id,mirbase,homeodb,snornabase,bioparadigms_slc,orphanet,pseudogene_org,horde_id,merops,imgt,iuphar,kznf_gene_catalog,mamit_trnadb,cd,lncrnadb,enzyme_id,intermediate_filament_db,rna_central_ids,lncipedia,gtrnadb) FROM '/mnt/non_alt_loci_set.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"



psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hgnc_gene (hgnc_id,symbol,name,locus_group,locus_type,status,location,location_sortable,alias_symbol,alias_name,prev_symbol,prev_name,gene_family,gene_family_id,date_approved_reserved,date_symbol_changed,date_name_changed,date_modified,entrez_id,ensembl_gene_id,vega_id,ucsc_id,ena,refseq_accession,ccds_id,uniprot_ids,pubmed_id,mgd_id,rgd_id,lsdb,cosmic,omim_id,mirbase,homeodb,snornabase,bioparadigms_slc,orphanet,pseudogene_org,horde_id,merops,imgt,iuphar,kznf_gene_catalog,mamit_trnadb,cd,lncrnadb,enzyme_id,intermediate_filament_db,rna_central_ids,lncipedia,gtrnadb) FROM '/mnt/alternative_loci_set.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"


# HCOP_data_load.txt


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hcop (human_entrez_gene,human_ensembl_gene,hgnc_id,human_name,human_symbol,human_chr,human_assert_ids,mouse_entrez_gene,mouse_ensembl_gene,mgi_id,mouse_name,mouse_symbol,mouse_chr,mouse_assert_ids,support) FROM '/mnt/human_mouse_hcop_fifteen_column.txt' with (DELIMITER E'\t', NULL '-', FORMAT CSV, header TRUE)"


# MgiGene_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_gene (mgi_id,type,symbol,name,genome_build,entrez_gene_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand) FROM '/mnt/MGI_Gene_Model_Coord.rpt' with (DELIMITER E'\t', NULL 'null', FORMAT CSV, header TRUE)"


# MGI_Mrk_List2_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_mrk_list2 (mgi_id,chr,cM,start,stop,strand,symbol,status,name,marker_type,feature_type,synonyms) FROM '/mnt/MRK_List2.rpt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mouse_gene_synonym (mgi_id,synonym) FROM '/mnt/Mrk_synonyms.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE)"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy human_gene_synonym (hgnc_id,synonym) FROM '/mnt/HGNC_synonyms.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE)"

################################################
# gene_entries.sql -- CONVERT TO A PSQL command

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene (symbol,name,mgi_id,type,genome_build,entrez_gene_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand,mgi_gene_id) SELECT symbol,name,mgi_id,type,genome_build,entrez_gene_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand,id from mgi_gene"

# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_gene set hcop_id = x.id from mouse_gene m, hcop x where m.mgi_id=x.mgi_id"



# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_gene_synonym set mgi_mrk_list2_id = x.id from mouse_gene_synonym m, mgi_mrk_list2 x where m.mgi_id=x.mgi_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene_synonym_relation (mouse_gene_id, mouse_gene_synonym_id) 
SELECT mouse_gene.id, mouse_gene_synonym.id
FROM  mouse_gene, mouse_gene_synonym
WHERE mouse_gene.mgi_id = mouse_gene_synonym.mgi_id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene (symbol,name,hgnc_id,hgnc_gene_id) 
SELECT symbol,name,hgnc_id,id from hgnc_gene"

# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE human_gene set hcop_id = x.id from human_gene h, hcop x where h.hgnc_id = x.hgnc_id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene_synonym_relation (human_gene_id, human_gene_synonym_id) 
SELECT human_gene.id, human_gene_synonym.id
FROM  human_gene, human_gene_synonym
WHERE human_gene.hgnc_id = human_gene_synonym.hgnc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO ortholog (support, support_count,human_gene_id,mouse_gene_id)
select array_to_string(array( select distinct unnest(string_to_array(support, ','))),',') as list, array_length(array( select distinct unnest(string_to_array(support, ','))),1) as count, human_gene.id, mouse_gene.id from hcop h, human_gene, mouse_gene 
WHERE h.hgnc_id = human_gene.hgnc_id and 
h.mgi_id = mouse_gene.mgi_id
GROUP BY list,count,human_gene.id, mouse_gene.id
order by count desc"

###################################################

# MGI_Strain_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy strain (mgi_id,name,type) FROM '/mnt/MGI_Strain_test.rpt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"



# MGI_Allele_data_load.txt

tail -n +14 /mnt/NorCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele (project_id,db_name,mgi_allele_id,allele_symbol,allele_name,mgi_id,gene_symbol,cell_line_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/EUCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele (project_id,db_name,mgi_allele_id,allele_symbol,allele_name,mgi_id,gene_symbol,cell_line_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/KOMP_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele (project_id,db_name,mgi_allele_id,allele_symbol,allele_name,mgi_id,gene_symbol,cell_line_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +8 /mnt/MGI_PhenotypicAllele.rpt.test.txt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_phenotypic_allele (mgi_allele_id,allele_symbol,allele_name,type,allele_attribute,pubmed_id,mgi_id,gene_symbol,refseq_id,ensembl_id,mp_ids,synonyms,gene_name) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_allele (allele_symbol,mgi_id,name)
select a.allele_symbol,a.mgi_allele_id, a.allele_name from mgi_allele a, mouse_gene m where a.mgi_id=m.mgi_id UNION select p.allele_symbol,p.mgi_allele_id, p.allele_name from mgi_phenotypic_allele p, mouse_gene m2 where p.mgi_id=m2.mgi_id"

# Enter the foreign key ids:
#psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_allele set mgi_allele_id = a.id from mgi_allele a, mouse_allele aa where a.mgi_allele_id=aa.mgi_id and a.allele_symbol=aa.allele_symbol"

#psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_allele set mgi_phenotypic_allele_id = a.id  from mgi_phenotypic_allele a, mouse_allele aa where a.mgi_id=aa.mgi_allele_id and a.allele_symbol=aa.allele_symbol"




psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene_allele (mouse_gene_id,allele_id)
select m.id, aa.id from mgi_allele a, mouse_gene m, mouse_allele aa where a.mgi_id=m.mgi_id and a.mgi_allele_id=aa.mgi_id
UNION select m2.id,aa2.id from mgi_phenotypic_allele p, mouse_gene m2, mouse_allele aa2 where p.mgi_id=m2.mgi_id and p.mgi_allele_id=aa2.mgi_id"

## Run test counts -- see MGI_Allele_data_load.txt


# MGI_Disease_data_load.txt

cat /mnt/MGI_DO.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_disease (doid,disease_name,omim_ids,homologene_id,organism_name,taxon_id,symbol,entrez_id,mgi_id) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease (do_id,name,mgi_disease_id)
select doid,disease_name,id from mgi_disease group by doid,disease_name"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO omim_table (omim_id)
select distinct(unnest(string_to_array(omim_ids, '|'))) from mgi_disease where omim_ids is not null"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease_omim (human_disease_id,omim_table_id)
select hd.id, ot.id from human_disease hd, omim_table ot, mgi_disease m, (select m2.id, unnest(string_to_array(m2.omim_ids, '|')) from mgi_disease m2 where m2.omim_ids is not null) mm where hd.do_id = m.doid and m.id = mm.id and mm.unnest = ot.omim_id group by hd.id, ot.id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene_disease (human_gene_id, human_disease_id, human_evidence, mgi_id, mouse_evidence)
(select a.gene_id,a.disease_id,True,mgi_id, True from (select h.id as "gene_id", hd.id as "disease_id" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_id = hg.entrez_id and hg.hgnc_id = h.hgnc_id and m.taxon_id=9606 and m.doid = hd.do_id) a INNER JOIN (select h.id as "gene_id", hd.id as "disease_id", m.mgi_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_id = mg.mgi_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_id=10090 and m.doid = hd.do_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id)
 UNION 
(select a.gene_id,a.disease_id,True,NULL as mgi_id, False from (select h.id as "gene_id", hd.id as "disease_id" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_id = hg.entrez_id and hg.hgnc_id = h.hgnc_id and m.taxon_id=9606 and m.doid = hd.do_id) a LEFT OUTER JOIN (select h.id as "gene_id", hd.id as "disease_id", m.mgi_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_id = mg.mgi_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_id=10090 and m.doid = hd.do_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE b.gene_id IS NULL and b.disease_id IS NULL)
 UNION 
(select b.gene_id,b.disease_id,False,mgi_id, True from (select h.id as "gene_id", hd.id as "disease_id" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_id = hg.entrez_id and hg.hgnc_id = h.hgnc_id and m.taxon_id=9606 and m.doid = hd.do_id) a RIGHT OUTER JOIN (select h.id as "gene_id", hd.id as "disease_id", m.mgi_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_id = mg.mgi_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_id=10090 and m.doid = hd.do_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE a.gene_id IS NULL and a.disease_id IS NULL)"



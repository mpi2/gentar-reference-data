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

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hgnc_gene (hgnc_acc_id,symbol,name,locus_group,locus_type,status,location,location_sortable,alias_symbol,alias_name,prev_symbol,prev_name,gene_family,gene_family_acc_id,date_approved_reserved,date_symbol_changed,date_name_changed,date_modified,entrez_acc_id,ensembl_gene_acc_id,vega_acc_id,ucsc_acc_id,ena,refseq_accession,ccds_acc_id,uniprot_acc_ids,pubmed_acc_id,mgi_gene_acc_id,rgd_acc_id,lsdb,cosmic,omim_acc_id,mirbase,homeodb,snornabase,bioparadigms_slc,orphanet,pseudogene_org,horde_acc_id,merops,imgt,iuphar,kznf_gene_catalog,mamit_trnadb,cd,lncrnadb,enzyme_acc_id,intermediate_filament_db,rna_central_acc_ids,lncipedia,gtrnadb) FROM '/mnt/non_alt_loci_set.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"



psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hgnc_gene (hgnc_acc_id,symbol,name,locus_group,locus_type,status,location,location_sortable,alias_symbol,alias_name,prev_symbol,prev_name,gene_family,gene_family_acc_id,date_approved_reserved,date_symbol_changed,date_name_changed,date_modified,entrez_acc_id,ensembl_gene_acc_id,vega_acc_id,ucsc_acc_id,ena,refseq_accession,ccds_acc_id,uniprot_acc_ids,pubmed_acc_id,mgi_gene_acc_id,rgd_acc_id,lsdb,cosmic,omim_acc_id,mirbase,homeodb,snornabase,bioparadigms_slc,orphanet,pseudogene_org,horde_acc_id,merops,imgt,iuphar,kznf_gene_catalog,mamit_trnadb,cd,lncrnadb,enzyme_acc_id,intermediate_filament_db,rna_central_acc_ids,lncipedia,gtrnadb) FROM '/mnt/alternative_loci_set.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"


# HCOP_data_load.txt into a temporary table.


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy hcop_tmp (human_entrez_gene,human_ensembl_gene,hgnc_id,human_name,human_symbol,human_chr,human_assert_ids,mouse_entrez_gene,mouse_ensembl_gene,mgi_id,mouse_name,mouse_symbol,mouse_chr,mouse_assert_ids,support) FROM '/mnt/human_mouse_hcop_fifteen_column.txt' with (DELIMITER E'\t', NULL '-', FORMAT CSV, header TRUE)"


# MgiGene_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_gene (mgi_gene_acc_id,type,symbol,name,genome_build,entrez_gene_acc_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_acc_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand) FROM '/mnt/MGI_Gene_Model_Coord.rpt' with (DELIMITER E'\t', NULL 'null', FORMAT CSV, header TRUE)"


# MGI_Mrk_List2_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_mrk_list2_tmp (mgi_id,chr,cM,start,stop,strand,symbol,status,name,marker_type,feature_type,synonyms) FROM '/mnt/MRK_List2.rpt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE)"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mouse_gene_synonym (mgi_gene_acc_id,synonym) FROM '/mnt/Mrk_synonyms.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE)"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy human_gene_synonym (hgnc_acc_id,synonym) FROM '/mnt/HGNC_synonyms.txt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE)"

################################################
# gene_entries.sql -- CONVERT TO A PSQL command

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene (symbol,name,mgi_gene_acc_id,type,genome_build,entrez_gene_acc_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_acc_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand,mgi_gene_id) SELECT symbol,name,mgi_gene_acc_id,type,genome_build,entrez_gene_acc_id,ncbi_chromosome,ncbi_start,ncbi_stop,ncbi_strand,ensembl_gene_acc_id,ensembl_chromosome,ensembl_start,ensembl_stop,ensembl_strand,id from mgi_gene"

# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE hcop set mouse_gene_id = m.id from mouse_gene m, hcop x where x.mgi_id=m.mgi_id"



# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_gene_synonym set mgi_mrk_list2_id = x.id from mouse_gene_synonym m, mgi_mrk_list2 x where m.mgi_id=x.mgi_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene_synonym_relation (mouse_gene_id, mouse_gene_synonym_id) 
SELECT mouse_gene.id, mouse_gene_synonym.id
FROM  mouse_gene, mouse_gene_synonym
WHERE mouse_gene.mgi_gene_acc_id = mouse_gene_synonym.mgi_gene_acc_id"


# Create the final version of mgi_mrk_list2
# - NOTE: there are different column names compared to mgi_mrk_list2_tmp

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mgi_mrk_list2 (mgi_marker_acc_id,chr,cM,start,stop,strand,symbol,status,name,marker_type,feature_type,synonyms,mouse_gene_id)
select mrk.mgi_id,mrk.chr,mrk.cM,mrk.start,mrk.stop,mrk.strand,mrk.symbol,mrk.status,mrk.name,mrk.marker_type,mrk.feature_type,mrk.synonyms, mouse_gene.id FROM 
mgi_mrk_list2_tmp mrk left outer join mouse_gene ON mrk.mgi_id = mouse_gene.mgi_gene_acc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP table mgi_mrk_list2_tmp"




psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene (symbol,name,hgnc_acc_id,hgnc_gene_id) 
SELECT symbol,name,hgnc_acc_id,id from hgnc_gene"

# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE human_gene set hcop_id = x.id from human_gene h, hcop x where h.hgnc_id = x.hgnc_id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene_synonym_relation (human_gene_id, human_gene_synonym_id) 
SELECT human_gene.id, human_gene_synonym.id
FROM  human_gene, human_gene_synonym
WHERE human_gene.hgnc_acc_id = human_gene_synonym.hgnc_acc_id"

# Create the final version of HCOP
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO hcop (mouse_gene_id, human_gene_id,human_entrez_gene,human_ensembl_gene,hgnc_id,human_name,human_symbol,human_chr,human_assert_ids,mouse_entrez_gene,mouse_ensembl_gene,mgi_id,mouse_name,mouse_symbol,mouse_chr,mouse_assert_ids,support)
select a.mouse_gene_id, human_gene.id as \"human_gene_id\", a.human_entrez_gene,a.human_ensembl_gene,a.hgnc_id,a.human_name,a.human_symbol,a.human_chr,a.human_assert_ids,a.mouse_entrez_gene,a.mouse_ensembl_gene,a.mgi_id,a.mouse_name,a.mouse_symbol,a.mouse_chr,a.mouse_assert_ids,a.support from (select mouse_gene.id as \"mouse_gene_id\", h.human_entrez_gene,h.human_ensembl_gene,h.hgnc_id,h.human_name,h.human_symbol,h.human_chr,h.human_assert_ids,h.mouse_entrez_gene,h.mouse_ensembl_gene,h.mgi_id,h.mouse_name,h.mouse_symbol,h.mouse_chr,h.mouse_assert_ids,h.support from hcop_tmp h left outer join mouse_gene ON h.mgi_id=mouse_gene.mgi_gene_acc_id) as a left outer join human_gene ON a.hgnc_id=human_gene.hgnc_acc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP TABLE hcop_tmp"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO ortholog (support, support_count,human_gene_id,mouse_gene_id)
select array_to_string(array( select distinct unnest(string_to_array(support, ','))),',') as list, array_length(array( select distinct unnest(string_to_array(support, ','))),1) as count, human_gene.id, mouse_gene.id from hcop h, human_gene, mouse_gene 
WHERE h.hgnc_id = human_gene.hgnc_acc_id and 
h.mgi_id = mouse_gene.mgi_gene_acc_id
GROUP BY list,count,human_gene.id, mouse_gene.id
order by count desc"

###################################################




# MGI_Strain_data_load.txt

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy strain (mgi_strain_acc_id,name,type) FROM '/mnt/MGI_Strain_test.rpt' with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"



# MGI_Allele_data_load.txt

tail -n +14 /mnt/NorCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/EUCOMM_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +14 /mnt/KOMP_Allele.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_allele_tmp (project_acc_id,db_name,mgi_allele_acc_id,allele_symbol,allele_name,mgi_marker_acc_id,gene_symbol,cell_line_acc_ids) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"

tail -n +8 /mnt/MGI_PhenotypicAllele.rpt.test.txt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_phenotypic_allele_tmp (mgi_allele_id,allele_symbol,allele_name,type,allele_attribute,pubmed_id,mgi_id,gene_symbol,refseq_id,ensembl_id,mp_ids,synonyms,gene_name) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header FALSE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_allele (allele_symbol,mgi_allele_acc_id,name) select a.allele_symbol,a.mgi_allele_acc_id, a.allele_name 
from 
mgi_allele_tmp a, mouse_gene m where a.mgi_marker_acc_id=m.mgi_gene_acc_id 
UNION 
select p.allele_symbol,p.mgi_allele_id, p.allele_name from mgi_phenotypic_allele_tmp p, mouse_gene m2 where p.mgi_id=m2.mgi_gene_acc_id"

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
select x.mgi_allele_id,x.allele_symbol,x.allele_name,x.type,x.allele_attribute,x.pubmed_id,x.mgi_id,x.gene_symbol,x.refseq_id,x.ensembl_id,x.mp_ids,x.synonyms,x.gene_name,x.mouse_allele_id, mouse_gene.id
FROM
(select mp.mgi_allele_id,mp.allele_symbol,mp.allele_name,mp.type,mp.allele_attribute,mp.pubmed_id,mp.mgi_id,mp.gene_symbol,mp.refseq_id,mp.ensembl_id,mp.mp_ids,mp.synonyms,mp.gene_name, mouse_allele.id as \"mouse_allele_id\" FROM 
mgi_phenotypic_allele_tmp mp left outer join mouse_allele ON mp.mgi_allele_id = mouse_allele.mgi_allele_acc_id) x 
left outer join mouse_gene 
ON x.mgi_id = mouse_gene.mgi_gene_acc_id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP table mgi_phenotypic_allele_tmp"




# Enter the foreign key ids:
#psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_allele set mgi_allele_id = a.id from mgi_allele a, mouse_allele aa where a.mgi_allele_id=aa.mgi_id and a.allele_symbol=aa.allele_symbol"

#psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE mouse_allele set mgi_phenotypic_allele_id = a.id  from mgi_phenotypic_allele a, mouse_allele aa where a.mgi_id=aa.mgi_allele_id and a.allele_symbol=aa.allele_symbol"

#psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_allele (allele_symbol,mgi_id,name,mgi_allele_id,mgi_phenotypic_allele_id) select r.allele_symbol,r.mgi_allele_id,r.allele_name,r.mgi_allele_primary_key,r.mgi_phenotypic_allele_primary_key from (((select a.allele_symbol,a.mgi_allele_id, a.allele_name from mgi_allele a, mouse_gene m where a.mgi_id=m.mgi_id UNION select p.allele_symbol,p.mgi_allele_id, p.allele_name from mgi_phenotypic_allele p, mouse_gene m2 where p.mgi_id=m2.mgi_id) as x LEFT OUTER JOIN (select aa.id as \"mgi_allele_primary_key\", aa.mgi_allele_id as \"mgi_allele_mgi_allele_id\" from mgi_allele aa, mouse_gene mm where aa.mgi_id=mm.mgi_id) as y ON x.mgi_allele_id = y.mgi_allele_mgi_allele_id) as xx LEFT OUTER JOIN (select pp.id as \"mgi_phenotypic_allele_primary_key\", pp.mgi_allele_id as \"mgi_phenotypic_allele_mgi_allele_id\" from mgi_phenotypic_allele pp, mouse_gene m4 where pp.mgi_id=m4.mgi_id) as z ON xx.mgi_allele_id = z.mgi_phenotypic_allele_mgi_allele_id) as r group by r.allele_symbol,r.mgi_allele_id,r.allele_name,r.mgi_allele_primary_key,r.mgi_phenotypic_allele_primary_key"



psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO mouse_gene_allele (mouse_gene_id,mouse_allele_id)
select m.id, aa.id from mgi_allele a, mouse_gene m, mouse_allele aa where a.mgi_marker_acc_id=m.mgi_gene_acc_id and a.mgi_allele_acc_id=aa.mgi_allele_acc_id
UNION select m2.id,aa2.id from mgi_phenotypic_allele p, mouse_gene m2, mouse_allele aa2 where p.mgi_marker_acc_id=m2.mgi_gene_acc_id and p.mgi_allele_acc_id=aa2.mgi_allele_acc_id"

## Run test counts -- see MGI_Allele_data_load.txt


# MGI_Disease_data_load.txt

cat /mnt/MGI_DO.rpt | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy mgi_disease (do_acc_id,disease_name,omim_acc_ids,homologene_acc_id,organism_name,taxon_acc_id,symbol,entrez_acc_id,mgi_gene_acc_id) FROM STDIN with (DELIMITER E'\t', NULL '', FORMAT CSV, header TRUE, ENCODING 'UTF8')"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease (do_acc_id,name,mgi_disease_id)
select do_acc_id,disease_name,id from mgi_disease group by do_acc_id,disease_name,id"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO omim_table (omim_acc_id)
select distinct(unnest(string_to_array(omim_acc_ids, '|'))) from mgi_disease where omim_acc_ids is not null"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_disease_omim (human_disease_id,omim_table_id)
select hd.id, ot.id from human_disease hd, omim_table ot, mgi_disease m, (select m2.id, unnest(string_to_array(m2.omim_acc_ids, '|')) from mgi_disease m2 where m2.omim_acc_ids is not null) mm where hd.do_acc_id = m.do_acc_id and m.id = mm.id and mm.unnest = ot.omim_acc_id group by hd.id, ot.id"


psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO human_gene_disease (human_gene_id, human_disease_id, human_evidence, mgi_gene_acc_id, mouse_evidence)
(select a.gene_id,a.disease_id,True,mgi_gene_acc_id, True from (select h.id as \"gene_id\", hd.id as \"disease_id\" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_acc_id = hg.entrez_acc_id and hg.hgnc_acc_id = h.hgnc_acc_id and m.taxon_acc_id=9606 and m.do_acc_id = hd.do_acc_id) a INNER JOIN (select h.id as \"gene_id\", hd.id as \"disease_id\", m.mgi_gene_acc_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_gene_acc_id = mg.mgi_gene_acc_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_acc_id=10090 and m.do_acc_id = hd.do_acc_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id)
 UNION 
(select a.gene_id,a.disease_id,True,NULL as mgi_gene_acc_id, False from (select h.id as \"gene_id\", hd.id as \"disease_id\" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_acc_id = hg.entrez_acc_id and hg.hgnc_acc_id = h.hgnc_acc_id and m.taxon_acc_id=9606 and m.do_acc_id = hd.do_acc_id) a LEFT OUTER JOIN (select h.id as \"gene_id\", hd.id as \"disease_id\", m.mgi_gene_acc_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_gene_acc_id = mg.mgi_gene_acc_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_acc_id=10090 and m.do_acc_id = hd.do_acc_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE b.gene_id IS NULL and b.disease_id IS NULL)
 UNION 
(select b.gene_id,b.disease_id,False,mgi_gene_acc_id, True from (select h.id as \"gene_id\", hd.id as \"disease_id\" from human_gene h, hgnc_gene hg, mgi_disease m, human_disease hd where m.entrez_acc_id = hg.entrez_acc_id and hg.hgnc_acc_id = h.hgnc_acc_id and m.taxon_acc_id=9606 and m.do_acc_id = hd.do_acc_id) a RIGHT OUTER JOIN (select h.id as \"gene_id\", hd.id as \"disease_id\", m.mgi_gene_acc_id from human_gene h, mouse_gene mg, ortholog o, mgi_disease m, human_disease hd where m.mgi_gene_acc_id = mg.mgi_gene_acc_id and mg.id = o.mouse_gene_id and o.support_count > 4 and o.human_gene_id = h.id and m.taxon_acc_id=10090 and m.do_acc_id = hd.do_acc_id) b ON a.gene_id = b.gene_id and a.disease_id = b.disease_id WHERE a.gene_id IS NULL and a.disease_id IS NULL)"



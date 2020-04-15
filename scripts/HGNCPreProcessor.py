import csv
import os
import sys


class HgncPreProcessor:

    def __init__(self):

        # Expects as input the HGNC file 'alternative_loci_set.txt'
        self.fileA = sys.argv[1]
        self.pathnameA = os.path.dirname(self.fileA)
        self.filenameA = os.path.abspath(self.fileA)

        # Expects as input the HGNC file 'non_alt_loci_set.txt'
        self.fileB = sys.argv[2]
        self.filenameB = os.path.abspath(self.fileB)

        # Note the output is placed in the same directory as the HGNC file 'alternative_loci_set.txt'
        self.outputfilename = os.path.abspath(os.path.join(self.pathnameA, 'HGNC_synonyms.txt'))

        self.data = []
        self.headings = ['hgnc_id', 'symbol', 'name', 'locus_group', 'locus_type', 'status', 'location',
                         'location_sortable', 'alias_symbol', 'alias_name', 'prev_symbol', 'prev_name', 'gene_family',
                         'gene_family_id', 'date_approved_reserved', 'date_symbol_changed', 'date_name_changed',
                         'date_modified', 'entrez_id', 'ensembl_gene_id', 'vega_id', 'ucsc_id', 'ena',
                         'refseq_accession', 'ccds_id', 'uniprot_ids', 'pubmed_id', 'mgd_id', 'rgd_id', 'lsdb',
                         'cosmic', 'omim_id', 'mirbase', 'homeodb', 'snornabase', 'bioparadigms_slc', 'orphanet',
                         'pseudogene.org', 'horde_id', 'merops', 'imgt', 'iuphar', 'kznf_gene_catalog', 'mamit-trnadb',
                         'cd', 'lncrnadb', 'enzyme_id', 'intermediate_filament_db', 'rna_central_ids', 'lncipedia',
                         'gtrnadb', 'agr']

    @staticmethod
    def test_headings(row, headings):

        if row != headings:
            print('The headings of the spreadsheet have changed')
            print('Expected:')
            for index, elem in enumerate(headings):
                print(index, elem)
            print('')
            print('Found:')
            for indexF, elemF in enumerate(row):
                print(indexF, elemF)
            print('')
            print('******************')
            sys.exit('Headers have changed')

    def read_hgnc_file(self, filename):
        with open(filename, newline='') as f:
            reader = csv.reader(f, delimiter='\t')
            try:
                counter = 0
                for row in reader:
                    counter += 1

                    # Ensure the expected columns are present
                    if counter == 1:
                        self.test_headings(row, self.headings)

                    # Load in the data rows
                    elif row[0]:
                        self.data.append(row)

            except csv.Error as e:
                sys.exit('file {}, line {}: {}'.format(self.filename, reader.line_num, e))

    def write_hgnc_file(self):
        with open(self.outputfilename, 'w') as f:
            writer = csv.writer(f, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            try:
                for row in self.data:
                    row_id = row[0].strip()

                    if row_id:
                        alias_synonyms = row[8].strip().split('|')

                        for i, syns in enumerate(alias_synonyms):
                            synonym = syns.strip()
                            if synonym:
                                writer.writerow([row_id, synonym])

                        previous_synonyms = row[10].strip().split('|')

                        for i, syns in enumerate(previous_synonyms):
                            synonym = syns.strip()
                            if synonym:
                                writer.writerow([row_id, synonym])

            except csv.Error as e:
                sys.exit('file {}, line {}: {}'.format(self.outputfilename, writer.line_num, e))


if __name__ == '__main__':
    processor = HgncPreProcessor()
    processor.read_hgnc_file(processor.filenameA)
    processor.read_hgnc_file(processor.filenameB)
    processor.write_hgnc_file()

import csv, sys, os

class HgncPreProcessor:

    def __init__(self):
    
        self.file = sys.argv[0]
        self.pathname = os.path.dirname(self.file)
        self.fullpath = os.path.abspath(self.pathname)
        
        self.data = []
        self.filenameA = 'alternative_loci_set.txt'
        self.filenameB = 'non_alt_loci_set.txt'
        self.outputfilename = 'HGNC_synonyms.txt'
        
        self.headings = ['hgnc_id','symbol','name','locus_group','locus_type','status','location','location_sortable','alias_symbol','alias_name','prev_symbol','prev_name','gene_family','gene_family_id','date_approved_reserved','date_symbol_changed','date_name_changed','date_modified','entrez_id','ensembl_gene_id','vega_id','ucsc_id','ena','refseq_accession','ccds_id','uniprot_ids','pubmed_id','mgd_id','rgd_id','lsdb','cosmic','omim_id','mirbase','homeodb','snornabase','bioparadigms_slc','orphanet','pseudogene.org','horde_id','merops','imgt','iuphar','kznf_gene_catalog','mamit-trnadb','cd','lncrnadb','enzyme_id','intermediate_filament_db','rna_central_ids','lncipedia','gtrnadb']
        
        
    
    
    def testHeadings(self, row, headings):
        
        
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
    
    
    def readHgncFile(self, filename):
        with open(filename, newline='') as f:
            reader = csv.reader(f, delimiter='\t')
            try:
                counter=0
                for row in reader:
                    counter+=1
                    
                    # Ensure the expected columns are present
                    if counter == 1:
                    	self.testHeadings(row,self.headings)
                    
                    
                    # Load in the data rows
                    elif row[0]:
                        self.data.append(row)
                    
                    
            except csv.Error as e:
                sys.exit('file {}, line {}: {}'.format(self.filename, reader.line_num, e))
    
    
    def writeHgncFile(self):
        with open(self.outputfilename, 'w') as f:
            writer = csv.writer(f, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
            try:
                for row in self.data:
                    id = row[0].strip()
                    
                    if id:
                        alias_synonyms = row[8].strip().split('|')
                        #alias_name = row[9].strip().split('|')
                        
                        for i,syns in enumerate(alias_synonyms):
                            synonym = syns.strip()
                            if synonym:
                                #if i < len(alias_name):
                                #    writer.writerow([id,synonym,alias_name[i]])
                                #else:
                                #    writer.writerow([id,synonym,''])
                                writer.writerow([id,synonym])
                                    
                        previous_synonyms = row[10].strip().split('|')
                        #previous_name = row[11].strip().split('|')
                        
                        
                        for i,syns in enumerate(previous_synonyms):
                            synonym = syns.strip()
                            if synonym:
                                #if i < len(previous_name):
                                #    writer.writerow([id,synonym,previous_name[i]])
                                #else:
                                #    writer.writerow([id,synonym,''])
                                writer.writerow([id,synonym])
                                    
            except csv.Error as e:
                sys.exit('file {}, line {}: {}'.format(self.outputfilename, writer.line_num, e))
                

if __name__ == '__main__':
    l = HgncPreProcessor()
    l.readHgncFile(l.filenameA)
    l.readHgncFile(l.filenameB)
    l.writeHgncFile()

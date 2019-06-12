--
-- PostgreSQL database dump
--

-- Dumped from database version 11.0 (Debian 11.0-1.pgdg90+2)
-- Dumped by pg_dump version 11.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: hgnc_gene; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.hgnc_gene (
    id bigint NOT NULL,
    alias_name text,
    alias_symbol character varying(255),
    bioparadigms_slc character varying(255),
    ccds_id character varying(255),
    cd character varying(255),
    cosmic character varying(255),
    date_approved_reserved timestamp without time zone,
    date_modified timestamp without time zone,
    date_name_changed timestamp without time zone,
    date_symbol_changed timestamp without time zone,
    ena character varying(255),
    ensembl_gene_id character varying(255),
    entrez_id bigint,
    enzyme_id character varying(255),
    gene_family character varying(255),
    gene_family_id character varying(255),
    gtrnadb character varying(255),
    hgnc_id character varying(255),
    homeodb bigint,
    horde_id character varying(255),
    imgt character varying(255),
    intermediate_filament_db character varying(255),
    iuphar character varying(255),
    kznf_gene_catalog bigint,
    lncipedia character varying(255),
    lncrnadb character varying(255),
    location character varying(255),
    location_sortable character varying(255),
    locus_group character varying(255),
    locus_type character varying(255),
    lsdb text,
    mamit_trnadb bigint,
    merops character varying(255),
    mgd_id character varying(255),
    mirbase character varying(255),
    name character varying(255),
    omim_id character varying(255),
    orphanet bigint,
    prev_name text,
    prev_symbol character varying(255),
    pseudogene_org character varying(255),
    pubmed_id character varying(255),
    refseq_accession character varying(255),
    rgd_id character varying(255),
    rna_central_ids character varying(255),
    snornabase character varying(255),
    status character varying(255),
    symbol character varying(255),
    ucsc_id character varying(255),
    uniprot_ids character varying(255),
    vega_id character varying(255)
);


ALTER TABLE public.hgnc_gene OWNER TO ref_admin;

--
-- Name: hgnc_gene_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.hgnc_gene_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hgnc_gene_id_seq OWNER TO ref_admin;

--
-- Name: hgnc_gene_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.hgnc_gene_id_seq OWNED BY public.hgnc_gene.id;

--
-- Name: hcop; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.hcop (
    id bigint NOT NULL,
    hgnc_id character varying(255),
    human_assert_ids text,
    human_chr character varying(255),
    human_ensembl_gene character varying(255),
    human_entrez_gene bigint,
    human_name character varying(255),
    human_symbol character varying(255),
    mgi_id character varying(255),
    mouse_assert_ids text,
    mouse_chr character varying(255),
    mouse_ensembl_gene character varying(255),
    mouse_entrez_gene bigint,
    mouse_name character varying(255),
    mouse_symbol character varying(255),
    support text
);


ALTER TABLE public.hcop OWNER TO ref_admin;

--
-- Name: hcop_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.hcop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hcop_id_seq OWNER TO ref_admin;

--
-- Name: hcop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.hcop_id_seq OWNED BY public.hcop.id;

--
-- Name: mgi_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_allele (
    id bigint NOT NULL,
    allele_name text,
    allele_symbol character varying(255),
    cell_line_ids text,
    db_name character varying(255),
    gene_symbol character varying(255),
    mgi_allele_id character varying(255),
    mgi_id character varying(255),
    project_id character varying(255)
);


ALTER TABLE public.mgi_allele OWNER TO ref_admin;

--
-- Name: mgi_allele_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_allele_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_allele_id_seq OWNER TO ref_admin;

--
-- Name: mgi_allele_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_allele_id_seq OWNED BY public.mgi_allele.id;


--
-- Name: mgi_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_disease (
    id bigint NOT NULL,
    disease_name character varying(255),
    doid character varying(255),
    entrez_id bigint,
    homologene_id bigint,
    mgi_id character varying(255),
    omim_ids text,
    organism_name character varying(255),
    symbol character varying(255),
    taxon_id bigint
);


ALTER TABLE public.mgi_disease OWNER TO ref_admin;

--
-- Name: mgi_disease_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_disease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_disease_id_seq OWNER TO ref_admin;

--
-- Name: mgi_disease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_disease_id_seq OWNED BY public.mgi_disease.id;


--
-- Name: mgi_gene; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_gene (
    id bigint NOT NULL,
    ensembl_chromosome character varying(255),
    ensembl_gene_id character varying(255),
    ensembl_start bigint,
    ensembl_stop bigint,
    ensembl_strand character varying(255),
    entrez_gene_id bigint,
    genome_build character varying(255),
    mgi_id character varying(255),
    name character varying(255),
    ncbi_chromosome character varying(255),
    ncbi_start bigint,
    ncbi_stop bigint,
    ncbi_strand character varying(255),
    symbol character varying(255),
    type character varying(255)
);


ALTER TABLE public.mgi_gene OWNER TO ref_admin;

--
-- Name: mgi_gene_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_gene_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_gene_id_seq OWNER TO ref_admin;

--
-- Name: mgi_gene_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_gene_id_seq OWNED BY public.mgi_gene.id;


--
-- Name: mgi_mrk_list2; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_mrk_list2 (
    id bigint NOT NULL,
    cm character varying(255),
    chr character varying(255),
    feature_type character varying(255),
    marker_type character varying(255),
    mgi_id character varying(255),
    name character varying(255),
    start character varying(255),
    status character varying(255),
    stop character varying(255),
    strand character varying(255),
    symbol character varying(255),
    synonyms text
);


ALTER TABLE public.mgi_mrk_list2 OWNER TO ref_admin;

--
-- Name: mgi_mrk_list2_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_mrk_list2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_mrk_list2_id_seq OWNER TO ref_admin;

--
-- Name: mgi_mrk_list2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_mrk_list2_id_seq OWNED BY public.mgi_mrk_list2.id;


--
-- Name: mgi_phenotypic_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_phenotypic_allele (
    id bigint NOT NULL,
    allele_attribute character varying(255),
    allele_name text,
    allele_symbol character varying(255),
    ensembl_id character varying(255),
    gene_name text,
    gene_symbol character varying(255),
    mgi_allele_id character varying(255),
    mgi_id character varying(255),
    mp_ids text,
    pubmed_id character varying(255),
    refseq_id character varying(255),
    synonyms text,
    type character varying(255)
);


ALTER TABLE public.mgi_phenotypic_allele OWNER TO ref_admin;

--
-- Name: mgi_phenotypic_allele_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_phenotypic_allele_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_phenotypic_allele_id_seq OWNER TO ref_admin;

--
-- Name: mgi_phenotypic_allele_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_phenotypic_allele_id_seq OWNED BY public.mgi_phenotypic_allele.id;


--
-- Name: mouse_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_allele (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    allele_symbol character varying(255) NOT NULL,
    mgi_id character varying(255),
    name text
);


ALTER TABLE public.mouse_allele OWNER TO ref_admin;

--
-- Name: mouse_allele_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mouse_allele_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mouse_allele_id_seq OWNER TO ref_admin;

--
-- Name: mouse_allele_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mouse_allele_id_seq OWNED BY public.mouse_allele.id;


--
-- Name: mouse_gene; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_gene (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    ensembl_chromosome character varying(255),
    ensembl_gene_id character varying(255),
    ensembl_start bigint,
    ensembl_stop bigint,
    ensembl_strand character varying(255),
    entrez_gene_id bigint,
    genome_build character varying(255),
    mgi_id character varying(255),
    name text,
    ncbi_chromosome character varying(255),
    ncbi_start bigint,
    ncbi_stop bigint,
    ncbi_strand character varying(255),
    symbol character varying(255),
    type character varying(255)
);


ALTER TABLE public.mouse_gene OWNER TO ref_admin;

--
-- Name: mouse_gene_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_gene_allele (
    mouse_gene_id bigint NOT NULL,
    allele_id bigint NOT NULL
);


ALTER TABLE public.mouse_gene_allele OWNER TO ref_admin;

--
-- Name: mouse_gene_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mouse_gene_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mouse_gene_id_seq OWNER TO ref_admin;

--
-- Name: mouse_gene_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mouse_gene_id_seq OWNED BY public.mouse_gene.id;


--
-- Name: mouse_gene_synonym; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_gene_synonym (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    mgi_id character varying(255),
    synonym character varying(255)
);


ALTER TABLE public.mouse_gene_synonym OWNER TO ref_admin;

--
-- Name: mouse_gene_synonym_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mouse_gene_synonym_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mouse_gene_synonym_id_seq OWNER TO ref_admin;

--
-- Name: mouse_gene_synonym_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mouse_gene_synonym_id_seq OWNED BY public.mouse_gene_synonym.id;


--
-- Name: mouse_gene_synonym_relation; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_gene_synonym_relation (
    mouse_gene_id bigint NOT NULL,
    mouse_gene_synonym_id bigint NOT NULL
);


ALTER TABLE public.mouse_gene_synonym_relation OWNER TO ref_admin;

--
-- Name: human_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_disease (
    id bigint NOT NULL,
    do_id character varying(255),
    name character varying(255)
);


ALTER TABLE public.human_disease OWNER TO ref_admin;

--
-- Name: human_disease_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.human_disease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.human_disease_id_seq OWNER TO ref_admin;

--
-- Name: human_disease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.human_disease_id_seq OWNED BY public.human_disease.id;


--
-- Name: human_disease_omim; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_disease_omim (
    human_disease_id bigint NOT NULL,
    omim_table_id bigint NOT NULL
);


ALTER TABLE public.human_disease_omim OWNER TO ref_admin;

--
-- Name: human_gene; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_gene (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    hgnc_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    symbol character varying(255) NOT NULL
);


ALTER TABLE public.human_gene OWNER TO ref_admin;

--
-- Name: human_gene_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_gene_disease (
    id bigint NOT NULL,
    human_evidence boolean NOT NULL,
    mgi_id character varying(255),
    mouse_evidence boolean NOT NULL,
    human_disease_id bigint NOT NULL,
    human_gene_id bigint NOT NULL
);


ALTER TABLE public.human_gene_disease OWNER TO ref_admin;

--
-- Name: human_gene_disease_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.human_gene_disease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.human_gene_disease_id_seq OWNER TO ref_admin;

--
-- Name: human_gene_disease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.human_gene_disease_id_seq OWNED BY public.human_gene_disease.id;


--
-- Name: human_gene_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.human_gene_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.human_gene_id_seq OWNER TO ref_admin;

--
-- Name: human_gene_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.human_gene_id_seq OWNED BY public.human_gene.id;


--
-- Name: human_gene_synonym; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_gene_synonym (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    hgnc_id character varying(255),
    synonym character varying(255)
);


ALTER TABLE public.human_gene_synonym OWNER TO ref_admin;

--
-- Name: human_gene_synonym_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.human_gene_synonym_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.human_gene_synonym_id_seq OWNER TO ref_admin;

--
-- Name: human_gene_synonym_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.human_gene_synonym_id_seq OWNED BY public.human_gene_synonym.id;


--
-- Name: human_gene_synonym_rel; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_gene_synonym_rel (
    human_gene_id bigint NOT NULL,
    human_gene_synonym_id bigint NOT NULL
);


ALTER TABLE public.human_gene_synonym_rel OWNER TO ref_admin;

--
-- Name: omim_table; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.omim_table (
    id bigint NOT NULL,
    omim_id character varying(255)
);


ALTER TABLE public.omim_table OWNER TO ref_admin;

--
-- Name: omim_table_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.omim_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.omim_table_id_seq OWNER TO ref_admin;

--
-- Name: omim_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.omim_table_id_seq OWNED BY public.omim_table.id;


--
-- Name: ortholog; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.ortholog (
    support character varying(255) NOT NULL,
    support_count bigint NOT NULL,
    human_gene_id bigint NOT NULL,
    mouse_gene_id bigint NOT NULL
);


ALTER TABLE public.ortholog OWNER TO ref_admin;

--
-- Name: strain; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.strain (
    id bigint NOT NULL,
    created_at timestamp without time zone,
    created_by character varying(255),
    last_modified timestamp without time zone,
    last_modified_by character varying(255),
    mgi_id character varying(255),
    name text NOT NULL,
    type character varying(255)
);


ALTER TABLE public.strain OWNER TO ref_admin;

--
-- Name: strain_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.strain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.strain_id_seq OWNER TO ref_admin;

--
-- Name: strain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.strain_id_seq OWNED BY public.strain.id;








--
-- Name: hcop id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.hcop ALTER COLUMN id SET DEFAULT nextval('public.hcop_id_seq'::regclass);


--
-- Name: hgnc_gene id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.hgnc_gene ALTER COLUMN id SET DEFAULT nextval('public.hgnc_gene_id_seq'::regclass);


--
-- Name: human_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease ALTER COLUMN id SET DEFAULT nextval('public.human_disease_id_seq'::regclass);


--
-- Name: human_gene id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene ALTER COLUMN id SET DEFAULT nextval('public.human_gene_id_seq'::regclass);


--
-- Name: human_gene_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_disease ALTER COLUMN id SET DEFAULT nextval('public.human_gene_disease_id_seq'::regclass);


--
-- Name: human_gene_synonym id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_synonym ALTER COLUMN id SET DEFAULT nextval('public.human_gene_synonym_id_seq'::regclass);


--
-- Name: mgi_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele ALTER COLUMN id SET DEFAULT nextval('public.mgi_allele_id_seq'::regclass);


--
-- Name: mgi_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_disease ALTER COLUMN id SET DEFAULT nextval('public.mgi_disease_id_seq'::regclass);


--
-- Name: mgi_gene id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_gene ALTER COLUMN id SET DEFAULT nextval('public.mgi_gene_id_seq'::regclass);


--
-- Name: mgi_mrk_list2 id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_mrk_list2 ALTER COLUMN id SET DEFAULT nextval('public.mgi_mrk_list2_id_seq'::regclass);


--
-- Name: mgi_phenotypic_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele ALTER COLUMN id SET DEFAULT nextval('public.mgi_phenotypic_allele_id_seq'::regclass);


--
-- Name: mouse_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_allele ALTER COLUMN id SET DEFAULT nextval('public.mouse_allele_id_seq'::regclass);


--
-- Name: mouse_gene id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene ALTER COLUMN id SET DEFAULT nextval('public.mouse_gene_id_seq'::regclass);


--
-- Name: mouse_gene_synonym id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_synonym ALTER COLUMN id SET DEFAULT nextval('public.mouse_gene_synonym_id_seq'::regclass);


--
-- Name: omim_table id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.omim_table ALTER COLUMN id SET DEFAULT nextval('public.omim_table_id_seq'::regclass);

--
-- Name: strain id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.strain ALTER COLUMN id SET DEFAULT nextval('public.strain_id_seq'::regclass);







--
-- Name: hcop hcop_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.hcop
    ADD CONSTRAINT hcop_pkey PRIMARY KEY (id);


--
-- Name: hgnc_gene hgnc_gene_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.hgnc_gene
    ADD CONSTRAINT hgnc_gene_pkey PRIMARY KEY (id);


--
-- Name: human_disease_omim human_disease_omim_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease_omim
    ADD CONSTRAINT human_disease_omim_pkey PRIMARY KEY (human_disease_id, omim_table_id);


--
-- Name: human_disease human_disease_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease
    ADD CONSTRAINT human_disease_pkey PRIMARY KEY (id);


--
-- Name: human_gene_disease human_gene_disease_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_disease
    ADD CONSTRAINT human_gene_disease_pkey PRIMARY KEY (id);


--
-- Name: human_gene human_gene_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene
    ADD CONSTRAINT human_gene_pkey PRIMARY KEY (id);


--
-- Name: human_gene_synonym human_gene_synonym_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_synonym
    ADD CONSTRAINT human_gene_synonym_pkey PRIMARY KEY (id);


--
-- Name: human_gene_synonym_rel human_gene_synonym_rel_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_synonym_rel
    ADD CONSTRAINT human_gene_synonym_rel_pkey PRIMARY KEY (human_gene_id, human_gene_synonym_id);



--
-- Name: mgi_allele mgi_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele
    ADD CONSTRAINT mgi_allele_pkey PRIMARY KEY (id);


--
-- Name: mgi_disease mgi_disease_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_disease
    ADD CONSTRAINT mgi_disease_pkey PRIMARY KEY (id);


--
-- Name: mgi_gene mgi_gene_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_gene
    ADD CONSTRAINT mgi_gene_pkey PRIMARY KEY (id);


--
-- Name: mgi_mrk_list2 mgi_mrk_list2_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_mrk_list2
    ADD CONSTRAINT mgi_mrk_list2_pkey PRIMARY KEY (id);


--
-- Name: mgi_phenotypic_allele mgi_phenotypic_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele
    ADD CONSTRAINT mgi_phenotypic_allele_pkey PRIMARY KEY (id);


--
-- Name: mouse_allele mouse_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_allele
    ADD CONSTRAINT mouse_allele_pkey PRIMARY KEY (id);



--
-- Name: mouse_gene_allele mouse_gene_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_allele
    ADD CONSTRAINT mouse_gene_allele_pkey PRIMARY KEY (mouse_gene_id, allele_id);


--
-- Name: mouse_gene mouse_gene_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene
    ADD CONSTRAINT mouse_gene_pkey PRIMARY KEY (id);


--
-- Name: mouse_gene_synonym mouse_gene_synonym_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_synonym
    ADD CONSTRAINT mouse_gene_synonym_pkey PRIMARY KEY (id);


--
-- Name: mouse_gene_synonym_relation mouse_gene_synonym_relation_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_synonym_relation
    ADD CONSTRAINT mouse_gene_synonym_relation_pkey PRIMARY KEY (mouse_gene_id, mouse_gene_synonym_id);


--
-- Name: omim_table omim_table_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.omim_table
    ADD CONSTRAINT omim_table_pkey PRIMARY KEY (id);


--
-- Name: ortholog ortholog_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.ortholog
    ADD CONSTRAINT ortholog_pkey PRIMARY KEY (mouse_gene_id, human_gene_id, support, support_count);



--
-- Name: strain strain_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.strain
    ADD CONSTRAINT strain_pkey PRIMARY KEY (id);



--
-- Name: human_gene_synonym_rel fk164i1het18j033e8a67r38j1; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_synonym_rel
    ADD CONSTRAINT fk164i1het18j033e8a67r38j1 FOREIGN KEY (human_gene_synonym_id) REFERENCES public.human_gene_synonym(id);



--
-- Name: human_gene_synonym_rel fk4veyu9qij3aukv51oei4cj0cc; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_synonym_rel
    ADD CONSTRAINT fk4veyu9qij3aukv51oei4cj0cc FOREIGN KEY (human_gene_id) REFERENCES public.human_gene(id);



--
-- Name: human_disease_omim fk7rytqghme1ffa7wj8v4oh5t0u; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease_omim
    ADD CONSTRAINT fk7rytqghme1ffa7wj8v4oh5t0u FOREIGN KEY (omim_table_id) REFERENCES public.omim_table(id);



--
-- Name: human_gene_disease fkblmwwdjhuxma76hvore5hoi36; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_disease
    ADD CONSTRAINT fkblmwwdjhuxma76hvore5hoi36 FOREIGN KEY (human_gene_id) REFERENCES public.human_gene(id);


--
-- Name: mouse_gene_synonym_relation fkbq04orkw7wfwvjejgdb4bp1hx; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_synonym_relation
    ADD CONSTRAINT fkbq04orkw7wfwvjejgdb4bp1hx FOREIGN KEY (mouse_gene_synonym_id) REFERENCES public.mouse_gene_synonym(id);



--
-- Name: mouse_gene_allele fkhakinpmpgq30o15elm57x4cpq; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_allele
    ADD CONSTRAINT fkhakinpmpgq30o15elm57x4cpq FOREIGN KEY (allele_id) REFERENCES public.mouse_allele(id);


--
-- Name: mouse_gene_synonym_relation fkhj32ev2dpo1oselyy6ymeq562; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_synonym_relation
    ADD CONSTRAINT fkhj32ev2dpo1oselyy6ymeq562 FOREIGN KEY (mouse_gene_id) REFERENCES public.mouse_gene(id);




--
-- Name: human_gene_disease fkjaxkft6y824w2k3f93ml1ofci; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_disease
    ADD CONSTRAINT fkjaxkft6y824w2k3f93ml1ofci FOREIGN KEY (human_disease_id) REFERENCES public.human_disease(id);


--
-- Name: human_disease_omim fkjt9bgr6vcvpy33oq8cbt1u1vu; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease_omim
    ADD CONSTRAINT fkjt9bgr6vcvpy33oq8cbt1u1vu FOREIGN KEY (human_disease_id) REFERENCES public.human_disease(id);




--
-- Name: mouse_gene_allele fkru8bt6pm5davofi7o73bn1j69; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_allele
    ADD CONSTRAINT fkru8bt6pm5davofi7o73bn1j69 FOREIGN KEY (mouse_gene_id) REFERENCES public.mouse_gene(id);




--
-- Name: ortholog fksx4xwbhlgssh52ougho53kyty; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.ortholog
    ADD CONSTRAINT fksx4xwbhlgssh52ougho53kyty FOREIGN KEY (mouse_gene_id) REFERENCES public.mouse_gene(id);



--
-- Name: ortholog fktgaxn9urr6pxq4spqllt8b36y; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.ortholog
    ADD CONSTRAINT fktgaxn9urr6pxq4spqllt8b36y FOREIGN KEY (human_gene_id) REFERENCES public.human_gene(id);
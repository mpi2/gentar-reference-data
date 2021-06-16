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

GRANT ALL ON schema public TO ref_admin;


--
-- Name: mgi_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_allele (
    id bigint NOT NULL,
    mouse_allele_id bigint,
    mouse_gene_id bigint,
    allele_name text,
    allele_symbol character varying(255),
    cell_line_acc_ids text,
    db_name character varying(255),
    gene_symbol character varying(255),
    mgi_allele_acc_id character varying(255),
    mgi_marker_acc_id character varying(255),
    project_acc_id character varying(255)
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
-- Name: mgi_allele_tmp; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_allele_tmp (
    id bigint NOT NULL,
    allele_name text,
    allele_symbol character varying(255),
    cell_line_acc_ids text,
    db_name character varying(255),
    gene_symbol character varying(255),
    mgi_allele_acc_id character varying(255),
    mgi_marker_acc_id character varying(255),
    project_acc_id character varying(255)
);


ALTER TABLE public.mgi_allele_tmp OWNER TO ref_admin;

--
-- Name: mgi_allele_tmp_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_allele_tmp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_allele_tmp_id_seq OWNER TO ref_admin;

--
-- Name: mgi_allele_tmp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_allele_tmp_id_seq OWNED BY public.mgi_allele_tmp.id;


--
-- Name: mgi_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_disease (
    id bigint NOT NULL,
    disease_name character varying(255),
    do_acc_id character varying(255),
    entrez_acc_id bigint,
    homologene_acc_id bigint,
    mgi_gene_acc_id character varying(255),
    omim_acc_ids text,
    organism_name character varying(255),
    symbol character varying(255),
    taxon_acc_id bigint
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
-- Name: mgi_phenotypic_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_phenotypic_allele (
    id bigint NOT NULL,
    mouse_allele_id bigint,
    mouse_gene_id bigint,
    allele_attribute character varying(255),
    allele_name text,
    allele_symbol character varying(255),
    ensembl_acc_id character varying(255),
    gene_name text,
    gene_symbol character varying(255),
    mgi_allele_acc_id character varying(255),
    mgi_marker_acc_id character varying(255),
    mp_acc_ids text,
    pubmed_acc_id character varying(255),
    refseq_acc_id character varying(255),
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
-- Name: mgi_phenotypic_allele_tmp; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mgi_phenotypic_allele_tmp (
    id bigint NOT NULL,
    allele_attribute character varying(255),
    allele_name text,
    allele_symbol character varying(255),
    ensembl_acc_id character varying(255),
    gene_name text,
    gene_symbol character varying(255),
    mgi_allele_acc_id character varying(255),
    mgi_marker_acc_id character varying(255),
    mp_acc_ids text,
    pubmed_acc_id character varying(255),
    refseq_acc_id character varying(255),
    synonyms text,
    type character varying(255)
);


ALTER TABLE public.mgi_phenotypic_allele_tmp OWNER TO ref_admin;

--
-- Name: mgi_phenotypic_allele_tmp_id_seq; Type: SEQUENCE; Schema: public; Owner: ref_admin
--

CREATE SEQUENCE public.mgi_phenotypic_allele_tmp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mgi_phenotypic_allele_tmp_id_seq OWNER TO ref_admin;

--
-- Name: mgi_phenotypic_allele_tmp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ref_admin
--

ALTER SEQUENCE public.mgi_phenotypic_allele_tmp_id_seq OWNED BY public.mgi_phenotypic_allele_tmp.id;


--
-- Name: mouse_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_allele (
    id bigint NOT NULL,
    allele_symbol character varying(255) NOT NULL,
    mgi_allele_acc_id character varying(255),
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
-- Name: mouse_gene_allele; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.mouse_gene_allele (
    mouse_gene_id bigint NOT NULL,
    mouse_allele_id bigint NOT NULL
);


ALTER TABLE public.mouse_gene_allele OWNER TO ref_admin;



--
-- Name: human_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_disease (
    id bigint NOT NULL,
    mgi_disease_id bigint NOT NULL,
    do_acc_id character varying(255),
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
-- Name: human_gene_disease; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.human_gene_disease (
    id bigint NOT NULL,
    human_evidence boolean NOT NULL,
    mgi_gene_acc_id character varying(255),
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
-- Name: omim_table; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.omim_table (
    id bigint NOT NULL,
    omim_acc_id character varying(255)
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
-- Name: strain; Type: TABLE; Schema: public; Owner: ref_admin
--

CREATE TABLE public.strain (
    id bigint NOT NULL,
    mgi_strain_acc_id character varying(255),
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
-- Name: human_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease ALTER COLUMN id SET DEFAULT nextval('public.human_disease_id_seq'::regclass);


--
-- Name: human_gene_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_gene_disease ALTER COLUMN id SET DEFAULT nextval('public.human_gene_disease_id_seq'::regclass);



--
-- Name: mgi_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele ALTER COLUMN id SET DEFAULT nextval('public.mgi_allele_id_seq'::regclass);


--
-- Name: mgi_allele_tmp id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele_tmp ALTER COLUMN id SET DEFAULT nextval('public.mgi_allele_tmp_id_seq'::regclass);


--
-- Name: mgi_disease id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_disease ALTER COLUMN id SET DEFAULT nextval('public.mgi_disease_id_seq'::regclass);


--
-- Name: mgi_phenotypic_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele ALTER COLUMN id SET DEFAULT nextval('public.mgi_phenotypic_allele_id_seq'::regclass);


--
-- Name: mgi_phenotypic_allele_tmp id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele_tmp ALTER COLUMN id SET DEFAULT nextval('public.mgi_phenotypic_allele_tmp_id_seq'::regclass);


--
-- Name: mouse_allele id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_allele ALTER COLUMN id SET DEFAULT nextval('public.mouse_allele_id_seq'::regclass);


--
-- Name: omim_table id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.omim_table ALTER COLUMN id SET DEFAULT nextval('public.omim_table_id_seq'::regclass);

--
-- Name: strain id; Type: DEFAULT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.strain ALTER COLUMN id SET DEFAULT nextval('public.strain_id_seq'::regclass);




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
-- Name: mgi_allele mgi_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele
    ADD CONSTRAINT mgi_allele_pkey PRIMARY KEY (id);


--
-- Name: mgi_allele_tmp mgi_allele_tmp_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele_tmp
    ADD CONSTRAINT mgi_allele_tmp_pkey PRIMARY KEY (id);


--
-- Name: mgi_disease mgi_disease_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_disease
    ADD CONSTRAINT mgi_disease_pkey PRIMARY KEY (id);



--
-- Name: mgi_phenotypic_allele mgi_phenotypic_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele
    ADD CONSTRAINT mgi_phenotypic_allele_pkey PRIMARY KEY (id);


--
-- Name: mgi_phenotypic_allele_tmp mgi_phenotypic_allele_tmp_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele_tmp
    ADD CONSTRAINT mgi_phenotypic_allele_tmp_pkey PRIMARY KEY (id);


--
-- Name: mouse_allele mouse_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_allele
    ADD CONSTRAINT mouse_allele_pkey PRIMARY KEY (id);



--
-- Name: mouse_gene_allele mouse_gene_allele_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_allele
    ADD CONSTRAINT mouse_gene_allele_pkey PRIMARY KEY (mouse_gene_id, mouse_allele_id);



--
-- Name: omim_table omim_table_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.omim_table
    ADD CONSTRAINT omim_table_pkey PRIMARY KEY (id);



--
-- Name: strain strain_pkey; Type: CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.strain
    ADD CONSTRAINT strain_pkey PRIMARY KEY (id);






--
-- Name: human_disease fk284iejet18j033e8a67r90s1; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.human_disease
    ADD CONSTRAINT human_disease_mgi_disease_id_unique UNIQUE (mgi_disease_id);

ALTER TABLE ONLY public.human_disease
    ADD CONSTRAINT fk284iejet18j033e8a67r90s1 FOREIGN KEY (mgi_disease_id) REFERENCES public.mgi_disease(id);



--
-- Name: mgi_allele fk235iejet18j033e8a67r28d2; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele
    ADD CONSTRAINT fk235iejet18j033e8a67r28d2 FOREIGN KEY (mouse_allele_id) REFERENCES public.mouse_allele(id);


--
-- Name: mgi_allele fk619iejet18j033e8a67r98w3; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_allele
    ADD CONSTRAINT fk619iejet18j033e8a67r98w3 FOREIGN KEY (mouse_gene_id) REFERENCES public.mouse_gene(id);




--
-- Name: mgi_phenotypic_allele fk394iejet18j033e8a67r62j9; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele
    ADD CONSTRAINT fk394iejet18j033e8a67r62j9 FOREIGN KEY (mouse_allele_id) REFERENCES public.mouse_allele(id);


--
-- Name: mgi_phenotypic_allele fk825iejet18j033e8a67r52l8; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mgi_phenotypic_allele
    ADD CONSTRAINT fk825iejet18j033e8a67r52l8 FOREIGN KEY (mouse_gene_id) REFERENCES public.mouse_gene(id);





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
-- Name: mouse_gene_allele fkhakinpmpgq30o15elm57x4cpq; Type: FK CONSTRAINT; Schema: public; Owner: ref_admin
--

ALTER TABLE ONLY public.mouse_gene_allele
    ADD CONSTRAINT fkhakinpmpgq30o15elm57x4cpq FOREIGN KEY (mouse_allele_id) REFERENCES public.mouse_allele(id);





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
-- Schema Search PATH
-- 

-- 
-- Need to specify the schema search path
-- The default is:
-- "$user", public
-- However this is causing an issue when specifying the SQL in the docker container.


SET search_path TO hdb_catalog, hdb_views, public;



-- 
-- Hasura user - Note only select granted on tables - i.e. read-only
-- 


-- We will create a separate user and grant permissions on hasura-specific
-- schemas and information_schema and pg_catalog
-- These permissions/grants are required for Hasura to work properly.

-- create a separate user for hasura
CREATE USER hasurauser WITH PASSWORD 'hasurauser';

-- create pgcrypto extension, required for UUID
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- create the schemas required by the hasura system
-- NOTE: If you are starting from scratch: drop the below schemas first, if they exist.
CREATE SCHEMA IF NOT EXISTS hdb_catalog;
CREATE SCHEMA IF NOT EXISTS hdb_views;

-- make the user an owner of system schemas
ALTER SCHEMA hdb_catalog OWNER TO hasurauser;
ALTER SCHEMA hdb_views OWNER TO hasurauser;

-- grant select permissions on information_schema and pg_catalog. This is
-- required for hasura to query list of available tables
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO hasurauser;
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO hasurauser;

-- Below permissions are optional. This is dependent on what access to your
-- tables/schemas - you want give to hasura. If you want expose the public
-- schema for GraphQL query then give permissions on public schema to the
-- hasura user.
-- Be careful to use these in your production db. Consult the postgres manual or
-- your DBA and give appropriate permissions.

-- grant all privileges on all tables in the public schema. This can be customised:
-- For example, if you only want to use GraphQL regular queries and not mutations,
-- then you can set: GRANT SELECT ON ALL TABLES...


REVOKE ALL ON SCHEMA public FROM hasurauser;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM hasurauser;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO hasurauser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO hasurauser;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO hasurauser;

-- 
-- Prevent Hasura from adding additional tables or triggers
-- Make sure run ALTER DEFAULT as hasurauser

ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON ROUTINES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON TYPES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON SCHEMAS FROM PUBLIC;

ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON TABLES FROM hasurauser;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON SEQUENCES FROM hasurauser;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON FUNCTIONS FROM hasurauser;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON ROUTINES FROM hasurauser;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON TYPES FROM hasurauser;
ALTER DEFAULT PRIVILEGES FOR ROLE hasurauser REVOKE ALL PRIVILEGES ON SCHEMAS FROM hasurauser;

-- Similarly add this for other schemas, if you have any.
-- GRANT USAGE ON SCHEMA <schema-name> TO hasurauser;
-- GRANT ALL ON ALL TABLES IN SCHEMA <schema-name> TO hasurauser;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA <schema-name> TO hasurauser;


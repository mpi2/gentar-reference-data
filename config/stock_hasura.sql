--
-- PostgreSQL database dump
--

-- Dumped from database version 11.15
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

ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_scheduled_event_invocation_logs DROP CONSTRAINT IF EXISTS hdb_scheduled_event_invocation_logs_event_id_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_cron_event_invocation_logs DROP CONSTRAINT IF EXISTS hdb_cron_event_invocation_logs_event_id_fkey;
DROP INDEX IF EXISTS hdb_catalog.hdb_version_one_row;
DROP INDEX IF EXISTS hdb_catalog.hdb_scheduled_event_status;
DROP INDEX IF EXISTS hdb_catalog.hdb_cron_events_unique_scheduled;
DROP INDEX IF EXISTS hdb_catalog.hdb_cron_event_status;
DROP INDEX IF EXISTS hdb_catalog.hdb_cron_event_invocation_event_id;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_version DROP CONSTRAINT IF EXISTS hdb_version_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_schema_notifications DROP CONSTRAINT IF EXISTS hdb_schema_notifications_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_scheduled_events DROP CONSTRAINT IF EXISTS hdb_scheduled_events_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_scheduled_event_invocation_logs DROP CONSTRAINT IF EXISTS hdb_scheduled_event_invocation_logs_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_metadata DROP CONSTRAINT IF EXISTS hdb_metadata_resource_version_key;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_metadata DROP CONSTRAINT IF EXISTS hdb_metadata_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_cron_events DROP CONSTRAINT IF EXISTS hdb_cron_events_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_cron_event_invocation_logs DROP CONSTRAINT IF EXISTS hdb_cron_event_invocation_logs_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_action_log DROP CONSTRAINT IF EXISTS hdb_action_log_pkey;
DROP TABLE IF EXISTS hdb_catalog.hdb_version;
DROP TABLE IF EXISTS hdb_catalog.hdb_schema_notifications;
DROP TABLE IF EXISTS hdb_catalog.hdb_scheduled_events;
DROP TABLE IF EXISTS hdb_catalog.hdb_scheduled_event_invocation_logs;
DROP TABLE IF EXISTS hdb_catalog.hdb_metadata;
DROP TABLE IF EXISTS hdb_catalog.hdb_cron_events;
DROP TABLE IF EXISTS hdb_catalog.hdb_cron_event_invocation_logs;
DROP TABLE IF EXISTS hdb_catalog.hdb_action_log;
DROP FUNCTION IF EXISTS hdb_catalog.gen_hasura_uuid();
DROP SCHEMA IF EXISTS hdb_catalog;
--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: hasurauser
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO hasurauser;

--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

GRANT USAGE ON SCHEMA public to hasurauser;

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    AS 'select public.gen_random_uuid()' LANGUAGE SQL STABLE;
    
 --   LANGUAGE sql
 --   AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO hasurauser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO hasurauser;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO hasurauser;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO hasurauser;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO hasurauser;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO hasurauser;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO hasurauser;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO hasurauser;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO hasurauser;

--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"sources":[{"kind":"postgres","name":"default","tables":[{"select_permissions":[{"role":"public","permission":{"columns":["entrez_acc_id","homeodb","human_gene_id","id","kznf_gene_catalog","mamit_trnadb","orphanet","agr_acc_id","alias_symbol","bioparadigms_slc","ccds_acc_id","cd","cosmic","ena","ensembl_gene_acc_id","enzyme_acc_id","gencc","gene_group","gene_group_acc_id","gtrnadb","hgnc_acc_id","horde_acc_id","imgt","intermediate_filament_db","iuphar","lncipedia","lncrnadb","location","location_sortable","locus_group","locus_type","mane_select","merops","mgi_gene_acc_id","mirbase","name","omim_acc_id","prev_symbol","pseudogene_org","pubmed_acc_id","refseq_accession","rgd_acc_id","rna_central_id","snornabase","status","symbol","ucsc_acc_id","uniprot_acc_ids","vega_acc_id","alias_name","lsdb","prev_name","date_approved_reserved","date_modified","date_name_changed","date_symbol_changed"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_gene_id"},"name":"human_gene"}],"table":{"schema":"public","name":"hgnc_gene"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","mgi_disease_id","do_acc_id","name"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mgi_disease_id"},"name":"mgi_disease"}],"table":{"schema":"public","name":"human_disease"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"human_disease_id","table":{"schema":"public","name":"human_disease_omim"}}},"name":"human_disease_omims"},{"using":{"foreign_key_constraint_on":{"column":"human_disease_id","table":{"schema":"public","name":"human_gene_disease"}}},"name":"human_gene_diseases"}]},{"select_permissions":[{"role":"public","permission":{"columns":["human_disease_id","omim_table_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_disease_id"},"name":"human_disease"},{"using":{"foreign_key_constraint_on":"omim_table_id"},"name":"omim_table"}],"table":{"schema":"public","name":"human_disease_omim"}},{"select_permissions":[{"role":"public","permission":{"columns":["entrez_gene_acc_id","id","ensembl_gene_acc_id","hgnc_acc_id","name","symbol"],"filter":{}}}],"table":{"schema":"public","name":"human_gene"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"human_gene_id","table":{"schema":"public","name":"hgnc_gene"}}},"name":"hgnc_genes"},{"using":{"foreign_key_constraint_on":{"column":"human_gene_id","table":{"schema":"public","name":"human_gene_disease"}}},"name":"human_gene_diseases"},{"using":{"foreign_key_constraint_on":{"column":"human_gene_id","table":{"schema":"public","name":"human_gene_synonym_relation"}}},"name":"human_gene_synonym_relations"},{"using":{"foreign_key_constraint_on":{"column":"human_gene_id","table":{"schema":"public","name":"human_mapping_filter"}}},"name":"human_mapping_filters"},{"using":{"foreign_key_constraint_on":{"column":"human_gene_id","table":{"schema":"public","name":"ortholog"}}},"name":"orthologs"}]},{"select_permissions":[{"role":"public","permission":{"columns":["human_disease_id","human_gene_id","id","human_evidence","mouse_evidence","mgi_gene_acc_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_disease_id"},"name":"human_disease"},{"using":{"foreign_key_constraint_on":"human_gene_id"},"name":"human_gene"}],"table":{"schema":"public","name":"human_gene_disease"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","hgnc_acc_id","synonym"],"filter":{}}}],"table":{"schema":"public","name":"human_gene_synonym"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"human_gene_synonym_id","table":{"schema":"public","name":"human_gene_synonym_relation"}}},"name":"human_gene_synonym_relations"}]},{"select_permissions":[{"role":"public","permission":{"columns":["human_gene_id","human_gene_synonym_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_gene_id"},"name":"human_gene"},{"using":{"foreign_key_constraint_on":"human_gene_synonym_id"},"name":"human_gene_synonym"}],"table":{"schema":"public","name":"human_gene_synonym_relation"}},{"select_permissions":[{"role":"public","permission":{"columns":["human_gene_id","id","orthologs_above_threshold","support_count_threshold","category_for_threshold"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_gene_id"},"name":"human_gene"}],"table":{"schema":"public","name":"human_mapping_filter"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","mouse_allele_id","mouse_gene_id","allele_symbol","db_name","gene_symbol","mgi_allele_acc_id","mgi_marker_acc_id","project_acc_id","allele_name","cell_line_acc_ids"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mouse_allele_id"},"name":"mouse_allele"},{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"}],"table":{"schema":"public","name":"mgi_allele"}},{"select_permissions":[{"role":"public","permission":{"columns":["entrez_acc_id","id","taxon_acc_id","disease_name","do_acc_id","mgi_gene_acc_id","organism_name","symbol","omim_acc_ids"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":{"column":"mgi_disease_id","table":{"schema":"public","name":"human_disease"}}},"name":"human_disease"}],"table":{"schema":"public","name":"mgi_disease"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"mgi_disease_id","table":{"schema":"public","name":"human_disease"}}},"name":"human_diseases"}]},{"select_permissions":[{"role":"public","permission":{"columns":["id","mouse_allele_id","mouse_gene_id","allele_attribute","allele_symbol","ensembl_acc_id","gene_symbol","mgi_allele_acc_id","mgi_marker_acc_id","pubmed_acc_id","refseq_acc_id","type","allele_name","gene_name","mp_acc_ids","synonyms"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mouse_allele_id"},"name":"mouse_allele"},{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"}],"table":{"schema":"public","name":"mgi_phenotypic_allele"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","allele_symbol","mgi_allele_acc_id","name"],"filter":{}}}],"table":{"schema":"public","name":"mouse_allele"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"mouse_allele_id","table":{"schema":"public","name":"mgi_allele"}}},"name":"mgi_alleles"},{"using":{"foreign_key_constraint_on":{"column":"mouse_allele_id","table":{"schema":"public","name":"mgi_phenotypic_allele"}}},"name":"mgi_phenotypic_alleles"},{"using":{"foreign_key_constraint_on":{"column":"mouse_allele_id","table":{"schema":"public","name":"mouse_gene_allele"}}},"name":"mouse_gene_alleles"}]},{"select_permissions":[{"role":"public","permission":{"columns":["ensembl_start","ensembl_stop","entrez_gene_acc_id","id","mgi_start","mgi_stop","ncbi_start","ncbi_stop","ensembl_chromosome","ensembl_gene_acc_id","ensembl_strand","genome_build","mgi_chromosome","mgi_cm","mgi_gene_acc_id","mgi_strand","ncbi_chromosome","ncbi_strand","subtype","symbol","type","name"],"filter":{}}}],"table":{"schema":"public","name":"mouse_gene"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"mgi_allele"}}},"name":"mgi_alleles"},{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"mgi_phenotypic_allele"}}},"name":"mgi_phenotypic_alleles"},{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"mouse_gene_allele"}}},"name":"mouse_gene_alleles"},{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"mouse_gene_synonym_relation"}}},"name":"mouse_gene_synonym_relations"},{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"mouse_mapping_filter"}}},"name":"mouse_mapping_filters"},{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_id","table":{"schema":"public","name":"ortholog"}}},"name":"orthologs"}]},{"select_permissions":[{"role":"public","permission":{"columns":["mouse_allele_id","mouse_gene_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mouse_allele_id"},"name":"mouse_allele"},{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"}],"table":{"schema":"public","name":"mouse_gene_allele"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","mgi_gene_acc_id","synonym"],"filter":{}}}],"table":{"schema":"public","name":"mouse_gene_synonym"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"mouse_gene_synonym_id","table":{"schema":"public","name":"mouse_gene_synonym_relation"}}},"name":"mouse_gene_synonym_relations"}]},{"select_permissions":[{"role":"public","permission":{"columns":["mouse_gene_id","mouse_gene_synonym_id"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"},{"using":{"foreign_key_constraint_on":"mouse_gene_synonym_id"},"name":"mouse_gene_synonym"}],"table":{"schema":"public","name":"mouse_gene_synonym_relation"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","mouse_gene_id","orthologs_above_threshold","support_count_threshold","category_for_threshold"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"}],"table":{"schema":"public","name":"mouse_mapping_filter"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","omim_acc_id"],"filter":{}}}],"table":{"schema":"public","name":"omim_table"},"array_relationships":[{"using":{"foreign_key_constraint_on":{"column":"omim_table_id","table":{"schema":"public","name":"human_disease_omim"}}},"name":"human_disease_omims"}]},{"select_permissions":[{"role":"public","permission":{"allow_aggregations":true,"columns":["human_gene_id","id","mouse_gene_id","support_count","category","is_max_human_to_mouse","is_max_mouse_to_human","support","support_raw"],"filter":{}}}],"object_relationships":[{"using":{"foreign_key_constraint_on":"human_gene_id"},"name":"human_gene"},{"using":{"foreign_key_constraint_on":"mouse_gene_id"},"name":"mouse_gene"}],"table":{"schema":"public","name":"ortholog"}},{"select_permissions":[{"role":"public","permission":{"columns":["id","mgi_strain_acc_id","type","name"],"filter":{}}}],"table":{"schema":"public","name":"strain"}}],"configuration":{"connection_info":{"use_prepared_statements":true,"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"retries":1,"idle_timeout":180,"max_connections":50}}}}],"version":3}	44
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":[]}	44	5ef6e0a3-5b93-4b04-bc8f-bbd0b8658056	2022-02-11 09:34:39.480149+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
440bfbb1-17e5-455b-a190-8f87ee19af9e	47	2022-02-10 12:17:29.169077+00	{}	{"console_notifications": {"admin": {"date": "2022-02-24T17:42:38.698Z", "read": "default", "showBadge": false}}, "telemetryNotificationShown": true}
\.


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


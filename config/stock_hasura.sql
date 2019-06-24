--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3 (Debian 11.3-1.pgdg90+1)
-- Dumped by pg_dump version 11.3 (Debian 11.3-1.pgdg90+1)

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

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: hasurauser
--

CREATE SCHEMA IF NOT EXISTS hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event_notifier(); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.hdb_schema_update_event_notifier() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    instance_id uuid;
    occurred_at timestamptz;
    curr_rec record;
  BEGIN
    instance_id = NEW.instance_id;
    occurred_at = NEW.occurred_at;
    PERFORM pg_notify('hasura_schema_update', json_build_object(
      'instance_id', instance_id,
      'occurred_at', occurred_at
      )::text);
    RETURN curr_rec;
  END;
$$;


ALTER FUNCTION hdb_catalog.hdb_schema_update_event_notifier() OWNER TO hasurauser;

--
-- Name: hdb_table_oid_check(); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.hdb_table_oid_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (EXISTS (SELECT 1 FROM information_schema.tables st WHERE st.table_schema = NEW.table_schema AND st.table_name = NEW.table_name)) THEN
      return NEW;
    ELSE
      RAISE foreign_key_violation using message = 'table_schema, table_name not in information_schema.tables';
      return NULL;
    END IF;
  END;
$$;


ALTER FUNCTION hdb_catalog.hdb_table_oid_check() OWNER TO hasurauser;

--
-- Name: inject_table_defaults(text, text, text, text); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        r RECORD;
    BEGIN
      FOR r IN SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = tab_schema AND table_name = tab_name AND column_default IS NOT NULL LOOP
          EXECUTE format('ALTER VIEW %I.%I ALTER COLUMN %I SET DEFAULT %s;', view_schema, view_name, r.column_name, r.column_default);
      END LOOP;
    END;
$$;


ALTER FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) OWNER TO hasurauser;

--
-- Name: insert_event_log(text, text, text, text, json); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    id text;
    payload json;
    session_variables json;
    server_version_num int;
  BEGIN
    id := gen_random_uuid();
    server_version_num := current_setting('server_version_num');
    IF server_version_num >= 90600 THEN
      session_variables := current_setting('hasura.user', 't');
    ELSE
      BEGIN
        session_variables := current_setting('hasura.user');
      EXCEPTION WHEN OTHERS THEN
                  session_variables := NULL;
      END;
    END IF;
    payload := json_build_object(
      'op', op,
      'data', row_data,
      'session_variables', session_variables
    );
    INSERT INTO hdb_catalog.event_log
                (id, schema_name, table_name, trigger_name, payload)
    VALUES
    (id, schema_name, table_name, trigger_name, payload);
    RETURN id;
  END;
$$;


ALTER FUNCTION hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json) OWNER TO hasurauser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.event_invocation_logs OWNER TO hasurauser;

--
-- Name: event_log; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL,
    next_retry_at timestamp without time zone
);


ALTER TABLE hdb_catalog.event_log OWNER TO hasurauser;

--
-- Name: event_triggers; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.event_triggers (
    name text NOT NULL,
    type text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    configuration json,
    comment text
);


ALTER TABLE hdb_catalog.event_triggers OWNER TO hasurauser;

--
-- Name: hdb_allowlist; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_allowlist (
    collection_name text
);


ALTER TABLE hdb_catalog.hdb_allowlist OWNER TO hasurauser;

--
-- Name: hdb_check_constraint; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_check_constraint AS
 SELECT (n.nspname)::text AS table_schema,
    (ct.relname)::text AS table_name,
    (r.conname)::text AS constraint_name,
    pg_get_constraintdef(r.oid, true) AS "check"
   FROM ((pg_constraint r
     JOIN pg_class ct ON ((r.conrelid = ct.oid)))
     JOIN pg_namespace n ON ((ct.relnamespace = n.oid)))
  WHERE (r.contype = 'c'::"char");


ALTER TABLE hdb_catalog.hdb_check_constraint OWNER TO hasurauser;

--
-- Name: hdb_foreign_key_constraint; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_foreign_key_constraint AS
 SELECT (q.table_schema)::text AS table_schema,
    (q.table_name)::text AS table_name,
    (q.constraint_name)::text AS constraint_name,
    (min(q.constraint_oid))::integer AS constraint_oid,
    min((q.ref_table_table_schema)::text) AS ref_table_table_schema,
    min((q.ref_table)::text) AS ref_table,
    json_object_agg(ac.attname, afc.attname) AS column_mapping,
    min((q.confupdtype)::text) AS on_update,
    min((q.confdeltype)::text) AS on_delete
   FROM ((( SELECT ctn.nspname AS table_schema,
            ct.relname AS table_name,
            r.conrelid AS table_id,
            r.conname AS constraint_name,
            r.oid AS constraint_oid,
            cftn.nspname AS ref_table_table_schema,
            cft.relname AS ref_table,
            r.confrelid AS ref_table_id,
            r.confupdtype,
            r.confdeltype,
            unnest(r.conkey) AS column_id,
            unnest(r.confkey) AS ref_column_id
           FROM ((((pg_constraint r
             JOIN pg_class ct ON ((r.conrelid = ct.oid)))
             JOIN pg_namespace ctn ON ((ct.relnamespace = ctn.oid)))
             JOIN pg_class cft ON ((r.confrelid = cft.oid)))
             JOIN pg_namespace cftn ON ((cft.relnamespace = cftn.oid)))
          WHERE (r.contype = 'f'::"char")) q
     JOIN pg_attribute ac ON (((q.column_id = ac.attnum) AND (q.table_id = ac.attrelid))))
     JOIN pg_attribute afc ON (((q.ref_column_id = afc.attnum) AND (q.ref_table_id = afc.attrelid))))
  GROUP BY q.table_schema, q.table_name, q.constraint_name;


ALTER TABLE hdb_catalog.hdb_foreign_key_constraint OWNER TO hasurauser;

--
-- Name: hdb_function; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_function (
    function_schema text NOT NULL,
    function_name text NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_function OWNER TO hasurauser;

--
-- Name: hdb_function_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_function_agg AS
 SELECT (p.proname)::text AS function_name,
    (pn.nspname)::text AS function_schema,
        CASE
            WHEN (p.provariadic = (0)::oid) THEN false
            ELSE true
        END AS has_variadic,
        CASE
            WHEN ((p.provolatile)::text = ('i'::character(1))::text) THEN 'IMMUTABLE'::text
            WHEN ((p.provolatile)::text = ('s'::character(1))::text) THEN 'STABLE'::text
            WHEN ((p.provolatile)::text = ('v'::character(1))::text) THEN 'VOLATILE'::text
            ELSE NULL::text
        END AS function_type,
    pg_get_functiondef(p.oid) AS function_definition,
    (rtn.nspname)::text AS return_type_schema,
    (rt.typname)::text AS return_type_name,
        CASE
            WHEN ((rt.typtype)::text = ('b'::character(1))::text) THEN 'BASE'::text
            WHEN ((rt.typtype)::text = ('c'::character(1))::text) THEN 'COMPOSITE'::text
            WHEN ((rt.typtype)::text = ('d'::character(1))::text) THEN 'DOMAIN'::text
            WHEN ((rt.typtype)::text = ('e'::character(1))::text) THEN 'ENUM'::text
            WHEN ((rt.typtype)::text = ('r'::character(1))::text) THEN 'RANGE'::text
            WHEN ((rt.typtype)::text = ('p'::character(1))::text) THEN 'PSUEDO'::text
            ELSE NULL::text
        END AS return_type_type,
    p.proretset AS returns_set,
    ( SELECT COALESCE(json_agg(q.type_name), '[]'::json) AS "coalesce"
           FROM ( SELECT pt.typname AS type_name,
                    pat.ordinality
                   FROM (unnest(COALESCE(p.proallargtypes, (p.proargtypes)::oid[])) WITH ORDINALITY pat(oid, ordinality)
                     LEFT JOIN pg_type pt ON ((pt.oid = pat.oid)))
                  ORDER BY pat.ordinality) q) AS input_arg_types,
    to_json(COALESCE(p.proargnames, ARRAY[]::text[])) AS input_arg_names
   FROM (((pg_proc p
     JOIN pg_namespace pn ON ((pn.oid = p.pronamespace)))
     JOIN pg_type rt ON ((rt.oid = p.prorettype)))
     JOIN pg_namespace rtn ON ((rtn.oid = rt.typnamespace)))
  WHERE (((pn.nspname)::text !~~ 'pg_%'::text) AND ((pn.nspname)::text <> ALL (ARRAY['information_schema'::text, 'hdb_catalog'::text, 'hdb_views'::text])) AND (NOT (EXISTS ( SELECT 1
           FROM pg_aggregate
          WHERE ((pg_aggregate.aggfnoid)::oid = p.oid)))));


ALTER TABLE hdb_catalog.hdb_function_agg OWNER TO hasurauser;

--
-- Name: hdb_function_info_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_function_info_agg AS
 SELECT hdb_function_agg.function_name,
    hdb_function_agg.function_schema,
    row_to_json(( SELECT e.*::record AS e
           FROM ( SELECT hdb_function_agg.has_variadic,
                    hdb_function_agg.function_type,
                    hdb_function_agg.return_type_schema,
                    hdb_function_agg.return_type_name,
                    hdb_function_agg.return_type_type,
                    hdb_function_agg.returns_set,
                    hdb_function_agg.input_arg_types,
                    hdb_function_agg.input_arg_names,
                    (EXISTS ( SELECT 1
                           FROM information_schema.tables
                          WHERE (((tables.table_schema)::text = hdb_function_agg.return_type_schema) AND ((tables.table_name)::text = hdb_function_agg.return_type_name)))) AS returns_table) e)) AS function_info
   FROM hdb_catalog.hdb_function_agg;


ALTER TABLE hdb_catalog.hdb_function_info_agg OWNER TO hasurauser;

--
-- Name: hdb_permission; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_permission (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    role_name text NOT NULL,
    perm_type text NOT NULL,
    perm_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_permission_perm_type_check CHECK ((perm_type = ANY (ARRAY['insert'::text, 'select'::text, 'update'::text, 'delete'::text])))
);


ALTER TABLE hdb_catalog.hdb_permission OWNER TO hasurauser;

--
-- Name: hdb_permission_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_permission_agg AS
 SELECT hdb_permission.table_schema,
    hdb_permission.table_name,
    hdb_permission.role_name,
    json_object_agg(hdb_permission.perm_type, hdb_permission.perm_def) AS permissions
   FROM hdb_catalog.hdb_permission
  GROUP BY hdb_permission.table_schema, hdb_permission.table_name, hdb_permission.role_name;


ALTER TABLE hdb_catalog.hdb_permission_agg OWNER TO hasurauser;

--
-- Name: hdb_primary_key; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_primary_key AS
 SELECT tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    json_agg(constraint_column_usage.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN ( SELECT x.tblschema AS table_schema,
            x.tblname AS table_name,
            x.colname AS column_name,
            x.cstrname AS constraint_name
           FROM ( SELECT DISTINCT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_depend d,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (d.refclassid = ('pg_class'::regclass)::oid) AND (d.refobjid = r.oid) AND (d.refobjsubid = a.attnum) AND (d.classid = ('pg_constraint'::regclass)::oid) AND (d.objid = c.oid) AND (c.connamespace = nc.oid) AND (c.contype = 'c'::"char") AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND (NOT a.attisdropped))
                UNION ALL
                 SELECT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (nc.oid = c.connamespace) AND (r.oid =
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confrelid
                            ELSE c.conrelid
                        END) AND (a.attnum = ANY (
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confkey
                            ELSE c.conkey
                        END)) AND (NOT a.attisdropped) AND (c.contype = ANY (ARRAY['p'::"char", 'u'::"char", 'f'::"char"])) AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])))) x(tblschema, tblname, colname, cstrname)) constraint_column_usage ON ((((tc.constraint_name)::text = (constraint_column_usage.constraint_name)::text) AND ((tc.table_schema)::text = (constraint_column_usage.table_schema)::text) AND ((tc.table_name)::text = (constraint_column_usage.table_name)::text))))
  WHERE ((tc.constraint_type)::text = 'PRIMARY KEY'::text)
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_primary_key OWNER TO hasurauser;

--
-- Name: hdb_query_collection; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_query_collection (
    collection_name text NOT NULL,
    collection_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_query_collection OWNER TO hasurauser;

--
-- Name: hdb_query_template; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_query_template (
    template_name text NOT NULL,
    template_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_query_template OWNER TO hasurauser;

--
-- Name: hdb_relationship; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);


ALTER TABLE hdb_catalog.hdb_relationship OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_schema_update_event (
    id bigint NOT NULL,
    instance_id uuid NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE hdb_catalog.hdb_schema_update_event OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event_id_seq; Type: SEQUENCE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE SEQUENCE hdb_catalog.hdb_schema_update_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hdb_catalog.hdb_schema_update_event_id_seq OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event_id_seq; Type: SEQUENCE OWNED BY; Schema: hdb_catalog; Owner: hasurauser
--

ALTER SEQUENCE hdb_catalog.hdb_schema_update_event_id_seq OWNED BY hdb_catalog.hdb_schema_update_event.id;


--
-- Name: hdb_table; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_table (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_table OWNER TO hasurauser;

--
-- Name: hdb_table_info_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_table_info_agg AS
 SELECT tables.table_name,
    tables.table_schema,
    COALESCE(columns.columns, '[]'::json) AS columns,
    COALESCE(pk.columns, '[]'::json) AS primary_key_columns,
    COALESCE(constraints.constraints, '[]'::json) AS constraints,
    COALESCE(views.view_info, 'null'::json) AS view_info
   FROM ((((information_schema.tables tables
     LEFT JOIN ( SELECT c.table_name,
            c.table_schema,
            json_agg(json_build_object('name', c.column_name, 'type', c.udt_name, 'is_nullable', (c.is_nullable)::boolean)) AS columns
           FROM information_schema.columns c
          GROUP BY c.table_schema, c.table_name) columns ON ((((tables.table_schema)::text = (columns.table_schema)::text) AND ((tables.table_name)::text = (columns.table_name)::text))))
     LEFT JOIN ( SELECT hdb_primary_key.table_schema,
            hdb_primary_key.table_name,
            hdb_primary_key.constraint_name,
            hdb_primary_key.columns
           FROM hdb_catalog.hdb_primary_key) pk ON ((((tables.table_schema)::text = (pk.table_schema)::text) AND ((tables.table_name)::text = (pk.table_name)::text))))
     LEFT JOIN ( SELECT c.table_schema,
            c.table_name,
            json_agg(c.constraint_name) AS constraints
           FROM information_schema.table_constraints c
          WHERE (((c.constraint_type)::text = 'UNIQUE'::text) OR ((c.constraint_type)::text = 'PRIMARY KEY'::text))
          GROUP BY c.table_schema, c.table_name) constraints ON ((((tables.table_schema)::text = (constraints.table_schema)::text) AND ((tables.table_name)::text = (constraints.table_name)::text))))
     LEFT JOIN ( SELECT v.table_schema,
            v.table_name,
            json_build_object('is_updatable', ((v.is_updatable)::boolean OR (v.is_trigger_updatable)::boolean), 'is_deletable', ((v.is_updatable)::boolean OR (v.is_trigger_deletable)::boolean), 'is_insertable', ((v.is_insertable_into)::boolean OR (v.is_trigger_insertable_into)::boolean)) AS view_info
           FROM information_schema.views v) views ON ((((tables.table_schema)::text = (views.table_schema)::text) AND ((tables.table_name)::text = (views.table_name)::text))));


ALTER TABLE hdb_catalog.hdb_table_info_agg OWNER TO hasurauser;

--
-- Name: hdb_unique_constraint; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_unique_constraint AS
 SELECT tc.table_name,
    tc.constraint_schema AS table_schema,
    tc.constraint_name,
    json_agg(kcu.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name))
  WHERE ((tc.constraint_type)::text = 'UNIQUE'::text)
  GROUP BY tc.table_name, tc.constraint_schema, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_unique_constraint OWNER TO hasurauser;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO hasurauser;

--
-- Name: remote_schemas; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.remote_schemas (
    id bigint NOT NULL,
    name text,
    definition json,
    comment text
);


ALTER TABLE hdb_catalog.remote_schemas OWNER TO hasurauser;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE SEQUENCE hdb_catalog.remote_schemas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hdb_catalog.remote_schemas_id_seq OWNER TO hasurauser;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: hdb_catalog; Owner: hasurauser
--

ALTER SEQUENCE hdb_catalog.remote_schemas_id_seq OWNED BY hdb_catalog.remote_schemas.id;


--
-- Name: hdb_schema_update_event id; Type: DEFAULT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_update_event ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.hdb_schema_update_event_id_seq'::regclass);


--
-- Name: remote_schemas id; Type: DEFAULT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.remote_schemas ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.remote_schemas_id_seq'::regclass);


--
-- Data for Name: event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at) FROM stdin;
\.


--
-- Data for Name: event_triggers; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.event_triggers (name, type, schema_name, table_name, configuration, comment) FROM stdin;
\.


--
-- Data for Name: hdb_allowlist; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_allowlist (collection_name) FROM stdin;
\.


--
-- Data for Name: hdb_function; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_function (function_schema, function_name, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_permission; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_permission (table_schema, table_name, role_name, perm_type, perm_def, comment, is_system_defined) FROM stdin;
public	hgnc_gene	public	select	{"filter": {}, "columns": ["id", "alias_name", "alias_symbol", "bioparadigms_slc", "ccds_id", "cd", "cosmic", "date_approved_reserved", "date_modified", "date_name_changed", "date_symbol_changed", "ena", "ensembl_gene_id", "entrez_id", "enzyme_id", "gene_family", "gene_family_id", "gtrnadb", "hgnc_id", "homeodb", "horde_id", "imgt", "intermediate_filament_db", "iuphar", "kznf_gene_catalog", "lncipedia", "lncrnadb", "location", "location_sortable", "locus_group", "locus_type", "lsdb", "mamit_trnadb", "merops", "mgd_id", "mirbase", "name", "omim_id", "orphanet", "prev_name", "prev_symbol", "pseudogene_org", "pubmed_id", "refseq_accession", "rgd_id", "rna_central_ids", "snornabase", "status", "symbol", "ucsc_id", "uniprot_ids", "vega_id"], "allow_aggregations": true}	\N	f
public	hcop	public	select	{"filter": {}, "columns": ["id", "hgnc_id", "human_assert_ids", "human_chr", "human_ensembl_gene", "human_entrez_gene", "human_name", "human_symbol", "mgi_id", "mouse_assert_ids", "mouse_chr", "mouse_ensembl_gene", "mouse_entrez_gene", "mouse_name", "mouse_symbol", "support"], "allow_aggregations": true}	\N	f
public	human_disease	public	select	{"filter": {}, "columns": ["name", "do_id", "id"], "allow_aggregations": true}	\N	f
public	human_disease_omim	public	select	{"filter": {}, "columns": ["human_disease_id", "omim_table_id"], "allow_aggregations": true}	\N	f
public	human_gene	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "hgnc_id", "name", "symbol"], "allow_aggregations": true}	\N	f
public	human_gene_disease	public	select	{"filter": {}, "columns": ["id", "human_evidence", "mgi_id", "mouse_evidence", "human_disease_id", "human_gene_id"], "allow_aggregations": true}	\N	f
public	human_gene_synonym	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "hgnc_id", "synonym"], "allow_aggregations": true}	\N	f
public	human_gene_synonym_rel	public	select	{"filter": {}, "columns": ["human_gene_id", "human_gene_synonym_id"], "allow_aggregations": true}	\N	f
public	mgi_allele	public	select	{"filter": {}, "columns": ["id", "allele_name", "allele_symbol", "cell_line_ids", "db_name", "gene_symbol", "mgi_allele_id", "mgi_id", "project_id"], "allow_aggregations": true}	\N	f
public	mgi_disease	public	select	{"filter": {}, "columns": ["id", "disease_name", "doid", "entrez_id", "homologene_id", "mgi_id", "omim_ids", "organism_name", "symbol", "taxon_id"], "allow_aggregations": true}	\N	f
public	mgi_gene	public	select	{"filter": {}, "columns": ["id", "ensembl_chromosome", "ensembl_gene_id", "ensembl_start", "ensembl_stop", "ensembl_strand", "entrez_gene_id", "genome_build", "mgi_id", "name", "ncbi_chromosome", "ncbi_start", "ncbi_stop", "ncbi_strand", "symbol", "type"], "allow_aggregations": true}	\N	f
public	mgi_mrk_list2	public	select	{"filter": {}, "columns": ["id", "cm", "chr", "feature_type", "marker_type", "mgi_id", "name", "start", "status", "stop", "strand", "symbol", "synonyms"], "allow_aggregations": true}	\N	f
public	mgi_phenotypic_allele	public	select	{"filter": {}, "columns": ["id", "allele_attribute", "allele_name", "allele_symbol", "ensembl_id", "gene_name", "gene_symbol", "mgi_allele_id", "mgi_id", "mp_ids", "pubmed_id", "refseq_id", "synonyms", "type"], "allow_aggregations": true}	\N	f
public	mouse_allele	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "allele_symbol", "mgi_id", "name"], "allow_aggregations": true}	\N	f
public	mouse_gene	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "ensembl_chromosome", "ensembl_gene_id", "ensembl_start", "ensembl_stop", "ensembl_strand", "entrez_gene_id", "genome_build", "mgi_id", "name", "ncbi_chromosome", "ncbi_start", "ncbi_stop", "ncbi_strand", "symbol", "type"], "allow_aggregations": true}	\N	f
public	mouse_gene_allele	public	select	{"filter": {}, "columns": ["mouse_gene_id", "allele_id"], "allow_aggregations": true}	\N	f
public	mouse_gene_synonym	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "mgi_id", "synonym"], "allow_aggregations": true}	\N	f
public	mouse_gene_synonym_relation	public	select	{"filter": {}, "columns": ["mouse_gene_id", "mouse_gene_synonym_id"], "allow_aggregations": true}	\N	f
public	omim_table	public	select	{"filter": {}, "columns": ["id", "omim_id"], "allow_aggregations": true}	\N	f
public	ortholog	public	select	{"filter": {}, "columns": ["support", "support_count", "category", "human_gene_id", "mouse_gene_id"], "allow_aggregations": true}	\N	f
public	strain	public	select	{"filter": {}, "columns": ["id", "created_at", "created_by", "last_modified", "last_modified_by", "mgi_id", "name", "type"], "allow_aggregations": true}	\N	f
\.


--
-- Data for Name: hdb_query_collection; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_query_collection (collection_name, collection_defn, comment, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_query_template; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_query_template (template_name, template_defn, comment, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_relationship; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_relationship (table_schema, table_name, rel_name, rel_type, rel_def, comment, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	detail	object	{"manual_configuration": {"remote_table": {"name": "tables", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	primary_key	object	{"manual_configuration": {"remote_table": {"name": "hdb_primary_key", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	columns	array	{"manual_configuration": {"remote_table": {"name": "columns", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	foreign_key_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_foreign_key_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	relationships	array	{"manual_configuration": {"remote_table": {"name": "hdb_relationship", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_permission_agg", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	check_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_check_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	unique_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_unique_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	event_log	trigger	object	{"manual_configuration": {"remote_table": {"name": "event_triggers", "schema": "hdb_catalog"}, "column_mapping": {"trigger_name": "name"}}}	\N	t
hdb_catalog	event_triggers	events	array	{"manual_configuration": {"remote_table": {"name": "event_log", "schema": "hdb_catalog"}, "column_mapping": {"name": "trigger_name"}}}	\N	t
hdb_catalog	event_invocation_logs	event	object	{"foreign_key_constraint_on": "event_id"}	\N	t
hdb_catalog	event_log	logs	array	{"foreign_key_constraint_on": {"table": {"name": "event_invocation_logs", "schema": "hdb_catalog"}, "column": "event_id"}}	\N	t
hdb_catalog	hdb_function_agg	return_table_info	object	{"manual_configuration": {"remote_table": {"name": "hdb_table", "schema": "hdb_catalog"}, "column_mapping": {"return_type_name": "table_name", "return_type_schema": "table_schema"}}}	\N	t
public	human_disease	human_disease_omims	array	{"foreign_key_constraint_on": {"table": "human_disease_omim", "column": "human_disease_id"}}	\N	f
public	human_disease	human_gene_diseases	array	{"foreign_key_constraint_on": {"table": "human_gene_disease", "column": "human_disease_id"}}	\N	f
public	human_disease_omim	human_disease	object	{"foreign_key_constraint_on": "human_disease_id"}	\N	f
public	human_disease_omim	omim_table	object	{"foreign_key_constraint_on": "omim_table_id"}	\N	f
public	human_gene	human_gene_diseases	array	{"foreign_key_constraint_on": {"table": "human_gene_disease", "column": "human_gene_id"}}	\N	f
public	human_gene	human_gene_synonym_rels	array	{"foreign_key_constraint_on": {"table": "human_gene_synonym_rel", "column": "human_gene_id"}}	\N	f
public	human_gene	orthologs	array	{"foreign_key_constraint_on": {"table": "ortholog", "column": "human_gene_id"}}	\N	f
public	human_gene_disease	human_disease	object	{"foreign_key_constraint_on": "human_disease_id"}	\N	f
public	human_gene_disease	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	human_gene_synonym	human_gene_synonym_rels	array	{"foreign_key_constraint_on": {"table": "human_gene_synonym_rel", "column": "human_gene_synonym_id"}}	\N	f
public	human_gene_synonym_rel	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	human_gene_synonym_rel	human_gene_synonym	object	{"foreign_key_constraint_on": "human_gene_synonym_id"}	\N	f
public	mouse_allele	mouse_gene_alleles	array	{"foreign_key_constraint_on": {"table": "mouse_gene_allele", "column": "allele_id"}}	\N	f
public	mouse_gene	mouse_gene_alleles	array	{"foreign_key_constraint_on": {"table": "mouse_gene_allele", "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	mouse_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": "mouse_gene_synonym_relation", "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	orthologs	array	{"foreign_key_constraint_on": {"table": "ortholog", "column": "mouse_gene_id"}}	\N	f
public	mouse_gene_allele	mouse_allele	object	{"foreign_key_constraint_on": "allele_id"}	\N	f
public	mouse_gene_allele	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	mouse_gene_synonym	mouse_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": "mouse_gene_synonym_relation", "column": "mouse_gene_synonym_id"}}	\N	f
public	mouse_gene_synonym_relation	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	mouse_gene_synonym_relation	mouse_gene_synonym	object	{"foreign_key_constraint_on": "mouse_gene_synonym_id"}	\N	f
public	omim_table	human_disease_omims	array	{"foreign_key_constraint_on": {"table": "human_disease_omim", "column": "omim_table_id"}}	\N	f
public	ortholog	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	ortholog	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
\.


--
-- Data for Name: hdb_schema_update_event; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_schema_update_event (id, instance_id, occurred_at) FROM stdin;
1	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:45.089795+00
2	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:45.179961+00
3	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:52.448063+00
4	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:55.9989+00
5	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:57.377478+00
6	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:35:57.556942+00
7	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:32.469999+00
8	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:36.098842+00
9	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:36.169608+00
10	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:37.848903+00
11	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:46.655173+00
12	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:46.672351+00
13	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:36:46.747221+00
14	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:37:23.203997+00
15	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:37:23.348601+00
16	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:37:26.744918+00
17	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:37:26.848238+00
18	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:38:08.311767+00
19	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:38:10.936644+00
20	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:38:11.012683+00
21	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:38:13.25953+00
22	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:39:09.274742+00
23	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 15:39:09.40138+00
24	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 16:07:22.989673+00
25	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 16:10:10.883696+00
26	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 16:10:10.94254+00
27	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-21 16:10:15.089693+00
28	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:36.369848+00
29	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:36.445714+00
30	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:40.277552+00
31	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:56.353746+00
32	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:56.370775+00
33	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:07:56.440311+00
34	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:10:19.772672+00
35	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:10:38.277078+00
36	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:10:38.29635+00
37	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:10:38.370135+00
38	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:11:14.612187+00
39	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:11:14.629371+00
40	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:11:14.701961+00
41	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:11:43.038059+00
42	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:11:43.169425+00
43	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:28.918762+00
44	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:29.022371+00
45	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:32.860646+00
46	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:32.964042+00
47	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:41.540011+00
48	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:41.69128+00
49	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:44.284005+00
50	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:44.39098+00
51	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:47.389243+00
52	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:47.489762+00
53	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:55.415018+00
54	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:55.51386+00
55	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:57.723832+00
56	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:12:57.873357+00
57	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:05.04503+00
58	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:05.156162+00
59	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:11.865803+00
60	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:11.95906+00
61	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:15.009405+00
62	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:13:15.138425+00
63	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:00.224983+00
64	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:00.370122+00
65	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:08.207248+00
66	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:08.316068+00
67	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:11.109555+00
68	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:11.245286+00
69	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:13.285533+00
70	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:13.378653+00
71	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:21.259634+00
72	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:21.388961+00
73	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:24.332595+00
74	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:24.45174+00
75	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:32.554279+00
76	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:32.643283+00
77	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:39.791861+00
78	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:39.981195+00
79	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:42.646608+00
80	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:42.751504+00
81	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:51.189554+00
82	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:51.310071+00
83	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:59.080172+00
84	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:18:59.2193+00
85	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:01.213702+00
86	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:01.348741+00
87	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:24.491855+00
88	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:24.638548+00
89	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:48.673566+00
90	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:19:48.846638+00
91	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:20:04.796785+00
92	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:20:04.976305+00
93	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:20:49.772429+00
94	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:20:49.977647+00
95	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:05.819409+00
96	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:05.997132+00
97	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:24.384591+00
98	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:24.541796+00
99	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:41.462078+00
100	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:21:41.630222+00
101	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:10.781463+00
102	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:10.956535+00
103	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:25.884366+00
104	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:26.056389+00
105	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:42.62702+00
106	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:42.760686+00
107	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:54.541445+00
108	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:22:54.697937+00
109	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:08.623254+00
110	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:08.786691+00
111	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:21.974571+00
112	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:22.15032+00
113	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:35.172715+00
114	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:35.333026+00
115	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:49.496313+00
116	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:23:49.643204+00
117	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:01.237505+00
118	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:01.379608+00
119	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:15.2753+00
120	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:15.417468+00
121	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:30.092415+00
122	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:30.262016+00
123	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:46.797208+00
124	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:24:46.961503+00
125	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:00.64607+00
126	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:00.753087+00
127	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:12.891374+00
128	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:13.043294+00
129	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:19.723538+00
130	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:19.749156+00
131	94a96fad-eb56-4c8f-b08d-beb893d3242a	2019-06-24 09:25:19.831408+00
\.


--
-- Data for Name: hdb_table; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_table (table_schema, table_name, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	t
information_schema	tables	t
information_schema	schemata	t
information_schema	views	t
hdb_catalog	hdb_primary_key	t
information_schema	columns	t
hdb_catalog	hdb_foreign_key_constraint	t
hdb_catalog	hdb_relationship	t
hdb_catalog	hdb_permission_agg	t
hdb_catalog	hdb_check_constraint	t
hdb_catalog	hdb_unique_constraint	t
hdb_catalog	hdb_query_template	t
hdb_catalog	event_triggers	t
hdb_catalog	event_log	t
hdb_catalog	event_invocation_logs	t
hdb_catalog	hdb_function_agg	t
hdb_catalog	hdb_function	t
hdb_catalog	remote_schemas	t
hdb_catalog	hdb_version	t
hdb_catalog	hdb_query_collection	t
hdb_catalog	hdb_allowlist	t
public	hcop	f
public	hgnc_gene	f
public	human_disease	f
public	human_disease_omim	f
public	human_gene	f
public	human_gene_disease	f
public	human_gene_synonym	f
public	human_gene_synonym_rel	f
public	mgi_allele	f
public	mgi_disease	f
public	mgi_gene	f
public	mgi_mrk_list2	f
public	mgi_phenotypic_allele	f
public	mouse_allele	f
public	mouse_gene	f
public	mouse_gene_allele	f
public	mouse_gene_synonym	f
public	mouse_gene_synonym_relation	f
public	omim_table	f
public	ortholog	f
public	strain	f
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
e06561b3-5d05-4c03-ba35-cb72e1d2ace0	17	2019-06-21 15:33:11.552179+00	{}	{"telemetryNotificationShown": true}
\.


--
-- Data for Name: remote_schemas; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.remote_schemas (id, name, definition, comment) FROM stdin;
\.


--
-- Name: hdb_schema_update_event_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: hasurauser
--

SELECT pg_catalog.setval('hdb_catalog.hdb_schema_update_event_id_seq', 131, true);


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: hasurauser
--

SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);


--
-- Name: event_invocation_logs event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);


--
-- Name: event_triggers event_triggers_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_pkey PRIMARY KEY (name);


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_key UNIQUE (collection_name);


--
-- Name: hdb_function hdb_function_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_function
    ADD CONSTRAINT hdb_function_pkey PRIMARY KEY (function_schema, function_name);


--
-- Name: hdb_permission hdb_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_pkey PRIMARY KEY (table_schema, table_name, role_name, perm_type);


--
-- Name: hdb_query_collection hdb_query_collection_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_query_collection
    ADD CONSTRAINT hdb_query_collection_pkey PRIMARY KEY (collection_name);


--
-- Name: hdb_query_template hdb_query_template_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_query_template
    ADD CONSTRAINT hdb_query_template_pkey PRIMARY KEY (template_name);


--
-- Name: hdb_relationship hdb_relationship_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);


--
-- Name: hdb_schema_update_event hdb_schema_update_event_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_update_event
    ADD CONSTRAINT hdb_schema_update_event_pkey PRIMARY KEY (id);


--
-- Name: hdb_table hdb_table_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_table
    ADD CONSTRAINT hdb_table_pkey PRIMARY KEY (table_schema, table_name);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: remote_schemas remote_schemas_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_name_key UNIQUE (name);


--
-- Name: remote_schemas remote_schemas_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_pkey PRIMARY KEY (id);


--
-- Name: event_invocation_logs_event_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);


--
-- Name: event_log_trigger_name_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_log_trigger_name_idx ON hdb_catalog.event_log USING btree (trigger_name);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_schema_update_event hdb_schema_update_event_notifier; Type: TRIGGER; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TRIGGER hdb_schema_update_event_notifier AFTER INSERT ON hdb_catalog.hdb_schema_update_event FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_schema_update_event_notifier();


--
-- Name: hdb_table hdb_table_oid_check; Type: TRIGGER; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TRIGGER hdb_table_oid_check BEFORE INSERT OR UPDATE ON hdb_catalog.hdb_table FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_table_oid_check();


--
-- Name: event_invocation_logs event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);


--
-- Name: event_triggers event_triggers_schema_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_schema_name_fkey FOREIGN KEY (schema_name, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES hdb_catalog.hdb_query_collection(collection_name);


--
-- Name: hdb_permission hdb_permission_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- Name: hdb_relationship hdb_relationship_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--


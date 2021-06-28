--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3 (Debian 11.3-1.pgdg90+1)
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

ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_relationship DROP CONSTRAINT IF EXISTS hdb_relationship_table_schema_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_permission DROP CONSTRAINT IF EXISTS hdb_permission_table_schema_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_computed_field DROP CONSTRAINT IF EXISTS hdb_computed_field_table_schema_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_allowlist DROP CONSTRAINT IF EXISTS hdb_allowlist_collection_name_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_action_permission DROP CONSTRAINT IF EXISTS hdb_action_permission_action_name_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.event_triggers DROP CONSTRAINT IF EXISTS event_triggers_schema_name_fkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.event_invocation_logs DROP CONSTRAINT IF EXISTS event_invocation_logs_event_id_fkey;
DROP TRIGGER IF EXISTS hdb_schema_update_event_notifier ON hdb_catalog.hdb_schema_update_event;
DROP INDEX IF EXISTS hdb_catalog.hdb_version_one_row;
DROP INDEX IF EXISTS hdb_catalog.hdb_schema_update_event_one_row;
DROP INDEX IF EXISTS hdb_catalog.event_log_trigger_name_idx;
DROP INDEX IF EXISTS hdb_catalog.event_log_locked_idx;
DROP INDEX IF EXISTS hdb_catalog.event_log_delivered_idx;
DROP INDEX IF EXISTS hdb_catalog.event_log_created_at_idx;
DROP INDEX IF EXISTS hdb_catalog.event_invocation_logs_event_id_idx;
ALTER TABLE IF EXISTS ONLY hdb_catalog.remote_schemas DROP CONSTRAINT IF EXISTS remote_schemas_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.remote_schemas DROP CONSTRAINT IF EXISTS remote_schemas_name_key;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_version DROP CONSTRAINT IF EXISTS hdb_version_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_table DROP CONSTRAINT IF EXISTS hdb_table_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_relationship DROP CONSTRAINT IF EXISTS hdb_relationship_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_query_collection DROP CONSTRAINT IF EXISTS hdb_query_collection_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_permission DROP CONSTRAINT IF EXISTS hdb_permission_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_function DROP CONSTRAINT IF EXISTS hdb_function_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_computed_field DROP CONSTRAINT IF EXISTS hdb_computed_field_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_allowlist DROP CONSTRAINT IF EXISTS hdb_allowlist_collection_name_key;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_action DROP CONSTRAINT IF EXISTS hdb_action_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_action_permission DROP CONSTRAINT IF EXISTS hdb_action_permission_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.hdb_action_log DROP CONSTRAINT IF EXISTS hdb_action_log_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.event_triggers DROP CONSTRAINT IF EXISTS event_triggers_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.event_log DROP CONSTRAINT IF EXISTS event_log_pkey;
ALTER TABLE IF EXISTS ONLY hdb_catalog.event_invocation_logs DROP CONSTRAINT IF EXISTS event_invocation_logs_pkey;
ALTER TABLE IF EXISTS hdb_catalog.remote_schemas ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS hdb_catalog.remote_schemas_id_seq;
DROP TABLE IF EXISTS hdb_catalog.remote_schemas;
DROP TABLE IF EXISTS hdb_catalog.hdb_version;
DROP VIEW IF EXISTS hdb_catalog.hdb_unique_constraint;
DROP VIEW IF EXISTS hdb_catalog.hdb_table_info_agg;
DROP TABLE IF EXISTS hdb_catalog.hdb_table;
DROP TABLE IF EXISTS hdb_catalog.hdb_schema_update_event;
DROP VIEW IF EXISTS hdb_catalog.hdb_role;
DROP TABLE IF EXISTS hdb_catalog.hdb_relationship;
DROP TABLE IF EXISTS hdb_catalog.hdb_query_collection;
DROP VIEW IF EXISTS hdb_catalog.hdb_primary_key;
DROP VIEW IF EXISTS hdb_catalog.hdb_permission_agg;
DROP TABLE IF EXISTS hdb_catalog.hdb_permission;
DROP VIEW IF EXISTS hdb_catalog.hdb_function_info_agg;
DROP VIEW IF EXISTS hdb_catalog.hdb_function_agg;
DROP TABLE IF EXISTS hdb_catalog.hdb_function;
DROP VIEW IF EXISTS hdb_catalog.hdb_foreign_key_constraint;
DROP TABLE IF EXISTS hdb_catalog.hdb_custom_types;
DROP VIEW IF EXISTS hdb_catalog.hdb_computed_field_function;
DROP TABLE IF EXISTS hdb_catalog.hdb_computed_field;
DROP VIEW IF EXISTS hdb_catalog.hdb_check_constraint;
DROP TABLE IF EXISTS hdb_catalog.hdb_allowlist;
DROP TABLE IF EXISTS hdb_catalog.hdb_action_permission;
DROP TABLE IF EXISTS hdb_catalog.hdb_action_log;
DROP TABLE IF EXISTS hdb_catalog.hdb_action;
DROP TABLE IF EXISTS hdb_catalog.event_triggers;
DROP TABLE IF EXISTS hdb_catalog.event_log;
DROP TABLE IF EXISTS hdb_catalog.event_invocation_logs;
DROP FUNCTION IF EXISTS hdb_catalog.insert_event_log(schema_name text, table_name text, trigger_name text, op text, row_data json);
DROP FUNCTION IF EXISTS hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text);
DROP FUNCTION IF EXISTS hdb_catalog.hdb_schema_update_event_notifier();
DROP FUNCTION IF EXISTS hdb_catalog.check_violation(msg text);
DROP SCHEMA IF EXISTS hdb_catalog;
--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: hasurauser
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO hasurauser;

--
-- Name: check_violation(text); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.check_violation(msg text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RAISE check_violation USING message=msg;
  END;
$$;


ALTER FUNCTION hdb_catalog.check_violation(msg text) OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event_notifier(); Type: FUNCTION; Schema: hdb_catalog; Owner: hasurauser
--

CREATE FUNCTION hdb_catalog.hdb_schema_update_event_notifier() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    instance_id uuid;
    occurred_at timestamptz;
    invalidations json;
    curr_rec record;
  BEGIN
    instance_id = NEW.instance_id;
    occurred_at = NEW.occurred_at;
    invalidations = NEW.invalidations;
    PERFORM pg_notify('hasura_schema_update', json_build_object(
      'instance_id', instance_id,
      'occurred_at', occurred_at,
      'invalidations', invalidations
      )::text);
    RETURN curr_rec;
  END;
$$;


ALTER FUNCTION hdb_catalog.hdb_schema_update_event_notifier() OWNER TO hasurauser;

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
    next_retry_at timestamp without time zone,
    archived boolean DEFAULT false NOT NULL
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
-- Name: hdb_action; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_action (
    action_name text NOT NULL,
    action_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_action OWNER TO hasurauser;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
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
-- Name: hdb_action_permission; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_action_permission (
    action_name text NOT NULL,
    role_name text NOT NULL,
    definition jsonb DEFAULT '{}'::jsonb NOT NULL,
    comment text
);


ALTER TABLE hdb_catalog.hdb_action_permission OWNER TO hasurauser;

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
-- Name: hdb_computed_field; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_computed_field (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    computed_field_name text NOT NULL,
    definition jsonb NOT NULL,
    comment text
);


ALTER TABLE hdb_catalog.hdb_computed_field OWNER TO hasurauser;

--
-- Name: hdb_computed_field_function; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_computed_field_function AS
 SELECT hdb_computed_field.table_schema,
    hdb_computed_field.table_name,
    hdb_computed_field.computed_field_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text) IS NULL) THEN (hdb_computed_field.definition ->> 'function'::text)
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'name'::text)
        END AS function_name,
        CASE
            WHEN (((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text) IS NULL) THEN 'public'::text
            ELSE ((hdb_computed_field.definition -> 'function'::text) ->> 'schema'::text)
        END AS function_schema
   FROM hdb_catalog.hdb_computed_field;


ALTER TABLE hdb_catalog.hdb_computed_field_function OWNER TO hasurauser;

--
-- Name: hdb_custom_types; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_custom_types (
    custom_types jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_custom_types OWNER TO hasurauser;

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
    min((q.confdeltype)::text) AS on_delete,
    json_agg(ac.attname) AS columns,
    json_agg(afc.attname) AS ref_columns
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
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_function OWNER TO hasurauser;

--
-- Name: hdb_function_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_function_agg AS
 SELECT (p.proname)::text AS function_name,
    (pn.nspname)::text AS function_schema,
    pd.description,
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
    (rt.typtype)::text AS return_type_type,
    p.proretset AS returns_set,
    ( SELECT COALESCE(json_agg(json_build_object('schema', q.schema, 'name', q.name, 'type', q.type)), '[]'::json) AS "coalesce"
           FROM ( SELECT pt.typname AS name,
                    pns.nspname AS schema,
                    pt.typtype AS type,
                    pat.ordinality
                   FROM ((unnest(COALESCE(p.proallargtypes, (p.proargtypes)::oid[])) WITH ORDINALITY pat(oid, ordinality)
                     LEFT JOIN pg_type pt ON ((pt.oid = pat.oid)))
                     LEFT JOIN pg_namespace pns ON ((pt.typnamespace = pns.oid)))
                  ORDER BY pat.ordinality) q) AS input_arg_types,
    to_json(COALESCE(p.proargnames, ARRAY[]::text[])) AS input_arg_names,
    p.pronargdefaults AS default_args,
    (p.oid)::integer AS function_oid
   FROM ((((pg_proc p
     JOIN pg_namespace pn ON ((pn.oid = p.pronamespace)))
     JOIN pg_type rt ON ((rt.oid = p.prorettype)))
     JOIN pg_namespace rtn ON ((rtn.oid = rt.typnamespace)))
     LEFT JOIN pg_description pd ON ((p.oid = pd.objoid)))
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
           FROM ( SELECT hdb_function_agg.description,
                    hdb_function_agg.has_variadic,
                    hdb_function_agg.function_type,
                    hdb_function_agg.return_type_schema,
                    hdb_function_agg.return_type_name,
                    hdb_function_agg.return_type_type,
                    hdb_function_agg.returns_set,
                    hdb_function_agg.input_arg_types,
                    hdb_function_agg.input_arg_names,
                    hdb_function_agg.default_args,
                    (EXISTS ( SELECT 1
                           FROM information_schema.tables
                          WHERE (((tables.table_schema)::text = hdb_function_agg.return_type_schema) AND ((tables.table_name)::text = hdb_function_agg.return_type_name)))) AS returns_table) e)) AS function_info
   FROM hdb_catalog.hdb_function_agg;


ALTER TABLE hdb_catalog.hdb_function_info_agg OWNER TO hasurauser;

--
-- Name: hdb_permission; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_permission (
    table_schema name NOT NULL,
    table_name name NOT NULL,
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
-- Name: hdb_relationship; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);


ALTER TABLE hdb_catalog.hdb_relationship OWNER TO hasurauser;

--
-- Name: hdb_role; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_role AS
 SELECT DISTINCT q.role_name
   FROM ( SELECT hdb_permission.role_name
           FROM hdb_catalog.hdb_permission
        UNION ALL
         SELECT hdb_action_permission.role_name
           FROM hdb_catalog.hdb_action_permission) q;


ALTER TABLE hdb_catalog.hdb_role OWNER TO hasurauser;

--
-- Name: hdb_schema_update_event; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_schema_update_event (
    instance_id uuid NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    invalidations json NOT NULL
);


ALTER TABLE hdb_catalog.hdb_schema_update_event OWNER TO hasurauser;

--
-- Name: hdb_table; Type: TABLE; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TABLE hdb_catalog.hdb_table (
    table_schema name NOT NULL,
    table_name name NOT NULL,
    configuration jsonb,
    is_system_defined boolean DEFAULT false,
    is_enum boolean DEFAULT false NOT NULL
);


ALTER TABLE hdb_catalog.hdb_table OWNER TO hasurauser;

--
-- Name: hdb_table_info_agg; Type: VIEW; Schema: hdb_catalog; Owner: hasurauser
--

CREATE VIEW hdb_catalog.hdb_table_info_agg AS
 SELECT schema.nspname AS table_schema,
    "table".relname AS table_name,
    jsonb_build_object('oid', ("table".oid)::integer, 'columns', COALESCE(columns.info, '[]'::jsonb), 'primary_key', primary_key.info, 'unique_constraints', COALESCE(unique_constraints.info, '[]'::jsonb), 'foreign_keys', COALESCE(foreign_key_constraints.info, '[]'::jsonb), 'view_info',
        CASE "table".relkind
            WHEN 'v'::"char" THEN jsonb_build_object('is_updatable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 4) = 4), 'is_insertable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 8) = 8), 'is_deletable', ((pg_relation_is_updatable(("table".oid)::regclass, true) & 16) = 16))
            ELSE NULL::jsonb
        END, 'description', description.description) AS info
   FROM ((((((pg_class "table"
     JOIN pg_namespace schema ON ((schema.oid = "table".relnamespace)))
     LEFT JOIN pg_description description ON (((description.classoid = ('pg_class'::regclass)::oid) AND (description.objoid = "table".oid) AND (description.objsubid = 0))))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', "column".attname, 'position', "column".attnum, 'type', COALESCE(base_type.typname, type.typname), 'is_nullable', (NOT "column".attnotnull), 'description', col_description("table".oid, ("column".attnum)::integer))) AS info
           FROM ((pg_attribute "column"
             LEFT JOIN pg_type type ON ((type.oid = "column".atttypid)))
             LEFT JOIN pg_type base_type ON (((type.typtype = 'd'::"char") AND (base_type.oid = type.typbasetype))))
          WHERE (("column".attrelid = "table".oid) AND ("column".attnum > 0) AND (NOT "column".attisdropped))) columns ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_build_object('constraint', jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer), 'columns', COALESCE(columns_1.info, '[]'::jsonb)) AS info
           FROM ((pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
             LEFT JOIN LATERAL ( SELECT jsonb_agg("column".attname) AS info
                   FROM pg_attribute "column"
                  WHERE (("column".attrelid = "table".oid) AND ("column".attnum = ANY ((index.indkey)::smallint[])))) columns_1 ON (true))
          WHERE ((index.indrelid = "table".oid) AND index.indisprimary)) primary_key ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('name', class.relname, 'oid', (class.oid)::integer)) AS info
           FROM (pg_index index
             JOIN pg_class class ON ((class.oid = index.indexrelid)))
          WHERE ((index.indrelid = "table".oid) AND index.indisunique AND (NOT index.indisprimary))) unique_constraints ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('constraint', jsonb_build_object('name', foreign_key.constraint_name, 'oid', foreign_key.constraint_oid), 'columns', foreign_key.columns, 'foreign_table', jsonb_build_object('schema', foreign_key.ref_table_table_schema, 'name', foreign_key.ref_table), 'foreign_columns', foreign_key.ref_columns)) AS info
           FROM hdb_catalog.hdb_foreign_key_constraint foreign_key
          WHERE ((foreign_key.table_schema = (schema.nspname)::text) AND (foreign_key.table_name = ("table".relname)::text))) foreign_key_constraints ON (true))
  WHERE ("table".relkind = ANY (ARRAY['r'::"char", 't'::"char", 'v'::"char", 'm'::"char", 'f'::"char", 'p'::"char"]));


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

COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at, archived) FROM stdin;
\.


--
-- Data for Name: event_triggers; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.event_triggers (name, type, schema_name, table_name, configuration, comment) FROM stdin;
\.


--
-- Data for Name: hdb_action; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_action (action_name, action_defn, comment, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_action_permission; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_action_permission (action_name, role_name, definition, comment) FROM stdin;
\.


--
-- Data for Name: hdb_allowlist; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_allowlist (collection_name) FROM stdin;
\.


--
-- Data for Name: hdb_computed_field; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_computed_field (table_schema, table_name, computed_field_name, definition, comment) FROM stdin;
\.


--
-- Data for Name: hdb_custom_types; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_custom_types (custom_types) FROM stdin;
\.


--
-- Data for Name: hdb_function; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_function (function_schema, function_name, configuration, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_permission; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_permission (table_schema, table_name, role_name, perm_type, perm_def, comment, is_system_defined) FROM stdin;
public	hgnc_gene	anonymous	select	{"filter": {}, "columns": ["agr_acc_id", "alias_name", "alias_symbol", "bioparadigms_slc", "ccds_acc_id", "cd", "cosmic", "date_approved_reserved", "date_modified", "date_name_changed", "date_symbol_changed", "ena", "ensembl_gene_acc_id", "entrez_acc_id", "enzyme_acc_id", "gene_family", "gene_family_acc_id", "gtrnadb", "hgnc_acc_id", "homeodb", "horde_acc_id", "human_gene_id", "imgt", "intermediate_filament_db", "iuphar", "kznf_gene_catalog", "lncipedia", "lncrnadb", "location", "location_sortable", "locus_group", "locus_type", "lsdb", "mamit_trnadb", "merops", "mgi_gene_acc_id", "mirbase", "name", "omim_acc_id", "orphanet", "prev_name", "prev_symbol", "pseudogene_org", "pubmed_acc_id", "refseq_accession", "rgd_acc_id", "rna_central_acc_ids", "snornabase", "status", "symbol", "ucsc_acc_id", "uniprot_acc_ids", "vega_acc_id"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	human_disease	anonymous	select	{"filter": {}, "columns": ["do_acc_id", "mgi_disease_id", "name"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	human_disease_omim	anonymous	select	{"filter": {}, "columns": ["human_disease_id", "omim_table_id"], "computed_fields": [], "allow_aggregations": false}	\N	f
public	human_gene	anonymous	select	{"filter": {}, "columns": ["ensembl_gene_acc_id", "entrez_gene_acc_id", "hgnc_acc_id", "name", "symbol"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	human_gene_disease	anonymous	select	{"filter": {}, "columns": ["human_disease_id", "human_evidence", "human_gene_id", "mgi_gene_acc_id", "mouse_evidence"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	human_gene_synonym	anonymous	select	{"filter": {}, "columns": ["hgnc_acc_id", "synonym"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	human_gene_synonym_relation	anonymous	select	{"filter": {}, "columns": ["human_gene_id", "human_gene_synonym_id"], "computed_fields": [], "allow_aggregations": false}	\N	f
public	human_mapping_filter	anonymous	select	{"filter": {}, "columns": ["category_for_threshold", "human_gene_id", "orthologs_above_threshold", "support_count_threshold"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mgi_allele	anonymous	select	{"filter": {}, "columns": ["allele_name", "allele_symbol", "cell_line_acc_ids", "db_name", "gene_symbol", "mgi_allele_acc_id", "mgi_marker_acc_id", "mouse_allele_id", "mouse_gene_id", "project_acc_id"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mgi_disease	anonymous	select	{"filter": {}, "columns": ["disease_name", "do_acc_id", "entrez_acc_id", "mgi_gene_acc_id", "omim_acc_ids", "organism_name", "symbol", "taxon_acc_id"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mgi_phenotypic_allele	anonymous	select	{"filter": {}, "columns": ["allele_attribute", "allele_name", "allele_symbol", "ensembl_acc_id", "gene_name", "gene_symbol", "mgi_allele_acc_id", "mgi_marker_acc_id", "mouse_allele_id", "mouse_gene_id", "mp_acc_ids", "pubmed_acc_id", "refseq_acc_id", "synonyms", "type"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mouse_allele	anonymous	select	{"filter": {}, "columns": ["allele_symbol", "mgi_allele_acc_id", "name"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mouse_gene	anonymous	select	{"filter": {}, "columns": ["ensembl_chromosome", "ensembl_gene_acc_id", "ensembl_start", "ensembl_stop", "ensembl_strand", "entrez_gene_acc_id", "genome_build", "mgi_chromosome", "mgi_cm", "mgi_gene_acc_id", "mgi_start", "mgi_stop", "mgi_strand", "name", "ncbi_chromosome", "ncbi_start", "ncbi_stop", "ncbi_strand", "subtype", "symbol", "type"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mouse_gene_allele	anonymous	select	{"filter": {}, "columns": ["mouse_gene_id", "mouse_allele_id"], "computed_fields": [], "allow_aggregations": false}	\N	f
public	mouse_gene_synonym	anonymous	select	{"filter": {}, "columns": ["mgi_gene_acc_id", "synonym"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	mouse_gene_synonym_relation	anonymous	select	{"filter": {}, "columns": ["mouse_gene_id", "mouse_gene_synonym_id"], "computed_fields": [], "allow_aggregations": false}	\N	f
public	mouse_mapping_filter	anonymous	select	{"filter": {}, "columns": ["category_for_threshold", "mouse_gene_id", "orthologs_above_threshold", "support_count_threshold"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	omim_table	anonymous	select	{"filter": {}, "columns": ["omim_acc_id"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	ortholog	anonymous	select	{"filter": {}, "columns": ["category", "human_gene_id", "is_max_human_to_mouse", "is_max_mouse_to_human", "mouse_gene_id", "support", "support_count", "support_raw"], "computed_fields": [], "allow_aggregations": true}	\N	f
public	strain	anonymous	select	{"filter": {}, "columns": ["mgi_strain_acc_id", "name", "type"], "computed_fields": [], "allow_aggregations": true}	\N	f
\.


--
-- Data for Name: hdb_query_collection; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_query_collection (collection_name, collection_defn, comment, is_system_defined) FROM stdin;
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
hdb_catalog	hdb_table	computed_fields	array	{"manual_configuration": {"remote_table": {"name": "hdb_computed_field", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	check_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_check_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	unique_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_unique_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	event_triggers	events	array	{"manual_configuration": {"remote_table": {"name": "event_log", "schema": "hdb_catalog"}, "column_mapping": {"name": "trigger_name"}}}	\N	t
hdb_catalog	event_log	trigger	object	{"manual_configuration": {"remote_table": {"name": "event_triggers", "schema": "hdb_catalog"}, "column_mapping": {"trigger_name": "name"}}}	\N	t
hdb_catalog	event_log	logs	array	{"foreign_key_constraint_on": {"table": {"name": "event_invocation_logs", "schema": "hdb_catalog"}, "column": "event_id"}}	\N	t
hdb_catalog	event_invocation_logs	event	object	{"foreign_key_constraint_on": "event_id"}	\N	t
hdb_catalog	hdb_function_agg	return_table_info	object	{"manual_configuration": {"remote_table": {"name": "hdb_table", "schema": "hdb_catalog"}, "column_mapping": {"return_type_name": "table_name", "return_type_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_action	permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_action_permission", "schema": "hdb_catalog"}, "column_mapping": {"action_name": "action_name"}}}	\N	t
hdb_catalog	hdb_role	action_permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_action_permission", "schema": "hdb_catalog"}, "column_mapping": {"role_name": "role_name"}}}	\N	t
hdb_catalog	hdb_role	permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_permission_agg", "schema": "hdb_catalog"}, "column_mapping": {"role_name": "role_name"}}}	\N	t
public	hgnc_gene	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	human_gene	hgnc_genes	array	{"foreign_key_constraint_on": {"table": {"name": "hgnc_gene", "schema": "public"}, "column": "human_gene_id"}}	\N	f
public	human_gene	human_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": {"name": "human_gene_synonym_relation", "schema": "public"}, "column": "human_gene_id"}}	\N	f
public	human_gene	human_mapping_filters	array	{"foreign_key_constraint_on": {"table": {"name": "human_mapping_filter", "schema": "public"}, "column": "human_gene_id"}}	\N	f
public	human_gene	orthologs	array	{"foreign_key_constraint_on": {"table": {"name": "ortholog", "schema": "public"}, "column": "human_gene_id"}}	\N	f
public	human_gene	human_gene_diseases	array	{"foreign_key_constraint_on": {"table": {"name": "human_gene_disease", "schema": "public"}, "column": "human_gene_id"}}	\N	f
public	human_gene_synonym	human_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": {"name": "human_gene_synonym_relation", "schema": "public"}, "column": "human_gene_synonym_id"}}	\N	f
public	human_gene_synonym_relation	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	mouse_gene	mouse_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": {"name": "mouse_gene_synonym_relation", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	mgi_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mgi_allele", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	mouse_gene_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mouse_gene_allele", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene_synonym_relation	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	ortholog	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	mgi_allele	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	mgi_phenotypic_allele	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	mouse_allele	mgi_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mgi_allele", "schema": "public"}, "column": "mouse_allele_id"}}	\N	f
public	mouse_allele	mgi_phenotypic_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mgi_phenotypic_allele", "schema": "public"}, "column": "mouse_allele_id"}}	\N	f
public	mouse_gene_allele	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	human_disease	mgi_disease	object	{"foreign_key_constraint_on": "mgi_disease_id"}	\N	f
public	human_disease	human_disease_omims	array	{"foreign_key_constraint_on": {"table": {"name": "human_disease_omim", "schema": "public"}, "column": "human_disease_id"}}	\N	f
public	human_disease_omim	omim_table	object	{"foreign_key_constraint_on": "omim_table_id"}	\N	f
public	human_gene_disease	human_gene	object	{"foreign_key_constraint_on": "human_gene_id"}	\N	f
public	omim_table	human_disease_omims	array	{"foreign_key_constraint_on": {"table": {"name": "human_disease_omim", "schema": "public"}, "column": "omim_table_id"}}	\N	f
public	human_gene_synonym_relation	human_gene_synonym	object	{"foreign_key_constraint_on": "human_gene_synonym_id"}	\N	f
public	mouse_gene	mouse_mapping_filters	array	{"foreign_key_constraint_on": {"table": {"name": "mouse_mapping_filter", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	orthologs	array	{"foreign_key_constraint_on": {"table": {"name": "ortholog", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene	mgi_phenotypic_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mgi_phenotypic_allele", "schema": "public"}, "column": "mouse_gene_id"}}	\N	f
public	mouse_gene_synonym	mouse_gene_synonym_relations	array	{"foreign_key_constraint_on": {"table": {"name": "mouse_gene_synonym_relation", "schema": "public"}, "column": "mouse_gene_synonym_id"}}	\N	f
public	mouse_gene_synonym_relation	mouse_gene_synonym	object	{"foreign_key_constraint_on": "mouse_gene_synonym_id"}	\N	f
public	ortholog	mouse_gene	object	{"foreign_key_constraint_on": "mouse_gene_id"}	\N	f
public	mgi_allele	mouse_allele	object	{"foreign_key_constraint_on": "mouse_allele_id"}	\N	f
public	mgi_disease	human_diseases	array	{"foreign_key_constraint_on": {"table": {"name": "human_disease", "schema": "public"}, "column": "mgi_disease_id"}}	\N	f
public	mgi_phenotypic_allele	mouse_allele	object	{"foreign_key_constraint_on": "mouse_allele_id"}	\N	f
public	mouse_allele	mouse_gene_alleles	array	{"foreign_key_constraint_on": {"table": {"name": "mouse_gene_allele", "schema": "public"}, "column": "mouse_allele_id"}}	\N	f
public	mouse_gene_allele	mouse_allele	object	{"foreign_key_constraint_on": "mouse_allele_id"}	\N	f
public	human_disease	human_gene_diseases	array	{"foreign_key_constraint_on": {"table": {"name": "human_gene_disease", "schema": "public"}, "column": "human_disease_id"}}	\N	f
public	human_disease_omim	human_disease	object	{"foreign_key_constraint_on": "human_disease_id"}	\N	f
public	human_gene_disease	human_disease	object	{"foreign_key_constraint_on": "human_disease_id"}	\N	f
\.


--
-- Data for Name: hdb_schema_update_event; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_schema_update_event (instance_id, occurred_at, invalidations) FROM stdin;
06aca69b-2551-47d2-bb6e-79e4c0548788	2020-06-21 15:47:51.57746+00	{"metadata":false,"remote_schemas":[]}
\.


--
-- Data for Name: hdb_table; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_table (table_schema, table_name, configuration, is_system_defined, is_enum) FROM stdin;
information_schema	tables	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
information_schema	schemata	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
information_schema	views	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
information_schema	columns	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_table	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_primary_key	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_foreign_key_constraint	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_relationship	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_permission_agg	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_computed_field	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_check_constraint	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_unique_constraint	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	event_triggers	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	event_log	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	event_invocation_logs	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_function	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_function_agg	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	remote_schemas	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_version	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_query_collection	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_allowlist	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_custom_types	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_action_permission	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_action	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_action_log	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
hdb_catalog	hdb_role	{"custom_root_fields": {}, "custom_column_names": {}}	t	f
public	hgnc_gene	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_gene	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_gene_synonym	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_gene_synonym_relation	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_mapping_filter	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_gene	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_gene_synonym	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_gene_synonym_relation	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_mapping_filter	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	ortholog	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mgi_allele	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mgi_disease	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mgi_phenotypic_allele	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_allele	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	mouse_gene_allele	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_disease	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_disease_omim	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	human_gene_disease	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	omim_table	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
public	strain	{"custom_root_fields": {}, "custom_column_names": {}}	f	f
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
042424d9-3823-4927-9c47-1c47832adc6b	34	2020-06-21 15:40:00.684659+00	{}	{}
\.


--
-- Data for Name: remote_schemas; Type: TABLE DATA; Schema: hdb_catalog; Owner: hasurauser
--

COPY hdb_catalog.remote_schemas (id, name, definition, comment) FROM stdin;
\.


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
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_action_permission hdb_action_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_action_permission
    ADD CONSTRAINT hdb_action_permission_pkey PRIMARY KEY (action_name, role_name);


--
-- Name: hdb_action hdb_action_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_action
    ADD CONSTRAINT hdb_action_pkey PRIMARY KEY (action_name);


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_key UNIQUE (collection_name);


--
-- Name: hdb_computed_field hdb_computed_field_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_pkey PRIMARY KEY (table_schema, table_name, computed_field_name);


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
-- Name: hdb_relationship hdb_relationship_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);


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
-- Name: event_log_created_at_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_log_created_at_idx ON hdb_catalog.event_log USING btree (created_at);


--
-- Name: event_log_delivered_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_log_delivered_idx ON hdb_catalog.event_log USING btree (delivered);


--
-- Name: event_log_locked_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_log_locked_idx ON hdb_catalog.event_log USING btree (locked);


--
-- Name: event_log_trigger_name_idx; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE INDEX event_log_trigger_name_idx ON hdb_catalog.event_log USING btree (trigger_name);


--
-- Name: hdb_schema_update_event_one_row; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE UNIQUE INDEX hdb_schema_update_event_one_row ON hdb_catalog.hdb_schema_update_event USING btree (((occurred_at IS NOT NULL)));


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: hasurauser
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_schema_update_event hdb_schema_update_event_notifier; Type: TRIGGER; Schema: hdb_catalog; Owner: hasurauser
--

CREATE TRIGGER hdb_schema_update_event_notifier AFTER INSERT OR UPDATE ON hdb_catalog.hdb_schema_update_event FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_schema_update_event_notifier();


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
-- Name: hdb_action_permission hdb_action_permission_action_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_action_permission
    ADD CONSTRAINT hdb_action_permission_action_name_fkey FOREIGN KEY (action_name) REFERENCES hdb_catalog.hdb_action(action_name) ON UPDATE CASCADE;


--
-- Name: hdb_allowlist hdb_allowlist_collection_name_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_allowlist
    ADD CONSTRAINT hdb_allowlist_collection_name_fkey FOREIGN KEY (collection_name) REFERENCES hdb_catalog.hdb_query_collection(collection_name);


--
-- Name: hdb_computed_field hdb_computed_field_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: hasurauser
--

ALTER TABLE ONLY hdb_catalog.hdb_computed_field
    ADD CONSTRAINT hdb_computed_field_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name) ON UPDATE CASCADE;


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

-- 
-- Change the access to hdb_catalog tables
-- 

REVOKE ALL ON hdb_catalog.hdb_table FROM hasurauser;
GRANT SELECT ON hdb_catalog.hdb_table TO hasurauser;


REVOKE ALL ON hdb_catalog.hdb_relationship FROM hasurauser;
GRANT SELECT ON hdb_catalog.hdb_relationship TO hasurauser;


REVOKE ALL ON hdb_catalog.hdb_permission FROM hasurauser;
GRANT SELECT ON hdb_catalog.hdb_permission TO hasurauser;


REVOKE ALL ON hdb_catalog.remote_schemas FROM hasurauser;
GRANT SELECT ON hdb_catalog.remote_schemas TO hasurauser;


REVOKE ALL ON hdb_catalog.hdb_action FROM hasurauser;
GRANT SELECT ON hdb_catalog.hdb_action TO hasurauser;


REVOKE ALL ON hdb_catalog.event_triggers FROM hasurauser;
GRANT SELECT ON hdb_catalog.event_triggers TO hasurauser;

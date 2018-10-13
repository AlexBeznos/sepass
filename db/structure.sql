--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.9
-- Dumped by pg_dump version 9.6.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: set_uniq_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_uniq_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN
          IF (TG_OP = 'UPDATE') THEN
            NEW."id" := OLD."id";
          ELSIF (TG_OP = 'INSERT') THEN
            NEW."id" := concat(uuid_generate_v4(), '-', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 100000);
          END IF;
          RETURN NEW;
        END;
      $$;


--
-- Name: trigger_set_created_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_created_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$        BEGIN
          IF (TG_OP = 'UPDATE') THEN
            NEW."created_at" := OLD."created_at";
          ELSIF (TG_OP = 'INSERT') THEN
            NEW."created_at" := CURRENT_TIMESTAMP;
          END IF;
          RETURN NEW;
        END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    data json NOT NULL,
    type text NOT NULL,
    status text NOT NULL,
    created_at timestamp without time zone,
    secret_id text
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    filename text NOT NULL
);


--
-- Name: secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secrets (
    id text NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    expiration_date timestamp without time zone NOT NULL,
    secret text,
    created_at timestamp without time zone
);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (id);


--
-- Name: secrets set_created_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_created_at BEFORE INSERT OR UPDATE ON public.secrets FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_created_at();


--
-- Name: events set_created_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_created_at BEFORE INSERT OR UPDATE ON public.events FOR EACH ROW EXECUTE PROCEDURE public.trigger_set_created_at();


--
-- Name: secrets set_uniq_id_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_uniq_id_trigger BEFORE INSERT OR UPDATE ON public.secrets FOR EACH ROW EXECUTE PROCEDURE public.set_uniq_id();


--
-- Name: events events_secret_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_secret_id_fkey FOREIGN KEY (secret_id) REFERENCES public.secrets(id);


--
-- PostgreSQL database dump complete
--

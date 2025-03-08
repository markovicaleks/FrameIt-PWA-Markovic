--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

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

SET default_table_access_method = heap;

--
-- Name: videos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.videos (
    id integer NOT NULL,
    title character varying(255),
    description text,
    note text,
    place character varying(255),
    city character varying(100),
    country character varying(100),
    continent character varying(100),
    gps_latitude numeric(10,7),
    gps_longitude numeric(10,7),
    persons text[],
    "timestamp" timestamp without time zone,
    trip character varying(255),
    video bytea
);


ALTER TABLE public.videos OWNER TO postgres;

--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.videos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.videos_id_seq OWNER TO postgres;

--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;


--
-- Name: videos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);


--
-- Data for Name: videos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.videos (id, title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, "timestamp", trip, video) FROM stdin;
1	Sonnenaufgang am Strand	Ein wunderschöner Sonnenaufgang mit sanften Wellen.	Das Licht war unglaublich!	Strand von Malibu	Malibu	USA	Nordamerika	34.0259000	-118.7798000	{Anna,Max}	2025-01-15 06:30:00	USA-Roadtrip 2025	\N
2	Wandern in den Alpen	Eine anstrengende, aber lohnenswerte Wanderung auf 2000m Höhe.	Die Aussicht auf die Berge war fantastisch.	Berchtesgadener Alpen	Berchtesgaden	Deutschland	Europa	47.6333000	12.9969000	{Lisa,Tom}	2024-08-10 10:15:00	Alpen-Trekking Sommer 2024	\N
3	Street Food in Bangkok	Probieren von verschiedenen Gerichten auf dem Nachtmarkt.	Besonders das Pad Thai war köstlich.	Bangkok Nachtmarkt	Bangkok	Thailand	Asien	13.7563000	100.5018000	{Jonas,Emma}	2024-11-20 19:45:00	Südostasien-Erkundung 2024	\N
4	Safari in der Serengeti	Löwenrudel in der Abendsonne gesehen.	Unvergessliches Erlebnis, so nah an der Natur.	Serengeti Nationalpark	Arusha	Tansania	Afrika	-2.3333000	34.8333000	{Mia,Paul}	2024-05-12 17:50:00	Afrika-Abenteuer 2024	\N
5	Pariser Nächte	Spaziergang entlang der Seine mit Blick auf den beleuchteten Eiffelturm.	Die Atmosphäre war so romantisch.	Eiffelturm und Seine	Paris	Frankreich	Europa	48.8584000	2.2945000	{Sophie,Lukas}	2025-01-01 21:30:00	Silvester in Europa 2025	\N
6	Tauchen am Great Barrier Reef	Entdeckung der atemberaubenden Unterwasserwelt.	Die Korallen waren bunt und lebendig.	Great Barrier Reef	Cairns	Australien	Ozeanien	-16.9186000	145.7781000	{Markus,Laura}	2024-09-05 08:45:00	Australien-Tauchreise 2024	\N
\.


--
-- Name: videos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.videos_id_seq', 6, true);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--


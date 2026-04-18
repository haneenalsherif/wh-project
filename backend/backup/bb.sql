--
-- PostgreSQL database dump
--

\restrict PPSIBDxyZPiyKbltWKKe8vg4YVdqENpzGl67b56rAtLLNabfPhdpFtRtawVbF5J

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

-- Started on 2026-04-15 02:23:47

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- TOC entry 230 (class 1259 OID 16486)
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    user_id integer,
    title character varying(100) NOT NULL,
    details text NOT NULL,
    lat numeric(10,7),
    lng numeric(10,7),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16485)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.addresses_id_seq OWNER TO postgres;

--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 229
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- TOC entry 222 (class 1259 OID 16411)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    store_id integer
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16410)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 221
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 226 (class 1259 OID 16444)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    product_name character varying(100) NOT NULL,
    price numeric(10,2) NOT NULL,
    qty integer NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16443)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 224 (class 1259 OID 16428)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_name character varying(100) NOT NULL,
    customer_phone character varying(30) NOT NULL,
    customer_address text NOT NULL,
    store_id integer,
    total_price numeric(10,2) NOT NULL,
    status character varying(30) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_method character varying(30),
    delivery_note text,
    user_id integer
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16427)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 220 (class 1259 OID 16397)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price numeric(6,2) NOT NULL,
    image text,
    store_id integer,
    category_key character varying(50),
    category_id integer
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16396)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 219
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 218 (class 1259 OID 16388)
-- Name: stores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stores (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(30) NOT NULL,
    delivery_fee numeric(6,2) NOT NULL,
    image text NOT NULL,
    page character varying(100) NOT NULL
);


ALTER TABLE public.stores OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16387)
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stores_id_seq OWNER TO postgres;

--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 217
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- TOC entry 228 (class 1259 OID 16474)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    phone character varying(30) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reset_token text,
    reset_expires timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16473)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4781 (class 2604 OID 16489)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 16414)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4778 (class 2604 OID 16447)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4775 (class 2604 OID 16431)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4773 (class 2604 OID 16400)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 16391)
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- TOC entry 4779 (class 2604 OID 16477)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4967 (class 0 OID 16486)
-- Dependencies: 230
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.addresses (id, user_id, title, details, lat, lng, created_at) FROM stdin;
2	3	البيت	مم	32.3829960	15.0974460	2026-04-14 01:21:40.400818
3	3	work	vdsvsdvds	32.3829960	15.0974460	2026-04-14 17:33:13.830121
4	3	wwww	hjh	32.3829960	15.0974460	2026-04-14 17:45:52.822799
5	5	عملي	نمنمي	32.3829960	15.0974460	2026-04-14 23:46:31.567359
\.


--
-- TOC entry 4959 (class 0 OID 16411)
-- Dependencies: 222
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, store_id) FROM stdin;
1	مشروبات	1
2	مأكولات	1
3	حلويات	1
4	أدوية السعال	2
5	غسول	2
6	مضاد حيوي	2
7	أطفال	2
8	الجهاز الهضمي	2
9	المسكنات وخافض الحرارة كبار	2
\.


--
-- TOC entry 4963 (class 0 OID 16444)
-- Dependencies: 226
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, product_name, price, qty) FROM stdin;
1	1	\N	فرابتشينو	12.00	4
2	2	\N	فرابتشينو	12.00	1
3	2	\N	قهوة ساخنة	8.00	1
4	3	\N	فرابتشينو	12.00	1
5	3	\N	قهوة ساخنة	8.00	1
6	4	\N	فرابتشينو	12.00	2
7	5	\N	فرابتشينو	12.00	2
8	6	\N	فرابتشينو	12.00	3
9	7	\N	فرابتشينو	12.00	4
10	8	\N	فرابتشينو	12.00	2
11	9	\N	فرابتشينو	12.00	3
12	10	\N	فرابتشينو	12.00	2
13	11	\N	فرابتشينو	12.00	3
\.


--
-- TOC entry 4961 (class 0 OID 16428)
-- Dependencies: 224
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, customer_name, customer_phone, customer_address, store_id, total_price, status, created_at, payment_method, delivery_note, user_id) FROM stdin;
1	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	48.00	pending	2026-04-13 23:17:07.712307	\N	\N	\N
2	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	20.00	pending	2026-04-13 23:22:40.884756	\N	\N	\N
3	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	20.00	pending	2026-04-13 23:29:12.746568	\N	\N	\N
4	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	24.00	pending	2026-04-13 23:56:08.430212	\N	\N	\N
5	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	24.00	pending	2026-04-13 23:56:57.319747	\N	\N	\N
6	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	36.00	pending	2026-04-13 23:59:34.286728	\N	\N	\N
7	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	48.00	pending	2026-04-14 00:12:20.0183	cash		\N
8	مستخدم	000000000	الدائري الثالث، بالقرب من جزيرة المهمل	1	24.00	pending	2026-04-14 00:13:13.916384	cash	bared	\N
9	aml abdullah	0922909170	تم تحديد موقعي الحالي بنجاح	1	36.00	pending	2026-04-14 18:11:24.415585	card		\N
10	aml abdullah	0922909170	تم تحديد موقعي الحالي بنجاح	1	24.00	pending	2026-04-14 19:32:08.358489	cash		4
11	اسماء احمد	0922909150	نمنمي	1	36.00	pending	2026-04-14 23:47:56.754743	card	اتلو	5
\.


--
-- TOC entry 4957 (class 0 OID 16397)
-- Dependencies: 220
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, price, image, store_id, category_key, category_id) FROM stdin;
1	آيس لاتيه الجديد	قهوة باردة كريمية ومنعشة	10.00	https://images.unsplash.com/photo-1509042239860-f550ce710b93	1	\N	\N
9	بخاخ أنف	لتخفيف الاحتقان وفتح مجرى التنفس.	8.00	https://images.unsplash.com/photo-1628771065518-0d82f1938462?q=80&w=500&auto=format&fit=crop	2	cough	\N
10	حبوب للبرد	مناسبة لتخفيف أعراض البرد والاحتقان.	12.00	https://images.unsplash.com/photo-1580281657527-47c17e7d55b2?q=80&w=500&auto=format&fit=crop	2	cough	\N
15	غسول بشرة	للاستخدام اليومي وتنظيف الوجه بلطف.	12.00	https://images.unsplash.com/photo-1556228578-8c89e6adf883?q=80&w=500&auto=format&fit=crop	2	wash	\N
16	غسول مطهر	مناسب للعناية والنظافة اليومية.	10.00	https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=500&auto=format&fit=crop	2	wash	\N
2	فرابتشينو	مشروب بارد غني بالكريمة	12.00	https://images.unsplash.com/photo-1495474472287	1	\N	1
8	شراب سعال	يساعد على تهدئة السعال وتقليل التهيج.	10.00	https://images.unsplash.com/photo-1584017911766-d451b3d0e843?q=80&w=500&auto=format&fit=crop	2	cough	4
14	غسول طبي	غسول لطيف ومناسب للبشرة الحساسة.	14.00	https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=500&auto=format&fit=crop	2	wash	5
20	مضاد حيوي A	منتج دوائي شائع ضمن هذه الفئة.	18.00	https://images.unsplash.com/photo-1580281657527-47c17e7d55b2?q=80&w=500&auto=format&fit=crop	2	antibiotic	6
21	مضاد حيوي B	خيار آخر ضمن المضادات الحيوية المتوفرة.	20.00	https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=500&auto=format&fit=crop	2	antibiotic	6
22	مضاد حيوي C	منتج إضافي متوفر ضمن نفس الفئة.	16.00	https://images.unsplash.com/photo-1628771065518-0d82f1938462?q=80&w=500&auto=format&fit=crop	2	antibiotic	6
5	باراسيتامول أطفال	شراب مناسب للأطفال لتخفيف الحرارة والآلام.	5.00	https://images.unsplash.com/photo-1584515933487-779824d29309?q=80&w=500&auto=format&fit=crop	2	pain-kids	7
6	خافض حرارة للأطفال	شراب لطيف للأطفال لتخفيف الحرارة والآلام.	11.00	https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=500&auto=format&fit=crop	2	pain-kids	7
7	شراب آلام الأطفال	مناسب للاستخدام اليومي عند الحاجة.	8.00	https://images.unsplash.com/photo-1628771065518-0d82f1938462?q=80&w=500&auto=format&fit=crop	2	pain-kids	7
17	دواء معدة	يساعد في تهدئة المعدة وتحسين الراحة.	11.00	https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?q=80&w=500&auto=format&fit=crop	2	digestive	8
18	مضاد حموضة	لتقليل الحموضة والانزعاج بعد الأكل.	9.00	https://images.unsplash.com/photo-1616671276441-2f2c277b8bf1?q=80&w=500&auto=format&fit=crop	2	digestive	8
19	حبوب هضم	تساعد في تحسين الهضم بعد الوجبات.	7.00	https://images.unsplash.com/photo-1580281657527-47c17e7d55b2?q=80&w=500&auto=format&fit=crop	2	digestive	8
23	قهوة ساخنة	قهوة دافئة بطعم غني وهادئ.	8.00	images/dolce2.jpg.jpg	1	\N	1
24	لازانيا	طبق ساخن غني بالجبن والصلصة.	18.00	images/dolce4.jpg.jpg	1	\N	2
25	بيتزا	بيتزا طازجة بمكونات شهية.	20.00	images/dolce5.jpg.jpg	1	\N	2
26	سندوتش خفيف	وجبة خفيفة وسريعة مناسبة في أي وقت.	14.00	images/dolce6.jpg.jpg	1	\N	2
27	كيك شوكولاتة	كيك غني بطبقات الشوكولاتة الطرية.	12.00	images/dolce7.jpg.jpg	1	\N	3
28	حلو اليوم	قطعة حلو خاصة بتقديم أنيق.	9.00	images/dolce9.jpg.jpg	1	\N	3
3	باراسيتامول	مسكن وخافض حرارة	5.00	https://images.unsplash.com/photo-1587854692152	2	pain-adults	9
4	إيبوبروفين	مضاد التهاب ومسكن	8.00	https://images.unsplash.com/photo-1584308666744	2	pain-adults	9
11	باراسيتامول	مسكن وخافض حرارة مناسب للاستخدام اليومي.	5.00	https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=500&auto=format&fit=crop	2	pain-adults	9
12	إيبوبروفين	مضاد التهاب ومسكن فعال للصداع وآلام الجسم.	8.00	https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=500&auto=format&fit=crop	2	pain-adults	9
13	شرائط لاصقة مسكنة	للاستخدام الموضعي لتخفيف الألم في العضلات والمفاصل.	9.00	https://images.unsplash.com/photo-1628771065518-0d82f1938462?q=80&w=500&auto=format&fit=crop	2	pain-adults	9
\.


--
-- TOC entry 4955 (class 0 OID 16388)
-- Dependencies: 218
-- Data for Name: stores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stores (id, name, type, delivery_fee, image, page) FROM stdin;
2	صيدلية أوميقا	pharmacy	3.00	https://images.unsplash.com/photo-1587854692152-cbe660dbde88?q=80&w=1200&auto=format&fit=crop	omega.html
3	برجر هاوس	restaurant	2.00	https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1200&auto=format&fit=crop	burger.html
1	دولشي الجديدة	cafe	0.75	https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=1200&auto=format&fit=crop	dolce.html
\.


--
-- TOC entry 4965 (class 0 OID 16474)
-- Dependencies: 228
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, phone, email, password, created_at, reset_token, reset_expires) FROM stdin;
2	حنين نورالدين	0912909122	hanen.sh72@gmail.com	$2b$10$yFRNPKrTFSCmUTM27XEDKOPfUp2s.zlXIBdtxVa35ErERVnjG0jva	2026-04-14 00:38:12.427782	\N	\N
3	حنين محمد الشريف	0921208031	hanen.sh@gmail.com	$2b$10$hL.2ovgVQU4GJBb9U3hhWO1n6bpthfGdmFG/LouMOG58DiYmwNXKK	2026-04-14 00:48:48.954463	\N	\N
4	aml abdullah	0922909170	han.sh@gmail.com	$2b$10$QXakOiu6tHYcWKYkn03tIuqp51BWRt7tWbbpKnAs0VjZboQGPEJ1C	2026-04-14 18:09:32.988383	\N	\N
1	حنين نورالدين	0912909125	hanen.sh722003@gmail.com	123456789	2026-04-14 00:32:33.441829	\N	\N
5	اسماء احمد محمد	0922909160	hanen.003@gmail.com	$2b$10$g7zdguLZoClSX1meovYHjuAJIrkNDASPuiTfxkWrvbHj7f.6/WnG6	2026-04-14 23:45:35.757302	\N	\N
\.


--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 229
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.addresses_id_seq', 5, true);


--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 221
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 9, true);


--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 13, true);


--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 11, true);


--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 219
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 28, true);


--
-- TOC entry 4985 (class 0 OID 0)
-- Dependencies: 217
-- Name: stores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stores_id_seq', 3, true);


--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 227
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- TOC entry 4800 (class 2606 OID 16494)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 4788 (class 2606 OID 16416)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 16449)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 16437)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 16404)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4784 (class 2606 OID 16395)
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- TOC entry 4794 (class 2606 OID 16484)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4796 (class 2606 OID 16482)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4798 (class 2606 OID 16480)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4808 (class 2606 OID 16495)
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4803 (class 2606 OID 16417)
-- Name: categories categories_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- TOC entry 4806 (class 2606 OID 16450)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 4807 (class 2606 OID 16455)
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 4804 (class 2606 OID 16438)
-- Name: orders orders_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);


--
-- TOC entry 4805 (class 2606 OID 16500)
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4801 (class 2606 OID 16422)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- TOC entry 4802 (class 2606 OID 16405)
-- Name: products products_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);


-- Completed on 2026-04-15 02:23:47

--
-- PostgreSQL database dump complete
--

\unrestrict PPSIBDxyZPiyKbltWKKe8vg4YVdqENpzGl67b56rAtLLNabfPhdpFtRtawVbF5J


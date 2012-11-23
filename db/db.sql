CREATE TABLE comments (
    id serial,
    quote integer,
    person integer,
    comment text
);

CREATE TABLE people (
    id serial,
    name character varying(50),
    avatar character varying(255)
);

CREATE TABLE quotes (
    id serial,
    person integer,
    comment text,
    quote_date timestamp without time zone,
    posted_by integer
);
-- PostgreSQL installieren mit Homebrew
-- postgres Serverstart:
-- pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
-- Serverstop:
-- pg_ctl -D /usr/local/var/postgres stop -s -m fast
-- später: http://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/


CREATE DATABASE schnuerchen_dev;
-- CREATE DATABASE schnuerchen_test;
-- eigentlich reicht schnuerchen_dev erstmal auch

DROP TABLE user_trophies;
DROP TABLE trophies;
DROP TABLE scores;
DROP TABLE games;
DROP TABLE gamecategories;
DROP TABLE scoretypes;
DROP TABLE users;

CREATE TABLE users (
	u_id		SERIAL PRIMARY KEY,
	username	VARCHAR(30) NOT NULL UNIQUE,
	firstname	VARCHAR(30) NOT NULL,
	email		VARCHAR(30) NOT NULL UNIQUE,
	password	VARCHAR(30) NOT NULL
);

-- bestimmt, ob scores.score Zeit oder Punkte sind - Lieber CHECK bei games.scoretype?
CREATE TABLE scoretypes (
	st_id		SERIAL PRIMARY KEY,
	descr		VARCHAR(20)
);

-- Add, Subtr, Mult, Div, Mix
CREATE TABLE gamecategories (
	gc_id		SERIAL PRIMARY KEY,
	descr		VARCHAR(20)
);

-- noch eine für Subcat.?

CREATE TABLE games (
	g_id		SERIAL PRIMARY KEY,
	name 		VARCHAR(30) NOT NULL,
	category	SERIAL REFERENCES gamecategories (gc_id),
	scoretype	SERIAL REFERENCES scoretypes (st_id)
);

CREATE TABLE scores (
	s_id 		SERIAL PRIMARY KEY,
	u_id		SERIAL REFERENCES users (u_id),
	g_id		SERIAL REFERENCES games (g_id),
	timestamp	TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
	score 		INTEGER NOT NULL,
	UNIQUE (u_id, g_id, timestamp)
);

CREATE TABLE trophies (
	t_id		SERIAL PRIMARY KEY,
	game		SERIAL REFERENCES games (g_id),
	min_score  	INTEGER NOT NULL,
	pod			INTEGER,
	CHECK (pod <= 3)
);

CREATE TABLE user_trophies (
	u_id		SERIAL REFERENCES users (u_id),
	t_id		SERIAL REFERENCES trophies (t_id),
	s_id 		SERIAL REFERENCES scores (s_id),
	UNIQUE (u_id, t_id)
);

-- TODO: Trigger, dass a & b nicht zweimal vertauscht drinstehen können
-- CREATE TABLE friendships (
-- 	user_a		SERIAL REFERENCES users,
-- 	user_b		SERIAL REFERENCES users,
-- 	UNIQUE (user_a, user_b),
-- 	CHECK (user_a != user_b)
-- );










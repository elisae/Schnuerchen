-- PostgreSQL installieren mit Homebrew
-- postgres Serverstart:
-- pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
-- Serverstop:
-- pg_ctl -D /usr/local/var/postgres stop -s -m fast
-- später: http://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/


CREATE DATABASE schnuerchen_dev;
-- CREATE DATABASE schnuerchen_test;
-- eigentlich reicht schnuerchen_dev erstmal auch
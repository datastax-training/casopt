CREATE KEYSPACE IF NOT EXISTS casopt WITH replication = {'class':'SimpleStrategy', 'replication_factor':3};
CREATE TABLE IF NOT EXISTS casopt.addressinfo (id int PRIMARY KEY, firstname text, lastname text, company text, address text, city text, county text, state text, zip text,homephone text,workphone text,email text,web text) with compression = {};
CREATE index IF NOT EXISTS state_address on casopt.addressinfo (state);
COPY casopt.addressinfo (id, firstname, lastname,  company,address, city, county, state, zip, homephone,workphone, email, web) FROM 'sample-data.csv' WITH HEADER=true;

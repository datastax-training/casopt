create table users (id bigint primary key,
name text,
screen_name text,
description text,
url text,
lang text,
location text,
urls set<text>);

CREATE TABLE trades (
  trade_id int,
  description text,
  exchng text,
  price float,
  quantity int,
  extra_id uuid,
  ticker text,
  trade_date timestamp,
  trade_timestamp timestamp,
  company_name text,
  PRIMARY KEY (trade_id)
);

CREATE TABLE trades_by_tickerday (
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
  PRIMARY KEY ((ticker, trade_date), trade_timestamp,trade_id)
);

-- CREATE DATABASE config_parser;

-- -- USE config_parser;

CREATE ROLE config_parser WITH LOGIN PASSWORD 'asdkqwsd123';

CREATE EXTENSION IF NOT EXISTS citext;

ALTER DATABASE config_parser OWNER TO config_parser;
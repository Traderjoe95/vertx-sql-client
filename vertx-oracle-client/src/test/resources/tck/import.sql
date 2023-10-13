ALTER SESSION SET CONTAINER=FREEPDB1;

CREATE TABLE World
(
  id           INTEGER           NOT NULL,
  randomNumber INTEGER DEFAULT 0 NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO World (id, randomNumber)
SELECT Rownum r, dbms_random.value
FROM dual
CONNECT BY Rownum <= 100;

-- Fortune Table
CREATE TABLE Fortune
(
    id      integer GENERATED by default on null as IDENTITY,
    message varchar(2048),
    PRIMARY KEY (id)
);
INSERT INTO Fortune (message)
VALUES ('fortune: No such file or directory');
INSERT INTO Fortune (message)
VALUES ('A computer scientist is someone who fixes things that are not broken.');
INSERT INTO Fortune (message)
VALUES ('After enough decimal places, nobody gives a damn.');
INSERT INTO Fortune (message)
VALUES ('A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1');
INSERT INTO Fortune (message)
VALUES ('A computer program does what you tell it to do, not what you want it to do.');
INSERT INTO Fortune (message)
VALUES ('Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen');
INSERT INTO Fortune (message)
VALUES ('Any program that runs right is obsolete.');
INSERT INTO Fortune (message)
VALUES ('A list is only as strong as its weakest link. — Donald Knuth');
INSERT INTO Fortune (message)
VALUES ('Feature: A bug with seniority.');
INSERT INTO Fortune (message)
VALUES ('Computers make very fast, very accurate mistakes.');
INSERT INTO Fortune (message)
VALUES ('<script>alert("This should not be displayed in a browser alert box.");</script>');
INSERT INTO Fortune (message)
VALUES ('フレームワークのベンチマーク');

-- immutable table for select query testing --
-- used by TCK

CREATE TABLE immutable
(
    id      integer       NOT NULL,
    message varchar(2048) NOT NULL,
    PRIMARY KEY (id)
);
INSERT INTO immutable (id, message)
VALUES (1, 'fortune: No such file or directory');
INSERT INTO immutable (id, message)
VALUES (2, 'A computer scientist is someone who fixes things that aren''t broken.');
INSERT INTO immutable (id, message)
VALUES (3, 'After enough decimal places, nobody gives a damn.');
INSERT INTO immutable (id, message)
VALUES (4, 'A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1');
INSERT INTO immutable (id, message)
VALUES (5, 'A computer program does what you tell it to do, not what you want it to do.');
INSERT INTO immutable (id, message)
VALUES (6, 'Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen');
INSERT INTO immutable (id, message)
VALUES (7, 'Any program that runs right is obsolete.');
INSERT INTO immutable (id, message)
VALUES (8, 'A list is only as strong as its weakest link. — Donald Knuth');
INSERT INTO immutable (id, message)
VALUES (9, 'Feature: A bug with seniority.');
INSERT INTO immutable (id, message)
VALUES (10, 'Computers make very fast, very accurate mistakes.');
INSERT INTO immutable (id, message)
VALUES (11, '<script>alert("This should not be displayed in a browser alert box.");</script>');
INSERT INTO immutable (id, message)
VALUES (12, 'フレームワークのベンチマーク');

-- mutable for insert,update,delete query testing --
-- used by TCK
CREATE TABLE mutable
(
    id  integer       NOT NULL,
    val varchar(2048) NOT NULL,
    PRIMARY KEY (id)
);

-- Collector API testing
CREATE TABLE test_collector
(
  id           INT,
  test_int_2   SMALLINT,
  test_int_4   INT,
  test_int_8   CLOB,
  test_float   FLOAT,
  test_double  NUMBER,
  test_varchar VARCHAR(20)
);

INSERT INTO test_collector
VALUES (1, 32767, 2147483647, 9223372036854775807, 123.456, 1.234567, 'HELLO,WORLD');
INSERT INTO test_collector
VALUES (2, 32767, 2147483647, 9223372036854775807, 123.456, 1.234567, 'hello,world');

CREATE TABLE basicdatatype
(
  id           INT,
  test_int_2   SMALLINT,
  test_int_4   INT,
  test_int_8   NUMBER(19),
  test_float_4 FLOAT(23),
  test_numeric NUMBER(5, 2),
  test_decimal DECIMAL,
  test_char    CHAR(8),
  test_varchar VARCHAR(20),
  test_date    DATE
);
INSERT INTO basicdatatype(id, test_int_2, test_int_4, test_int_8, test_float_4, test_numeric,
                          test_decimal, test_char, test_varchar, test_date)
VALUES (1, 32767, 2147483647, 9223372036854775807, 3.40282E38, 999.99,
        12345, 'testchar', 'testvarchar', TO_DATE('2019-01-01', 'YYYY-MM-DD'));
INSERT INTO basicdatatype(id, test_int_2, test_int_4, test_int_8, test_float_4, test_numeric,
                          test_decimal, test_char, test_varchar, test_date)
VALUES ('2', '32767', '2147483647', '9223372036854775807', '3.40282E38', '999.99',
        '12345', 'testchar', 'testvarchar', TO_DATE('2019-01-01', 'YYYY-MM-DD'));
INSERT INTO basicdatatype(id, test_int_2, test_int_4, test_int_8, test_float_4, test_numeric,
                          test_decimal, test_char, test_varchar, test_date)
VALUES (3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

CREATE TABLE binary_data_types
(
  id        INT,
  test_raw  RAW(255),
  test_blob BLOB
);
INSERT INTO binary_data_types(id, test_raw, test_blob)
VALUES (1, UTL_RAW.CAST_TO_RAW('See you space cowboy...'), UTL_RAW.CAST_TO_RAW('See you space cowboy...'));
INSERT INTO binary_data_types(id, test_raw, test_blob)
VALUES (2, UTL_RAW.CAST_TO_RAW('See you space cowboy...'), UTL_RAW.CAST_TO_RAW('See you space cowboy...'));
INSERT INTO binary_data_types(id, test_raw, test_blob)
VALUES (3, NULL, NULL);

CREATE TABLE temporal_data_types
(
  id                           INT,
  test_date                    DATE,
  test_timestamp               TIMESTAMP,
  test_timestamp_with_timezone TIMESTAMP WITH TIME ZONE
);
INSERT INTO temporal_data_types(id, test_date, test_timestamp, test_timestamp_with_timezone)
VALUES (1, date '2019-11-04', timestamp '2018-11-04 15:13:28', timestamp '2019-11-04 15:13:28 +01:02');
INSERT INTO temporal_data_types(id, test_date, test_timestamp, test_timestamp_with_timezone)
VALUES (2, date '2019-11-04', timestamp '2018-11-04 15:13:28', timestamp '2019-11-04 15:13:28 +01:02');
INSERT INTO temporal_data_types(id, test_date, test_timestamp, test_timestamp_with_timezone)
VALUES (3, NULL, NULL, NULL);

-- No response reproducer

CREATE TABLE passenger
(
  id             NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nif            VARCHAR(15) NOT NULL,
  name           VARCHAR(25) NOT NULL,
  last_name      VARCHAR(55) NOT NULL,
  contact_number VARCHAR(20) NOT NULL,
  created_at     INT         NOT NULL,
  updated_at     INT,
  address_id     NUMBER
);

-- Don't forget to commit...
COMMIT;

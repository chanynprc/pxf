
-----------------------------------------------------
------ Check that Filter Push Down is working -------
-----------------------------------------------------

-- Check that the filter is being pushed down. We create an external table
-- that returns the filter being sent from the C-side

DROP EXTERNAL TABLE IF EXISTS test_filter CASCADE;

CREATE EXTERNAL TABLE test_filter (t0 text, a1 integer, b2 boolean, c3 numeric, d4 char(2), e5 varchar(2), filterValue text)
    LOCATION (E'pxf://dummy_path?PROFILE=system:filter')
    FORMAT 'CSV';

----------------------------------------------------
------ Check that Filter Push Down is enabled ------
----------------------------------------------------
SET gp_external_enable_filter_pushdown = true;

-- control - no predicates
SELECT * FROM test_filter;

SET optimizer = off;

-- test logical predicates
SELECT * FROM test_filter WHERE  t0 = 'B' AND a1 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND a1 = 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND a1 <= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND (a1 = 2 OR a1 = 10) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' OR (a1 >= 0 AND a1 <= 2) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  b2 = false ORDER BY t0, a1;
SELECT t0, a1, filtervalue FROM test_filter WHERE a1 < 5 AND b2 = false ORDER BY t0, a1;
SELECT round(sqrt(a1)::numeric,5), filtervalue FROM test_filter WHERE a1 < 5 AND b2 = false ORDER BY t0, a1;
SELECT round(sqrt(a1)::numeric,5), filtervalue FROM test_filter WHERE b2 = false ORDER BY t0;
SELECT * FROM test_filter WHERE  b2 = false AND (a1 = 3 OR a1 = 10) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  b2 = false OR (a1 >= 0 AND a1 <= 2) ORDER BY t0, a1;

-- test text predicates
SELECT * FROM test_filter WHERE  t0 =  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 =  'C ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <= 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 >  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 >= 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <> 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 LIKE     'C%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT LIKE 'C%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IN     ('C','D') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT IN ('C','D') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 BETWEEN     'B' AND 'D' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT BETWEEN 'B' AND 'D' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IS NOT NULL ORDER BY t0, a1;

-- test integer predicates
SELECT * FROM test_filter WHERE  a1 =  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 >  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 >= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <> 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IN     (2,3) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 NOT IN (2,3) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 BETWEEN     2 AND 4 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 NOT BETWEEN 2 AND 4 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IS NOT NULL ORDER BY t0, a1;

-- test numeric predicates
SELECT * FROM test_filter WHERE  c3 =  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <= 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 >  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 >= 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <> 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IN     (1.11,2.21) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 NOT IN (1.11,2.21) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 BETWEEN     1.11 AND 4.41 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 NOT BETWEEN 1.11 AND 4.41 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IS NOT NULL ORDER BY t0, a1;

-- test char predicates
SELECT * FROM test_filter WHERE  d4 =  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 =  'BB ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 >  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 >= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <> 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 LIKE     'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT LIKE 'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IN     ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT IN ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 BETWEEN     'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT BETWEEN 'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IS NOT NULL ORDER BY t0, a1;

-- test varchar predicates
SELECT * FROM test_filter WHERE  e5 =  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 =  'BB ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 >  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 >= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <> 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 LIKE     'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT LIKE 'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IN     ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT IN ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 BETWEEN     'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT BETWEEN 'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IS NOT NULL ORDER BY t0, a1;

SET optimizer = on;

-- test logical predicates
SELECT * FROM test_filter WHERE  t0 = 'B' AND a1 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND a1 = 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND a1 <= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' AND (a1 = 2 OR a1 = 10) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 = 'C' OR (a1 >= 0 AND a1 <= 2) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  b2 = false ORDER BY t0, a1;
SELECT t0, a1, filtervalue FROM test_filter WHERE a1 < 5 AND b2 = false ORDER BY t0, a1;
SELECT round(sqrt(a1)::numeric,5), filtervalue FROM test_filter WHERE a1 < 5 AND b2 = false ORDER BY t0, a1;
SELECT round(sqrt(a1)::numeric,5), filtervalue FROM test_filter WHERE b2 = false ORDER BY t0;
SELECT * FROM test_filter WHERE  b2 = false AND (a1 = 3 OR a1 = 10) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  b2 = false OR (a1 >= 0 AND a1 <= 2) ORDER BY t0, a1;

-- test text predicates
SELECT * FROM test_filter WHERE  t0 =  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 =  'C ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <= 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 >  'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 >= 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 <> 'C' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 LIKE     'C%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT LIKE 'C%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IN     ('C','D') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT IN ('C','D') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 BETWEEN     'B' AND 'D' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 NOT BETWEEN 'B' AND 'D' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  t0 IS NOT NULL ORDER BY t0, a1;

-- test integer predicates
SELECT * FROM test_filter WHERE  a1 =  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 >  2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 >= 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 <> 2 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IN     (2,3) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 NOT IN (2,3) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 BETWEEN     2 AND 4 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 NOT BETWEEN 2 AND 4 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  a1 IS NOT NULL ORDER BY t0, a1;

-- test numeric predicates
SELECT * FROM test_filter WHERE  c3 =  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <= 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 >  1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 >= 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 <> 1.11 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IN     (1.11,2.21) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 NOT IN (1.11,2.21) ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 BETWEEN     1.11 AND 4.41 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 NOT BETWEEN 1.11 AND 4.41 ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  c3 IS NOT NULL ORDER BY t0, a1;

-- test char predicates
SELECT * FROM test_filter WHERE  d4 =  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 =  'BB ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 >  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 >= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 <> 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 LIKE     'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT LIKE 'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IN     ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT IN ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 BETWEEN     'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 NOT BETWEEN 'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  d4 IS NOT NULL ORDER BY t0, a1;

-- test varchar predicates
SELECT * FROM test_filter WHERE  e5 =  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 =  'BB ' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 >  'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 >= 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 <> 'BB' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 LIKE     'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT LIKE 'B%' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IN     ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT IN ('BB','CC') ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 BETWEEN     'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 NOT BETWEEN 'AA' AND 'CC' ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IS NULL ORDER BY t0, a1;
SELECT * FROM test_filter WHERE  e5 IS NOT NULL ORDER BY t0, a1;

-----------------------------------------------------
------ Check that Filter Push Down is disabled ------
-----------------------------------------------------

-- Now let's make sure nothing gets pushed down when we disable the
-- gp_external_enable_filter_pushdown guc

SET gp_external_enable_filter_pushdown = off;

SET optimizer = off;
SELECT * FROM test_filter WHERE t0 = 'J' AND a1 = 9 AND b2 = false AND c3 = 9.91 AND d4 = 'JJ' AND e5 = 'JJ' ORDER BY t0, a1;

SET optimizer = on;
SELECT * FROM test_filter WHERE t0 = 'J' AND a1 = 9 AND b2 = false AND c3 = 9.91 AND d4 = 'JJ' AND e5 = 'JJ' ORDER BY t0, a1;

-----------------------------------------------------------------------
------ Check that Filter Push Down is working with HEX delimiter ------
-----------------------------------------------------------------------

DROP EXTERNAL TABLE IF EXISTS test_filter CASCADE;
CREATE EXTERNAL TABLE test_filter (t0 text, a1 integer, b2 boolean, c3 numeric, d4 char(2), e5 varchar(2), filterValue text)
    LOCATION (E'pxf://dummy_path?PROFILE=system:filter')
    FORMAT 'CSV' (DELIMITER E'\x01');

SET gp_external_enable_filter_pushdown = true;

SET optimizer = off;
SELECT * FROM test_filter WHERE t0 = 'J' AND a1 = 9 AND b2 = false AND c3 = 9.91 AND d4 = 'JJ' AND e5 = 'JJ' ORDER BY t0, a1;

SET optimizer = on;
SELECT * FROM test_filter WHERE t0 = 'J' AND a1 = 9 AND b2 = false AND c3 = 9.91 AND d4 = 'JJ' AND e5 = 'JJ' ORDER BY t0, a1;

-- start_ignore
{{ CLEAN_UP }}-- clean up used tables
{{ CLEAN_UP }}DROP EXTERNAL TABLE IF EXISTS test_filter CASCADE;
-- end_ignore

-- @description query01 for PXF filter pushdown disabled case

SET gp_external_enable_filter_pushdown = off;
SELECT * FROM test_filter WHERE  t0 = 'C' AND a1 = 2 ORDER BY t0, a1;

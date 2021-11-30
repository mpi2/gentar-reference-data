-- 
-- Schema Search PATH
-- 

-- 
-- Need to specify the schema search path
-- The default is:
-- "$user", public
-- However this is causing an issue when specifying the SQL in the docker container.


alter user hasurauser set search_path='hdb_catalog, hdb_views, public';
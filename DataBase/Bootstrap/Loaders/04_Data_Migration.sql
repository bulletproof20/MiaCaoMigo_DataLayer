-- =========================================================
-- DATA MIGRATION LAYER (Bootstrap/Loaders/04_Data_Migration.sql)
-- =========================================================
--
-- DESCRIPTION
-- Reserved for ETL, reference imports, or batch migrations that must
-- run after integrity objects exist.
--
-- OFFICIAL DATA BOOTSTRAP (wired in init.sql)
-- ---------------------------------------------------------
--   Bootstrap/Loaders/10_Official_Bootstrap.sql delegates to:
--     DataSeed/04_Loaders/00_MasterData.sql
--     DataSeed/04_Loaders/01_DemoData.sql
--
-- MANUAL-ONLY TIERS (never in init.sql)
-- ---------------------------------------------------------
--   TestData        | 04_Loaders/03_TestData.sql
--   DevelopmentData | 04_Loaders/02_DevelopmentData.sql
--                     or 09_DevelopmentData.sql (-v MIACAOMIGO_SEED_DEV=1)
--
-- See: DataBase/DataSeed/MANIFEST.txt
-- =========================================================

\echo '========================================'
\echo 'DATA MIGRATION LAYER (no ETL scripts wired)'
\echo '========================================'


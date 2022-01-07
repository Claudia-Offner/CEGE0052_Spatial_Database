------------------------------------------------------- STEP 1: DDL -------------------------------------------------------

drop schema if exists ucesccf cascade;
create schema ucesccf;

-- ========================================================================================================================
-- TABLES WITH GEOMETRY
-- ========================================================================================================================


-- 1. localzoo
create table ucesccf.localzoo
(localzoo_id serial not null,
 localzoo_name character varying (100) not null);

select AddGeometryColumn ('ucesccf', 'localzoo', 'location', 27700, 'geometry', 2);

-- 2. enclosures
create table ucesccf.enclosures
(enclosure_id serial not null,
 localzoo_id integer not null,
 enclosure_name character varying (100) not null,
 animal_type character varying (100) not null);

select AddGeometryColumn ('ucesccf', 'enclosures', 'location', 27700, 'geometry',3);

-- 3. shelters
create table ucesccf.shelters
(shelter_id serial not null,
 enclosure_id integer not null,
 shelter_name character varying (100) not null,
 animal_type character varying (100) not null);

select AddGeometryColumn ('ucesccf', 'shelters', 'location', 27700, 'geometry', 3);

-- 4. humidity_sensors
create table ucesccf.humidity_sensors
(sensor_id serial not null,
 humidity_sensor_name character varying (100) not null,
 shelter_id integer);

select AddGeometryColumn ('ucesccf', 'humidity_sensors', 'location', 27700, 'point', 3);

-- 5. fencing
create table ucesccf.fencing
(fencing_id serial not null,
 localzoo_id integer not null,
 fencing_name character varying (100) not null,
 date_installed character varying (100) not null);

select AddGeometryColumn ('ucesccf', 'fencing', 'location', 27700, 'geometry', 3);


-- ========================================================================================================================
-- TABLES FOR REPORTS
-- ========================================================================================================================

-- 6. admission_reports (per month)
create table ucesccf.admission_reports
(admission_report_id serial not null,
 localzoo_id integer not null,
 zookeeper_id integer not null,
 number_of_visitors integer not null,
 report_date character varying (100) not null);

-- 7. enclosure_reports (per month)
create table ucesccf.enclosure_reports
(enclosure_report_id serial not null,
 enclosure_id integer not null,
 zookeeper_id integer not null,
 stairs_condition integer not null,
 gate_condition integer not null,
 fence_condition integer not null,
 feed_dispenser_condition integer not null,
 water_trough_condition integer not null,
 toy_condition integer not null,
 report_date character varying (100) not null);

-- 8. shelter_reports (per month)
create table ucesccf.shelter_reports
(shelter_report_id serial not null,
 shelter_id integer not null,
 zookeeper_id integer not null,
 ceiling_condition integer not null,
 wall_condition integer not null,
 door_condition integer not null,
 feed_dispenser_condition integer not null,
 water_trough_condition integer not null,
 heating_system_condition integer not null,
 report_date character varying (100) not null);

-- 9. animal_reports (per week)
create table ucesccf.animal_reports
(animal_report_id serial not null,
 enclosure_id integer not null,
 shelter_id integer not null,
 animal_id integer not null,
 zookeeper_id integer not null,
 weight integer not null,
 body_temperature integer not null,
 coat_condition character varying (100) not null,
 report_date character varying (100) not null);


-- ========================================================================================================================
-- TABLES FOR OTHER ASSETS
-- ========================================================================================================================

-- 10. animals
create table ucesccf.animals
(animal_id serial not null,
 enclosure_id integer not null,
 shelter_id integer not null,
 animal_type character varying (100) not null,
 animal_name character varying (100) not null,
 date_of_captivity character varying (100) not null);

-- 11. humidity_sensor_values
create table ucesccf.humidity_sensor_values
(humidity_sensor_value_id serial not null,
 humidity_sensor_id integer not null,
 humidity_sensor_value numeric not null,
 reading_timestamp character varying (100) not null);

-- 12.zookeepers
create table ucesccf.zookeepers
(zookeeper_id serial not null,
 zookeeper_name character varying (100) not null);

-- ========================================================================================================================
-- TABLES FOR VALUES
-- ========================================================================================================================

-- 13. asset_health_indicators
create table ucesccf.asset_health_indicators
(asset_health_indicator_id serial not null,
 asset_health_indicator_description character varying (100) not null);

-- 14. parameters
create table ucesccf.parameters
(parameter_id serial not null,
 parameter_type character varying (100) not null,
 asset_name character varying (100) not null,
 asset_subname character varying (100) not null,
 asset_identifier character varying (100),
 asset_unit character varying (100) not null,
 asset_value integer not null,
 date_created date default CURRENT_DATE);


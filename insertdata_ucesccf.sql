------------------------------------------------ STEP 3: INSERT DATA (DML) ------------------------------------------------

-- CHECK
-- select * from ucesccf.localzoo;
-- select * from ucesccf.enclosures;
-- select * from ucesccf.shelters;
-- select * from ucesccf.humidity_sensors;
-- select * from ucesccf.fencing;
-- select * from ucesccf.admission_reports;
-- select * from ucesccf.enclosure_reports;
-- select * from ucesccf.shelter_reports;
-- select * from ucesccf.animal_reports;
-- select * from ucesccf.animals;
-- select * from ucesccf.humidity_sensor_values;
-- select * from ucesccf.zookeepers;
-- select * from ucesccf.asset_health_indicators;
-- select * from ucesccf.parameters;

-- ========================================================================================================================
-- GEOSPATIAL ASSETS 
-- ========================================================================================================================

-- localzoo (1) - 2D Polygon
insert into ucesccf.localzoo 
(localzoo_name, location)
values 
('Zootopia', st_geomfromtext('POLYGON((0 0, 0 500, 500 500, 500 0, 0 0))',27700));

-- fencing (3) - 3D Linestring
insert into ucesccf.fencing
(localzoo_id, fencing_name, date_installed, location)
values
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'East Fence', '2017-08-10', st_geomfromtext('LINESTRING(0 150 20, 0 500 20)',27700)),
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'North Fence', '2017-08-10', st_geomfromtext('LINESTRING(0 500 20, 500 500 20)',27700)),
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'West Fence', '2017-08-10', st_geomfromtext('LINESTRING(500 500 20, 500 150 20)',27700));

-- enclosures (3) - 3D Polygons
insert into ucesccf.enclosures 
(localzoo_id, enclosure_name, animal_type, location) 
values 
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'A', 'Capybara', st_geomfromtext('POLYGON((10 490 1, 150 490 1, 150 250 1, 10 250 1, 10 490 1))',27700)),
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'B', 'Wombat', st_geomfromtext('POLYGON((275 490 1, 490 490 1, 490 375 1, 275 375 1, 275 490 1))',27700)),
((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), 'C', 'Alpaca', st_geomfromtext('POLYGON((275 350 1, 490 350 1, 490 215 1, 275 215 1, 275 350 1))',27700));

-- shelters (4) - 3D Polyhedra Surface
insert into ucesccf.shelters 
(enclosure_id, shelter_name, animal_type, location) 
values 
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), 'Playhouse', 'Capybara', st_extrude(st_geomfromtext('POLYGON((20 475 0, 130 475 0, 130 430 0, 20 430 0, 20 475 0))',27700), 0, 0, 50)),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), 'Sleephouse', 'Capybara', st_extrude(st_geomfromtext('POLYGON((20 260 0, 130 260 0, 130 290 0, 20 290 0, 20 260 0))',27700), 0, 0, 50)),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), 'Sleephouse', 'Wombat', st_extrude(st_geomfromtext(' POLYGON((475 475 0, 475 380 0, 450 380 0, 450 475 0, 475 475 0))',27700), 0, 0, 50)),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), 'Sleephouse', 'Alpaca', st_extrude(st_geomfromtext('POLYGON((475 330 0, 475 225 0, 450 225 0, 450 330 0, 475 330 0))',27700), 0, 0, 50));

-- humidity_sensors (9) - 3D Points
insert into ucesccf.humidity_sensors 
  (humidity_sensor_name, location)
values 
('Sensor 1', st_geomfromtext('POINT(21 474 30)',27700)), --capy play
('Sensor 2', st_geomfromtext('POINT(129 431 30)',27700)), -- capy play
('Sensor 3', st_geomfromtext('POINT(21 289 30)',27700)), -- capy sleep
('Sensor 4', st_geomfromtext('POINT(129 261 30)',27700)), -- capy sleep
('Sensor 5', st_geomfromtext('POINT(474 474 30)',27700)), -- wombat sleep
('Sensor 6', st_geomfromtext('POINT(451 381 30)',27700)), -- wombat sleep
('Sensor 7', st_geomfromtext('POINT(474 329 30)',27700)), -- alpaca sleep
('Sensor 8', st_geomfromtext('POINT(451 226 30)',27700)), -- alpaca sleep
('Sensor 9', st_geomfromtext('POINT(75 450 30)',27700)); -- capy play


update ucesccf.humidity_sensors b
set shelter_id = 
(select shelter_id from ucesccf.shelters a where st_3dintersects(a.location, b.location));


-- ========================================================================================================================
-- LIVE ASSET DATA
-- ========================================================================================================================

-- zookeepers (3)
insert into ucesccf.zookeepers
(zookeeper_name)
values
('Steve Irwin'),
('Jane Goodall'),
('David Attenborough');

-- animals (11) 
insert into ucesccf.animals
(enclosure_id, shelter_id, animal_type, animal_name, date_of_captivity)
values
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), 'Capybara', 'Connor', '2017-09-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), 'Capybara', 'Cowboy', '2017-09-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), 'Capybara', 'Cranberry', '2018-01-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), 'Capybara', 'Barbara', '2019-07-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'),'Capybara', 'Bernice', '2020-09-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), 'Wombat', 'Wiggles', '2019-01-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), 'Wombat', 'Sir Wombels', '2019-01-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), 'Wombat', 'Waddles', '2019-02-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), 'Alpaca', 'Phil', '2019-05-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), 'Alpaca', 'Ethel', '2019-05-12'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), 'Alpaca', 'Thistle', '2019-09-12');


-- ========================================================================================================================
--  ASSET PARAMETERS TABLES 
-- ========================================================================================================================

insert into ucesccf.parameters
(parameter_type, asset_name, asset_subname, asset_identifier, asset_unit, asset_value)
values 
-- enclosure parameters
('cost', 'enclosures', 'monthly maintenance', 'A', '£ per enclosure', 5000),
('cost', 'enclosures', 'monthly maintenance', 'B', '£ per enclosure', 8000),
('cost', 'enclosures', 'monthly maintenance', 'C', '£ per enclosure', 3500),
-- animal parameters
('cost', 'animals','monthly maintenance', 'Capybaras', '£ per animal', 1000),
('cost', 'animals','monthly maintenance', 'Wombats', '£ per animal', 2666),
('cost', 'animals','monthly maintenance', 'Alpacas', '£ per animal', 1167),
('cost', 'animals','monthly maintenance', 'Tapirs', '£ per animal', 2200),
('cost', 'animals','animal adoption', 'Capybaras', '£ per animal', 5000),
('cost', 'animals','animal adoption', 'Wombats', '£ per animal', 13330),
('cost', 'animals','animal adoption', 'Alpacas', '£ per animal', 5835),
('cost', 'animals','animal adoption', 'Tapirs', '£ per animal', 11000);
insert into ucesccf.parameters
(parameter_type, asset_name, asset_subname, asset_unit, asset_value)
values 
-- enclosures/shelters replacements
('cost', 'animals','medical visit', '£ per animal', 1500),
('cost', 'enclosures/shelters', 'feed dispensers', '£ per item', 250),
('cost', 'enclosures/shelters', 'water troughs', '£ per item', 200),
('cost', 'enclosures/shelters', 'toys', '£ per item', 100),
('cost', 'enclosures/shelters', 'heating system', '£ per item', 10000),
('cost', 'enclosures/shelters', 'ventilation system', '£ per item', 8000),
('cost', 'enclosures/shelters', 'gate', '£ per m', 200),
('cost', 'general', 'paint', '£ per m', 12),
('cost', 'general', 'fencing', '£ per m', 50),
('cost', 'general', 'door', '£ per m', 150),

-- admission parameters
('income', 'admissions', 'general', '£ per person', 10),
-- weighting (for asset importance)
('weighting', 'shelters','ceiling_condition','times as important', 1),
('weighting', 'shelters','wall_condition','times as important', 1),
('weighting', 'shelters','door_condition','times as important', 2),
('weighting', 'shelters','feed_dispenser_condition','times as important', 1),
('weighting', 'shelters','water_trough_condition','times as important', 4),
('weighting', 'shelters','heating_system_condition','times as important', 3),
('weighting', 'enclosures','stair_condition','times as important', 1),
('weighting', 'enclosures','gate_condition','times as important', 1),
('weighting', 'enclosures','fence_condition','times as important', 2),
('weighting', 'enclosures','feed_dispenser_condition','times as important', 1),
('weighting', 'enclosures','water_trough_condition','times as important', 4),
('weighting', 'enclosures','toy_condition','times as important', 3);


-- ========================================================================================================================
-- LOOK UP TABLE
-- ========================================================================================================================

-- asset_health_indicator
insert into ucesccf.asset_health_indicators
(asset_health_indicator_id, asset_health_indicator_description)
values
(1, 'New or in serviceable condition'),
(2, 'Replace within 3 years'),
(3, 'Replace within 6 months (deteriorating, evidence of high usage, etc.)'),
(4, 'Overdue for replacement (poor condition, unusable, etc.)'),
(5, 'Item does not exist');


-- ========================================================================================================================
-- HUMIDITY VALUES (4 weeks)
-- ========================================================================================================================

insert into ucesccf.humidity_sensor_values(humidity_sensor_id, reading_timestamp, humidity_sensor_value)
values
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 1'),'2021-12-01 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 1'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 1'),'2021-12-14 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 1'),'2021-12-21 10:05:00', 0.40),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 2'),'2021-12-01 10:05:00', 0.35),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 2'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 2'),'2021-12-14 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 2'),'2021-12-21 10:05:00', 0.40),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 3'),'2021-12-01 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 3'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 3'),'2021-12-14 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 3'),'2021-12-21 10:05:00', 0.30),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 4'),'2021-12-01 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 4'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 4'),'2021-12-14 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 4'),'2021-12-21 10:05:00', 0.30),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 5'),'2021-12-01 10:05:00', 0.48),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 5'),'2021-12-07 10:05:00', 0.40),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 5'),'2021-12-14 10:05:00', 0.45),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 5'),'2021-12-21 10:05:00', 0.55),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 6'),'2021-12-01 10:05:00', 0.45),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 6'),'2021-12-07 10:05:00', 0.55),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 6'),'2021-12-14 10:05:00', 0.66),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 6'),'2021-12-21 10:05:00', 0.77),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 7'),'2021-12-01 10:05:00', 0.21),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 7'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 7'),'2021-12-14 10:05:00', 0.37),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 7'),'2021-12-21 10:05:00', 0.31),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 8'),'2021-12-01 10:05:00', 0.22),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 8'),'2021-12-07 10:05:00', 0.33),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 8'),'2021-12-14 10:05:00', 0.45),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 8'),'2021-12-21 10:05:00', 0.66),

((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 9'),'2021-12-01 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 9'),'2021-12-07 10:05:00', 0.30),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 9'),'2021-12-14 10:05:00', 0.35),
((select sensor_id from ucesccf.humidity_sensors where humidity_sensor_name = 'Sensor 9'),'2021-12-21 10:05:00', 0.35);

-- ========================================================================================================================
-- REPORTS
-- ========================================================================================================================

-- admission_reports (per month)
insert into ucesccf.admission_reports
 (localzoo_id, zookeeper_id, number_of_visitors, report_date)
 values
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 596, '2021-01-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1210, '2021-02-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 2003, '2021-03-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 2483, '2021-04-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 4356, '2021-05-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 11234, '2021-06-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 21240, '2021-07-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 23455, '2021-08-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 12634, '2021-09-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 5041, '2021-10-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 604, '2021-11-01'),
 ((select localzoo_id from ucesccf.localzoo where localzoo_name = 'Zootopia'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1000, '2021-12-01');


-- enclosure_reports (per month)
insert into ucesccf.enclosure_reports
 (enclosure_id, zookeeper_id, stairs_condition, gate_condition, fence_condition, feed_dispenser_condition, water_trough_condition, toy_condition, report_date)
 values
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 3, 1, 3, '2021-10-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 3, 1, 3, '2021-11-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 4, 1, 4, '2021-12-01'),

 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 1, 1, 2, '2021-10-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 1, 1, 2, '2021-11-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 3, 1, 2, 1, 2, '2021-12-01'),

 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 2, 1, 1, 1, '2021-10-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 2, 1, 1, 3, '2021-11-01'),
 ((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 2, 1, 1, 4, '2021-12-01');

-- shelter_reports (per month)
insert into ucesccf.shelter_reports
 (shelter_id, zookeeper_id, ceiling_condition, wall_condition, door_condition, feed_dispenser_condition, water_trough_condition, heating_system_condition, report_date)
 values
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 1, 1, 1, 1, 1, '2020-10-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 1, 1, 1, 1, 1, '2020-11-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 2, 1, 1, 2, 2, 1,'2020-12-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 1, 3, 1, '2020-10-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 1, 3, 1, '2020-11-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 2, 4, 1, '2020-12-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 1, 1, 1, 1, 3, '2020-10-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 1, 1, 2, 1, 3, '2020-11-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 1, 1, 3, 2, 4, '2020-12-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 3, 1, 1, '2020-10-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 3, 1, 1, '2020-11-01'),
 ((select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 1, 2, 1, 4, 2, 1, '2020-12-01');


-- animal_reports (per week)
insert into ucesccf.animal_reports
(enclosure_id, shelter_id, animal_id, zookeeper_id, weight, body_temperature, coat_condition, report_date)
values
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Connor'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 45, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Connor'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 45, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Connor'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 45, 90, 'excellent', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Connor'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 45, 90, 'excellent', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cowboy'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cowboy'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cowboy'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Playhouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cowboy'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cranberry'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 60, 90, 'good', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cranberry'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 60, 90, 'good', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cranberry'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 60, 90, 'good', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Cranberry'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 60, 90, 'good', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Barbara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 70, 90, 'good', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Barbara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 70, 90, 'good', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Barbara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 70, 90, 'good', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Barbara'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 70, 90, 'good', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Bernice'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Bernice'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Bernice'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Capybara'), (select animal_id from ucesccf.animals where animal_name = 'Bernice'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 90, 'excellent', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Wiggles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 25, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Wiggles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 25, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Wiggles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 25, 90, 'excellent', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Wiggles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 25, 90, 'excellent', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Sir Wombels'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 40, 90, 'good', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Sir Wombels'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 40, 90, 'good', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Sir Wombels'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 40, 99, 'poor', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Sir Wombels'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 30, 105, 'poor', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Waddles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 50, 90, 'good', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Waddles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 50, 90, 'good', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Waddles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 50, 90, 'good', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'B'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Wombat'), (select animal_id from ucesccf.animals where animal_name = 'Waddles'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 50, 90, 'good', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Phil'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 100, 90, 'good', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Phil'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 100, 90, 'good', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Phil'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 100, 98, 'poor', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Phil'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 85, 106, 'poor', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Ethel'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 90, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Ethel'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 90, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Ethel'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 90, 90, 'excellent', '2021-12-14'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Ethel'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 90, 90, 'excellent', '2021-12-21'),

((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Thistle'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 110, 90, 'excellent', '2021-12-01'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Thistle'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 105, 90, 'excellent', '2021-12-07'),
((select enclosure_id from ucesccf.enclosures where enclosure_name = 'C'), (select shelter_id from ucesccf.shelters where shelter_name = 'Sleephouse' and animal_type = 'Alpaca'), (select animal_id from ucesccf.animals where animal_name = 'Thistle'), (select zookeeper_id from ucesccf.zookeepers where zookeeper_name like '%Steve%'), 108, 90, 'excellent', '2021-12-21');


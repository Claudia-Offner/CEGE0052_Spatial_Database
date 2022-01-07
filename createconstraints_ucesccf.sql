---------------------------------------------------- STEP 2: CONSTRAINTS --------------------------------------------------

-- ========================================================================================================================
-- PRIMARY KEYS (14)
-- ========================================================================================================================

-- PK WITH GEOMETRY
alter table ucesccf.localzoo
add constraint localzoo_pk
primary key (localzoo_id);

alter table ucesccf.enclosures
add constraint enclosures_pk
primary key (enclosure_id);

alter table ucesccf.shelters
add constraint shelters_pk
primary key (shelter_id);

alter table ucesccf.humidity_sensors
add constraint humidity_sensors_pk
primary key (sensor_id);

alter table ucesccf.fencing
add constraint fencing_pk
primary key (fencing_id);

-- PK FOR REPORTS
alter table ucesccf.admission_reports
add constraint admission_reports_pk
primary key (admission_report_id);

alter table ucesccf.enclosure_reports
add constraint enclosure_reports_pk
primary key (enclosure_report_id);

alter table ucesccf.shelter_reports
add constraint shelter_reports_pk
primary key (shelter_report_id);

alter table ucesccf.animal_reports
add constraint animal_reports_pk
primary key (animal_report_id);

-- PK FOR LIVE ASSETS
alter table ucesccf.zookeepers
add constraint zookeepers_pk
primary key (zookeeper_id);

alter table ucesccf.animals
add constraint animals_pk
primary key (animal_id);

-- PK FOR VALUES
alter table ucesccf.humidity_sensor_values
add constraint humidity_sensor_values_pk
primary key (humidity_sensor_value_id);

alter table ucesccf.parameters
add constraint parameters_pk
primary key (parameter_id);

alter table ucesccf.asset_health_indicators
add constraint asset_health_indicators_pk
primary key (asset_health_indicator_id);

-- ========================================================================================================================
-- FOREIGN KEYS (15)
-- ========================================================================================================================

-- FK : ONE

alter table ucesccf.fencing
add constraint localzoo_id_fk
foreign key (localzoo_id)
references ucesccf.localzoo(localzoo_id);

alter table ucesccf.enclosures
add constraint localzoo_id_fk 
foreign key (localzoo_id)
references ucesccf.localzoo(localzoo_id);

alter table ucesccf.shelters
add constraint enclosure_id_fk 
foreign key (enclosure_id)
references ucesccf.enclosures(enclosure_id);

alter table ucesccf.humidity_sensors
add constraint shelter_id_fk 
foreign key (shelter_id)
references ucesccf.shelters(shelter_id);

alter table ucesccf.humidity_sensor_values
add constraint humidity_sensors_fk 
foreign key (humidity_sensor_id)
references ucesccf.humidity_sensors(sensor_id);

alter table ucesccf.admission_reports
add constraint localzoo_id_fk 
foreign key (localzoo_id)
references ucesccf.localzoo(localzoo_id);

-- FK : TWO
-- enclosure_reports
alter table ucesccf.enclosure_reports
add constraint enclosure_id_fk 
foreign key (enclosure_id)
references ucesccf.enclosures(enclosure_id);

alter table ucesccf.enclosure_reports
add constraint zookeeper_id_fk 
foreign key (zookeeper_id)
references ucesccf.zookeepers(zookeeper_id);

-- shelter_reports
alter table ucesccf.shelter_reports
add constraint shelter_id_fk 
foreign key (shelter_id)
references ucesccf.shelters(shelter_id);

alter table ucesccf.shelter_reports
add constraint zookeeper_id_fk 
foreign key (zookeeper_id)
references ucesccf.zookeepers(zookeeper_id);

-- animals
alter table ucesccf.animals
add constraint enclosure_id_fk 
foreign key (enclosure_id)
references ucesccf.enclosures(enclosure_id);

alter table ucesccf.animals
add constraint shelter_id_fk 
foreign key (shelter_id)
references ucesccf.shelters(shelter_id);


-- FK : FOUR
-- animal_reports
alter table ucesccf.animal_reports
add constraint enclosure_id_fk 
foreign key (enclosure_id)
references ucesccf.enclosures(enclosure_id);

alter table ucesccf.animal_reports
add constraint shelter_id_fk 
foreign key (shelter_id)
references ucesccf.shelters(shelter_id);

alter table ucesccf.animal_reports
add constraint animal_id_fk 
foreign key (animal_id)
references ucesccf.animals(animal_id);

alter table ucesccf.animal_reports
add constraint zookeeper_id_fk 
foreign key (zookeeper_id)
references ucesccf.zookeepers(zookeeper_id);

-- ========================================================================================================================
-- UNIQUE CONSTRAINTS (14)
-- ========================================================================================================================


-- localzoo
alter table ucesccf.localzoo
add constraint localzoo_unique
unique(localzoo_name);

-- enclosures
alter table ucesccf.enclosures
add constraint enclosures_unique
unique(enclosure_name);

-- shelters
alter table ucesccf.shelters
add constraint shelters_unique
unique(shelter_name, animal_type);

-- humidity_sensors
alter table ucesccf.humidity_sensors
add constraint humidity_sensors_unique
unique(location);

-- fencing
alter table ucesccf.fencing
add constraint fencing_unique
unique(location);

-- admission_reports (per month)
alter table ucesccf.admission_reports
add constraint admission_reports_unique
unique(report_date, localzoo_id);

-- enclosure_reports (per month)
alter table ucesccf.enclosure_reports
add constraint enclosure_reports_unique
unique(report_date, enclosure_id, zookeeper_id);

-- shelter_reports (per month)
alter table ucesccf.shelter_reports
add constraint shelter_reports_unique
unique(report_date, shelter_id, zookeeper_id);

-- animal_reports (per week)
alter table ucesccf.animal_reports
add constraint animal_reports_unique
unique(report_date, animal_id, zookeeper_id);

-- humidity_sensor_values
alter table ucesccf.humidity_sensor_values
add constraint humidity_sensor_values_unique
unique(humidity_sensor_id, reading_timestamp);

-- animals
alter table ucesccf.animals
add constraint animals_unique
unique(animal_type, animal_name, date_of_captivity);

-- zookeepers
alter table ucesccf.zookeepers
add constraint zookeepers_unique
unique(zookeeper_name);

-- parameters
alter table ucesccf.parameters
add constraint parameters_unique 
unique(parameter_type, asset_name, asset_subname, asset_identifier);

-- asset health indicators
alter table ucesccf.asset_health_indicators
add constraint asset_health_indicators_unique 
unique(asset_health_indicator_description);


-- ========================================================================================================================
-- CHECK CONSTRAINTS (1)
-- ========================================================================================================================

alter table ucesccf.animals
add constraint animals_check
check (animal_type in ('Capybara', 'Wombat', 'Alpaca'));


-------------------------------------------------- PART 4: CREATE VIEWS ---------------------------------------------------

-- CHECK
-- select * from ucesccf.animal_health;
-- select * from ucesccf.ventilation_installment;
-- select * from ucesccf.asset_replacements;
-- select * from ucesccf.tapir_expansion;
-- select * from ucesccf.annual_enclosure_costs;
-- select * from ucesccf.fencing_costs;
-- select * from ucesccf.total_cost_income;


-- ========================================================================================================================
-- V0. LATEST PARAMETERS
-- ========================================================================================================================

drop view if exists ucesccf.latest_parameters cascade;
create view ucesccf.latest_parameters as

select parameter_id, parameter_type, asset_name, asset_subname, asset_identifier, asset_unit, asset_value, max(date_created) as date_created
from ucesccf.parameters group by parameter_id order by parameter_id;

-- ========================================================================================================================
-- BOTTOM LEVEL VIEW (Humidity Sensors)
-- ========================================================================================================================
-- V1. ANIMAL HEALTH INFORMATION
-- Queries for decisions 1 [selected in decisions 2 & 5]
-- ========================================================================================================================

drop view if exists ucesccf.animal_health cascade;
create view ucesccf.animal_health as

-- Get latest humidity report
with latest_humidity as
(select distinct on (humidity_sensor_id) humidity_sensor_id, humidity_sensor_value_id, humidity_sensor_value, reading_timestamp
    from ucesccf.humidity_sensor_values 
    order by humidity_sensor_id, reading_timestamp desc),

-- Get latest animal report
latest_animal_report as
(select distinct on (animal_id) animal_id, zookeeper_id, report_date, enclosure_id, shelter_id, body_temperature, weight, coat_condition
    from ucesccf.animal_reports 
    order by animal_id, report_date desc),

-- Join to sensor table
latest_humidity_sensors as
(select b.location, b.shelter_id, a.*
     from latest_humidity a
     inner join ucesccf.humidity_sensors b on a.humidity_sensor_id = b.sensor_id),
 
-- Join to animal report table
animal_sensors as
(select a.*, b.animal_id, b.zookeeper_id, b.report_date, b.body_temperature, b.weight, b.coat_condition
     from latest_humidity_sensors a
     inner join latest_animal_report b on a.shelter_id = b.shelter_id),

-- Join to zookeeper table
zookeeper_sensors_animals as
(select h.*, j.zookeeper_name
    from animal_sensors h 
    inner join ucesccf.zookeepers j on h.zookeeper_id = j.zookeeper_id)
 
-- Join to animal table
select (select localzoo_id from ucesccf.localzoo), a.*, b.animal_type, b.animal_name, b.date_of_captivity
    from zookeeper_sensors_animals a
    inner join ucesccf.animals b on a.animal_id = b.animal_id;


-- ========================================================================================================================
-- V2. VENTILATION INSTALLMENT
-- Queries for decisions 2 [selected in decision 5]
-- ========================================================================================================================

drop view if exists ucesccf.ventilation_installment cascade;
create view ucesccf.ventilation_installment as

-- Get sensors with humidity values less than 50%
with sensor_info as
(select distinct on (humidity_sensor_id)humidity_sensor_id, shelter_id, location 
    from ucesccf.animal_health where humidity_sensor_value > 0.5),

-- Create sensor buffer
sensor_buffer as
(select shelter_id, humidity_sensor_id, st_buffer(location, 10) as sensor_buffer from sensor_info),

-- Get 2d ground polygon of polyhedra
shelter_non_polyhedra as
(select enclosure_id, shelter_id, st_geomfromtext(st_astext(ST_Extent(location)), 27700) as location 
    from ucesccf.shelters group by shelter_id order by shelter_id),

-- Join shelter information to buffer
shelter_buffer as
(select d.enclosure_id, d.location as shelter_location, f.* 
    from shelter_non_polyhedra d inner join sensor_buffer f
    on d.shelter_id = f.shelter_id),

-- Identify one of the locations where sensor buffer intersects the shelter walls
ventilation_locations as
(select distinct on(humidity_sensor_id) humidity_sensor_id, enclosure_id, shelter_id, 
    st_astext((ST_Dump(st_intersection(ST_Boundary(sensor_buffer), ST_Boundary(shelter_location)))).geom) as where_to_install_ventilation_system
    from shelter_buffer
    where st_intersects(sensor_buffer, shelter_location))

-- Add cost and shelter information 
select (select localzoo_id from ucesccf.localzoo),
    b.enclosure_id, a.animal_type, a.shelter_name, 
    b.shelter_id, b.humidity_sensor_id, b.where_to_install_ventilation_system, 
    (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and 
        asset_name = 'enclosures/shelters' and 
        asset_subname = 'ventilation system') as cost_of_ventilation_system
    from ucesccf.shelters a 
    inner join ventilation_locations b on a.shelter_id = b.shelter_id;


-- ========================================================================================================================
-- V3. ASSET REPLACEMENTS
-- Queries for decisions 3 [selected in decision 5]
-- ========================================================================================================================

drop view if exists ucesccf.asset_replacements cascade;
create view ucesccf.asset_replacements as

-- SHELTER ASSETS--------------------------------------
-- Get latest report condition values for each shelter
with latest_shelter_report as
(select distinct on (shelter_id) shelter_id, zookeeper_id, report_date, 
    ceiling_condition, wall_condition, door_condition, feed_dispenser_condition, water_trough_condition, heating_system_condition
    from ucesccf.shelter_reports order by shelter_id, report_date desc),

shelter_asset_costs as
-- ceiling condition
(select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='paint') as cost, ceiling_condition as asset_health_indicator_id, 'ceilings' as asset_component from latest_shelter_report 
union all
-- wall condition
select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='paint') as cost, wall_condition   as asset_health_indicator_id,'walls' as asset_component from latest_shelter_report 
union all 
-- door condition
select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='door' ) as cost, door_condition as asset_health_indicator_id,'doors' as asset_component from latest_shelter_report
union all
-- feed dispenser condition
select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='feed dispensers') as cost, feed_dispenser_condition  as asset_health_indicator_id, 'feed dispensers' as asset_component from latest_shelter_report 
union all
-- water trough condition
select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='water troughs') as cost, water_trough_condition  as asset_health_indicator_id,'water troughs' as asset_component from latest_shelter_report 
union all
-- heating system condition
select shelter_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='heating system') as cost, heating_system_condition  as asset_health_indicator_id,'heating systems' as asset_component from latest_shelter_report),

-- Assign asset_health_indicators descriptions
shelter_replacement_health as
(select a.*, b.asset_health_indicator_description
    from shelter_asset_costs a left join ucesccf.asset_health_indicators b
    on a.asset_health_indicator_id = b.asset_health_indicator_id),

-- Add shelter information from table
shelter_condition as
(select d.location, d.shelter_name, d.animal_type, d.enclosure_id, f.* 
    from ucesccf.shelters d inner join shelter_replacement_health f
    on d.shelter_id = f.shelter_id),

-- Add local zoo id
shelter_assets as
(select (select localzoo_id from ucesccf.localzoo), enclosure_id, shelter_id, shelter_name, animal_type, asset_component, asset_health_indicator_description, 
    asset_health_indicator_id, cost from shelter_condition order by enclosure_id, asset_component),

-- ENCLOSURE ASSETS--------------------------------------
-- Get latest report condition values for each enclosure

latest_enclosure_report as
(select distinct on (enclosure_id) enclosure_id, zookeeper_id, report_date, 
    stairs_condition, gate_condition, fence_condition, feed_dispenser_condition, water_trough_condition, toy_condition 
    from ucesccf.enclosure_reports
    order by enclosure_id, report_date desc),

-- Add weights for each asset from table
enclosure_asset_costs as
-- stair condition
(select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='paint') as cost, stairs_condition as asset_health_indicator_id, 'stairs' as asset_component from latest_enclosure_report 
union all
-- fence condition
select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='fencing') as cost, fence_condition as asset_health_indicator_id,'fencing' as asset_component from latest_enclosure_report
union all
-- gate condition
select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='gate') as cost, gate_condition   as asset_health_indicator_id,'gate' as asset_component from latest_enclosure_report 
union all 
-- feed dispenser condition
select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='feed dispensers') as cost, feed_dispenser_condition  as asset_health_indicator_id, 'feed dispensers' as asset_component from latest_enclosure_report 
union all
-- water trough condition
select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='water troughs') as cost, water_trough_condition  as asset_health_indicator_id,'water troughs' as asset_component from latest_enclosure_report 
union all
-- toy condition
select enclosure_id, (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='enclosures/shelters' and asset_subname ='toys') as cost, toy_condition  as asset_health_indicator_id,'toys' as asset_component from latest_enclosure_report),

-- Assign asset_health_indicators descriptions
enclosure_replacement_health as
(select a.*, b.asset_health_indicator_description
    from enclosure_asset_costs a left join ucesccf.asset_health_indicators b
    on a.asset_health_indicator_id = b.asset_health_indicator_id),

-- Add enclosures information from table
enclosure_condition as
(select d.location, d.enclosure_name, d.animal_type, d.localzoo_id, f.* 
    from ucesccf.enclosures d inner join enclosure_replacement_health f
    on d.enclosure_id = f.enclosure_id),

-- Add local zoo id
enclosure_assets as
(select localzoo_id, enclosure_id, 0 as shelter_id, enclosure_name, animal_type, asset_component, asset_health_indicator_description, 
    asset_health_indicator_id, cost from enclosure_condition order by enclosure_id, asset_component)

-- Merge enclosure & shelter replacements, selecting only those with relevant asset health
(select localzoo_id, enclosure_id, shelter_id, enclosure_name as name, 
    animal_type,  asset_component, asset_health_indicator_description, cost 
    from enclosure_assets where asset_health_indicator_id >= 3 and asset_health_indicator_id != 5)
union all
(select  localzoo_id, enclosure_id, shelter_id, shelter_name as name, 
    animal_type,  asset_component, asset_health_indicator_description, cost 
    from shelter_assets where asset_health_indicator_id >= 3 and asset_health_indicator_id != 5);


-- ========================================================================================================================
-- V4. TAPIR EXPANSION CALCULATIONS
-- Queries for decisions 4 [selected in decision 5]
-- ========================================================================================================================

drop view if exists ucesccf.tapir_expansion cascade;
create view ucesccf.tapir_expansion as

-- Get number of Capybaras in the enclosure
with animal_count as
(select enclosure_id, count(*) 
    from ucesccf.animals where animal_type = 'Capybara' group by enclosure_id),

-- Calculate current area of enclosure
area_count as 
(select a.*, b.location from animal_count a 
    left join ucesccf.enclosures b on a.enclosure_id = b.enclosure_id),

-- Calculate available space, number of tapirs that can fit and further space needed
tapir_expansion as
(select enclosure_id, st_area(location) as current_area, 
    st_area(location)-(count*(50^2)) as space_available, 
    round((st_area(location)-(count*(50^2)))/100^2) as number_of_tapirs_that_fit,
    ((st_area(location)-(count*(50^2)))-(3*(100^2)))*-1 as space_needed_for_3_tapirs,
    (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_subname ='animal adoption' and asset_identifier='Tapirs') as cost_per_tapir  
    from area_count)

-- Add total cost of capybaras that fit
select (select localzoo_id from ucesccf.localzoo), enclosure_id, current_area, space_available, number_of_tapirs_that_fit, 
    (cost_per_tapir*number_of_tapirs_that_fit) as total_cost_of_tapirs_that_currently_fit, space_needed_for_3_tapirs 
    from tapir_expansion;


-- ========================================================================================================================
-- MIDDLE LEVEL VIEW (Enclosures - selects bottom level views from decisions 1, 2, 3, 4)
-- ========================================================================================================================
-- V5. PROJECTED ENCLOSURE COSTS - MIDDLE LEVEL
-- Queries for decisions 5 [selected in decision 7]
-- ========================================================================================================================

drop view if exists ucesccf.annual_enclosure_costs cascade;
create view ucesccf.annual_enclosure_costs as

-- Get unhealthy animals
with unhealthy_animals as
(select distinct on (animal_id) animal_id, localzoo_id, shelter_id, zookeeper_name, animal_type, animal_name, body_temperature, weight, coat_condition,  report_date,
    (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name = 'animals' and asset_subname = 'medical visit') as cost_for_medical_visit 
    from ucesccf.animal_health where coat_condition = 'poor' and body_temperature > 100 
    order by animal_id, report_date desc),

-- Add enclosure information
unhealthy_animals_enclosure as
(select b.enclosure_id, a.* 
    from unhealthy_animals a inner join ucesccf.shelters b
    on b.shelter_id = a.shelter_id),

-- Take the sum of costs for previous decisions    
medical_costs as
(select enclosure_id, sum(cost_for_medical_visit) as medical_cost from unhealthy_animals_enclosure group by enclosure_id),

ventillation_costs as
(select enclosure_id, sum(cost_of_ventilation_system) as ventillation_costs from ucesccf.ventilation_installment group by enclosure_id),

replacement_costs as
(select enclosure_id, sum(cost) as replacement_cost from ucesccf.asset_replacements group by enclosure_id),
 
maintenance_costs as
(select a.*, (b.asset_value*12) as maintenance_costs
    from ucesccf.enclosures a
    inner join ucesccf.latest_parameters b on a.enclosure_name = b.asset_identifier),

tapir_maintenance as
(select (select enclosure_id from ucesccf.enclosures where enclosure_name = 'A'),
    (asset_value*12) as tapir_mainentance from ucesccf.latest_parameters where asset_name = 'animals' and 
    asset_subname = 'monthly maintenance' and asset_identifier = 'Tapirs'),

-- Join the costs together
all_costs as
(select a.localzoo_id, a.enclosure_id, coalesce(a.maintenance_costs, 0) as maintenance_costs, coalesce(b.replacement_cost, 0) as replacement_cost, 
 coalesce(c.ventillation_costs,0) as ventillation_cost, coalesce(d.medical_cost,0) as medical_cost, 
 coalesce(e.total_cost_of_tapirs_that_currently_fit, 0) as new_tapir_cost, coalesce((f.tapir_mainentance*2), 0) as new_tapir_maintenance
    from maintenance_costs a
    left join replacement_costs b on a.enclosure_id = b.enclosure_id
    left join ventillation_costs c on a.enclosure_id = c.enclosure_id
    left join medical_costs d on a.enclosure_id = d.enclosure_id
    left join ucesccf.tapir_expansion e on a.enclosure_id = e.enclosure_id
    left join tapir_maintenance f on a.enclosure_id = f.enclosure_id)

-- Add the total cost
select *, (maintenance_costs+replacement_cost+ventillation_cost+medical_cost+new_tapir_cost+new_tapir_maintenance) as total_cost from all_costs;


-- ========================================================================================================================
-- V6. REQUIRED FENCING COSTS
-- Queries for decisions 6 [selected in decision 7]
-- ========================================================================================================================

drop view if exists ucesccf.fencing_costs cascade; 
create view ucesccf.fencing_costs as

-- Calculate length of current zoo
with perimeter as 
(select localzoo_id, st_perimeter(location) as zoo_perimeter from ucesccf.localzoo),

-- Calculate length of current fence
fence as 
(select localzoo_id, sum(st_length(location)) as fence_length from ucesccf.fencing group by localzoo_id),

-- Join perimeter/length info into table
fencing_table as 
(select a.*, b.* from perimeter a 
    left join fence b on a.localzoo_id = b.localzoo_id),

-- Calculate fencing needed & individual unit cost
needed_fencing as
(select 
    (select localzoo_id from ucesccf.localzoo), zoo_perimeter, fence_length as current_fencing_length_m, (zoo_perimeter-fence_length) as needed_fencing_length_m, 
    (select asset_value from ucesccf.latest_parameters where parameter_type = 'cost' and asset_name ='general' and asset_subname ='fencing') as cost_per_meter
    from fencing_table)

-- Add total cost of needed fence
select *, (cost_per_meter*needed_fencing_length_m) as total_cost_of_needed_fence from needed_fencing;


-- ========================================================================================================================
-- TOP LEVEL VIEW (Local Zoo - selects middle level views from decisions 5, 6)
-- ========================================================================================================================
-- V7. TOTAL COSTS & INCOME - TOP LEVEL
-- Queries for decisions 7
-- ========================================================================================================================

drop view if exists ucesccf.total_cost_income cascade;
create view ucesccf.total_cost_income as

-- Get income per person 
with income_per_visitor as 
(select (select localzoo_id from ucesccf.localzoo), asset_value as income 
    from ucesccf.latest_parameters where parameter_type = 'income'),

-- Get number of visitors from past year
total_visitors as 
(select localzoo_id, sum(number_of_visitors) as total_visitors 
    from ucesccf.admission_reports group by localzoo_id),

-- Join visitor and price information
income_table as 
(select a.*, b.* from income_per_visitor a 
    left join total_visitors b on a.localzoo_id = b.localzoo_id),

-- Calculation total income
total_income as 
(select (select localzoo_id from ucesccf.localzoo), (income*total_visitors) as total_income 
    from income_table),

-- Annual costs
total_costs as
(select localzoo_id, sum(total_cost) as enclosure_costs, (select total_cost_of_needed_fence from ucesccf.fencing_costs) 
 from ucesccf.annual_enclosure_costs group by localzoo_id)

-- Join annual income & costs
select a.localzoo_id, a.total_income, b.enclosure_costs, b.total_cost_of_needed_fence
    from total_income a
    inner join total_costs b on a.localzoo_id = b.localzoo_id;


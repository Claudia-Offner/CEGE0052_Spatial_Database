--------------------------------------------------- PART 5: DECISIONS -----------------------------------------------------

-- ========================================================================================================================
-- D1. Asset Health. Recently, the zoo has experienced increases in rainfall and some of the zoo animals have fallen ill. 
-- The zoo needs to decide which animals require special medical treatment and if their illness is related to humidity. 
-- Which animals need to be taken to the doctor and what are the humidity values in their shelter? Animals are considered 
-- sick if their coat condition is 'poor' & they have a body temperature over 100 degrees. [Linked to decision 5].
-- ========================================================================================================================

select animal_id, localzoo_id, shelter_id, zookeeper_name, animal_type, animal_name, body_temperature, weight, 
coat_condition,  report_date, humidity_sensor_id, humidity_sensor_value, reading_timestamp
    from ucesccf.animal_health where coat_condition = 'poor' and body_temperature > 100
    order by animal_id, report_date desc;


-- ========================================================================================================================
-- D2. Comfort & Safety. The zoo needs to improve the animal shelters to prevent humidity from impacting the animals. Given 
-- decision 1, it seems that humidity does not impact shelters evenly so ventilation systems should only be installed near 
-- the effected locations. Which shelters need a ventilation system installed and where should it be mounted?  Ventilation 
-- systems need to be mounted in shelters where animals are sick and near sensors with humidity values greater than 50% . 
-- [Linked to decision 5].
-- ========================================================================================================================
-- Referenec: https://gis.stackexchange.com/questions/171611/how-do-i-get-the-points-where-a-line-crosses-a-polygon    
-- Referenec: https://slo.yaghigroup.com/261963-st-contains-for-3d-geometry-TGEWYU-article

select * from ucesccf.ventilation_installment;


-- ========================================================================================================================
-- D3. Asset Health. The zoo needs to decide what assets need replacing for every enclosure in the next year. Which assets 
-- need to be replaced within every enclosure? This should also include respective shelter asset replacements. [Linked to 
-- decision 5].
-- ========================================================================================================================

-- Transpose data
with enclosure_replacement as
(select fd.localzoo_id, fd.enclosure_id, fd.animal_type, fd.asset_component as Feed_dispensers, t.asset_component as Toys, 
    g.asset_component as Gate, wt.asset_component as Water_troughs, hs.asset_component as Heating_systems
from ucesccf.asset_replacements fd
left join ucesccf.asset_replacements t on fd.enclosure_id = t.enclosure_id and t.asset_component = 'toys'
left join ucesccf.asset_replacements g on fd.enclosure_id = g.enclosure_id and g.asset_component = 'gate'
left join ucesccf.asset_replacements wt on fd.enclosure_id = wt.enclosure_id and wt.asset_component = 'water troughs'
left join ucesccf.asset_replacements hs on fd.enclosure_id = hs.enclosure_id and hs.asset_component = 'heating systems'
where fd.asset_component = 'feed dispensers'),

-- Count asset occurances
enclosure_replacement_count as
(select distinct(enclosure_id), animal_type, count(feed_dispensers) as feed_dispensers, count(toys) as toys, 
    count(gate) as gate, count(water_troughs) as water_troughs,  count(heating_systems) as heating_systems 
    from enclosure_replacement group by enclosure_id, animal_type),

-- Calculate total cost per enclosure
enclosure_cost as
(select localzoo_id, enclosure_id, sum(cost) as total_enclosure_cost from ucesccf.asset_replacements group by enclosure_id, 
    localzoo_id order by enclosure_id)

-- Add enclosure information
select b.localzoo_id, a.*, b.total_enclosure_cost from enclosure_replacement_count a
left join enclosure_cost b on a.enclosure_id = b.enclosure_id;


-- ========================================================================================================================
-- D4. Estate Capacity. The zoo wishes to purchase 3 tapirs to add to the enclosure A and is unsure if the current 
-- enclosure has enough space. Considering that each capybara requires 50m2 of space and each tapir requires 100m2, how 
-- many tapirs can the enclosure hold in its current state? How much more space would be required to add 3 tapirs to the 
-- capybara enclosure? [Linked to decision 5].
-- ========================================================================================================================

select * from ucesccf.tapir_expansion;


-- ========================================================================================================================
-- D5. Budget. The zoo needs to estimate next years projected costs for each enclosure. Assuming that the zoo decides to 
-- only purchase the number of tapirs that can currently fit in enclosure A, what are the projected costs of each enclosure 
-- for next year? Take into account ventilation instalments, medical visits, new animals, assets replacements and 
-- maintenance costs. [Linked to decision 7].
-- ========================================================================================================================

select a.localzoo_id, a.enclosure_id, a.enclosure_name, a.animal_type, b.maintenance_costs, b.replacement_cost, 
b.ventillation_cost, b.medical_cost, b.new_tapir_cost, b.new_tapir_maintenance, b.total_cost 
    from ucesccf.enclosures a  
    left join ucesccf.annual_enclosure_costs b on a.enclosure_id = b.enclosure_id;


-- ========================================================================================================================
-- D6. Comfort & safety. The zoo has recently purchased land on the south side of the estate. Most of the property already 
-- has fence, but this new area has not been fenced in yet. How many meters of fencing does the zoo need to fence off its 
-- newly acquired land? [Linked to decision 7].
-- ========================================================================================================================

select * from ucesccf.fencing_costs;

-- ========================================================================================================================
-- D7. Budget. The local zoo aims to open a manatee enclosure next year, which will cost £1,000,000 and take up 250 m2. 
-- Assuming that their annual income will be the same next year and that the zoo has received a grant of £500,000 from the 
-- WWF, does the zoo have enough budget to open a manatee enclosure next year? Take into account last years income and next 
-- years projected costs calculated in previous decisions.
-- ========================================================================================================================

with project_income_costs as
(select localzoo_id, (total_income+500000) as total_projected_income, 
(enclosure_costs + total_cost_of_needed_fence) as total_projected_cost from ucesccf.total_cost_income)

select *, (total_projected_income-total_projected_cost) as projected_budget_after_costs, 
    (total_projected_income-total_projected_cost-1000000 ) as projected_budget_after_costs_and_manatees 
    from project_income_costs;


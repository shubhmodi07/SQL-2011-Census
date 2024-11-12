select * from dataset1;
select * from dataset2;

-- Data for bihar and jharkhand
select * from dataset1 where state in ('Jharkhand','Bihar');
select * from dataset2 where state in ('Jharkhand','Bihar');

-- Calculate total population of India
select sum(population) as Total_Population from dataset1;

-- Average growth of India
select avg(growth)*100 as Average_Growth from dataset2;

-- Average growth for each state
select state,avg(growth)*100 as average_growth from dataset2 group by state;

-- Average sex ratio of every state
select state,round(avg(sex_ratio)) as average_sex_ratio from dataset2 group by state;

-- Average literacy rate
select state,avg(literacy) as average_literacy_rate from dataset2 group by state;

-- States with average literacy rate above 90
select state,avg(literacy) as average_literacy_rate from dataset2 group by state having avg(Literacy)>90 order by avg(Literacy) desc;

-- Top 3 states with highest average growth rate
select state,avg(growth)*100 as average_growth from dataset2 group by state order by avg(growth) desc limit 3;

--  Top 3 states with lowest sex ratio
select state,round(avg(sex_ratio)) as average_sex_ratio from dataset2 group by state order by avg(sex_ratio) limit 3;

-- States starting with 'A'
select distinct state from dataset1 where state like 'A%';

-- States starting with 'A' or 'B'
select distinct state from dataset1 where state like 'A%' or state like 'B%';

-- Number of districts in each state
select state,count(district) as number_of_districts from dataset2 group by state order by count(district) desc;

-- Joining both tables
select b.District,b.state,b.Sex_Ratio,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district;

-- Number of males and females in each district
-- population=males+females
-- population=males+(sex_ratio*males)
-- population=males(1+sex_ratio)
-- males=population/(1+sex_Ratio)

select t.district,t.state,round(t.population/(t.ratio+1)) males,round(t.population-t.population/(t.ratio+1)) females from
(select b.District,b.state,b.Sex_Ratio/1000 as ratio,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) t;

-- Number of males and females in each state
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select t.district,t.state,round(t.population/(t.ratio+1)) males,round(t.population-t.population/(t.ratio+1)) females from
(select b.District,b.state,b.Sex_Ratio/1000 as ratio,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) t) d
group by d.state;

-- Total literacy rate for each district
(select b.District,b.state,b.Literacy,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district);

-- Total literate population for each district
-- Total literate people=population*literacy_rate/100
select c.district,c.state,c.population,round(c.lit_ratio*c.population) as Total_literate_population from
(select b.District,b.state,b.Literacy/100 as lit_ratio,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) c;

-- Total literate population for each state
select d.state,sum(d.population) as Total_population,sum(d.Total_literate_population) as Total_literate_population from
(select c.district,c.state,c.population,round(c.lit_ratio*c.population) as Total_literate_population from
(select b.District,b.state,b.Literacy/100 as lit_ratio,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) c) d
group by d.state;

-- Population in previous census for each district
-- New population=(1+growth)*old population
-- old population=new population/(1+growth)
select c.district,c.state,c.growth,c.population,round(c.population/(c.growth+1)) as old_population from
(select b.District,b.state,b.Growth,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) c;

-- Population in previous census for each state
select d.state,sum(d.population) as Current_Population,sum(d.old_population) as Old_Population from
(select c.district,c.state,c.growth,c.population,round(c.population/(c.growth+1)) as old_population from
(select b.District,b.state,b.Growth,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) c) d
group by d.state;

-- Total population of India Current vs Old
select sum(e.current_population) as Total_Current_Population,sum(e.old_population) as Total_Old_Population from
(select d.state,sum(d.population) as Current_Population,sum(d.old_population) as Old_Population from
(select c.district,c.state,c.growth,c.population,round(c.population/(c.growth+1)) as old_population from
(select b.District,b.state,b.Growth,a.Population from dataset1 a 
join dataset2 b
on a.district=b.district) c) d
group by d.state) e;

-- Top 3 district from each state with highest literacy rate
select district,state,literacy,district_rank from
(select District, State, Literacy, dense_rank() over(partition by state order by literacy desc) as district_rank from dataset2) a
where district_rank in (1,2,3);

-- Top 3 district from each state with lowest literacy rate
select district,state,literacy,district_rank from
(select District, State, Literacy, dense_rank() over(partition by state order by literacy) as district_rank from dataset2) a
where district_rank in (1,2,3);
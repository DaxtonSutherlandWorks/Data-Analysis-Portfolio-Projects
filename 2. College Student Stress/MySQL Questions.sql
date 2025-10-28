/* SQL pratice questions take from https://www.kaggle.com/datasets/rxnach/student-stress-factors-a-comprehensive-analysis 
	Solved by Daxton Sutherland
*/

/* Descriptive Statistics*/

-- 1) How many students are in the dataset?
-- Solution: Use the Count function
Select Count(*) as 'total_students'
From stressleveldataset;

-- 2) What is the average anxiety level of students in the database
-- Solution: Solved by the AVG function
Select Avg(anxiety_level) as 'AVG_anxiety_level'
From stressleveldataset;

-- 3) How many students have reported a history of mental health issues?
-- Solution: Count the column and filter by 1 for history
Select Count(*) as 'students_with_MH_history'
From stressleveldataset
Where mental_health_history = 1;

/* Psychological Factors */

-- 1) How many students have a self-esteem level below the average?
-- Solution: Use a subquery and filter with Where
Select Count(*) as 'self_esteem < AVG'
From stressleveldataset
Where self_esteem < (
	Select Avg(self_esteem)
    From stressleveldataset
    );

-- 2) What percentage of students have reported experiencing depression?
-- Solution: Divide count of students answering greater than 0 for depression by total count.
Select ((Select Count(*) From stressleveldataset Where depression > 0) / Count(*)) * 100.0 as "percent_reporting_depression"
From stressleveldataset;

/* Physiological Factors */

-- 1) How many students experience headaches frequently?
-- According to datasource, 4-5 is considered "high"
-- Solution: Filter a count with Where.
Select Count(*) as "students_experiencing_frequent_headaches"
From stressleveldataset
Where headache >= 4;

-- 2) What is the average blood pressure reading among the students?
-- According to datasource, 2-3 is considered medium for blood pressure
-- Solution: AVG function
Select Avg(blood_pressure) as 'AVG_blood_pressure'
From stressleveldataset;

-- 3) How many students rate their sleep quality as poor?
-- According to datasource, 0-1 is considered low
-- Solution: Count funciton with Where filtering
Select Count(*) as "students_with_poor_sleep"
From stressleveldataset
Where sleep_quality < 2;

/* Environmental Factors */

-- 1) How many students live in conditions with high noise levels?
-- Solution: Count with where filtering
Select Count(*) as "students_with_high_noise_level"
From stressleveldataset
Where noise_level > 3;

-- 2) What percentage of students feel unsafe in their living conditions?
-- This is tricky on this scale. For better context I am going to show the percent of answers
-- Solution: Dividing the count of each answer by the total count of responses
Select safety, Count(*) * 100.0 / sum(Count(*)) over() as "percent_answered"
From stressleveldataset
Group By safety 
Order By safety;

-- 3) How many students have reported not having their basic needs met?
-- Again, the scale makes context unclear. For better context I am going to show the percent of answers
-- Solution: Dividing the count of each answer by the total count of responses
Select basic_needs, Count(*) * 100.0 / sum(Count(*)) over() as "percent_answered"
From stressleveldataset
Group By basic_needs 
Order By basic_needs;

/* Academic Factors */

-- 1) How many students rate their academic performance as below average?
-- Below average would be considered 0-1, based on the data owner.
-- Solution: Count function with a Where filter.alter
Select Count(*) as "students_who_rate_academic_performance_as_below_AVG"
From stressleveldataset
Where academic_performance < 2;

-- 2) What is the average study load reported by students?
-- Solution: AVG function
Select Avg(study_load) as "AVG_study_load"
From stressleveldataset;

-- 3) How many students have concerns about their future careers?
-- Solution: Count every student reporting above a 0 for future_career_concerns
Select Count(*)
From stressleveldataset
Where future_career_concerns > 0;

/* Social Factors */

-- 1) How many students feel they have strong social support?
-- Defined as 4-5 by data owner's standards
-- Solution: Count function with where filtering
-- I initially couldn't believe this returned 0 under my original solution,
-- So I changed my answer to show total student answers.
-- As you can see, no students feel they have stron social support, with answers ranging
-- from low to medium. 
Select social_support as social_support_score, Count(*) as students_answered
From stressleveldataset
Group By social_support
Order By social_support;

-- 2) What percentage of students have experienced bullying?
-- Solution: Dividing bullying answers over 0 by total answer count.
Select (Select Count(*) From stressleveldataset Where bullying > 0) / Count(*) * 100.0 as "percent_experiencing_bullying"
From stressleveldataset;

-- 3) How many students participate in extracurricular activities?
-- Solution: Count with Where filter
Select Count(*)
From stressleveldataset
Where extracurricular_activities > 0;

/* Compare Analysis */

-- 1) Is there a correlation between anxiety level and academic performance?
-- In a professional enviornment, I would find a library to calculate a correlation coefficient.
-- Just to show that I can do it, however, I will actually calculate it.
-- Solution: Recreate the formula for a correlation coefficient.
-- Observation: There is a strong indicator that as anxiety rises, performance lowers and vice versa.

Select
@avg_anx := Avg(anxiety_level),
@avg_perf := Avg(academic_performance),
@division := (Stddev_Samp(anxiety_level) * Stddev_Samp(academic_performance))
From stressleveldataset;

Select
	Sum((anxiety_level - @avg_anx) * (academic_performance - @avg_perf)) / 
    ((Count(anxiety_level) - 1) * @division)
    as "correlation_coefficient_of_anxiety_and_performance"
From stressleveldataset;

-- 2) Do students with poor sleep quality also report higher levels of depression?
-- Solution: Correlation can answer this question too
-- Observation: There is a strong indicator that as sleep quality decreases, depression rises and vice versa.

Select
@avg_slp := Avg(sleep_quality),
@avg_dep := Avg(depression),
@slp_dep_division := (Stddev_Samp(sleep_quality) * Stddev_Samp(depression))
From stressleveldataset;

Select
	Sum((sleep_quality - @avg_slp) * (depression - @avg_dep)) / 
    ((Count(anxiety_level) - 1) * @slp_dep_division)
    as "correlation_coefficient_of_sleep_and_depression"
From stressleveldataset;

-- 3) Are students who experience bullying more likely to have a history of mental health issues?
-- Solution: Another question where correlation is appropriate
-- Observation: There is a strong indicator that as bullying increases, so does the likelyhood of a mental health history and vice versa.
Select
@avg_bul := Avg(bullying),
@avg_mh := Avg(mental_health_history),
@bul_mh_division := (Stddev_Samp(bullying) * Stddev_Samp(mental_health_history))
From stressleveldataset;

Select
	Sum((bullying - @avg_bul) * (mental_health_history - @avg_mh)) / 
    ((Count(bullying) - 1) * @bul_mh_division)
    as "correlation_coefficient_of_bullying_and_mental_health_history"
From stressleveldataset;

/* General Exploration */

-- 1) Which factor (Psychological, Physiological, Environmental, Academic, Social) has the highest number of students reporting negative experiences or conditions?
/* Factor divisions:
	Psychological: anxiety_level, self_esteem, mental_health_history, depression
    Physiological: headache, blood_pressure, sleep_quality, breathing_problem
	Environmental: noise_level, living_conditions, safety, basic_needs
    Academic: academic_performance, study_load, teacher_student_relationship, future_career_concerns
    Social: social_support, peer_pressure, extracurricular_activities, bullying
    
    !!!Important detail: most questions are on a six point scale where a 0 or 1 is negative, in otherwords the bottom third.
    anxiety_level, self_esteem, and depression appear to be on a 31 point scale, so I am considering 0-10 as poor.
    stress_level ranks from 0-2, so I am considering a 0 as negative.
    blood_pressure ranks from 1-3, so on a similar scale to stress_level, 1 is considered negative.
    mental_health_history is a binary 0 or 1, we'll consider 0 negative.
    This was done to bring everything to a closer scale and not allow factors with a higher scale to outweigh other factors. */
 
 -- Solution: Make CTEs for with only qualifying rows for each factor, then combine Counts   

With
	psych_cte as (Select * From stressleveldataset 
					Where anxiety_level < 11 
					OR mental_health_history = 1
                    OR self_esteem < 11
                    OR depression < 11),
	physio_cte as (Select * From stressleveldataset
					Where headache < 2
                    OR blood_pressure = 1
                    OR sleep_quality < 2
                    OR breathing_problem < 2),
	enviro_cte as (Select * From stressleveldataset
					Where noise_level < 2
					OR living_conditions < 2
                    OR safety < 2
                    OR basic_needs < 2),
	academic_cte as (Select * From stressleveldataset
						Where academic_performance < 2
                        OR study_load < 2
                        OR teacher_student_relationship < 2
                        OR future_career_concerns < 2),
	social_cte as (Select * From stressleveldataset
					Where social_support < 2
                    OR peer_pressure < 2
                    OR extracurricular_activities < 2
                    OR bullying < 2)
Select 'Psychological' as 'Factor', Count(*) as "total_negative answers"
From psych_cte
Union All
Select 'Physiological' as 'Factor', Count(*)
From physio_cte
Union All
Select 'Environmental' as 'Factor', Count(*)
From enviro_cte
Union All
Select 'Academic' as 'Factor', Count(*)
From academic_cte
Union All
Select 'Social' as 'Factor', Count(*)
From social_cte;

-- 3) Which specific feature within each factor has the most significant impact on student stress, based on the dataset?
-- I swapped the last two questions because we can expand on this question to answer the next one
-- For now, correlation is going to be the back bone of this question. I've tweaked my formulat for correlation to be more readabke in bulk.
-- The generated correlation table shows that self esteem, sleep quality, safety/basic needs, future career concerns, and bullying are the biggest contributors in each factor.
With
	psych_corr_cte as (Select
						  Round((Avg(anxiety_level * stress_level) - Avg(anxiety_level) * Avg(stress_level)) /
						  (Stddev(anxiety_level) * Stddev(stress_level)), 2) As corr_anxiety_stress,
                          Round((Avg(self_esteem * stress_level) - Avg(self_esteem) * Avg(stress_level)) /
						  (Stddev(self_esteem) * Stddev(stress_level)), 2) As corr_self_esteem_stress,
                          Round((Avg(mental_health_history * stress_level) - Avg(mental_health_history) * Avg(stress_level)) /
						  (Stddev(mental_health_history) * Stddev(stress_level)), 2) As corr_mh_stress,
                          Round((Avg(depression * stress_level) - Avg(depression) * Avg(stress_level)) /
						  (Stddev(depression) * Stddev(stress_level)), 2) AS corr_depression_stress
                          From stressleveldataset),
	physio_corr_cte as (Select
						  Round((Avg(headache * stress_level) - Avg(headache) * Avg(stress_level)) /
						  (Stddev(headache) * Stddev(stress_level)), 2) As corr_headache_stress,
                          Round((Avg(blood_pressure * stress_level) - Avg(blood_pressure) * Avg(stress_level)) /
						  (Stddev(blood_pressure) * Stddev(stress_level)), 2) As corr_blood_pressure_stress,
                          Round((Avg(sleep_quality * stress_level) - Avg(sleep_quality) * Avg(stress_level)) /
						  (Stddev(sleep_quality) * Stddev(stress_level)), 2) As corr_sleep_quality_stress,
                          Round((Avg(breathing_problem * stress_level) - Avg(breathing_problem) * Avg(stress_level)) /
						  (Stddev(breathing_problem) * Stddev(stress_level)), 2) As corr_breathing_problem_stress
                          From stressleveldataset),
	enviro_corr_cte as (Select
						Round((Avg(noise_level * stress_level) - Avg(noise_level) * Avg(stress_level)) /
						(Stddev(noise_level) * Stddev(stress_level)), 2) AS corr_noise_stress,
						Round((Avg(living_conditions * stress_level) - Avg(living_conditions) * Avg(stress_level)) /
						(Stddev(living_conditions) * Stddev(stress_level)), 2) AS corr_living_cond_stress,
						Round((Avg(safety * stress_level) - Avg(safety) * Avg(stress_level)) /
						(Stddev(safety) * Stddev(stress_level)), 2) AS corr_safety_stress,
						Round((Avg(basic_needs * stress_level) - Avg(basic_needs) * Avg(stress_level)) /
						(Stddev(basic_needs) * Stddev(stress_level)), 2) AS corr_basic_needs_stress
						From stressleveldataset),
	academic_corr_cte As (Select
						  Round((Avg(academic_performance * stress_level) - Avg(academic_performance) * Avg(stress_level)) /
						  (Stddev(academic_performance) * Stddev(stress_level)), 2) AS corr_academic_perf_stress,
						  Round((Avg(study_load * stress_level) - Avg(study_load) * Avg(stress_level)) /
						  (Stddev(study_load) * Stddev(stress_level)), 2) AS corr_study_load_stress,
						  Round((Avg(teacher_student_relationship * stress_level) - Avg(teacher_student_relationship) * Avg(stress_level)) /
						  (Stddev(teacher_student_relationship) * Stddev(stress_level)), 2) AS corr_teacher_rel_stress,
						  Round((Avg(future_career_concerns * stress_level) - Avg(future_career_concerns) * Avg(stress_level)) /
						  (Stddev(future_career_concerns) * Stddev(stress_level)), 2) AS corr_future_career_stress
						  FROM stressleveldataset),
	social_corr_cte As (Select
						Round((Avg(social_support * stress_level) - Avg(social_support) * Avg(stress_level)) /
						(Stddev(social_support) * Stddev(stress_level)), 2) AS corr_social_support_stress,
						Round((Avg(peer_pressure * stress_level) - Avg(peer_pressure) * Avg(stress_level)) /
						(Stddev(peer_pressure) * Stddev(stress_level)), 2) AS corr_peer_pressure_stress,
						Round((Avg(extracurricular_activities * stress_level) - Avg(extracurricular_activities) * Avg(stress_level)) /
						(Stddev(extracurricular_activities) * Stddev(stress_level)), 2) AS corr_extracurricular_stress,
						Round((Avg(bullying * stress_level) - Avg(bullying) * Avg(stress_level)) /
						(Stddev(bullying) * Stddev(stress_level)), 2) AS corr_bullying_stress
						FROM stressleveldataset)
Select *
From psych_corr_cte
Join physio_corr_cte
Join enviro_corr_cte
Join academic_corr_cte
Join social_corr_cte;

-- 2) Are there any noticeable trends or patterns when comparing different factors?
-- With our correlation table for stress in mind, we can think of some other correlations to demonstrate and compare.
-- This query produces a table of other correlations I thought might show trends
With
interesting_corr_cte As (Select
						Round((Avg(headache * sleep_quality) - Avg(headache) * Avg(sleep_quality)) /
						(Stddev(headache) * Stddev(sleep_quality)), 2) AS corr_headache_sleep,
                        Round((Avg(breathing_problem * sleep_quality) - Avg(breathing_problem) * Avg(sleep_quality)) /
						(Stddev(breathing_problem) * Stddev(sleep_quality)), 2) AS corr_breathing_sleep,
                        Round((Avg(blood_pressure * sleep_quality) - Avg(blood_pressure) * Avg(sleep_quality)) /
						(Stddev(blood_pressure) * Stddev(sleep_quality)), 2) AS corr_blood_sleep,
                        Round((Avg(anxiety_level * sleep_quality) - Avg(anxiety_level) * Avg(sleep_quality)) /
						(Stddev(anxiety_level) * Stddev(sleep_quality)), 2) AS corr_anxiety_sleep,
                        Round((Avg(noise_level * sleep_quality) - Avg(noise_level) * Avg(sleep_quality)) /
						(Stddev(noise_level) * Stddev(sleep_quality)), 2) AS corr_noise_sleep,
                        Round((Avg(noise_level * living_conditions) - Avg(noise_level) * Avg(living_conditions)) /
						(Stddev(noise_level) * Stddev(living_conditions)), 2) AS corr_noise_living_condition,
                        Round((Avg(safety * living_conditions) - Avg(safety) * Avg(living_conditions)) /
						(Stddev(safety) * Stddev(living_conditions)), 2) AS corr_safety_living_condition,
                        Round((Avg(basic_needs * living_conditions) - Avg(basic_needs) * Avg(living_conditions)) /
						(Stddev(basic_needs) * Stddev(living_conditions)), 2) AS corr_basic_needs_living_condition,
                        Round((Avg(anxiety_level * living_conditions) - Avg(anxiety_level) * Avg(living_conditions)) /
						(Stddev(anxiety_level) * Stddev(living_conditions)), 2) AS corr_anxiety_living_condition,
                        Round((Avg(anxiety_level * basic_needs) - Avg(anxiety_level) * Avg(basic_needs)) /
						(Stddev(anxiety_level) * Stddev(basic_needs)), 2) AS corr_anxiety_basic_needs,
                        Round((Avg(study_load * teacher_student_relationship) - Avg(study_load) * Avg(teacher_student_relationship)) /
						(Stddev(study_load) * Stddev(teacher_student_relationship)), 2) AS corr_study_load_teacher_relationship,
                        Round((Avg(future_career_concerns * academic_performance) - Avg(future_career_concerns) * Avg(academic_performance)) /
						(Stddev(future_career_concerns) * Stddev(academic_performance)), 2) AS corr_future_career_concerns_academic_performance,
                        Round((Avg(future_career_concerns * social_support) - Avg(future_career_concerns) * Avg(social_support)) /
						(Stddev(future_career_concerns) * Stddev(social_support)), 2) AS corr_future_career_concerns_social_support,
                        Round((Avg(academic_performance * extracurricular_activities) - Avg(academic_performance) * Avg(extracurricular_activities)) /
						(Stddev(academic_performance) * Stddev(extracurricular_activities)), 2) AS corr_academic_performance_extracurricular_activities,
                        Round((Avg(peer_pressure * bullying) - Avg(peer_pressure) * Avg(bullying)) /
						(Stddev(peer_pressure) * Stddev(bullying)), 2) AS corr_peer_pressure_bullying
                        From stressleveldataset)
Select * From interesting_corr_cte

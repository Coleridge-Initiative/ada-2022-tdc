/*Populate tr_tdc_2022.dbo.employer_industry

This table identifies the primary industry (naics_code) for each employer by
quarter and year.

The source table for tr_tdc_2022.dbo.employer_industry is
ds_in_dwd.dbo.qcew_employers. Primary industries are identified by
aggreagting this table by ui_account_number, year and quarter and selecting
the naics_code with the highest total wages. Ties are broken with the
highest naics_code.
 
 */

TRUNCATE TABLE tr_tdc_2022.dbo.employer_industry;

-- summed_wages calculates all_wages, the sum of total_wages for each 
-- ui_account_number, year and quarter and naics_code.
WITH summed_wages AS (
	SELECT
	empr_no,
	YEAR,
	quarter,
	SUM(cast(total_wages AS bigint)) AS all_wages,
	NAICS 
	FROM  ds_in_dwd.dbo.qcew_employers 
	WHERE ( 
			CAST(CONCAT(CAST(year AS varchar(4)), CAST(quarter AS varchar(1))) AS int)
			<= 20194 )
	GROUP BY
	   empr_no,
	   YEAR,
	   quarter,
	   NAICS ),

-- Remove duplicats
no_duplicates AS (
	SELECT
		empr_no,
		year,
		quarter,
		NAICS
	FROM (
		SELECT
			empr_no,
			year,
			quarter,
			NAICS,
			row_number() OVER (
				PARTITION BY empr_no, YEAR, quarter
				ORDER BY all_wages DESC, NAICS DESC
				) AS priority
			FROM summed_wages
	) t
	WHERE priority = 1
)

-- Populate target table with ui_account_number, year quarter the primary
-- naics_code. 
INSERT INTO tr_tdc_2022.dbo.employer_industry (
empr_no,
year,
quarter,
yearq,
naics_code,
adj_naics_2,
naics_length_6)


-- Join to empr_no_id to get shorted employer id.
-- Calculate adjusted NAICS 2.
-- Calcualte naics_length_6.
SELECT
a.empr_no,
a.year,
a.quarter,
CAST(CONCAT(CAST(a.year AS varchar(4)), CAST(a.quarter AS varchar(1))) AS int) AS yearq,
a.NAICS AS naics_code,
CASE WHEN LEFT(a.NAICS, 2) IN ('31','32','33') THEN '31'
	WHEN LEFT(a.NAICS, 2) IN ('44','45') THEN '44'
	WHEN LEFT(a.NAICS, 2) IN ('48','49') THEN '48'
	ELSE LEFT(a.NAICS, 2)
END AS adj_naics_2,
CASE 
    WHEN len(a.NAICS) = 6
    THEN 1
    ELSE 0
END AS naics_length_6
FROM no_duplicates a ;
     
    
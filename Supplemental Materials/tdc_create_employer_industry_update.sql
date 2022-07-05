-- Create tr_tdc_2022.dbo.employer_industry
--
-- This table contains the primary industry for each employer by quarter
-- and year.


CREATE TABLE
    tr_tdc_2022.dbo.employer_industry 
	(
	empr_no varchar(64),
	year int,
	quarter int,
	yearq int,
	naics_code varchar(6),
	adj_naics_2 varchar(2),
	naics_length_6 tinyint,
	
	PRIMARY KEY (empr_no, year, quarter)
	);

CREATE INDEX employer_industry_empr_no 
ON tr_tdc_2022.dbo.employer_industry
(
    empr_no
);
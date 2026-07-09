-- Pan number validation project using SQL

USE pan;

DROP TABLE IF EXISTS pan_numbers_dataset;
CREATE TABLE pan_numbers_dataset(
	pan_numbers VARCHAR(30)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PAN Number Validation Dataset.csv'
INTO TABLE pan_numbers_dataset
FIELDS TERMINATED BY '\r\n'
LINES TERMINATED BY '\r\n'
(pan_numbers);

SELECT * FROM pan_numbers_dataset;
SELECT COUNT(*) AS total_records FROM pan_numbers_dataset;

-- CLEAN THE DATA
-- 1. IDENTIFY NULLS
SELECT COUNT(*) FROM pan_numbers_dataset
WHERE pan_numbers IS NULL OR pan_numbers = '';

-- 2. TRAILING SPACES
SELECT * FROM pan_numbers_dataset
WHERE pan_numbers != TRIM(pan_numbers);

-- 3. DUPLICATES
SELECT pan_numbers, COUNT(*) FROM pan_numbers_dataset
WHERE pan_numbers IS NOT NULL AND pan_numbers != ''
GROUP BY pan_numbers
HAVING count(*) > 1;

SELECT DISTINCT(pan_numbers) FROM pan_numbers_dataset;

-- 4. CORRECT CASE
SELECT * FROM pan_numbers_dataset
WHERE BINARY pan_numbers != UPPER(pan_numbers);

-- SELECT LENGTH(pan_num), HEX(pan_num)
-- FROM pan_num_dataset_cleaned
-- WHERE pan_num LIKE 'VGLOD3180G%';     -- length 13 i.e presence of \r or \n or \t

DROP TABLE IF EXISTS pan_num_dataset_cleaned;
CREATE TABLE pan_num_dataset_cleaned AS
SELECT DISTINCT(UPPER(
      TRIM(BOTH '\r' FROM TRIM(BOTH '\n' FROM TRIM(BOTH '\t' FROM REPLACE(REPLACE(REPLACE(pan_numbers, '﻿',''), ' ',''), ' ','')))))
) AS pan_num
FROM pan_numbers_dataset
WHERE pan_numbers IS NOT NULL 
  AND pan_numbers != ''
  AND TRIM(pan_numbers) != '';

SELECT * FROM pan_num_dataset_cleaned;

-- VALIDATING FORMAT
/* 1. CONTAIN 10 CHARACTERS - 
		1ST 5 ALPHABET, NEXT 4 NUMBERS, LAST ALPHABET
   2. NO ADJACENT DUPLICATE (IN NUMBERS AND ALPHABET BOTH)
   3. NO SEQUENCE (IN BOTH)		*/
   
-- FUNCTION TO CHECK ADJACENT ARE SAME OR NOT
-- IF SAME RETURNS TRUE ELSE FALSE
DELIMITER $$
CREATE FUNCTION check_adj(Pstr VARCHAR(30)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN 
	DECLARE i INT DEFAULT 1;
    
	WHILE i < (LENGTH(Pstr)-1) DO
		IF SUBSTRING(Pstr, i, 1) = SUBSTRING(Pstr, i+1, 1) 
        THEN
			RETURN TRUE;
		END IF;
        SET i = i + 1;
	END WHILE;
    
    	RETURN FALSE;
END $$

DELIMITER ;
SELECT check_adj('ABCDE');  -- 0, NO ADJACENT SAME
SELECT check_adj('AABCD');  -- 1, ADJACENT
SELECT check_adj('11235');  -- 1, ADJACENT


-- FUNCTION TO CHECK SEQUENCE 
-- IF THEY ARE SEQUENTIAL RETURNS TRUE ELSE FALSE
DROP FUNCTION IF EXISTS check_seq;
DELIMITER $$
CREATE FUNCTION check_seq(Pstr varchar(30))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE i INT DEFAULT 1;
    
	WHILE i < (LENGTH(Pstr)-1) DO
		IF  ASCII(SUBSTRING(Pstr, i+1, 1)) - ASCII(SUBSTRING(Pstr, i, 1)) != 1
        THEN
			RETURN FALSE;
		END IF;
        SET i = i + 1;
	END WHILE;
    
    RETURN TRUE;
END$$

DELIMITER ;
SELECT check_seq('12345'); -- 1
SELECT check_seq('BCDEF'); -- 1
SELECT check_seq('62345'); -- 0
SELECT check_seq('ACDEF'); -- 0

-- VALID
SELECT * FROM pan_num_dataset_cleaned
WHERE check_adj(pan_num) = 0
  AND check_seq(SUBSTRING(pan_num, 1, 5)) = 0
  AND check_seq(SUBSTRING(pan_num, 6, 4)) = 0
  AND pan_num REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$';

-- INVALID
SELECT * FROM pan_num_dataset_cleaned
WHERE check_adj(pan_num) = 1
   OR check_seq(SUBSTRING(pan_num, 1, 5)) = 1
   OR check_seq(SUBSTRING(pan_num, 6, 4)) = 1
   OR pan_num NOT REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$';

CREATE OR REPLACE VIEW cln_valid_invalid_pan AS
WITH cte_valid_pan AS(
	SELECT * FROM pan_num_dataset_cleaned 
    WHERE check_adj(pan_num) = '0'
		 AND check_seq(SUBSTRING(pan_num, 1, 5)) = '0'
         AND check_seq(SUBSTRING(pan_num, 6, 4)) = '0'
         AND pan_num REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
SELECT cln.pan_num,
	CASE WHEN vld.pan_num IS NULL 
		THEN 'Invalid PAN'
		ELSE 'Valid PAN' 
	END AS validity
FROM pan_num_dataset_cleaned cln
LEFT JOIN cte_valid_pan vld
ON cln.pan_num = vld.pan_num;

SELECT * FROM cln_valid_invalid_pan;

-- SUMMARY REPORT
SELECT 
(SELECT COUNT(*) FROM pan_numbers_dataset) AS Processed_records,
(SELECT COUNT(*) FROM pan_num_dataset_cleaned) AS Cleaned_records,
(SELECT COUNT(*) FROM cln_valid_invalid_pan 
WHERE validity = 'Valid PAN') AS valid_records,
(SELECT COUNT(*) FROM cln_valid_invalid_pan 
WHERE validity = 'Invalid PAN')AS Invalid_records, 
(SELECT Processed_records - Cleaned_records) AS missing_incomplete_PANS;




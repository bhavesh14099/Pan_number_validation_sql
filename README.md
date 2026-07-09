# PAN Number Data Cleaning & Validation using SQL  

## 📌 Overview  
The **PAN Number Validation Project** focuses on cleaning and validating a dataset of **Permanent Account Numbers (PAN)** issued to Indian nationals.  

**Problem Statement:**  
A PAN is a 10-character alphanumeric identifier that must strictly follow the official format. However, real-world datasets often contain **missing values, duplicates, incorrect formatting, hidden characters, and invalid PANs**.  

The challenge is to:  
- Clean the dataset by handling missing values, duplicates, and inconsistent formatting.  
- Validate each PAN number against the official rules:  
  - Must be exactly 10 characters.  
  - First 5 → Alphabets (uppercase).  
  - Next 4 → Digits.  
  - Last 1 → Alphabet (uppercase).  
  - No adjacent duplicates (in alphabets or digits).  
  - No sequential patterns (ABCDE, 1234, etc.).  
- Categorize PAN numbers as **Valid** or **Invalid**.  
- Generate a **summary report** of processed, valid, invalid, and missing PANs.  

This project demonstrates **practical data cleaning and validation in SQL**, relevant to real-world ETL pipelines, compliance systems, and data quality checks.  

---

## 📂 Dataset  
- File: **PAN Number Validation Dataset.csv**  
- Contains raw PAN numbers (valid, invalid, incomplete).  
- Common issues:  
  - Missing entries  
  - Lower/uppercase inconsistencies  
  - Extra spaces and hidden characters (`\r`, `\n`, `\t`)  
  - Duplicate records  
  - Invalid formats  

---

## 🛠 Tech Stack  
- **Database:** MySQL 8+  
- **Language:** SQL  
- **Concepts Applied:**  
  - Data Cleaning (TRIM, REPLACE, DISTINCT, CASE)  
  - Regular Expressions for format validation  
  - SQL User Defined Functions (UDFs)  
  - Views for PAN classification  
  - Aggregate queries for reporting  

---

## ✨ Features  
1. **Data Cleaning**  
   - Handle missing/null PAN numbers  
   - Remove spaces & hidden characters  
   - Convert to uppercase  
   - Remove duplicates  

2. **Validation Rules**  
   - PAN must follow official 10-character format  
   - Reject adjacent duplicate characters  
   - Reject sequential alphabets/digits  
   - Classify PANs as Valid or Invalid  

3. **Classification View**  
   - A SQL view that maps each cleaned PAN to either **Valid** or **Invalid**  

4. **Summary Report**  
   - Processed records  
   - Cleaned records  
   - Valid PANs  
   - Invalid PANs  
   - Missing/incomplete PANs  

---

## 🖥 Sample Output  

### ✅ Valid PAN Examples  
AXYBZ9283F
PLMNO9876K

### ❌ Invalid PAN Examples  
ABCD12345	  Only 9 characters (should be 10)
ABCDE12A4F	Alphabets in the numeric section
AAABB1234C	Adjacent duplicate alphabets
ABCDE1234F	Sequential alphabets not allowed


### 📊 Actual Summary Report (from dataset)  
| Processed Records | Cleaned Records | Valid Records | Invalid Records | Missing/Incomplete |  
|-------------------|-----------------|---------------|-----------------|--------------------|  
| 10000             | 9025            | 3150          | 5875            | 975                |  

---

## 🚀 Future Enhancements  
- Build a Power BI / Tableau dashboard to visualize valid vs invalid PAN distribution and trends.
- Create a Python pipeline to automate data loading, cleaning, and validation workflows.
- Deploy the validation logic as an API service for real-time PAN verification.
- Integrate with cloud platforms (AWS/Azure/GCP) to handle larger datasets efficiently.
- Add detailed error categorization (length issues, duplicates, sequence errors) for deeper analytics.
  
---
## 🙌 Acknowledgements  
This project was created as part of a hands-on exercise in **data cleaning and validation using SQL**. It highlights how structured query language can be leveraged not only for querying but also for **ensuring data quality and compliance**.  




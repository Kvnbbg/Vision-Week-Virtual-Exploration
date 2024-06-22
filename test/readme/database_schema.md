## database_of_tests.md

This document serves as a reference for various tests you can perform on your database using SQL. 

**Note:** These are basic examples and might need adjustments depending on your specific database schema and desired outcomes.

### 1. Inserting Data

This section demonstrates inserting data into a table.

**Example:** Inserting data into an `Animals` table.

```sql
INSERT INTO Animals (name, type, country_id) VALUES ('Slim', 'Giraffe', 1);
```

**Explanation:**

- This statement inserts a new row into the `Animals` table.
- Columns include `name` (animal's name), `type` (animal type), and `country_id` (foreign key referencing a country).
- Values are specified for each column.

### 2. Creating a Table

This section shows how to create a new table.

**Example:** Creating a `Zoo` table to store animal information.

```sql
CREATE TABLE Zoo (
    animal_name VARCHAR(255),
    animal_type VARCHAR(255),
    country VARCHAR(255)
);
```

**Explanation:**

- This statement defines a new table named `Zoo`.
- The table has three columns:
    - `animal_name`: Stores the animal's name (text with a maximum length of 255 characters).
    - `animal_type`: Stores the animal type (text with a maximum length of 255 characters).
    - `country`: Stores the animal's country of origin (text with a maximum length of 255 characters).

### 3. Selecting Data

This section covers selecting data from a table.

**Example:** Selecting all data from the `Animals` table.

```sql
SELECT * FROM Animals;
```

**Explanation:**

- This statement retrieves all columns (`*`) from every row (`*`) in the `Animals` table.

**Example (Filtering):** Select animals from a specific country.

```sql
SELECT * FROM Animals WHERE country_id = 2;
```

**Explanation:**

- This statement retrieves all columns (`*`) from rows in the `Animals` table where the `country_id` is equal to 2.

### 4. Joining Tables

This section demonstrates joining data from multiple tables.

**Example:** Joining `Animals` and `Countries` tables to populate the `Zoo` table.

```sql
INSERT INTO Zoo (animal_name, animal_type, country)
SELECT Animals.name, Animals.type, Countries.name
FROM Animals
INNER JOIN Countries ON Animals.country_id = Countries.country_id
ORDER BY country;
```

**Explanation:**

- This statement populates the `Zoo` table by selecting data from both `Animals` and `Countries` tables.
- `INNER JOIN` combines rows where the `country_id` in `Animals` matches the `country_id` in `Countries`.
- Selected columns include `name` and `type` from `Animals` and `name` from `Countries` (renamed to `country`).
- The result is ordered by the `country` name.

### 5. Filtering with `BETWEEN` and `IN`

This section showcases filtering data using specific conditions.

**Example (BETWEEN):** Find animals added between specific dates.

```sql
SELECT * FROM Animals WHERE entry_date BETWEEN '2024-01-01' AND '2024-05-09';
```

**Explanation (assuming an `entry_date` column):**

- This statement retrieves all columns (`*`) from rows in the `Animals` table where the `entry_date` falls between January 1st, 2024, and today's date (May 9th, 2024) (inclusive).

**Example (IN):** Find animals of specific types.

```sql
SELECT * FROM Animals WHERE type IN ('Giraffe', 'Elephant', 'Lion');
```

**Explanation:**

- This statement retrieves all columns (`*`) from rows in the `Animals` table where the `type` matches any of the values in the list: 'Giraffe', 'Elephant', or 'Lion'.

**Remember:** 

- Replace table and column names with your actual database schema.
- Adjust data types and filtering conditions based on your needs.
- Explore additional SQL functionalities like functions, aggregate functions, and subqueries for more complex tasks.

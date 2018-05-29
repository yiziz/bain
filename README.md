# README

## Architecture

```
 |--------|       |------------|          |------------|
 |        | ----> |            | -------> |            |
 | Client |  GET  | API Server |  Query   | Data Store |
 |        |       |            |          |            |
 |        | <==== |            | <======= |            |
 |________|  JSON |____________|   Data   |____________|
```

### Typical flow

  1. Client sends a `GET` request to the `/providers` endpoint
  2. API server receives and interprets the request to query data
  3. Data store receives the query from the server and returns the data
  4. API server returns the fetched data to the client in a specified JSON format

The scale of the system was not specified within the challenge.  The fact that the API is internal would indicate that the scale is smaller than if it was public.  However, the fact that the API is for a national healthcare provider could mean the scale is, in fact, quite large. To get a more accurate understanding of the scale, I would need to know the purposes of which the system was being used for.  Should the need to scale arise, one reasonable solution would be to place a load balancer between the client and server and introducing more instances of the app server.  The data store could also be partitioned in a manner that optimizes for faster reads (given that writes are rare).

## Technologies
#### Rails
Rails is a popular web application framework that allows for fast development and access to a relatively large pool of talent.  While Rails does not provide a speedy web server solution, it does have an engaged developer community and provides a relatively easier path to hiring and, perhaps thus, maintenance.  Because the challenge did not specify scale, the performance aspects of Rails was largely ignored, though some aspects of scaling have been mentioned in the [Architecture](#architecture) section.

#### Postgres
Postgres is the world's most advanced open source database.  It is a good choice for storing a structured dataset and already is integrated with many tools, including Rails.  Being a popularly used relational database that uses the SQL language, finding people that understand and can work with Postgres should be relatively easy.  Also, considering its advanced nature, Postgres focuses heavily on performance and can handle security and compliance well, especially should the need to tackle HIPAA arise.

#### RSpec
RSpec is a popular Ruby testing tool.  It focuses on the readability of its tests and its ability to handle various types of tests.

## Database design
There are two tables: `providers` and `states`.

#### states table
The provided dataset has a `Provider State` column that I assume follows the `ISO 3166-2` standard.  Since querying on `string`s is much slower than on `integer`s, a states table was created to speed up queries.  It is populated with the United States state codes data found under the `ISO 3166-2` standard. Because this data rarely changes, I have created two hashes that map a state `code` to its database `id` and vice versa.  The hashes are also cached using `Rails.cache` feature. By doing so, fetching data can be more performant since we can avoid the joins or lookups between the `providers` table and the `states` table to get the state codes for each provider.

#### providers table
The `providers` table was created to store all the provider data. To comply with the usual table column naming standards, all columns from the csv have been lowercased and underscored, e.g. `Provider Name` becomes `provider_name`. Most of the columns names are formatted in the above mentioned manner and their corresponding data types remain as they were in the csv.  There are some exceptions.

#### dealing with currency
There are multiple columns in the dataset that store a currency value.  For this homework, I assume all currency values are USD, number groupings are delimited with a comma, and periods are used as the decimal separator. To effectively query on these values, the string values must be converted to numeric values.  To address the precision of the USD, I will be storing all values in cents. This will allow me to store the values as integers, which will avoid floating point issues and can be more performant than some database decimal types.  Also, to avoid confusion, all currency column names will be suffixed with `_in_cents`. Note: I chose `integer` over `bigint` as I assumed that no amount would be over 2 billion cents ($20,000,000.00).

#### providers column exceptions
* Provider Id - I assume this is a unique id referencing the provider in another system.  Although, we could use this as the id in our `providers` table, it would be safer to not tightly couple our table design to an outside system's.  To avoid confusion, this column is renamed to `external_provider_id` and its data type is integer. Since we are not querying this column and this is not a foreign key, no index was added.
* Provider State - Now using `state_id` as a foreign key to  `states`. See notes on [states table](#states-table)
* Average Covered Charges - Changed to `average_covered_charges_in_cents`. See [dealing with currency](#dealing-with-currency).
* Average Total Payments - Changed to `average_total_payments_in_cents`. See [dealing with currency](#dealing-with-currency).
* Average Medicare Payments - Changed to `average_medicare_payments_in_cents`. See [dealing with currency](#dealing-with-currency).

#### indexing
To help with query performance, the following columns are indexed:

  * `providers.id`
  * `providers.total_discharges`
  * `providers.average_covered_charges_in_cents`
  * `providers.average_total_payments_in_cents`
  * `providers.average_medicare_payments_in_cents`
  * `providers.state_id`
  * `states.id`

## Code organization
To allow maximum readability and understanding, I adhered to the Rails framework standards.  Although, I did add a few things.

#### queries
Building the query that fetches the correct providers can introduce some complicated logic into the codebase.  To isolate that logic and hopefully make it more readable, I created a `ProviderQuery` class that is suppose to interpret any supplied parameters and output the correct providers query.

#### serializers
To properly format the JSON that is sent back to the client, I decided to use a popular and well documented serialization tool called `active_model_serializers`.  This allows me to easily develop the serialization logic without introducing complexity into the models or controllers.

## API considerations

#### versioning
APIs are often improved on at a later point, but legacy endpoints must often still be supported.  To deal with this eventuality, I added versioning to my controller structure and routing. This makes it possible to query for providers data from both the `/providers` endpoint and the `/v1/providers` endpoint.

#### errors
I assumed that if the endpoint was given bad input, like a mistyped parameter, the query would not execute and the endpoint would return a `400` bad request and any parameter errors it detected.

#### caching
Caching can be effective for the `/providers` endpoint should a common set of params be used often and/or the dataset rarely change. This would have been considered if the homework specified clarifying use cases.

#### rate limiting
Most public APIs rate limit to deter abuse.  Since this is an internal system, abuse should be less, but given the scale of the system, this still could have been considered. This would have been considered if the homework specified clarifying use cases.

#### ordering
I assumed that the ordering does not matter and thus the default ordering is based on how the data is loaded into the database.

#### pagination
There probably should be a default limit on the number of providers returned. Because the JSON format specified did not allow for meta data, I would have had to use HEADER values to implement pagination. However, for the sake of correctness, I did not include pagination.

#### security
Even internal systems need to be secured, especially if the system could be extended to be used in a data sensitive environment.  Some considerations include adding SSL and authentication.  However, for this homework, I assumed this internal system is already secured in some manner.

## Heroku

https://guarded-tor-63817.herokuapp.com/providers

Heroku only provides 10,000 free rows of Postgres storage.  The Rails meta, schema migration, and states data take up 61 rows.  So I'm using a subset of the providers data (first 9899 rows).  The total number of rows used in Postgres should be 9960.

#### Sample queries

```
https://guarded-tor-63817.herokuapp.com/providers?state=AL&max_discharges=32&min_discharges=32
```

```
[
  {
    "Provider Name": "GEORGIANA HOSPITAL",
    "Provider Street Address": "515 MIRANDA ST",
    "Provider City": "GEORGIANA",
    "Provider Zip Code": "36033",
    "Hospital Referral Region Description": "AL - Montgomery",
    "Total Discharges": 32,
    "Provider State": "AL",
    "Average Total Payments": "$4,277.31",
    "Average Covered Charges": "$5,062.59",
    "Average Medicare Payments": "$3,386.18"
  },
  {
    "Provider Name": "ELIZA COFFEE MEMORIAL HOSPITAL",
    "Provider Street Address": "205 MARENGO STREET",
    "Provider City": "FLORENCE",
    "Provider Zip Code": "35631",
    "Hospital Referral Region Description": "AL - Birmingham",
    "Total Discharges": 32,
    "Provider State": "AL",
    "Average Total Payments": "$10,439.46",
    "Average Covered Charges": "$45,393.21",
    "Average Medicare Payments": "$8,606.93"
  },
  {
    "Provider Name": "UNIVERSITY OF ALABAMA HOSPITAL",
    "Provider Street Address": "619 SOUTH 19TH STREET",
    "Provider City": "BIRMINGHAM",
    "Provider Zip Code": "35233",
    "Hospital Referral Region Description": "AL - Birmingham",
    "Total Discharges": 32,
    "Provider State": "AL",
    "Average Total Payments": "$8,031.12",
    "Average Covered Charges": "$35,841.09",
    "Average Medicare Payments": "$5,858.50"
  }
]
```

```
https://guarded-tor-63817.herokuapp.com/providers?state=CO&min_average_covered_charges=41000&max_average_covered_charges=42000
```

```
[
  {
    "Provider Name": "MEDICAL CENTER OF AURORA, THE",
    "Provider Street Address": "1501 S POTOMAC ST",
    "Provider City": "AURORA",
    "Provider Zip Code": "80012",
    "Hospital Referral Region Description": "CO - Denver",
    "Total Discharges": 41,
    "Provider State": "CO",
    "Average Total Payments": "$7,252.58",
    "Average Covered Charges": "$41,536.24",
    "Average Medicare Payments": "$5,971.48"
  }
]
```

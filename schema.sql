/* Database schema to keep the structure of entire database. */

CREATE TABLE animals(
    id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR,
    date_of_birth DATE,
    escape_attempts INT,
    neutered BOOLEAN,
    weight_kg DECIMAL,
    PRIMARY KEY(id)
);

-- Query and update animals table
ALTER TABLE animals
ADD species VARCHAR(50);

-- Query multiple tables
CREATE TABLE owners(
    id INT GENERATED ALWAYS AS IDENTITY,
    full_name VARCHAR(50),
    age INT,
    PRIMARY KEY(id)
);

CREATE TABLE species(
    id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(50),
        PRIMARY KEY(id)
);

ALTER TABLE animals DROP COLUMN species;
ALTER TABLE animals
ADD COLUMN species_id INT CONSTRAINT species_fk REFERENCES species (id);
ALTER TABLE animals
ADD COLUMN owner_id INT CONSTRAINT owner_fk REFERENCES owners (id);

-- Add join table for visits
CREATE TABLE vets(
    id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(50),
    age INT,
    date_of_graduation DATE,
    PRIMARY KEY(id)
);

CREATE TABLE specializations(
    species_id INT,
    vet_id INT,
    PRIMARY KEY(species_id, vet_id)
);

CREATE TABLE visits(
    animal_id INT,
    vet_id INT,
    visit_date DATE,
    PRIMARY KEY(animal_id, vet_id, visit_date)
);

-- Database performance audit

ALTER TABLE owners ADD COLUMN email VARCHAR(120);

CREATE INDEX animal_visits ON visits(animal_id ASC);

CREATE INDEX vet_visits ON visits(vet_id ASC);

CREATE INDEX email_ids ON owners(email ASC);
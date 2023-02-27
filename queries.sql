/*Queries that provide answers to the questions from all projects.*/
-- Find all animals whose name ends in "mon".
SELECT * FROM animals WHERE name LIKE '%mon';

-- List the name of all animals born between 2016 and 2019
SELECT name FROM animals WHERE date_of_birth BETWEEN 'Jan 01,2016' AND 'Dec 31, 2019';

-- List the name of all animals that are neutered and have less than 3 escape attempts.
SELECT name FROM animals WHERE neutered = true AND escape_attempts < 3;

-- List the date of birth of all animals named either "Agumon" or "Pikachu".
SELECT date_of_birth FROM animals WHERE name in ('Agumon', 'Pikachu');

-- List name and escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

-- Find all animals that are neutered.
SELECT * FROM animals WHERE neutered = true;

-- Find all animals not named Gabumon.
SELECT * FROM animals WHERE name != 'Gabumon';

-- Find all animals with a weight between 10.4kg and 17.3kg 
-- (including the animals with the weights that equals precisely 10.4kg or 17.3kg)
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

/*Vet clinic database: query and update animals table*/
-- Inside a transaction update the animals table by setting the species column to unspecified.
-- Then roll back the change and verify that the species columns went back to the state before the transaction.
BEGIN;
UPDATE animals
SET species = 'unspecified';
ROLLBACK;

-- Inside a transaction, 
-- Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
-- Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
-- Commit the transaction.
BEGIN;
UPDATE animals
SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals
SET species = 'pokemon' WHERE species = 'null';
COMMIT;

-- Inside a transaction delete all records in the animals table, then roll back the transaction.
BEGIN;
DELETE FROM animals;
ROLLBACK;

-- Inside a transaction: Delete all animals born after Jan 1st, 2022.
-- Create a savepoint for the transaction.
-- Update all animals' weight to be their weight multiplied by -1.
-- Rollback to the savepoint
-- Update all animals' weights that are negative to be their weight multiplied by -1.
-- Commit transaction
BEGIN;
DELETE FROM animals
WHERE date_of_birth > 'Jan 1, 2022';
SAVEPOINT savepoint1;
UPDATE animals
SET weight_kg = (weight_kg * -1);
ROLLBACK TO SAVEPOINT savepoint1;
UPDATE animals
SET weight_kg = (weight_kg * -1)
WHERE weight_kg < 0;
COMMIT;

-- How many animals are there?
SELECT COUNT(*) FROM animals;

-- How many animals have never tried to escape?
  SELECT COUNT(*) FROM animals
  WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) FROM animals
GROUP BY neutered;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MAX(weight_kg), MIN(weight_kg) FROM animals
GROUP BY species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) FROM animals
WHERE date_of_birth BETWEEN 'Jan 01, 1990' AND 'Dec 31, 2000'
GROUP BY species;

/*Vet clinic database: query multiple tables*/
-- What animals belong to Melody Pond?
SELECT animals.name
FROM animals
INNER JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT animals.name
FROM animals
INNER JOIN species ON animals.species_id = species.id
WHERE species.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT owners.full_name, animals.name
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id;

-- How many animals are there per species?
SELECT count(*), species.name
FROM animals
INNER JOIN species ON animals.species_id = species.id
GROUP BY species.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name
FROM animals
INNER JOIN owners ON animals.owner_id = owners.id
INNER JOIN species ON animals.species_id = species.id
WHERE species.name = 'Digimon' 
AND owners.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT animals.name
FROM animals
INNER JOIN owners ON animals.owner_id = owners.id
WHERE animals.escape_attempts = 0
AND owners.full_name = 'Dean Winchester';

-- Who owns the most animals?
SELECT owners.full_name,
COUNT(animals.owner_id)
FROM animals
INNER JOIN owners ON owners.id = animals.owner_id
GROUP BY owners.full_name;

/*Vet clinic database: add "join table" for visits*/
-- Who was the last animal seen by William Tatcher?
SELECT a.name, v.visit_date
FROM animals a
  JOIN visits v ON a.id = v.animal_id
  JOIN vets ve ON v.vet_id = ve.id
WHERE ve.name = 'William Tatcher'
ORDER BY v.visit_date DESC
LIMIT 1;

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(*)
FROM (
        SELECT v.animal_id from visits v
            JOIN vets ve ON v.vet_id = ve.id
        WHERE ve.name = 'Stephanie Mendez'
        GROUP BY v.animal_id
    )as xx;

-- List all vets and their specialties, including vets with no specialties.
SELECT ve.name, s.name
FROM vets ve
  LEFT JOIN specializations sp ON ve.id = sp.vet_id
  LEFT JOIN species s ON sp.species_id = s.id;

  -- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
  SELECT a.name, v.visit_date
FROM animals a
    JOIN visits v ON a.id = v.animal_id
    JOIN vets as ve ON v.vet_id = ve.id
WHERE ve.name = 'Stephanie Mendez'
    AND v.visit_date BETWEEN 'April 1, 2020' AND 'August 30, 2020';

-- What animal has the most visits to vets?
SELECT COUNT(v.animal_id) as total_animal_visits, a.name, v.visit_date
FROM visits v
    JOIN animals a ON v.animal_id = a.id
GROUP BY a.name, v.visit_date
ORDER BY total_animal_visits DESC
LIMIT 1;

-- Who was Maisy Smith's first visit?
SELECT a.name
FROM animals a
    JOIN visits v ON a.id = v.animal_id
    JOIN vets ve ON v.vet_id = ve.id
WHERE ve.name = 'Maisy Smith'
ORDER BY v.visit_date ASC
LIMIT 1;

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT a.name as animal_name,
    a.date_of_birth,
    a.escape_attempts,
    a.neutered,
    a.weight_kg,
    ve.name as vet_name,
    ve.age,
    ve.date_of_graduation,
    v.visit_date
FROM animals a
    JOIN visits v ON a.id = v.animal_id
    JOIN vets ve ON v.vet_id = ve.id
ORDER BY v.visit_date DESC
LIMIT 1;

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT count(*)
FROM visits v
    JOIN vets ve ON v.vet_id = ve.id
    JOIN animals a ON v.animal_id = a.id
    JOIN species s ON a.species_id = s.id
WHERE ve.name = 'Maisy Smith'

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT count(*) as total_visits,
    s.name as species_name
FROM visits v
    JOIN vets ve ON v.vet_id = ve.id
    JOIN animals a ON v.animal_id = a.id
    JOIN species s ON a.species_id = s.id
WHERE ve.name = 'Maisy Smith'
GROUP BY s.name
ORDER BY total_visits DESC;

-- WEEK 2 DAY 1

EXPLAIN ANALYZE SELECT COUNT(*) FROM visits where animal_id = 4;

EXPLAIN ANALYZE SELECT * FROM visits where vet_id = 2;

EXPLAIN ANALYZE SELECT * FROM owners where email = 'owner_18327@mail.com';
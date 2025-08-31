CREATE DATABASE realestate;


USE realestate;


CREATE TABLE office (
    of_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(100),
    man_id INT UNIQUE
);


CREATE TABLE employee (
    em_id INT PRIMARY KEY AUTO_INCREMENT,
    em_name VARCHAR(30),
    office_id INT,
    FOREIGN KEY (office_id) REFERENCES office(of_id)
);

ALTER TABLE office
ADD CONSTRAINT fk_manager
FOREIGN KEY (man_id) REFERENCES employee(em_id);


CREATE TABLE property (
    pr_id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(60),
    zip VARCHAR(40),
    office_id INT NOT NULL,
    FOREIGN KEY (office_id) REFERENCES office(of_id)
);


CREATE TABLE owner (
    o_id INT PRIMARY KEY AUTO_INCREMENT,
    o_name VARCHAR(30)
);


CREATE TABLE propertyowner (
    prop_id INT,
    owner_id INT,
    percent_owned DECIMAL(6,2),
    PRIMARY KEY (prop_id, owner_id),
    FOREIGN KEY (prop_id) REFERENCES property(pr_id),
    FOREIGN KEY (owner_id) REFERENCES owner(o_id)
);


INSERT INTO office (location) VALUES
('Cairo'),
('Alex'),
('Aswan');


INSERT INTO employee (em_name, office_id) VALUES
('Mohamed', 1),
('Ahmed', 2),
('Ziad', 3),
('Samy', 2),
('Seif', 1);


UPDATE office SET man_id = 1 WHERE of_id = 1; 
UPDATE office SET man_id = 2 WHERE of_id = 2; 
UPDATE office SET man_id = 3 WHERE of_id = 3;


INSERT INTO property (address, city, state, zip, office_id) VALUES
('26k', 'Cairo', '404l', '1125', 2),
('223o', 'Alex', '884l', '1142', 1),
('296s', 'Giza', '222l', '9611', 3),
('40dk', 'Aswan', '995l', '3335', 2),
('99a', 'Luxor', '66l', '1239', 1);


INSERT INTO owner (o_name) VALUES
('Kamal'),
('Zain'),
('Amira'),
('Hady');


INSERT INTO propertyowner (prop_id, owner_id, percent_owned) VALUES
(1, 1, 100.00),
(2, 2, 60.00), (2, 3, 40.00),
(3, 4, 100.00),
(4, 1, 100.00),
(5, 2, 100.00);


SELECT e.em_id, e.em_name
FROM employee e
JOIN office o ON e.office_id = o.of_id
WHERE o.location = 'Cairo';

select pr_id  ,address, city
from property
where city ="Alex";


SELECT p.pr_id, p.address, o.location AS office_location
FROM property p
JOIN office o ON p.office_id = o.of_id;

SELECT ow.o_name, p.address, po.percent_owned
FROM owner ow
JOIN propertyowner po ON ow.o_id = po.owner_id
JOIN property p ON po.prop_id = p.pr_id;


SELECT o.location, COUNT(e.em_id) AS num_employees
FROM office o
LEFT JOIN employee e ON o.of_id = e.office_id
GROUP BY o.location;


SELECT AVG(property_count) AS avg_properties_per_office
FROM (
    SELECT office_id, COUNT(*) AS property_count
    FROM property
    GROUP BY office_id
) t;

SELECT e.em_id, e.em_name
FROM employee e
WHERE e.em_id NOT IN (SELECT man_id FROM office WHERE man_id IS NOT NULL);


SELECT o.location, COUNT(p.pr_id) AS property_count
FROM office o
JOIN property p ON o.of_id = p.office_id
GROUP BY o.location
HAVING COUNT(p.pr_id) > (
    SELECT AVG(property_count)
    FROM (
        SELECT office_id, COUNT(*) AS property_count
        FROM property
        GROUP BY office_id
    ) t
);


SELECT ow.o_name, COUNT(po.prop_id) AS num_properties
FROM owner ow
JOIN propertyowner po ON ow.o_id = po.owner_id
GROUP BY ow.o_id, ow.o_name
HAVING COUNT(po.prop_id) > 1;


CREATE VIEW office_summary AS
SELECT o.of_id, o.location,
       COUNT(DISTINCT e.em_id) AS num_employees,
       COUNT(DISTINCT p.pr_id) AS num_properties
FROM office o
LEFT JOIN employee e ON o.of_id = e.office_id
LEFT JOIN property p ON o.of_id = p.office_id
GROUP BY o.of_id, o.location;


CREATE INDEX idx_property_city ON property(city);


START TRANSACTION;
    DELETE FROM propertyowner WHERE prop_id = 2;
    INSERT INTO propertyowner (prop_id, owner_id, percent_owned)
    VALUES (2, 3, 100.00);
COMMIT;
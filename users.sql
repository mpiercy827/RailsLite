CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL
);

INSERT INTO
  users (id, name, email)
VALUES
  (1, "Matt Piercy", "foo@bar.com");

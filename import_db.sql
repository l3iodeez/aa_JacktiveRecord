

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(50) NOT NULL,
  lname VARCHAR(50) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  body TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Henry', 'Dotson'),
  ('William', 'Liang');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('How to SQL?','What is a SELECT?', 1),
  ('How to Ruby?', 'What is a method?', 1),
  ('What is Rails?', 'Activewhat?', 2);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (1,3),
  (2,1),
  (2,2);

INSERT INTO
  replies(question_id, user_id, parent_id, body)
VALUES
  (1, 2, NULL, 'Hi'),
  (3, 1, NULL, 'Hola');

INSERT INTO
  replies(question_id, user_id, parent_id, body)
VALUES
  (1, 1, (SELECT MAX(id) FROM replies WHERE question_id = 1), 'Hello');

  INSERT INTO
    question_likes(user_id, question_id)
  VALUES
    (1,3),
    (2,1),
    (2,2);

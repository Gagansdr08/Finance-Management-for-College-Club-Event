-- Drop existing tables if they exist
DROP TABLE IF EXISTS club,
domain,
event,
member,
participants,
transactions CASCADE;
-- Create table `event`
CREATE TABLE event (
  event_id VARCHAR(10) NOT NULL,
  event_name VARCHAR(20) DEFAULT NULL,
  venue VARCHAR(10) DEFAULT NULL,
  date DATE DEFAULT NULL,
  total_budget NUMERIC(10, 2) DEFAULT NULL,
  PRIMARY KEY (event_id)
);
-- Create table `club`
CREATE TABLE club (
  club_id VARCHAR(10) NOT NULL,
  club_name VARCHAR(10) NOT NULL,
  vertical VARCHAR(10) DEFAULT NULL,
  event_id VARCHAR(10) DEFAULT NULL,
  headed_by VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (club_id, club_name),
  CONSTRAINT fk_club2event FOREIGN KEY (event_id) REFERENCES event (event_id),
  CONSTRAINT fk_club2member FOREIGN KEY (headed_by) REFERENCES member (member_id)
);
-- Insert data into `club`
INSERT INTO club
VALUES ('AIK01', 'Aikya', 'Social', 'EV02', NULL),
  ('EMB01', 'Embrione', 'CS', 'EV01', 'MEM00');
-- Create table `domain`
CREATE TABLE domain (
  domain_id VARCHAR(10) NOT NULL,
  domain_name VARCHAR(10) DEFAULT NULL,
  sub_budget NUMERIC(10, 2) DEFAULT 0.00,
  club_id VARCHAR(10) DEFAULT NULL,
  headed_by VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (domain_id)
);
ALTER TABLE domain
ADD CONSTRAINT fk_domain2member FOREIGN KEY (headed_by) REFERENCES member (member_id);
-- Insert data into `domain`
INSERT INTO domain
VALUES ('HEAD', 'head', 0.00, 'EMB01', 'MEM00'),
  ('LOG', 'logistics', 5000.00, 'EMB01', 'MEM01'),
  ('MARK', 'marketing', 10000.00, 'EMB01', 'MEM03'),
  ('OP', 'operations', 4000.00, 'EMB01', 'MEM100');
-- Insert data into `event`
INSERT INTO event
VALUES (
    'EV01',
    'Kodikon',
    'PESU52',
    '2023-11-11',
    100000.00
  ),
  (
    'EV02',
    'Haul It Away',
    'PESU52',
    '2023-12-15',
    50000.00
  );
-- Create table `member`
CREATE TABLE member (
  member_id VARCHAR(10) NOT NULL,
  name VARCHAR(10) NOT NULL,
  domain_id VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (member_id),
  CONSTRAINT fk_member2domain FOREIGN KEY (domain_id) REFERENCES domain (domain_id)
);
-- Insert data into `member`
INSERT INTO member
VALUES ('MEM00', 'Krishna', 'HEAD'),
  ('MEM01', 'Amitabh', 'LOG'),
  ('MEM02', 'Abhishek', 'OP'),
  ('MEM03', 'Dhruv', 'MARK'),
  ('MEM10', 'Rahul', 'LOG'),
  ('MEM100', 'Saurabh', 'OP'),
  ('MEM101', 'Kriti', 'OP'),
  ('MEM200', 'Shyam', 'LOG');
-- Create table `participants`
CREATE TABLE participants (
  srn VARCHAR(10) NOT NULL,
  name VARCHAR(10) NOT NULL,
  phone_no INTEGER DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  transaction_id VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (srn),
  CONSTRAINT fk_part2trans FOREIGN KEY (transaction_id) REFERENCES transactions (trans_id)
);
-- Insert data into `participants`
INSERT INTO participants
VALUES ('PES01', 'Ram', 1234, 'ram@gmail.com', 'T001'),
  ('PES02', 'Laxman', 2345, 'lax@gmail.com', 'T002'),
  (
    'PES038',
    'Bharat',
    12345,
    'bharat@gmail.com',
    'T100'
  );
-- Create table `transactions`
CREATE TABLE transactions (
  trans_id VARCHAR(10) NOT NULL,
  type VARCHAR(50) DEFAULT NULL,
  date DATE DEFAULT NULL,
  mode VARCHAR(10) DEFAULT NULL,
  amount NUMERIC(10, 2) DEFAULT NULL,
  remarks VARCHAR(100) DEFAULT NULL,
  domain_id VARCHAR(10) DEFAULT NULL,
  event_id VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (trans_id),
  CONSTRAINT fk_trans2domain FOREIGN KEY (domain_id) REFERENCES domain (domain_id),
  CONSTRAINT fk_trans2events FOREIGN KEY (event_id) REFERENCES event (event_id)
);
-- Insert data into `transactions`
INSERT INTO transactions
VALUES (
    'T001',
    'Register',
    '2023-10-01',
    'Online',
    150.00,
    NULL,
    'LOG',
    'EV01'
  ),
  (
    'T002',
    'Register',
    '2023-10-01',
    'Cash',
    300.00,
    NULL,
    'LOG',
    'EV01'
  ),
  (
    'T003',
    'Expenditure',
    '2023-10-02',
    'Online',
    2500.00,
    'Banners and posters',
    'MARK',
    'EV01'
  ),
  (
    'T004',
    'Sponsor',
    '2023-10-05',
    'Check',
    20000.00,
    'Red Bull',
    'MARK',
    'EV01'
  ),
  (
    'T005',
    'Register',
    '2023-10-06',
    'Cash',
    150.00,
    NULL,
    'LOG',
    'EV01'
  ),
  (
    'T006',
    'Expenditure',
    '2023-11-08',
    'Online',
    5000.00,
    'Free cool drinks',
    'MARK',
    'EV01'
  ),
  (
    'T0101',
    'Register',
    '2023-11-10',
    'Cash',
    300.00,
    '',
    'LOG',
    'EV01'
  ),
  (
    'T011',
    'Expenditure',
    '2023-11-08',
    'Online',
    1000.00,
    'Pizza and snacks',
    'OP',
    'EV01'
  ),
  (
    'T100',
    'Register',
    '2023-11-14',
    'Online',
    300.00,
    'Tickets',
    'LOG',
    'EV01'
  );
-- Create trigger function to delete participants on transaction deletion
CREATE OR REPLACE FUNCTION trg_delete_participant() RETURNS TRIGGER AS $$ BEGIN
DELETE FROM participants
WHERE transaction_id = OLD.trans_id;
RETURN OLD;
END;
$$ LANGUAGE plpgsql;
-- Create trigger
CREATE TRIGGER trg_delete_participant BEFORE DELETE ON transactions FOR EACH ROW EXECUTE FUNCTION trg_delete_participant();
-- Create function to calculate domain expenditure
CREATE OR REPLACE FUNCTION domain_expenditure(dom_id VARCHAR) RETURNS NUMERIC(10, 2) AS $$
DECLARE total NUMERIC(10, 2);
BEGIN
SELECT COALESCE(SUM(amount), 0) INTO total
FROM transactions
WHERE domain_id = dom_id
  AND type = 'Expenditure';
RETURN total;
END;
$$ LANGUAGE plpgsql;
-- Create function to calculate domain income
CREATE OR REPLACE FUNCTION domain_income(dom_id VARCHAR) RETURNS NUMERIC(10, 2) AS $$
DECLARE total NUMERIC(10, 2);
BEGIN
SELECT COALESCE(SUM(amount), 0) INTO total
FROM
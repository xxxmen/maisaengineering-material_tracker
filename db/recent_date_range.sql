CREATE OR REPLACE VIEW recent_date_range AS
    SELECT numbers.id,
        DATE_SUB(CURDATE(), INTERVAL (numbers.id - 1) DAY) AS date, 
        dayname(DATE_SUB(CURDATE(), INTERVAL (numbers.id - 1) DAY)) AS dayname FROM 
            numbers WHERE numbers.id < 30;

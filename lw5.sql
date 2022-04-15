# 1
USE lw5;
ALTER TABLE booking
	ADD FOREIGN KEY(id_client) REFERENCES client(id_client);
ALTER TABLE room
	ADD FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel);
ALTER TABLE room
	ADD FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category);
ALTER TABLE room_in_booking
	ADD FOREIGN KEY(id_booking) REFERENCES booking(id_booking);
ALTER TABLE room_in_booking
	ADD FOREIGN KEY(id_room) REFERENCES room(id_room);

# 2 Выдать информацию о клиентах гостиницы "Космос", проживающих в номерах категории "Люкс" на 1 апреля 2019г.
SELECT client.name FROM client 
	LEFT JOIN booking ON booking.id_client = client.id_client
    LEFT JOIN room_in_booking rib ON rib.id_booking = booking.id_booking
    LEFT JOIN room ON room.id_room = rib.id_room
    LEFT JOIN room_category rc ON rc.id_room_category = room.id_room_category
    LEFT JOIN hotel ON hotel.id_hotel = room.id_hotel
    WHERE rib.checkin_date <= '2019-04-01' AND rib.checkout_date > '2019-04-01' AND rc.name = 'Люкс' AND hotel.name = 'Космос';
    
# 3  Дать список свободных номеров всех гостиниц на 22 апреля. 
SELECT DISTINCT room.number, room.price, rc.name, h.name FROM room 
	LEFT JOIN room_category rc ON rc.id_room_category = room.id_room_category
	LEFT JOIN hotel h ON h.id_hotel = room.id_hotel
	LEFT JOIN room_in_booking rib ON rib.id_room = room.id_room
	WHERE ((rib.checkin_date < '2019-04-22' AND rib.checkout_date <= '2019-04-22') OR (rib.checkin_date > '2019-04-22'));

# 4 Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров. 
SELECT rc.name, COUNT(rib.id_room_in_booking) AS number_of_clients FROM room 
	LEFT JOIN room_category rc ON rc.id_room_category = room.id_room_category
	LEFT JOIN hotel h ON h.id_hotel = room.id_hotel
	LEFT JOIN room_in_booking rib ON rib.id_room = room.id_room
	WHERE h.name = 'Космос' AND rib.checkin_date <= '2019-03-23' AND rib.checkout_date > '2019-03-23'
	GROUP BY rc.name;

# 5 Дать список последних проживавших клиентов по всем комнатам гостиницы "Космос", выехавшим в апреле с указанием даты выезда. 
SELECT room.number, c.name, rib.checkout_date FROM client c
	LEFT JOIN booking b ON b.id_client = c.id_client
	LEFT JOIN room_in_booking rib ON rib.id_booking = b.id_booking
	LEFT JOIN room  ON room.id_room = rib.id_room
	INNER JOIN (SELECT room.id_room, MAX(rib.checkout_date) AS last_checkout_date FROM room 
					INNER JOIN room_in_booking rib ON rib.id_room = room.id_room AND
						rib.checkout_date >= '2019-04-01' AND rib.checkout_date <= '2019-04-30'
					INNER JOIN hotel h ON h.id_hotel = room.id_hotel AND h.name = 'Космос'
					GROUP BY room.id_room
				) AS rr ON rr.id_room = room.id_room AND rr.last_checkout_date = rib.checkout_date;

# 6 Продлить на 2 дня дату проживания в гостинице "Космос" всем клиентам комнат категории "Бизнес", которые заселились 10 мая. 
UPDATE room_in_booking rib 
	LEFT JOIN room ON room.id_room = rib.id_room
	LEFT JOIN room_category rc ON rc.id_room_category = room.id_room_category
	LEFT JOIN hotel h ON h.id_hotel = room.id_hotel
    SET checkout_date = DATE_ADD(checkout_date, INTERVAL 2 DAY) 
	WHERE rib.checkin_date = '2019-05-10' AND rc.name = 'Бизнес' AND h.name = 'Космос';

# 7 Найти все "пересекающиеся" варианты проживания. 
SELECT DISTINCT * FROM room_in_booking rib1
	INNER JOIN room_in_booking rib2 ON rib2.id_room_in_booking != rib1.id_room_in_booking AND rib2.id_room = rib1.id_room
	WHERE (rib1.checkin_date >= rib2.checkin_date AND rib1.checkin_date < rib2.checkout_date) OR
          (rib2.checkin_date >= rib1.checkin_date AND rib2.checkin_date < rib1.checkout_date);

# 8 Создать бронирование в транзакции. 
START TRANSACTION;
  INSERT INTO client (name, phone) VALUES ('Петров Петр Петрович', '+7999999999');
  INSERT INTO booking (id_client, booking_date) 
	(SELECT id_client, '2022-02-25' FROM client WHERE client.name = 'Петров Петр Петрович' AND client.phone = '+7999999999');
  INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
	(SELECT id_booking, 233, '2022-03-01', '2022-03-04' FROM booking WHERE booking.id_client = 	
      (SELECT id_client FROM client WHERE client.name = 'Петров Петр Петрович' AND client.phone = '+7999999999' LIMIT 1));
COMMIT;

# 9
CREATE INDEX index_room_in_booking_checkin_date ON room_in_booking(checkin_date);
CREATE INDEX index_room_in_booking_checkout_date ON room_in_booking(checkout_date);
CREATE INDEX index_room_category_name ON room_category(name);
CREATE INDEX index_hotel_name ON hotel(name);

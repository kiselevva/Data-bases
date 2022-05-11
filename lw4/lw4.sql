
USE lw4;
#без указания списка полей
INSERT INTO genre
	VALUES(1, 'Комедия', 'Описание жанра комедия');
#с указанием списка полей
INSERT INTO genre (id_genre, name, description)
	VALUES(2, 'Роман','Описания жанра роман');
INSERT INTO genre
	VALUES(3, 'Поэма', 'Описание');
#с чтением значения из другой таблицы
INSERT INTO author (first_name, last_name, date_of_birth)
	SELECT first_name, last_name, date_of_birth FROM employee;

#удаление всех записей    
DELETE FROM genre;
#удаление по условию
DELETE FROM author WHERE first_name='Иван' AND last_name='Иванов';

#update всех записей
UPDATE employee SET first_name='Николай';
#по условию обновляя один атрибут
UPDATE employee SET first_name='Анатолий' WHERE id_employee='2';
#по условию обновляя несколько атрибутов
UPDATE employee SET first_name='Александр', last_name='Волков' WHERE id_employee='1';

#с набором извлекаемых атрибутов (SELECT atr 1, atr 2 FROM...)
SELECT id_employee, last_name FROM employee;
#со всеми атрибутами (SELECT * FROM...)
SELECT * FROM employee;
#c условием по атрибуту (SELECT * FROM ... WHERE atr1 = value)
SELECT * FROM employee WHERE first_name='Иван';

#с сортировкой по возрастанию ASC + ограничение вывода количества записей
SELECT * FROM author ORDER BY first_name ASC LIMIT 2, 3;
#c сортировкой по убыванию DESC
SELECT * FROM author ORDER BY id_author DESC;
#c сортировкой по двум атрибутам + ограничение вывода количества записей
SELECT * FROM author ORDER BY last_name, date_of_birth LIMIT 4;
#c cортировкой по первому атрибуту, из списка извлекаемых
SELECT * FROM author ORDER BY id_author;

#where по дате
SELECT * FROM book WHERE date_publishing='1836-10-14';
#where по дате в диапазоне
SELECT * FROM book WHERE date_publishing > '1825-10-14' AND date_publishing < '1860-04-19';
#извлечь только год year
SELECT id_book, YEAR(date_publishing) as year_publishing FROM book;

#посчитать кол-во записей в таблице
SELECT COUNT(*) FROM author;
#посчитать кол-во уникальных записей в таблице
SELECT COUNT(DISTINCT(id_author)) FROM author;
#вывести уникальные значения столбца
SELECT DISTINCT(id_author) FROM author;
#найти максимальное значение столбца
SELECT MAX(id_author) FROM author;
#найти минимальное значение столбца
SELECT MIN(id_author) FROM author;
#написать запрос COUNT() + GROUP BY
SELECT COUNT(id_author), last_name FROM author GROUP BY last_name;

#выводит полную сумму продаж каждого работника, где общая сумма продаж превышает 1100
SELECT id_employee, SUM(amount) AS total_amount FROM sale GROUP BY id_employee HAVING SUM(amount)>1100; 
#выводит кол-во выпущенных книг каждого издательства, где кол-во страниц больше 170
SELECT id_publishing_house, COUNT(id_book) AS book_quantity, page_number FROM book GROUP BY id_publishing_house HAVING AVG(page_number) > 170;
#выводит количество проданных экземпляров каждой книги, где дата продажи позже 2022-02-01 00:00:00
SELECT id_copy, SUM(quantity) AS total_quantity FROM sale GROUP BY id_copy, sale_date HAVING sale_date > '2022-02-01 00:00:00';

SELECT genre.id_genre, genre.name, book.id_genre, book.name FROM genre
	LEFT JOIN book ON genre.id_genre = book.id_genre 
    WHERE genre.id_genre > 2;
SELECT genre.id_genre, genre.name, book.id_genre, book.name FROM genre
	RIGHT JOIN book ON genre.id_genre = book.id_genre 
    WHERE genre.id_genre < 2;
#сколько каждый сотрудник продал экземпляров книг
SELECT employee.id_employee, SUM(sale.quantity) AS total_quantity FROM employee
	LEFT JOIN sale ON employee.id_employee = sale.id_employee
    LEFT JOIN copy ON copy.id_copy = sale.id_copy
    LEFT JOIN book ON book.id_book = copy.id_book
    GROUP BY employee.id_employee    HAVING total_quantity > 5;
SELECT genre.id_genre, genre.name, book.id_genre, book.name FROM genre 
	INNER JOIN book ON genre.id_genre = book.id_genre;
    
#выберем все экземпляры книг из copy, которые были проданы в таблице sale
SELECT id_copy, id_book FROM copy
WHERE id_copy IN (SELECT id_copy FROM sale); 
#выберем все выпущенные экземпляры книг и добавим информацию о названии книги
SELECT id_copy, id_book, quantity, (SELECT name FROM book WHERE book.id_book = copy.id_book) AS book_name FROM copy;
#
SELECT name, date_publishing FROM 
	(SELECT * FROM book WHERE name = 'Тихий Дон') book
    ORDER BY book.name;
#
SELECT name, description FROM book 
	INNER JOIN (SELECT * FROM copy WHERE date_of_printing > '2000-01-01') c ON book.id_book = c.id_book;

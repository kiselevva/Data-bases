# 1
ALTER TABLE dealer
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_production) REFERENCES production(id_production);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer);
ALTER TABLE `order`
	ADD FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy);
ALTER TABLE production
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE production
	ADD FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine);
    
# 2. Выдать информацию по всем заказам лекарства "Кордерон" компании "Аргус" с указанием названий аптек, дат, объема заказов.
SELECT p.name, o.date, o.quantity FROM `order` o
	LEFT JOIN pharmacy p ON p.id_pharmacy = o.id_pharmacy
	LEFT JOIN production pr ON pr.id_production = o.id_production
	LEFT JOIN company c ON c.id_company = pr.id_company
	LEFT JOIN medicine m ON m.id_medicine = pr.id_medicine
	WHERE m.name = 'Кордерон' AND c.name = 'Аргус';

# 3.  Дать список лекарств компании "Фарма", на которые не были сделаны заказы до 25 января. 
SELECT m.name FROM medicine m WHERE m.id_medicine NOT IN (
	SELECT m.id_medicine FROM medicine m
		LEFT JOIN production pr ON pr.id_medicine = m.id_medicine
		LEFT JOIN company c ON c.id_company = pr.id_company
		INNER JOIN `order` o ON o.id_production = pr.id_production
		WHERE c.name = 'Фарма'
		GROUP BY m.id_medicine
		HAVING (MIN(o.date) > '2019-02-25')
);

# 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов. 
SELECT c.name, MIN(pr.rating) AS min_rating, MAX(pr.rating) AS max_rating FROM medicine m
	LEFT JOIN production pr ON pr.id_medicine = m.id_medicine
	LEFT JOIN company c ON c.id_company = pr.id_company
	LEFT JOIN `order` o ON o.id_production = pr.id_production
	GROUP BY c.name
	HAVING COUNT(o.id_order) >= 120;

# 5. Дать списки сделавших заказы аптек по всем дилерам компании "AstraZeneca". Если у дилера нет заказов, в названии аптеки проставить NULL. 
SELECT p.name, d.name FROM company c
	LEFT JOIN dealer d ON d.id_company = c.id_company
	LEFT JOIN `order` o ON o.id_dealer = d.id_dealer
	LEFT JOIN pharmacy p ON p.id_pharmacy = o.id_pharmacy
	WHERE c.name = 'AstraZeneca';

# 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней. 
UPDATE production pr 
	LEFT JOIN medicine m ON m.id_medicine = pr.id_medicine
    SET price = (price * 0.8) 
	WHERE pr.price > 3000 AND m.cure_duration <= 7;

# 7 
CREATE INDEX index_production_price ON production(price);
CREATE INDEX index_medicine_cure_duration ON medicine(cure_duration);
CREATE INDEX index_company_name ON company(name);
CREATE INDEX index_medicine_name ON medicine(name);
CREATE INDEX index_order_date ON `order`(date);

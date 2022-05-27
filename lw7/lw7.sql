USE lw7;
# 1.
ALTER TABLE student
	ADD FOREIGN KEY(id_group) REFERENCES `group`(id_group);
ALTER TABLE mark
	ADD FOREIGN KEY(id_lesson) REFERENCES lesson(id_lesson);
ALTER TABLE mark
	ADD FOREIGN KEY(id_student) REFERENCES student(id_student);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_teacher) REFERENCES teacher(id_teacher);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_subject) REFERENCES subject(id_subject);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_group) REFERENCES `group`(id_group);

# 2. Выдать оценки студентов по информатике если они обучаются данному предмету. Оформить выдачу данных с использованием view. 
CREATE VIEW informatics_marks AS
SELECT st.name, m.mark FROM student st
	LEFT JOIN mark m ON m.id_student = st.id_student
	LEFT JOIN lesson l ON l.id_lesson = m.id_lesson
	LEFT JOIN subject s ON s.id_subject = l.id_subject
	WHERE s.name = 'Информатика';

SELECT * FROM informatics_marks;

# 3. Дать информацию о должниках с указанием фамилии студента и названия предмета. Должниками считаются студенты, не имеющие оценки по предмету, 
#    который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы. 
CREATE PROCEDURE get_debtors (IN id_group INT)
BEGIN
SELECT st.name AS student, s.name AS subject FROM student st
	LEFT JOIN `group` g ON g.id_group = st.id_group
	LEFT JOIN lesson l ON l.id_group = g.id_group
	LEFT JOIN subject s ON s.id_subject = l.id_subject
    LEFT JOIN mark m ON m.id_lesson = l.id_lesson AND m.id_student = st.id_student
	WHERE g.id_group = 1
	GROUP BY st.name, s.name
	HAVING COUNT(m.mark) = 0
END;

CALL get_debtors ('1', @id_group);
SELECT * FROM student;

# 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, о которым занимается не менее 35 студентов.
SELECT stat.id_subject, AVG(m.mark) FROM (
SELECT subject_has_student.id_subject FROM
	(SELECT DISTINCT s.id_subject, s.name AS subject, st.id_student FROM subject s
		LEFT JOIN lesson l ON l.id_subject = s.id_subject
        LEFT JOIN `group` g ON g.id_group = l.id_group
		LEFT JOIN student st ON st.id_group = g.id_group) subject_has_student
		GROUP BY subject_has_student.id_subject
		HAVING COUNT(subject_has_student.id_student) > 35
) stat
JOIN lesson l ON l.id_subject = stat.id_subject
JOIN mark m ON m.id_lesson = l.id_lesson
GROUP BY stat.id_subject;

# 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить 
#   значениями NULL поля оценки. 
SELECT DISTINCT g.name AS `group`, st.name AS student, s.name AS subject, l.date, m.mark FROM `group` g
	LEFT JOIN student st ON st.id_group = g.id_group
	LEFT JOIN lesson l ON l.id_group = g.id_group
	LEFT JOIN subject s ON s.id_subject = l.id_subject
	LEFT JOIN mark m ON m.id_student = st.id_student AND m.id_lesson = l.id_lesson
	WHERE g.name = 'ВМ';

# 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл. 
SELECT m.id_mark FROM `group` g
	LEFT JOIN lesson l ON l.id_group = g.id_group
	LEFT JOIN mark m ON m.id_lesson = l.id_lesson
	LEFT JOIN subject s ON s.id_subject = l.id_subject
	WHERE g.name = 'ПС' AND s.name = 'БД' AND l.date < '12.05.2019' AND m.mark < 5;

UPDATE mark 
	LEFT JOIN lesson l ON l.id_group = `group`.id_group
	LEFT JOIN mark m ON m.id_lesson = l.id_lesson
	LEFT JOIN subject s ON s.id_subject = l.id_subject
    SET mark = mark + 1 
	WHERE `group`.name = 'ПС' AND s.name = 'БД' AND l.date < '12.05.2019' AND m.mark < 5;

# 7.
CREATE INDEX index_subject_name ON subject(name);
CREATE INDEX index_mark_mark ON mark(mark);
CREATE INDEX index_group_name ON `group`(name);
CREATE INDEX index_lesson_date ON lesson(date);
create database DrivingSchool
go
use DrivingSchool

create table Category
(
Category_Id tinyint primary key identity,
[Name] nvarchar(30),
[Desc] nvarchar(40),
)

create table Groups
(
Group_Id smallint primary key identity,
[Name] nvarchar(30),
Category tinyint not null

foreign key (Category) references Category(Category_Id)
)

create table Students
(
Student_Id int primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
[Address] nvarchar(30),
Phone nvarchar(12)
)

create table GroupsList
(
GL_Id int primary key identity,
[Group] smallint not null,
Student int not null

foreign key ([Group]) references Groups(Group_Id),
foreign key (Student) references Students(Student_Id)
)

create table Cars
(
Car_Id tinyint primary key identity,
StateNumber nvarchar(11),
Mark nvarchar(30),
Color nvarchar(30)
)

create table Instructors
(
Instructor_Id tinyint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
[Address] nvarchar(30),
Phone nvarchar(12)
)

create table Exams
(
Exam_Id bigint primary key identity,
Student int not null,
Instructor tinyint not null,
Car tinyint not null,
[Date] datetime

foreign key (Instructor) references Instructors(Instructor_Id),
foreign key (Student) references Students(Student_Id),
foreign key (Car) references Cars(Car_Id)
)

create table Payment 
(
Pay_Id bigint primary key identity,
Student int not null,
Exam bigint not null,
Summ smallint,
[Date] datetime default GETDATE()

foreign key (Exam) references Exams(Exam_Id),
foreign key (Student) references Students(Student_Id)
)

go
create trigger StudentName
on Students
after insert,update
as
Update Students
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger InstructorName
on Instructors
after insert,update
as
Update Instructors
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger PaymentSumm
on Payment
after insert,update
as
if(select Summ from inserted) < 0
begin
Print 'Сумма оплаты не может быть отрицательным числом'
update Payment set Summ = 0 where Pay_Id = (select Pay_Id from inserted)
end

go
create procedure AddPayment
@Student int, @Exam bigint, @Summ smallint
as
insert into Payment(Student,Exam,Summ) values (@Student,@Exam,@Summ)

go
create procedure GroupStudentsCount
@GroupName nvarchar(30)
as
declare @GroupId smallint = (select Group_Id from Groups where [Name] = @GroupName), @StudentsCount int
select @StudentsCount = COUNT(*) from GroupsList where [Group] = @GroupId
print 'В группе ' + @GroupName + ': ' + @StudentsCount + ' человек.'

go
create view GroupsListView
as
select Groups.[Name] as 'Группа', Students.Surname + ' ' + Students.[Name] + ' ' + Students.Patronymic as 'Учащийся' from GroupsList
inner join Groups on Group_Id = [Group]
inner join Students on Student_Id = Student

go
create view PaymentView
as
select Students.Surname + ' ' + Students.[Name] + ' ' + Students.Patronymic as 'Учащийся', 
Instructors.Surname + ' ' + Instructors.[Name] + ' ' + Instructors.Patronymic as 'Инструктор', 
Cars.StateNumber as 'Гос. номер машины', [Date] as 'Дата проведения' from Exams
inner join Instructors on Instructor_Id = Instructor
inner join Cars on Car_Id = Car
inner join Students on Student_Id = Student
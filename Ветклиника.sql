create database Vet_Clinic
go

use Vet_Clinic

create table [Owner]
(
Owner_Id int primary key identity,
Surname nvarchar(50),
[Name] nvarchar (50),
Patronymic nvarchar(50),
[Address] nvarchar(150),
Phone nvarchar(12)
)

create table Animal
(
Animal_Id smallint primary key identity,
[Name] nvarchar(50),
Old tinyint,
Birthday date,
[Owner] int not null

foreign key ([Owner]) references [Owner](Owner_Id)
)

create table Post
(
Post_Id tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(150)
)

create table Specification
(
Specification_Id tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(150) 
)

create table Doctor
(
Doctor_Id smallint primary key identity,
Surname nvarchar(50) ,
[Name] nvarchar(50) ,
Patronymic nvarchar(50),
Experience tinyint ,
Schedule nvarchar(50),
Cabinet tinyint ,
Post tinyint not null,
Specification tinyint not null

foreign key (Post) references Post(Post_Id),
foreign key (Specification) references Specification(Specification_Id)
)

create table Reseption
(
Note_Id smallint primary key identity,
[Date] datetime2 ,
Doctor smallint not null,
Animal smallint not null

foreign key (Doctor) references Doctor(Doctor_Id),
foreign key (Animal) references Animal(Animal_Id)
)

create table Symptoms
(
Symptom_Id tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(50)
)

create table SymptomsJournal
(
Note_Id int primary key identity,
ReseptionNote smallint not null,
Symptoms tinyint not null

foreign key (ReseptionNote) references Reseption(Note_Id),
foreign key (Symptoms) references Symptoms(Symptom_Id)
)

create table Treatment
(
Treatment_Id tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(150)
)

create table TreatmentJournal
(
Note_Id int primary key identity,
Treatment tinyint not null,
ReseptionNote smallint not null

foreign key (Treatment) references Treatment(Treatment_Id),
foreign key (ReseptionNote) references Reseption(Note_Id)
)

create table DiseaseClassification
(
Class_Id tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(150)
)

create table Disease
(
Disease tinyint primary key identity,
[Name] nvarchar(50),
[Description] nvarchar(150),
[Classification] tinyint,

foreign key ([Classification]) references  DiseaseClassification(Class_Id)
)

create table DiseaseJournal
(
Note_Id int primary key identity,
ReseptionNote smallint not null,
Disease tinyint not null,
DiseaseDate date

foreign key (ReseptionNote) references Reseption(Note_Id),
foreign key (Disease) references Disease(Disease),
)


go

create trigger UpdateOwnerFIO
on [Owner]
after insert,update
as
Update Owner
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger UpdateDoctorFIO
on Doctor
after insert,update
as
Update Doctor
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))


go
create trigger ReseptionNoteTime
on Reseption
after insert,update
as
if ((select [Date] from inserted) > GETDATE())
begin
Print 'Выбранное время больше текущего, дата записи установлена как текущая'
Update Reseption set [Date] = GETDATE()
end

go
create trigger AnimalOld
on Animal
after insert, update
as
declare @Old tinyint, @birtday datetime, @CurrentYear datetime
set @birtday = (select Birthday from inserted)
set @CurrentYear = GETDATE()
set @birtday = YEAR(@birtday)
set @CurrentYear = Year(@CurrentYear)
set @Old = Convert(tinyint,@CurrentYear - @birtday)
Update Animal
set Old = @Old where Animal_Id = (select Animal_Id from inserted)


go
create procedure DoctorsAnimalFind
@Surname nvarchar(50)
as
declare @Doctor smallint
set @Doctor = (select Doctor_Id from Doctor where Surname = @Surname)
select Animal.[Name] from Reseption inner join Animal on Reseption.Animal = Animal.Animal_Id  where Doctor = @Doctor 


go
create procedure PutDisease
@AnimalName nvarchar(50), @Disease nvarchar(50)
as
declare @Animal_Id smallint, @Disease_Id tinyint, @ReceptionNote smallint
set @Animal_Id = (select Animal_Id from Animal where [Name] = @AnimalName)
set @Disease_Id = (select Disease from Disease where [Name] = @Disease)
set @ReceptionNote = (Select Note_Id from Reseption where Note_Id = @Animal_Id)
insert into DiseaseJournal Values(@ReceptionNote,@Disease_Id,GETDATE())


go
create view Doctors
as
select Surname as 'Фамилия', [Doctor].[Name] as 'Имя',Patronymic as 'Отчество', Experience as 'Стаж работы',Schedule as 'График работы ',
Cabinet as 'Номер кабинета', Post.[Name] as 'Должность', Specification.[Name] as 'Спецификация' from Doctor
inner join Post on Doctor.Post = Post.Post_Id
inner join Specification on Doctor.Specification = Specification.Specification_Id

go
create view Animals
as
select Animal.[Name] as 'Кличка', Old as 'Возраст',Birthday as 'Дата рождения', [Owner].[Surname] as 'Хозяин' from Animal
inner join [Owner] on [Owner].Owner_Id = Animal.[Owner]

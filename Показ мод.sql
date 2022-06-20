create database FashionShow
go

use FashionShow

create table Models
(
Model_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Age tinyint,
[Weight] float,
Height tinyint,
Phone nvarchar(18),
)

create table Visagiste
(
Visagiste_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Phone nvarchar(18),
Email nvarchar(30)
)

create table Designer
(
Designer_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Phone nvarchar(18),
Email nvarchar(30)
)

create table Forms
(
Form_Id smallint primary key identity,
[Name] nvarchar(30),
[Description] nvarchar(500),
Designer smallint not null

foreign key (Designer) references Designer(Designer_Id)
)

create table Organizers
(
Organizer_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Phone nvarchar(18),
Email nvarchar(30)
)

create table Contests
(
Contest_Id smallint primary key identity,
[Name] nvarchar(30),
[Description] nvarchar(500),
[Location] nvarchar(30),
CarryngDate datetime,
Organizer smallint not null

foreign key (Organizer) references Organizers(Organizer_Id)
)

create table Perfomances
(
Perf_Id int primary key identity,
Model smallint not null,
Form smallint not null,
Visagiste smallint not null,
Contest smallint not null


foreign key (Model) references Models(Model_Id),
foreign key (Form) references Forms(Form_Id),
foreign key (Visagiste) references Visagiste(Visagiste_Id),
foreign key (Contest) references Contests(Contest_Id)
)


go
create trigger ModelFullName
on Models
after insert,update
as
Update Models
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))
where Model_Id = (select Model_Id from inserted)

go
create trigger VisagisteFullName
on Visagiste
after insert,update
as
Update Visagiste
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))
where Visagiste_Id = (select Visagiste_Id from inserted)

go
create trigger DesignerFullName
on Designer
after insert,update
as
Update Designer
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))
where Designer_Id = (select Designer_Id from inserted)


go
create trigger ModelPhone
on Models
after insert,update
as
declare @NewPhone nvarchar(18)
set @NewPhone = (select Phone from inserted)
if len(@NewPhone) = 11
begin
set @NewPhone = SUBSTRING(@NewPhone,1,1) + ' (' + SUBSTRING(@NewPhone,2,3) + ') ' + SUBSTRING(@NewPhone,5,3) + '-' + SUBSTRING(@NewPhone,8,2) + '-' + SUBSTRING(@NewPhone,10,2)
update Models set Phone = @NewPhone where Model_Id = (select Model_Id from inserted)
end

go
create trigger VisagistePhone
on Visagiste
after insert,update
as
declare @NewPhone nvarchar(18)
set @NewPhone = (select Phone from inserted)
if len(@NewPhone) = 11
begin
set @NewPhone = SUBSTRING(@NewPhone,1,1) + ' (' + SUBSTRING(@NewPhone,2,3) + ') ' + SUBSTRING(@NewPhone,5,3) + '-' + SUBSTRING(@NewPhone,8,2) + '-' + SUBSTRING(@NewPhone,10,2)
update Visagiste set Phone = @NewPhone where Visagiste_Id = (select Visagiste_Id from inserted)
end

go
create trigger DesignerPhone
on Designer
after insert,update
as
declare @NewPhone nvarchar(18)
set @NewPhone = (select Phone from inserted)
if len(@NewPhone) = 11
begin
set @NewPhone = SUBSTRING(@NewPhone,1,1) + ' (' + SUBSTRING(@NewPhone,2,3) + ') ' + SUBSTRING(@NewPhone,5,3) + '-' + SUBSTRING(@NewPhone,8,2) + '-' + SUBSTRING(@NewPhone,10,2)
update Designer set Phone = @NewPhone where Designer_Id = (select Designer_Id from inserted)
end

go
create trigger OrganizerPhone
on Organizers
after insert,update
as
declare @NewPhone nvarchar(18)
set @NewPhone = (select Phone from inserted)
if len(@NewPhone) = 11
begin
set @NewPhone = SUBSTRING(@NewPhone,1,1) + ' (' + SUBSTRING(@NewPhone,2,3) + ') ' + SUBSTRING(@NewPhone,5,3) + '-' + SUBSTRING(@NewPhone,8,2) + '-' + SUBSTRING(@NewPhone,10,2)
update Organizers set Phone = @NewPhone where Organizer_Id = (select Organizer_Id from inserted)
end


go
create procedure CreateModel
@Surname nvarchar(30),@Name nvarchar(30),@Patronymic nvarchar(30),@Age tinyint,@Weight float, @Height tinyint, @Phone nvarchar(18)
as
insert into Models(Surname,[Name],Patronymic,Age,[Weight],Height,Phone) values(@Surname,@Name,@Patronymic,@Age,@Weight,@Height,@Phone)
go
create procedure CreateDesigner
@Surname nvarchar(30),@Name nvarchar(30),@Patronymic nvarchar(30),@Phone nvarchar(18), @Email nvarchar(30)
as
insert into Designer(Surname,[Name],Patronymic,Phone,Email) values(@Surname,@Name,@Patronymic,@Phone,@Email)
go
create procedure CreateOrganizer
@Surname nvarchar(30),@Name nvarchar(30),@Patronymic nvarchar(30),@Phone nvarchar(18), @Email nvarchar(30)
as
insert into Organizers(Surname,[Name],Patronymic,Phone,Email) values(@Surname,@Name,@Patronymic,@Phone,@Email)
go
create procedure CreateVisagiste
@Surname nvarchar(30),@Name nvarchar(30),@Patronymic nvarchar(30),@Phone nvarchar(18), @Email nvarchar(30)
as
insert into Visagiste(Surname,[Name],Patronymic,Phone,Email) values(@Surname,@Name,@Patronymic,@Phone,@Email)

go 
create procedure ComingContests
as
select Contests.[Name] as 'Название', [Description] as 'Описание',[Location] as 'Место проведения', CarryngDate as 'Дата проведения', Organizers.Surname + ' ' + Organizers.[Name] + ' ' + Organizers.Patronymic  as 'Организатор' from Contests
inner join Organizers on Organizer_Id = Organizer
where CarryngDate > GETDATE()


go
create view PerfomancesView
as
select Models.Surname + ' ' + Models.[Name] + ' ' + Models.Patronymic as 'Модель',Forms.[Name] as 'Образ', Visagiste.Surname + ' ' + Visagiste.[Name] + ' ' + Visagiste.Patronymic as 'Визажист',Contests.[Name] as 'Конкурс' from Perfomances
inner join Models on Model_Id = Model
inner join Visagiste on Visagiste_Id = Visagiste
inner join Forms on Form_Id = Form
inner join Contests on Contest_Id = Contest

go
Create view FormsView
as
select Forms.[Name] as 'Название', [Description] as 'Описание', Designer.Surname + ' ' + Designer.[Name] + ' '+ Designer.Patronymic as 'Дизайнер' from Forms
inner join Designer on Designer_Id = Designer



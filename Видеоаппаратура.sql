
create database Video_Hardware
go

use Video_Hardware

create table Color
(
Color_Id smallint primary key identity,
[Name] nvarchar(30) not null,
RGB_Code int not null
)

create table Matrix
(
Matrix_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(60) not null
)

create table Material
(
Material_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(60) not null
)

create table Hardware_Type
(
[Type_Id] tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(60) not null
)

create table Manufacturer
(
Manufacturer_Id tinyint primary key identity,
Company_Name nvarchar(30) not null,
[Location] nvarchar(60) not null,
Phone nvarchar(30) not null,
Established date not null default GETDATE()
)

create table Hardware_Classification
(
Class_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(60) not null
)

create table Hardware
(
Hardware_Id smallint primary key identity,
Model nvarchar(30) not null,
[Type] tinyint not null,
Color smallint not null,
Matrix tinyint not null,
Body_Material tinyint not null,
Manufacturer tinyint not null,
[Classification] tinyint not null,
[Status] nvarchar(30) default 'В производстве' 

foreign key ([Type]) references Hardware_Type([Type_Id]),

foreign key (Color) references Color(Color_Id),
foreign key (Matrix) references Matrix(Matrix_Id),
foreign key (Body_Material) references Material([Material_Id]),
foreign key (Manufacturer) references Manufacturer([Manufacturer_Id]),
foreign key ([Classification]) references Hardware_Classification(Class_Id)
)

create table [Function]
(
Function_Id smallint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(60) not null
)

create table Hardware_Function
(
HardFun_Id int primary key identity,
Hardware smallint not null,
[Function] smallint not null,

foreign key (Hardware) references Hardware(Hardware_Id),
foreign key ([Function]) references [Function](Function_Id)
)

go
create trigger ManufacturerDateCheck
on Manufacturer
after Insert,Update
as
if((select Established from inserted) > GetDate() )
begin
Print 'Дата основания больше текущей даты. Изменения не будут зафиксированы'
Rollback transaction
end

go
create trigger HardwareDelete
on Hardware
instead of Delete
as
Update Hardware set [Status] = 'Снято с производства'

go
create procedure FunctionFind
@Name nvarchar(30)
as
declare @Id int 
set @Id = (select Function_Id from [Function] where [Name] = @Name)
select Hardware.Model from Hardware_Function inner join Hardware on Hardware_Function.Hardware = Hardware.Hardware_Id where [Function] = @Id

go
create procedure GetHardwareInfo
@Name nvarchar(30)
as
select * from Hardware where Model = @Name


go
create view HardwareView
as
select Model as 'Модель',
Hardware_Type.[Name] as 'Тип устройства',
Color.[Name] as 'Цвет',
Matrix.[Name] as 'Матрица',
Material.[Name] as 'Материал корпуса',
Manufacturer.Company_Name as 'Производитель',
[Hardware_Classification].[Name] as 'Классификация устройства',
[Status]

from Hardware inner join Hardware_Type on Hardware.Type = Hardware_Type.[Type_Id]
inner join Color on Hardware.Color = Color.Color_Id
inner join Matrix on Hardware.Matrix = Matrix.Matrix_Id
inner join Material on Hardware.Body_Material= Material.Material_Id
inner join Manufacturer on Hardware.Manufacturer= Manufacturer.Manufacturer_Id
inner join [Hardware_Classification] on Hardware.[Classification]= [Hardware_Classification].Class_Id

create database ClothShop
go
use ClothShop

create table Manufacturer
(
Manuf_Id smallint primary key identity,
Company_Name nvarchar(30),
[Address] nvarchar(40),
Phone nvarchar(12),
[Date] datetime
)

create table Kind
(
Kind_Id tinyint primary key identity,
[Name] nvarchar(40),
[Desc] nvarchar(300)
)

create table Material 
(
Material_Id tinyint primary key identity,
[Name] nvarchar(40),
Desc nvarchar(300)
)

create table Clothes
(
Cloth_Id int primary key identity,
Material tinyint not null,
Kind tinyint not null,
Manufacturer smallint not null,
Price int
foreign key (Material) references Material(Material_Id),
foreign key (Kind) references Kind(Kind_Id),
foreign key (Manufacturer) references Manufacturer(Manuf_Id)
)

create table Buyer
(
Buyer_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
[Address] nvarchar(40),
Phone nvarchar(12),
)

create table Stock
(
Stock_Id int primary key identity,
Cloth int not null,
Size tinyint,
[Count] smallint
foreign key (Cloth) references Clothes(Cloth_Id),
)

create table Orders
(
Order_Id int primary key identity,
Buyer smallint not null,
Stock int not null,
OrderDate datetime

foreign key (Buyer) references Buyer(Buyer_Id),
foreign key (Stock) references Stock(Stock_Id)
)

go
create trigger OrderTime
on Orders
after Insert,Update
as
if((select OrderDate from inserted) > GetDate() )
begin
Print 'Дата заказа больше текущей даты. Изменения не будут зафиксированы'
Rollback transaction
end


go
create trigger ManufacturerDate
on Manufacturer
after Insert,Update
as
if((select [Date] from inserted) > GetDate() )
begin
Print 'Дата основания компании больше текущей даты. Изменения не будут зафиксированы'
Rollback transaction
end

go
create trigger BuyerName
on Buyer
after insert,update
as
Update Buyer
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))


go
create procedure SelectOrders
@Buyer smallint
as
Select Cloth as 'Одежда', Size as 'Размер',OrderDate as 'Дата заказа' from Orders 
inner join Stock on Stock = Stock_Id
where Buyer = @Buyer

go
create procedure ManufacturerInfoGet
@Name nvarchar(30)
as
Select Company_Name as 'Название компании', [Address] as 'Местоположение' , Phone as 'Контактный телефон', [Date] 'Дата основания' from Manufacturer
where Company_Name = @Name

go
create procedure NewBuyer
@Surname nvarchar(30), @Name nvarchar(30), @Patronymic nvarchar(30), @Address nvarchar(40), @Phone nvarchar(12)
as
Insert into Buyer Values(@Surname,@Name,@Patronymic,@Address,@Phone)

go
create view ClothesView
as
select Cloth_Id as 'Идентификатор', Material.[Name] as 'Материал', Kind.[Name] as 'Вид', Manufacturer.Company_Name 'Производитель', Price as 'Стоимость'  from Clothes
inner join Material on Material = Material_Id
inner join Kind on Kind_Id = Kind
inner join Manufacturer on Manufacturer = Manuf_Id

go
create view OrdersView
as
select Buyer.Surname + ' ' + Buyer.[Name] + ' ' + Buyer.Patronymic as 'Покупатель', Stock.Cloth as 'Идентификатор одежды',OrderDate as 'Дата заказа'  from Orders
inner join Buyer on Buyer_Id = Buyer
inner join Stock on Cloth = Stock

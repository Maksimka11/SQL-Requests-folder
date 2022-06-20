create database BurgerKing
go

use BurgerKing

create table Post
(
Post_Id tinyint primary key identity,
[Name] nvarchar(50),
[Desc] nvarchar(1000)
)

create table Employees
(
Empl_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
[Address] nvarchar(60),
Phone nvarchar(12),
Post tinyint not null

foreign key (Post) references Post(Post_Id)
)

create table Clients
(
Client_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
[Address] nvarchar(60),
Phone nvarchar(12),
)

create table Providers
(
Provider_Id smallint primary key identity,
CompanyName nvarchar(30),
[Address] nvarchar(60),
Phone nvarchar(12),
Email nvarchar(40)
)

create table Products
(
Product_Id smallint primary key,
[Name] nvarchar(30),
[Desc] nvarchar(1000),
[Provider] smallint

foreign key ([Provider]) references Providers(Provider_Id)
)

create table Goods
(
Goods_Id smallint primary key identity,
[Name] nvarchar(30),
[Desc] nvarchar(1000),
Price float not null
)

create table GoodsStructure
(
Structure_Id int primary key identity,
Goods smallint not null,
Product smallint not null,
Grammar smallint

foreign key (Goods) references Goods(Goods_Id),
foreign key (Product) references Products(Product_Id)
)


create table Orders
(
Order_Id int primary key identity,
Client smallint not null,
Employee smallint not null,
Goods smallint not null,
OrderDate datetime not null default Getdate()

foreign key (Client) references Clients(Client_Id),
foreign key (Employee) references Employees(Empl_Id),
foreign key (Goods) references Goods(Goods_Id)
)


go

create trigger ClientFullName
on Clients
after insert,update
as
Update Clients
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))


go
create trigger EmployeeFullName
on Employees
after insert,update
as
Update Employees
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))


go

create trigger ProviderEmailFilter
on Providers
after insert, update
as
if (select Email from inserted) not like '%_@%_.__%'
begin
Print 'Email был введен не корректно, изменения не были внесены'
Rollback
end

go
create procedure ClientOrders
@Surname nvarchar(30)
as
Declare @ClientId smallint
set @ClientId = (select Client_Id from Clients where Surname = @Surname)

select Goods.[Name], OrderDate from Orders inner join Goods on Goods.Goods_Id = Orders.Goods where Client = @ClientId


go

create procedure GetGoodsStructure
@Name nvarchar(30)
as
Declare @GoodsId smallint
set @GoodsId = (Select Goods_Id from Goods where [Name] = @Name)
select Products.[Name] as 'Продукт', Grammar as 'Граммовка' from GoodsStructure inner join Products on GoodsStructure.Product = Products.Product_Id where GoodsStructure.Goods = @GoodsId
 


go
create view OrdersView
as
select Clients.Surname + ' ' + Clients.[Name] + ' ' + Clients.Patronymic as 'Клиент', 
Employees.Surname + ' ' + Employees.[Name] + ' ' + Employees.Patronymic as 'Сотрудник', 
Goods.[Name] as 'Товар', OrderDate as 'Дата заказа' from Orders
inner join Clients on Orders.Client = Clients.Client_Id
inner join Employees on Orders.Employee = Employees.Empl_Id
inner join Goods on Goods.Goods_Id = Orders.Goods


go
create view GoodsStructureView
as 
select Goods.[Name] as 'Товар', Products.[Name] as 'Продукт', Grammar as 'Граммовка' from GoodsStructure
inner join Goods on Goods.Goods_Id = GoodsStructure.Goods
inner join Products on Products.Product_Id = GoodsStructure.Product

go
create view EmployeesView
as
select Surname as 'Фамилия', [Employees].[Name] as 'Имя', Patronymic as 'Отчество', 
[Address] = 'Адрес', Phone as 'Контактный телефон', Post.[Name] as 'Должность' from Employees
inner join Post on Post_Id = Employees.Post

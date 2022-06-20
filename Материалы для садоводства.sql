create database Garden 
go
use Garden

create table ManufacturedGoods
(
Goods_Id smallint primary key identity,
[Name] nvarchar(40),
[Desc] nvarchar(300)
)

create table Suppliers
(
Supplier_Id smallint primary key identity,
[Name] nvarchar(40),
Surname nvarchar(40),
Patronymic nvarchar(40),
Phone nvarchar(30),
)

create table Plants
(
Plant_Id smallint primary key identity,
[Name] nvarchar(40),
[Desc] nvarchar(300),
Supplier smallint not null

foreign key (Supplier) references Suppliers(Supplier_Id)
)

create table Gardeners
(
Gardener_Id smallint primary key identity,
[Name] nvarchar(40),
Surname nvarchar(40),
Patronymic nvarchar(40),
Phone nvarchar(30),
)

create table GardenersGoods
(
GardGoods_Id int primary key identity,
Goods smallint not null,
Gardener smallint not null,
[Count] smallint

foreign key (Goods) references ManufacturedGoods(Goods_Id),
foreign key (Gardener) references Gardeners(Gardener_Id)
)

create table GardenersPlants
(
GardPlants_Id int primary key identity,
Plant smallint not null,
Gardener smallint not null,
[Count] smallint

foreign key (Plant) references Plants(Plant_Id),
foreign key (Gardener) references Gardeners(Gardener_Id)
)

create table Tools
(
Tool_Id smallint primary key identity,
[Name] nvarchar(40),
[Desc] nvarchar(300),
Supplier smallint not null

foreign key (Supplier) references Suppliers(Supplier_Id)
)

create table GardenersTools
(
GardTool_Id int primary key identity,
Tool smallint not null,
Gardener smallint not null,
[Count] smallint

foreign key (Tool) references Tools(Tool_Id),
foreign key (Gardener) references Gardeners(Gardener_Id)
)

create table SoilTypes
(
[Type_Id] tinyint primary key identity,
[Name] nvarchar(40),
[Desc] nvarchar(300)
)

create table Earth
(
Earth_Id smallint primary key identity,
Soil tinyint not null,
[Location] nvarchar(40),
Area float

foreign key (Soil) references SoilTypes([Type_Id])
)

create table GardenerseEarth
(
GardEarth_Id int primary key identity,
Earth smallint not null,
Gardener smallint not null

foreign key (Earth) references Earth(Earth_Id),
foreign key (Gardener) references Gardeners(Gardener_Id)
)


go
create trigger FullNameForGardener
on Gardeners
after insert, update
as
Update Gardeners
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger FullNameForSuppliers
on Suppliers
after insert, update
as
Update Suppliers
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger GardenersGoodsCount
on GardenersGoods
after insert,update
as
if(select [Count] from inserted) < 0 
begin
Print 'Количество продуктов не может быть меньше нуля.'
Update GardenersGoods
set [Count] = 0 where GardGoods_Id =  (select GardGoods_Id from inserted)
end

go
create trigger GardenersPlantsCount
on GardenersPlants
after insert,update
as
if(select [Count] from inserted) < 0 
begin
Print 'Количество растений не может быть меньше нуля.'
Update GardenersPlants
set [Count] = 0 where GardPlants_Id =  (select GardPlants_Id from inserted)
end

go
create trigger GardenersToolsCount
on GardenersTools
after insert,update
as
if(select [Count] from inserted) < 0 
begin
Print 'Количество инструментов не может быть меньше нуля.'
Update GardenersTools
set [Count] = 0 where GardTool_Id =  (select GardTool_Id from inserted)
end


go
create procedure SupplierPlants
@Supplier smallint
as
select * from Plants where Supplier = @Supplier

go
create procedure SupplierTools
@Supplier smallint
as
select * from Tools where Supplier = @Supplier


go
create procedure GoodsFind
@Name nvarchar(40)
as
select ManufacturedGoods.[Name] as 'Продукт',Gardeners.Surname as 'Садовод',[Count] as 'Количество' from GardenersGoods
inner join ManufacturedGoods on Goods = Goods_Id
inner join Gardeners on Gardener_Id = Gardener
where ManufacturedGoods.[Name] = @Name


go
create view GardenersPlantsView
as
select Plants.[Name] as 'Растение', Gardeners.[Surname] + ' ' + Gardeners.[Name] + ' ' + Gardeners.Patronymic as 'Садовод', [Count] as 'Количество' from GardenersPlants
inner join Plants on Plant_Id = Plant
inner join Gardeners on Gardener_Id = Gardener

go
create view GardenersEarthView
as
select 'Местоположение: ' + Earth.[Location] + 'Площадь: ' + CONVERT(nvarchar(50),Earth.Area) as 'Земля', Gardeners.[Surname] + ' ' + Gardeners.[Name] + ' ' + Gardeners.Patronymic as 'Садовод' from GardenerseEarth
inner join Earth on Earth_Id = Earth
inner join Gardeners on Gardener_Id = Gardener

go
create view GardenersGoodsView
as
select ManufacturedGoods.[Name] as 'Продукт', Gardeners.[Surname] + ' ' + Gardeners.[Name] + ' ' + Gardeners.Patronymic as 'Садовод', [Count] as 'Количество' from GardenersGoods
inner join ManufacturedGoods on Goods_Id = Goods
inner join Gardeners on Gardener_Id = Gardener

go
create view GardenersToolsView
as
select Tools.[Name] as 'Инструмент', Gardeners.[Surname] + ' ' + Gardeners.[Name] + ' ' + Gardeners.Patronymic as 'Садовод', [Count] as 'Количество' from GardenersTools
inner join Tools on Tool_Id = Tool
inner join Gardeners on Gardener_Id = Gardener


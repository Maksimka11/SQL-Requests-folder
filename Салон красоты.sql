create database Salon
go

use Salon
go

Create table Client
(
Client_Id smallint primary key identity,
Surname nvarchar(30) not null,
[Name] nvarchar(30) not null,
Patronymic nvarchar(30),
Phone nvarchar(30)
)

create table Reviews
(
Review_Id tinyint primary key identity,
Client smallint not null,
Review nvarchar(100)
foreign key (Client) references Client(Client_Id)
);

create table Service_Classification
(
Class_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(100) not null
)

create table [Service]
(
Service_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
ServiceClass tinyint not null,
Price float not null
foreign key (ServiceClass) references  Service_Classification(Class_Id)
)


create table Master_Classification
(
Class_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(100) not null
)

Create table [Master]
(
Master_Id tinyint primary key identity,
Surname nvarchar(30) not null,
[Name] nvarchar(30) not null,
Patronymic nvarchar(30),
Phone nvarchar(30),
Experience tinyint not null,
[Classification] tinyint not null,
[Status] nvarchar(30) not null default 'Работает'

foreign key ([Classification]) references Master_Classification(Class_Id)
)



create table Consumables
(
Consum_Id tinyint primary key identity,
[Master] tinyint,
[Name] nvarchar(50) not null,
[Provider] nvarchar(100)

foreign key ([Master]) references [Master](Master_Id)
)


create table [State]
(
State_Id tinyint primary key identity,
[Name] nvarchar(30) not null,
[Description] nvarchar(100) not null
)

create table Journal
(
Journal_Id int primary key identity,
Client smallint not null,
[Service] tinyint not null,
[Master] tinyint not null,
[State] tinyint not null,
[Date] datetime2 not null,

foreign key (Client) references Client(Client_Id),
foreign key ([Service]) references [Service](Service_Id),
foreign key ([Master]) references [Master](Master_Id),
foreign key ([State]) references [State](State_Id),
)

go

create trigger MasterDelete
on [Master]
instead of Delete
as
Update [Master] set [Status] = 'Уволен'

go
create trigger FilterFIO
on Client
after insert, update
as
Update Client
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger MasterFilterFIO
on [Master]
after insert, update
as
Update Client
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create procedure GetServicePrice
as
declare @minPrice float,@maxPrice float, @minName nvarchar(30), @maxName nvarchar(30)
select @minPrice = min(Price), @maxPrice = max(Price) from [Service]
set @minName = (select [Name] from [Service] where Price = @minPrice)
set @maxName = (select [Name] from [Service] where Price = @maxPrice)
print 'Минимальная цена: ' +@minName+ ' ' + Convert(varchar,@minPrice)
print 'Максимальная цена: '+@maxName+ ' ' + Convert(varchar,@maxPrice)

go
create procedure GetMasterInfo
@Surname nvarchar(30)
as
select * from [Master] where Surname = @Surname

go
create view JournalView
as
select Client.Surname as Client,
[Master].Surname as [Master],
[Service].[Name] as [Service],
[State].[Name] as [State],
Journal.[Date] as [Date]
from Journal inner join  Client on Journal.Client = Client.Client_Id
inner join [Master] on Journal.[Master] = [Master].Master_Id
inner join [Service] on Journal.[Service] = [Service].Service_Id
inner join [State] on Journal.[State] = [State].State_Id






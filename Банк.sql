create database Bank
go
use Bank

create table Clients
(
Client_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Birthday date,
Passport nvarchar(10),
[Address] nvarchar(40),
Phone nvarchar(10)
)


create table Employees
(
Employee_Id smallint primary key identity,
Surname nvarchar(30),
[Name] nvarchar(30),
Patronymic nvarchar(30),
Birthday date,
Passport nvarchar(10),
[Address] nvarchar(40),
Phone nvarchar(10)
)

create table Branches
(
Branch_Id smallint primary key identity,
[Address] nvarchar(40),
Phone nvarchar(12),
Schedule nvarchar(100)
)

create table BranchesEmployees
(
BE_Id int primary key identity,
Branch smallint not null,
Employees smallint not null

foreign key (Branch) references Branches(Branch_Id),
foreign key (Employees) references Employees(Employee_Id)
)


create table LoansType
(
[Type_Id] smallint primary key identity,
[Name] nvarchar(40),
[Description] nvarchar(500)
)

create table Loans
(
Loan_Id int primary key identity,
Summ int,
LoanDate date,
Reason nvarchar(500),
[Type] smallint not null,
Branch smallint not null

foreign key ([Type]) references LoansType([Type_Id]),
foreign key (Branch) references Branches(Branch_Id)
)

create table ClientsLoans
(
CL_Id bigint primary key identity,
Loan int not null,
Client smallint not null

foreign key (Loan) references Loans(Loan_Id),
foreign key (Client) references Clients(Client_Id)
)

create table Payouts
(
Payout bigint primary key identity,
DateAndTime datetime,
Loan int not null,
Summ int

foreign key (Loan) references Loans(Loan_Id)
)

go
create trigger ClientsFIO
on Clients
after insert,update
as
Update Clients
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))

go
create trigger EmployeeFIO
on Employees
after insert,update
as
Update Clients
Set Surname = CONCAT(UPPER(Left(Surname,1)), LOWER(SUBSTRING(Surname,2,Len(Surname)-1))),
[Name] = CONCAT(UPPER(Left([Name],1)), LOWER(SUBSTRING([Name],2,Len([Name])-1))),
Patronymic = CONCAT(UPPER(Left(Patronymic,1)), LOWER(SUBSTRING(Patronymic,2,Len(Patronymic)-1)))


go
create trigger ClientBirthdayCheck
on Clients
after insert,update
as
if ((select Birthday from inserted) > GETDATE())
begin
Print 'Дата рождения не может быть больше текущей даты'
Update Clients set Birthday = GETDATE() where Client_Id = (select Client_Id from inserted)
end

go
create trigger EmployeeBirthdayCheck
on Employees
after insert,update
as
if ((select Birthday from inserted) > GETDATE())
begin
Print 'Дата рождения не может быть больше текущей даты'
Update Employees set Birthday = GETDATE() where Employee_Id = (select Employee_Id from inserted)
end

go
create procedure AddPayout
@Loan int, @Summ int
as
Insert into Payouts Values(GETDATE(),@Loan,@Summ)

go
create procedure NewBrach
@Address nvarchar(40), @Phone nvarchar(12),@Schedule nvarchar(100)
as
insert into Branches Values(@Address,@Phone,@Schedule)


go
create procedure EmployeesInBranch
@Branch smallint
as
select Employees.Surname + ' ' + Employees.[Name] + ' ' + Employees.Patronymic as 'Сотрудник'  from BranchesEmployees
inner join Employees on Employees = Employee_Id


go
create view LoansView
as
select Summ as 'Сумма', LoanDate as 'Дата займа', Reason as 'Причина',LoansType.[Name] as 'Тип займа',Branches.[Address] as 'Отделение банка' from Loans
inner join LoansType on [Type_Id] = [Type]
inner join Branches on Branch= Branch_Id



go
create view ClientsView
as
select Surname as 'Фамилия', [Name] as 'Имя', Patronymic as 'Отчество', Birthday as 'Дата рождения', Passport as 'Серия и номер паспорта', [Address] as 'Адрес проживания', Phone as 'Контактный телефон' from Clients
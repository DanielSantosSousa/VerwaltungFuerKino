use master;
drop database if exists CinemaManagement;
GO
create database CinemaManagement;
GO
use CinemaManagement;

create table Genres(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Description] varchar(50)
);

create table Movies(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Title varchar(50)
);

create table MoviesToGenres(
	fk_MovieId int FOREIGN KEY REFERENCES Movies(Id),
	fk_GenreId int FOREIGN KEY REFERENCES Genres(Id)
)

create table Rooms(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Number int
);

create table Screenings(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	fk_MovieId int FOREIGN KEY REFERENCES Movies(Id),
	fk_RoomId int FOREIGN KEY REFERENCES Rooms(Id),
	[Start] datetime,
	[End] datetime,
	Is3D tinyint
);

create table Seats(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	fk_RoomId int FOREIGN KEY REFERENCES Rooms(Id),
	[Row] int,
	[Col] int
);

create table Tickets(
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	fk_ScreeningId int FOREIGN KEY REFERENCES Screenings(Id),
	fk_SeatId int FOREIGN KEY REFERENCES Seats(Id),
	Price float
);

GO
drop procedure if exists GetFreeSeatIdForScreening;

GO
create procedure GetFreeSeatIdForScreening
    @ScreeningId int  
as  
begin
	select top 1 s.Id from Seats s 
	join Screenings sc on sc.fk_RoomId = s.fk_RoomId
	where sc.Id = @ScreeningId
	and s.Id not in (select tk.fk_SeatId from Tickets tk where tk.fk_ScreeningId = @ScreeningId)
end

GO
drop procedure if exists GenerateTicketForScreening;

GO
create procedure GenerateTicketForScreening
    @ScreeningId int,
	@Price float
as  
begin
	declare @SeatId int;
	exec @SeatId = GetFreeSeatIdForScreening @ScreeningId
	insert into Tickets (fk_screeningId, fk_SeatId, Price) values (@ScreeningId, @SeatId, @Price)
end

GO
drop trigger if exists ConflictingScreeningsTrigger;

GO
create trigger ConflictingScreeningsTrigger on Screenings
for insert as
IF EXISTS (SELECT * FROM inserted i1
				INNER JOIN inserted i2 ON i1.fk_RoomId = i2.fk_RoomId
					AND i1.Id <> i2.Id
                    AND ((i1.[Start] > i2.[Start]
							AND i1.[Start] < i2.[End])
						OR (i1.[End] > i2.[Start]
							AND i1.[End] < i2.[End])
						OR (i1.[Start] < i2.[Start]
							AND i1.[End] > i2.[End])))
   OR EXISTS (SELECT * FROM Screenings sc
				INNER JOIN inserted i ON i.fk_RoomId = sc.fk_RoomId
					AND i.Id <> sc.Id
                    AND ((i.[Start] > sc.[Start]
							AND i.[Start] < sc.[End])
						OR (i.[End] > sc.[Start]
							AND i.[End] < sc.[End])
						OR (i.[Start] < sc.[Start]
							AND i.[End] > sc.[End])))
begin
	RAISERROR('No two screenings can take place at the same time.', 16, 1)
end
use CinemaManagement;
go
insert into Genres ([Description]) values ('Action') , ('Comedy'), ('Romance'), ('Fantasy'), ('Sci-Fi');
go
insert into Movies (Title) values ('Iron Man 1') , ('Avengers'), ('Star Wars'), ('Doctor Who'), ('I am a spider so what?'), ('I Was the Seventh Prince When I Was Reincarnated');
go
insert into MoviesToGenres (fk_GenreId, fk_MovieId) values 
	((select Id from Genres where [Description] = 'Action'), (select Id from Movies where Title = 'Iron Man 1')),
	((select Id from Genres where [Description] = 'Action'), (select Id from Movies where Title = 'Avengers')),
	((select Id from Genres where [Description] = 'Comedy'), (select Id from Movies where Title = 'Star Wars')),
	((select Id from Genres where [Description] = 'Sci-Fi'), (select Id from Movies where Title = 'Star Wars')),
	((select Id from Genres where [Description] = 'Action'), (select Id from Movies where Title = 'Doctor Who')),
	((select Id from Genres where [Description] = 'Sci-Fi'), (select Id from Movies where Title = 'Doctor Who')),
	((select Id from Genres where [Description] = 'Fantasy'), (select Id from Movies where Title = 'I am a spider so what?')),
	((select Id from Genres where [Description] = 'Romance'), (select Id from Movies where Title = 'I Was the Seventh Prince When I Was Reincarnated')),
	((select Id from Genres where [Description] = 'Fantasy'), (select Id from Movies where Title = 'I Was the Seventh Prince When I Was Reincarnated'));
go
insert into Rooms (Number) values (101), (102), (103), (104), (201), (202), (203), (204);
go

declare @room int = 101;
while @room < 205
begin
insert into Seats (fk_RoomId, Col, [Row]) values 
	((select Id from Rooms where Number = @room), 1, 1),
	((select Id from Rooms where Number = @room), 2, 1),
	((select Id from Rooms where Number = @room), 3, 1),
	((select Id from Rooms where Number = @room), 1, 2),
	((select Id from Rooms where Number = @room), 2, 2),
	((select Id from Rooms where Number = @room), 3, 2)

if(@room <> 104)
	set @room = @room + 1
else
	set @room = 201
end
go

insert into Screenings (fk_MovieId, fk_RoomId, [Start], [End], Is3D) values
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 101), '08-06-2022 11:30', '08-06-2022 12:30', 0),
((select Id from Movies where Title = 'Avengers'), (select Id from Rooms where Number = 101), '08-06-2022 13:45', '08-06-2022 15:00', 0),
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 102), '08-06-2022 11:30', '08-06-2022 12:30', 1),
((select Id from Movies where Title = 'Doctor Who'), (select Id from Rooms where Number = 103), '07-06-2022 11:30', '07-06-2022 12:30', 0),
((select Id from Movies where Title = 'I am a spider so what?'), (select Id from Rooms where Number = 103), '08-06-2022 13:30', '08-06-2022 15:30', 0),
((select Id from Movies where Title = 'Star Wars'), (select Id from Rooms where Number = 102), '08-06-2022 12:45', '08-06-2022 14:00', 1),
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 103), '08-06-2022 09:30', '08-06-2022 10:30', 0),
((select Id from Movies where Title = 'I Was the Seventh Prince When I Was Reincarnated'), (select Id from Rooms where Number = 104), '08-06-2022 11:30', '08-06-2022 12:30', 0),
((select Id from Movies where Title = 'Star Wars'), (select Id from Rooms where Number = 101), '08-06-2022 10:30', '08-06-2022 11:15', 0)
go

declare @screeningsId int
set @screeningsId = (select Id from Screenings 
	where fk_MovieId = (select Id from Movies where Title = 'Iron Man 1')
	and fk_RoomId = (select Id from Rooms where Number = 101)
	and [Start] = '08-06-2022 11:30')
exec GenerateTicketForScreening @ScreeningsId,  10.50;
exec GenerateTicketForScreening @ScreeningsId,  10.50;
exec GenerateTicketForScreening @ScreeningsId,  10.50;
exec GenerateTicketForScreening @ScreeningsId,  10.50;
exec GenerateTicketForScreening @ScreeningsId,  10.50;
exec GenerateTicketForScreening @ScreeningsId,  10.50;

set @screeningsId = (select Id from Screenings 
	where fk_MovieId = (select Id from Movies where Title = 'Doctor Who')
	and fk_RoomId = (select Id from Rooms where Number = 103)
	and [Start] = '07-06-2022 11:30')
exec GenerateTicketForScreening @ScreeningsId,  15.49;
exec GenerateTicketForScreening @ScreeningsId,  15.49;
exec GenerateTicketForScreening @ScreeningsId,  15.49;
exec GenerateTicketForScreening @ScreeningsId,  15.49;

set @screeningsId = (select Id from Screenings 
	where fk_MovieId = (select Id from Movies where Title = 'Avengers')
	and fk_RoomId = (select Id from Rooms where Number = 101)
	and [Start] = '08-06-2022 13:45')
exec GenerateTicketForScreening @ScreeningsId,  15.49;
exec GenerateTicketForScreening @ScreeningsId,  15.49;
go
use master;
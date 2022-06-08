use CinemaManagement;
go
select m.Title as 'Movie(s) with most expensive tickets' from Movies m
join Screenings sc on m.Id = sc.fk_MovieId
join Tickets t on sc.Id = t.fk_ScreeningId
where t.Price = (select max(t2.Price) from Tickets t2)
group by Title

go
declare @screeningId int = (select top 1 sc.Id from Screenings sc 
	join Movies m on sc.fk_MovieId = m.Id 
	where m.Title = 'Doctor Who'
	order by sc.[Start] desc
	)
declare @ticketId int;
exec @ticketId = GenerateTicketForScreening @screeningId, 10.00;
select m.Title as 'Movie', sc.[Start], r.Number as 'Room', s.[Row] as 'Seat Row', s.[Col] as 'Seat Column'
from Screenings sc
join Movies m on m.Id = sc.fk_MovieId
join Rooms r on r.Id = sc.fk_RoomId
join Tickets t on t.fk_ScreeningId = sc.Id
join Seats s on s.Id = t.fk_SeatId
where t.Id = @ticketId

go
select top 1 sum(t.Price) as 'Earnings', m.Title as 'Title' 
from Tickets t
join Screenings sc on sc.Id = t.fk_ScreeningId
join Movies m on m.Id = sc.fk_MovieId
group by m.Title
order by Earnings desc
go

--funktioniert nicht:
insert into Screenings (fk_MovieId, fk_RoomId, [Start], [End], Is3D) values
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 201), '08-06-2022 11:30', '08-06-2022 12:30', 0),
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 201), '08-06-2022 11:30', '08-06-2022 12:30', 0)
go
--funtioniert:
insert into Screenings (fk_MovieId, fk_RoomId, [Start], [End], Is3D) values
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 201), '08-06-2022 11:30', '08-06-2022 12:30', 0)
--funktioniert nicht:
insert into Screenings (fk_MovieId, fk_RoomId, [Start], [End], Is3D) values
((select Id from Movies where Title = 'Iron Man 1'), (select Id from Rooms where Number = 201), '08-06-2022 10:30', '08-06-2022 12:00', 0)
go

drop table if exists #UnfilledScreenings
create table #UnfilledScreenings(
	ScreeningId int
)

declare @idColumn int
select @idColumn = min( Id ) from Screenings
while @idColumn is not null
begin
    declare @freeSeatId int
	exec @freeSeatId = GetFreeSeatIdForScreening @idColumn
	if(@freeSeatId != 0) begin
		insert into #UnfilledScreenings values (@idColumn)
	end
    select @idColumn = min( Id ) from Screenings where Id > @idColumn
end
select m.Title as 'Movie', sc.[Start]
from Screenings sc
join Movies m on m.Id = sc.fk_MovieId
where sc.Id in (select ScreeningId from #UnfilledScreenings)
go
use master;
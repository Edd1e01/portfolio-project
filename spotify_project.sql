
inspecting data 
select * from dbo.spotify_top_songs 
---List the most popular songs on Spotify globally in October 2023, 
---along with song title, artist name, album type, release date, and link to album art for each song?
    select * from dbo.spotify_top_songs where MONTH(date) = 10 and year(Date)=2023 order by popularity desc;

---Find out the artists with the most songs in the top 50 songs on Spotify globally in 2023, 
---along with the number of songs, total length, and total streams for each artist?
   select count(song) as num_songs, count(duration_ms) as total_duration, count(popularity) as total_streams
   from dbo.spotify_top_songs where date between '2023-01-01' and '2023-12-31' and position < 50 
   group by artist 
   order by num_songs desc;

---analyze the change in the position of songs in the top 50 songs on Spotify globally by day, week, or month, 
---and find the songs with the biggest fluctuations, smallest, or most stable?
  -- 1 bảng tạm để tính toán sự thay đổi của vị trí các bài hát theo từng ngày
     with daily_change as (
	  select date,song,position, 
	  LAG(position) over(partition by song order by date) as prev_position,
	  position - LAG(position) OVER (PARTITION BY song ORDER BY date) AS position_change
	  FROM dbo.spotify_top_songs WHERE position <= 50 )
	  
	  select song, [date], position_change,
	  case 
	      when position_change > 0 then 'Up'
		  when position_change <0 then 'down'
		  else 'stable'
		  end as trend
	  from daily_change
	  order by abs(position_change) desc;

 -- 1 bảng tạm để tính toán sự thay đổi của vị trí các bài hát theo tuần
	with weekly_change as (
	select DATEPART(year,date) as year,
	       DATEPART(week,date) as week,song,position,
		   lag(position) over (partition by song order by date) as prev_position,
		   position - lag(position) over (partition by song order by date) as position_change
	from dbo.spotify_top_songs
	where position <=50
	)
	select song, [week], position_change,
	  case 
	      when position_change > 0 then 'Up'
		  when position_change <0 then 'down'
		  else 'stable'
		  end as trend
	  from weekly_change
	  order by abs(position_change) desc;

 -- 1 bảng tạm để tính toán sự thay đổi của vị trí các bài hát theo tháng
     with monthly_change as (
	 select DATEPART(year,date) as year,
	        DATEPART(month,date) as month, song,position,
	     lag(position) over (partition by song order by date) as prev_position,
		 position - lag(position) over (partition by song order by date) as position_change
     from dbo.spotify_top_songs
	 where position <=50
	 )
	select song, [month], position_change,
	  case 
	      when position_change > 0 then 'Up'
		  when position_change <0 then 'down'
		  else 'stable'
		  end as trend
	  from monthly_change
	  order by abs(position_change) desc;
    
-- Tìm ra những bài hát có biến động lớn nhất, nhỏ nhất hoặc ổn định nhất theo tháng
WITH monthly_change AS (
	 SELECT DATEPART(year, date) as year,
	        DATEPART(month, date) as month, song, position,
	     lag(position) over (partition by song order by date) as prev_position,
		 position - lag(position) over (partition by song order by date) as position_change
     FROM dbo.spotify_top_songs
	 WHERE position <= 50
)
SELECT song, [MONTH], position_change, 
	CASE
		WHEN position_change > 0 THEN 'up'
		WHEN position_change < 0 THEN 'down'
		ELSE 'stable'
	END AS trend
FROM monthly_change
ORDER BY abs(position_change) DESC;

---Can you analyze the impact of new album releases on the popularity of songs on Spotify globally?
-- Tạo một bảng tạm thời để lưu trữ khoảng cách thời gian giữa ngày phát hành album và ngày xuất hiện trong top 50 bài hát
   with release_gap AS (
   select song, artist, release_Date, MIN(date) AS first_date, DATEDIFF(day, release_Date, MIN(date)) AS gap
   from dbo.spotify_top_songs
   where position <= 50
   group by song, artist, release_Date
   )
-- Tìm ra các bài hát có khoảng cách thời gian lớn nhất, nhỏ nhất và trung bình
   select max(gap) as max_gap, min(gap) as min_gap, avg(gap) as avg_gap 
   from release_gap;

---Can you analyze the distribution of artists in the top 50 songs on Spotify globally?
   select artist,count(Song) as song_count 
   from dbo.spotify_top_songs
   where position <= 50
   group by artist
   order by song_count desc;

---Can you analyze the correlation between song length and song popularity on Spotify globally?
   select song,artist,popularity, duration_ms / 60000 as duration 
   from dbo.spotify_top_songs
   where position <= 50;

---Can you analyze the difference between album types (single, album, compilation) in the top 50 songs on Spotify globally?
   select album_type, count(song) as song_count, 
          avg(popularity) as avg_popularity,
		  avg(duration_ms) as avg_duration
	from dbo.spotify_top_songs
	where position <=50
	group by album_type

---Can you analyze the distribution of songs by day of the week on Spotify globally?
   select DATEPART(weekday,date) as week_day, 
          count(song) as song_count
	from dbo.spotify_top_songs
	where position <= 50
	group by week_day 
	order by song_count desc;

---Can you analyze the correlation between the number of songs in an album and the album's popularity on Spotify globally?
   select album_type, count(song) as song_count,
          avg(popularity) as avg_popularity
	from dbo.spotify_top_songs
	where position <= 50
	group by album_type

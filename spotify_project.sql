
inspecting data 
select * from dbo.spotify_top_songs 
---1.Liệt kê các bài hát phổ biến nhất trên Spotify toàn cầu vào tháng 10 năm 2023
--- cùng với tên bài hát, tên nghệ sĩ, loại album, ngày phát hành và liên kết tới ảnh bìa album của từng bài hát.
    select * from dbo.spotify_top_songs where MONTH(date) = 10 and year(Date)=2023 order by popularity desc;

---2.Tìm ra những nghệ sĩ có nhiều bài hát nhất trong 50 bài hát hàng đầu trên Spotify toàn cầu vào năm 2023,
---cùng với số lượng bài hát, tổng thời lượng và tổng lượt phát của mỗi nghệ sĩ?
   select count(song) as num_songs, count(duration_ms) as total_duration, count(popularity) as total_streams
   from dbo.spotify_top_songs where date between '2023-01-01' and '2023-12-31' and position < 50 
   group by artist 
   order by num_songs desc;

---3.Tìm ra bài hát nổi tiếng nhất của từng nghệ sĩ
    select song, artist, popularity
FROM (
  SELECT song, artist, popularity, ROW_NUMBER () OVER (PARTITION BY artist ORDER BY popularity DESC) AS rank
  FROM dbo.spotify_top_songs
) AS sub
WHERE rank = 1;

---4. Hãy phân tích sự phân bố của các nghệ sĩ trong 50 bài hát hàng đầu trên Spotify trên toàn cầu không?
   select artist,count(Song) as song_count 
   from dbo.spotify_top_songs
   where position <= 50
   group by artist
   order by song_count desc;

---5.Hãy phân tích sự khác biệt giữa các loại album (đĩa đơn, album, tổng hợp) 
---trong 50 bài hát hàng đầu trên Spotify toàn cầu không?
   select album_type, count(song) as song_count, 
          avg(popularity) as avg_popularity,
		  avg(duration_ms) as avg_duration
	from dbo.spotify_top_songs
	where position <=50
	group by album_type

---6.Hãy phân tích tác động của việc phát hành album mới đến mức độ phổ biến của các bài hát trên Spotify trên toàn cầu không?
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

---7. Hãy phân tích mối tương quan giữa số lượng bài hát trong một album 
---và mức độ phổ biến của album trên Spotify trên toàn cầu không?
   select album_type, count(song) as song_count,
          avg(popularity) as avg_popularity
	from dbo.spotify_top_songs
	where position <= 50
	group by album_type;

---8.Phân tích mối tương quan giữa thời lượng bài hát và mức độ phổ biến của bài hát trên Spotify trên toàn cầu không?
   select song,artist,popularity, duration_ms / 60000 as duration 
   from dbo.spotify_top_songs
   where position <= 50;

---9.Phân tích việc phân phối các bài hát theo ngày trong tuần trên Spotify trên toàn cầu không?
   select DATEPART(weekday,date) as week_day, 
          count(song) as song_count
	from dbo.spotify_top_songs
	where position <= 50
	group by week_day 
	order by song_count desc;
---10.Phân tích sự thay đổi vị trí của các bài hát trong top 50 bài hát trên Spotify toàn cầu theo ngày, tuần, tháng và
--- tìm ra bài hát có biến động lớn nhất, nhỏ nhất hay ổn định nhất?
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








inspect data
select * from dbo.book_ratings 
---I. PHÂN TÍCH
---1.tìm những quyển sách có average rating cao nhất
    select book,author,avg_rating 
	from dbo.book_Ratings 
	order by Avg_Rating desc

---2.Phân tích thể loại sách phổ biến
   select genres, count(*) as genre_count
   from book_Ratings
   group by Genres
   order by genre_count desc;
---3.Những quyển sách thuộc thể loại nào được đánh giá nhiều nhất
    select Genres,sum(num_ratings) as total_ratings 
	from dbo.book_Ratings
	group by Genres
	order by total_ratings desc;

---4.Những quyển sách nào của author nào có description chứa từ khóa nào liên quan đến cổ điển,tiểu thuyết lịch sử,viễn tưởng v.v.?
   select book,author from dbo.book_Ratings 
   where Description like '%classic%'
      or Description like'%historical fiction%' 
      or Description like '%fiction%'

---5.Số lượng cuốn sách của mỗi tác giả
    select author,COUNT(book) as total_books
	from dbo.book_Ratings
	group by author
	order by total_books desc;

---6.Tìm cuốn sách với số đánh giá cao nhất
    select book,author, avg_rating,num_ratings 
	from dbo.book_Ratings
	where Num_Ratings = (select max(num_ratings) from dbo.book_Ratings);

---7.tìm ra tác giả có xếp hạng trung bình của tất cả sách của họ lớn nhất
   select  Top 1 author, max(avg_Rating) as highest_avg_Rating
   from dbo.book_Ratings
   group by Author
   order by highest_avg_Rating desc;
---8.Tìm những quyển sách có mô tả ngắn nhất, dài nhất
   select book,LEN(description) as description_length
   from dbo.book_Ratings
   order by description_length desc;
---9.Tìm quyển sách nào có nhiều thể loại nhất và ít nhất
   select book,COUNT(genres) as genre_count
   from dbo.book_Ratings
   group by Book
   order by genre_count desc;

---10.Tính tổng số lượt đánh giá cho từng giả
   select author, sum(num_Ratings) as total_ratings
   from book_Ratings
   group by Author;

---11.Đếm số lượng sách có điểm đánh giá tb >4 và số lượt đánh giá >50
   select count(*) as high_Rated_books_Count
   from book_Ratings
   where Avg_Rating > 4 and Num_Ratings >50;

---12.Tính tổng số sách được đánh giá tb cao hơn mức TB chung của tất cả sách trong bảng
-- Tạo bảng tạm để tính điểm tb chung của tất cả sách
   with avg_rating_Cte as (
   select AVG(avg_Rating) as overall_avg_Rating
   from book_Ratings
   )
   select COUNT(*) as high_Rated_books_Count
   from book_Ratings
   cross join avg_rating_Cte
   where Avg_Rating > overall_avg_Rating;

---13.Liệt kê tác giả có ít một nhất sách có xếp hạng tb dưới 3.5 và có ít nhất 3 sách trong bảng
-- tạo 1 bảng tạm để tính điểm TB của từng tác giả
   with author_avg_rating as (
   select author,avg_Rating as author_rating
   from book_Ratings
   )
   select a.Author from author_avg_rating as a
   join book_Ratings as b on a.Author=b.Author
   group by a.Author
   having COUNT(b.Book) >=3 and MIN(b.avg_rating)<3.5;

---14.Tính số lượng sách của mỗi thể loại và có điểm tb cao hơn mức tb của thể loại đó
--tạo bảng tạm để tính điểm tb chung của từng thể loại sách 
   with genres_avg_Rating as (
   select genres,avg_rating as genres_rating
   from book_Ratings
   )
   select g.Genres,count(*) as high_rated_books
   from genres_avg_Rating as g
   join book_Ratings as b on g.Genres=b.Genres
   where b.Avg_Rating > g.genres_rating
   group by g.Genres;

---15.Phân tích sự phân bổ của số lượt đánh giá cho từng thể loại sách. 
---Có sự tương quan nào giữa số lượng đánh giá và điểm trung bình không?
   select genres,
          count(*) as book_count,
		  avg(num_ratings) as avg_num_Ratings,
		  avg(avg_rating) as overall_avg_rating
   from book_Ratings
   group by Genres
   order by avg_num_Ratings;

---16.Tính tổng số lượt đánh giá cho mỗi tác giả 
---và xác định xem có mối quan hệ nào giữa tổng lượt đánh giá và xếp hạng tb không?
   with author_rating_stats as (
   select author,
          count(*) as total_books,
		  avg(Avg_Rating) as overall_avg_Rating,
		  sum(num_ratings) as total_num_ratings
   from book_Ratings
   group by Author
   )
   select a.Author, a.total_books,a.total_num_ratings,a.overall_avg_Rating
   from author_rating_stats as a
   order by total_num_ratings;

---17.Liệt kê những quyển sách có điểm tb cao nhưng số lượng đánh giá thấp. 
---Có sự tương quan nào giữa điểm tb và số lượng đánh giá không?
   select book,author,avg_rating,num_Ratings
   from book_Ratings
   where Avg_Rating >4 and Num_Ratings <10
   order by Avg_Rating desc;

---18.xếp hạng và số lượng đánh giá theo tác giả
   select author, avg(Avg_Rating) as avg_author_Rating,
          sum(num_ratings) as total_ratings
   from book_Ratings
   group by Author
   order by Author;
---XẾP HẠNG
---19.Xếp hạng sách theo số lượng đánh giá
   select case 
          when num_Ratings < 100 then 'Dưới 100 đánh giá'
		  when num_ratings >=100 and num_ratings < 500 then '100-499 đánh giá'
		  when num_ratings >=500 and num_ratings < 1000 then '500-999 đánh giá'
		  else '1000 đánh giá trở lên'
		  end as rating_cluster,
		  avg(avg_rating) as avg_rating
   from dbo.book_Ratings 
   group by
        case 
		  when num_Ratings < 100 then 'Dưới 100 đánh giá'
		  when num_ratings >=100 and num_ratings < 500 then '100-499 đánh giá'
		  when num_ratings >=500 and num_ratings < 1000 then '500-999 đánh giá'
		  else '1000 đánh giá trở lên'
		  end
   order by rating_cluster;
--- DỰ ĐOÁN
---20.Dự đoán xếp hạng của một quyển sách dựa trên tổng đánh giá trung bình
   select book,author, avg(avg_rating) as predicted_rating
   from dbo.book_Ratings
   where Author = 'Carson McCullers'
   group by Book,Author
   order by predicted_rating desc;

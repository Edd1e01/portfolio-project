use eddie_project
go
select * from dbo.book_ratings 
--- tìm những quyển sách có average rating cao nhất
    select book,author,avg_rating 
	from dbo.book_Ratings 
	order by Avg_Rating desc

---phân tích thể loại sách phổ biến
   select genres, count(*) as genre_count
   from book_Ratings
   group by Genres
   order by genre_count desc;
--- Những quyển sách thuộc thể loại nào được đánh giá nhiều nhất
    select Genres,sum(num_ratings) as total_ratings 
	from dbo.book_Ratings
	group by Genres
	order by total_ratings desc;

---Những quyển sách nào của author nào có description chứa từ khóa nào liên quan đến cổ điển,tiểu thuyết lịch sử,viễn tưởng v.v.?
   select book,author from dbo.book_Ratings 
   where Description like '%classic%'
      or Description like'%historical fiction%' 
      or Description like '%fiction%'

--- Số lượng cuốn sách của mỗi tác giả
    select author,COUNT(book) as total_books
	from dbo.book_Ratings
	group by author
	order by total_books desc;

---Tìm cuốn sách với số đánh giá cao nhất
    select book,author, avg_rating,num_ratings 
	from dbo.book_Ratings
	where Num_Ratings = (select max(num_ratings) from dbo.book_Ratings);

---Dự đoán xếp hạng của một quyển sách dựa trên tổng đánh giá trung bình
   select book,author, avg(avg_rating) as predicted_rating
   from dbo.book_Ratings
   where Author = 'Carson McCullers'
   group by Book,Author
   order by predicted_rating desc;

---Xếp hạng sách theo số lượng đánh giá
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
   order by rating_cluster

---xếp hạng và số lượng đánh giá theo tác giả
   select author, avg(Avg_Rating) as avg_author_Rating,
          sum(num_ratings) as total_ratings
   from book_Ratings
   group by Author
   order by Author;

---tìm ra tác giả có xếp hạng trung bình của tất cả sách của họ lớn nhất
   select  Top 1 author, max(avg_Rating) as highest_avg_Rating
   from dbo.book_Ratings
   group by Author
   order by highest_avg_Rating desc;

---Tìm những quyển sách có mô tả ngắn nhất, dài nhất
   select book,LEN(description) as description_length
   from dbo.book_Ratings
   order by description_length desc;

---Tìm quyển sách nào có nhiều thể loại nhất và ít nhất
   select book,COUNT(genres) as genre_count
   from dbo.book_Ratings
   group by Book
   order by genre_count desc;

---Tìm những quyển sách có khả năng được đánh giá cao nhất,thấp nhất dựa trên mô tả của chúng
   select book,description,
   score_description(description) as description_score
   from book_Ratings
   order by description_score desc;

---Tìm những quyển sách có thể thuộc nhiều thể loại khác nhau dựa trên mô tả chúng
   select book,description,classify_description(description) as genres
   from book_Ratings
   where genres <> genres 
   order by len(genres) desc;

---Tìm quyển sách được dự đoán là sẽ có nhiều đánh giá hơn trong tương lai dựa trên các yếu tố như tác giả,thể loại, điểm tb
   select book,author,genres,avg_rating,num_ratings,
   predict_num_ratings(author,genres,avg_rating) as future_num_ratings
   from book_Ratings
   order by future_num_ratings desc;

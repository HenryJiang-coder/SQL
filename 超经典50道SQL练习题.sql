-- 超经典SQL练习题，做完这些你的ＳＱＬ就过关了
use test
GO

-- 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数


select A.Sid,A.CId,A.score as course01score, B.CId,B.score as course02score 
from SC as A join SC as B on A.Sid = B.Sid and A.Cid = '01' and B.Cid = '02' and A.score > B.score


select A.*,B.Cid,B.score from (select * from SC where Cid='01')A 
left join(select * from SC where Cid='02')B 
on A.Sid=B.Sid
where A.score>B.score;

--1.1 查询同时存在" 01 "课程和" 02 "课程的情况

select A.sid, A.cid, A.score, B.cid, B.score from (select sid, cid, score from SC where cid = '01') as A join 
(select sid, cid, score from SC as B where cid = '02') as B on A.sid = B.sid;

--1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )

select A.sid, A.cid, A.score, B.cid, B.score from (select sid, cid, score from SC where cid = '01') as A left join 
(select sid, cid, score from SC as B where cid = '02') as B on A.sid = B.sid;

--1.3 查询不存在" 01 "课程但存在" 02 "课程的情况

select sid, cid,score from SC as A where cid = '02' and not exists (select * from SC as B where cid = '01' and A.sid = B.sid); 


select * from SC where CId='02'and Sid not in(select Sid from SC where Cid='01')

--2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩

select SC.Sid, Sname, AVG(score) as AVGSCORE from Student join SC on Student.SId = SC.SId 
group by SC.SId,Sname having AVG(score) >= 60;

select A.Sid,B.Sname,A.dc from(select Sid,AVG(score)dc from SC group by Sid)A
left join Student B on A.Sid=B.Sid where A.dc>=60

-- 3. 查询在 SC 表存在成绩的学生信息
select * from Student as A where exists (select * from SC as B where A.sid =B.sid)


select * from Student where Sid in (select distinct Sid from SC)

-- 4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )

select sname, student.sid, A.courseCount, A.SUMSCORE from student 
left join (select sid, count(cid) as courseCount, sum(score) as SUMSCORE from SC group by sid) as A on student.SId = A.Sid;


-- 5. 查询「李」姓老师的数量 

select count(*) from Teacher where Tname like '李%';

-- 6. 查询学过「张三」老师授课的同学的信息 

select * from Student where sid in (select sid from SC where cid in (select cid from Course where Tid in (select Tid from Teacher where Tname = '张三')))

-- 7. 查询没有学全所有课程的同学的信息

select * from Student where sid not in 
(select sid from SC 
group by sid having count(distinct CId)= (select count(cid) from Course));

-- 8 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息 

select * from Student 
where Sid in(select distinct Sid from SC where Cid in(select Cid from SC where Sid='01')
);

-- 9 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息

select * from student where sid in 
(select sid from SC where Cid in 
(select distinct Cid from SC where sid = '01') 
and Sid <>'01' group by sid having count(cid)=3);

-- 10. 查询没学过"张三"老师讲授的任一门课程的学生姓名 

select * from student where not sid in (select sid from SC where cid in (select cid from Course where tid in (select tid from Teacher where tname = '张三')))

-- 11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩 

select Student.Sid, sname,A.AVGSCORE from Student join 
(select sid, AVG(score) as AVGSCORE from SC where score < 60 group by sid having count(score)>=2 ) as A on A.sid = Student.SId 

-- 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息

select * , score from Student join (select sid, score from SC where cid = '01' and score <60) as A 
on Student.sid = A.sid order by A.score desc;

-- 13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩

select sid, max(case cid when '01' then score else 0 end) as score01,
max(case cid when '02' then score else 0 end) as score02,
max(case cid when '03' then score else 0 end) as score03,
AVG(score) as AVGSCORE 
from SC group by sid order by AVG(score) desc;

-- 14. 查询各科成绩最高分、最低分和平均分：

    /*以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
    及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
    要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排序*/


select SC.cid, cname, MAX(score) as MAXscore, MIN(Score) as MINscore, AVG(score) as AVGscore,
Sum(case when score > =60 then 1 else 0 end)/cast(count(*) as float) as 及格率,
Sum(case when score > =70 and score <=80 then 1 else 0 end)/cast(count(*) as float) as 中等率,
Sum(case when score > =80 and score <=90 then 1 else 0 end)/cast(count(*) as float) as 优良率,
Sum(case when score > =90 then 1 else 0 end)/cast(count(*) as float) as 优秀率,
Count(*) as 选修人数
from SC join course on SC.cid = course.cid
group by SC.cid,cname order by SC.cid;

-- 15. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺

select *,RANK()over(order by score desc)排名 from SC;

--15.1 按各科成绩进行排序，并显示排名，Score 重复时合并名次

select *,DENSE_RANK()over(order by score desc)排名 from SC;


--16. 查询学生的总成绩，并进行排名，总分重复时保留名次空缺

select *, RANK()over(order by SUMSCORE desc) as RANKSUM from (select SId, sum(score) as SUMSCORE from SC group by sid) as A;

--16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺

select *, Dense_rank()over (order by SUMSCORE desc) as RUNKSUM from (select sid, sum(score) as SUMSCORE from SC group by sid) as A;

--17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比 

select SC.cid, cname, 
sum((case when score >=85 and score <=100 then 1 else 0 end)) as '100-85',
sum((case when score >=70 and score <=85 then 1 else 0 end)) as '85-70', 
sum((case when score >=60 and score <=70 then 1 else 0 end)) as '70-60', 
sum((case when score >=0 and score <=60 then 1 else 0 end)) as '60-0' , 
sum((case when score >=85 and score <=100 then 1 else 0 end)) /cast(count(*) as float) as '100-85 %', 
sum((case when score >=70 and score <=85 then 1 else 0 end)) /cast(count(*) as float) as '85-70 %',
sum((case when score >=60 and score <=70 then 1 else 0 end)) /cast(count(*) as float) as '70-60 %',
sum((case when score >=0 and score <=60 then 1 else 0 end)) /cast(count(*) as float) as '60-0 %'
from SC join course on SC.cid = course.cid group by SC.cid,cname;


--18. 查询各科成绩前三名的记录（方法 1）
select * from (select *, rank()over (partition by cid order by score desc) as A from SC) as B where B.A <=3;


--18. 查询各科成绩前三名的记录（方法 2）相关子查询
select * from SC as A where (select count(*) from SC as B where B.score > A.score and B.cid = A.cId)<3 
order by cid, score desc;

--18. 查询各科成绩前三名的记录（方法 3）连结 (比当前元组大的其他元组的数量不能超过3，数量只能为或1 或2)

select a.Sid,a.CId,a.score from SC a 
left join SC b on a.Cid=b.CId and a.score< b.score
group by a.Sid,a.CId,a.score
having COUNT(b.SId)<3 order by a.cid

--19. 查询每门课程被选修的学生数 

select cid, count(sid) as SNUMBER from SC group by cid;

--20. 查询出只选修两门课程的学生学号和姓名

select sid, sname from student where sid in (select sid from SC group by sid having count (distinct cid) =2);

--21. 查询男生、女生人数

select sum(case when Ssex = '男' then 1 else 0 end) as 男生人数,
sum(case when Ssex = '女' then 1 else 0 end) as 女生人数 from student 


--22. 查询名字中含有「风」字的学生信息

select * from student where sname like '%风%';

--23. 查询同名同性学生名单，并统计同名人数

select * from student
select A.Sname, count(*) as '同名人数' from student as A join student as B 
on A.SId<>B.Sid and A.Sname = B.Sname
group by A.sname;


select A.sid, B.sid from student as A join Student as B on A.SId<>B.Sid and A.Sname = B.Sname


--24.查询 1990 年出生的学生名单
select * from Student where Year(Sage) = '1990';


--25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列

select cid, AVG(score) as AVGSCORE from SC group by cid order by AVG(score) desc, cid;


--26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩

select A.sid, sname, AVG(score) as AVGSCORE from SC as A join student as B on A.sid = B.sid 
group by A.sid, sname having AVG(score)>=85; 


-- 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
select student.sname, score from SC join student on SC.SId = student.SId 
where SC.sid in (select sid from SC where score < 60 and cid in (select cid from course where cname = '数学'));

-- 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）

select A.Sid,A.sname,B.Cid,B.score from Student A left join SC B on A.Sid=B.Sid

-- 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数

select student.sid, sname, cname, score from student, SC, course 
where student.sid = SC.sid and SC.cid = course.cid
and student.sid in (select distinct sid from SC where sid not in (select sid from SC where score < 70));

-- 30. 查询不及格的课程
select * from SC where score < 60;


-- 31. 查询课程编号为01且课程成绩在80分以上的学生的学号和姓名

select sid, sname from student where sid in (select sid from SC where cid = 01 and score >80);

--32. 求每门课程的学生人数

select cid, count(sid) as '人数' from SC group by cid

--33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩 select * from course

select student.*, score from Student join SC on Student.sid = SC.sid where Student.sid in 
(select sid from SC where cid in (select cid from course,Teacher where course.tid = Teacher.tid and Teacher.Tname='张三'))
order by SC.score desc OFFSET 0 ROWS fetch next 1 ROWS ONLY;


select top 1* from SC 
where Cid in (select Cid from Course where Tid in (select Tid from Teacher where Tname='张三')) 
order by score desc

--34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩

select *from(select *,DENSE_RANK()over (order by score desc)A 
from SC 
where Cid in (select Cid from Course where Tid in (select Tid from Teacher where Tname='张三')))B
where B.A=1


--35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩 

select C.Sid,max(C.Cid)Cid,max(C.score)score from SC C 
left join(select Sid,avg(score)A from SC group by Sid)B 
on C.Sid=B.Sid
where C.score=B.A
group by C.Sid
having COUNT(0)=(select COUNT(0)from SC where Sid=C.Sid)

--36. 查询每门功成绩最好的前两名

select * from (select *, rank()over(partition by cid order by score desc) as RANKC from SC) as A 
where A.RANKC <3 order by cid; 

select * from SC as A where (select count(*) from SC as B where A.cid = B.cid and A.score<B.score ) < 2 
order by A.cid,A.score desc

-- 37.统计每门课程的学生选修人数（超过5人的课程才统计）。
	--要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

select cid, count(*) as '选修人数' from SC group by cid having count(*)> 5
order by count(*) desc, cid;

--38. 检索至少选修两门课程的学生学号

select sid from SC group by sid having count(cid)>=2;

--39. 查询选修了全部课程的学生信息

select * from student where sid in 
(select sid from SC group by SC.sid having count(cid) = (select count(*) from course));

--40. 查询各学生的年龄，只按年份来算

select Sid, sname, DATEDIFF(year,Sage,getdate()) as age from student;

-- 41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
	--方法是把时间转化成 Int 格式来做条件比较大小，判断是否超期

select *,(case when convert(int,'1'+substring(CONVERT(varchar(10),Sage,112),5,8))
<convert(int,'1'+substring(CONVERT(varchar(10),GETDATE(),112/*112是将格式转化为yymmdd*/),5,8)) 
then datediff(yy,Sage,GETDATE()) 
else datediff(yy,Sage,GETDATE())-1 
end)age 
from Student

--42. 查询本周过生日的学生
	--方法：采取将生日转化为当年日期，再转化为本年中的第几个星期进行判断搜出结果

select *,(case when datename(wk,convert(datetime,(convert(varchar(10),year(GETDATE()))+substring(convert(varchar(10),Sage,112),5,8))))=DATENAME(WK,GETDATE()) 
then 1 else 0 end)生日提醒
from Student

--43. 查询下周过生日的学生

select *,(case when datename(wk,convert(datetime,(convert(varchar(10),year(GETDATE()))+
substring(convert(varchar(10),Sage,112),5,8))))=DATENAME(WK,GETDATE())+1 
then 1 else 0 end)生日提醒
from Student


--44. 查询本月过生日的学生


select *,(case when month(convert(datetime,(convert(varchar(10),year(GETDATE()))+substring(convert(varchar(10),Sage,112),5,8))))=month(GETDATE())
then 1 else 0 end)生日提醒
from Student


--45. 查询下月过生日的学生

select *,(case when month(convert(datetime,(convert(varchar(10),year(GETDATE()))+substring(convert(varchar(10),Sage,112),5,8))))=month(GETDATE())+1
then 1 else 0 end)生日提醒
from Student




USE ig_clone;

-- ----- Analysis Questions ----- --

#1 We want to reward our users who have been around the longest.  Find the 5 oldest users.*/

SELECT * FROM users
ORDER BY created_at
LIMIT 5;

#2 What day of the week do most users register on? We need to figure out when to schedule an ad campgain*/
SELECT date_format(created_at,'%W') AS 'day of the week', COUNT(*) AS 'total registration'
FROM users
GROUP BY 1
ORDER BY 2 DESC;

#3 We want to target our inactive users with an email campaign. Find the users who have never posted a photo*/
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;

#4 How many times does the average user post?*//*total number of photos/total number of users*/
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2);

#5 /*user ranking by postings higher to lower*/
SELECT users.username,COUNT(photos.image_url)
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 2 DESC;

#6*Total Posts by users (longer versionof SELECT COUNT(*)FROM photos) */
SELECT SUM(user_posts.total_posts_per_user)
FROM (SELECT users.username,COUNT(photos.image_url) AS total_posts_per_user
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY users.id) AS user_posts;
        
#7*total numbers of users who have posted at least one time */
SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos ON users.id = photos.user_id;

#8*A brand wants to know which hashtags to use in a post What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC;

#9 *We have a small problem with bots on our site...Find users who have liked every single photo on the site*/
SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos);

#10  List all comments on photos uploaded by a specific user
SELECT c.comment_text, u.username AS commenter, p.image_url AS photo
FROM comments c
JOIN users u ON c.user_id = u.id
JOIN photos p ON c.photo_id = p.id
WHERE p.user_id = (SELECT id FROM users WHERE username = 'Kenton_Kirlin');


#11  Find the most liked photo and its uploader

SELECT p.image_url, u.username, like_count
FROM (
    SELECT photo_id, COUNT(*) AS like_count
    FROM likes
    GROUP BY photo_id
    ORDER BY like_count DESC
    LIMIT 1
) most_liked
JOIN photos p ON most_liked.photo_id = p.id
JOIN users u ON p.user_id = u.id;

#12 Find all users who haven't uploaded a photo
SELECT username
FROM users
WHERE id NOT IN (SELECT DISTINCT user_id FROM photos);

#13  Count the number of tags used on each photo
SELECT p.image_url, COUNT(pt.tag_id) AS tag_count
FROM photos p
LEFT JOIN photo_tags pt ON p.id = pt.photo_id
GROUP BY p.id;

#14 Find photos with more than 5 likes
SELECT p.id AS photo_id, p.image_url
FROM photos p
WHERE p.id IN (
    SELECT photo_id
    FROM likes
    GROUP BY photo_id
    HAVING COUNT(user_id) > 5
);

#15 List usernames of people who commented on their own photos

SELECT DISTINCT u.username
FROM users u
JOIN comments c ON u.id = c.user_id
WHERE c.photo_id IN (SELECT id FROM photos WHERE user_id = u.id);

#16 Find the user who follows the most other users
SELECT u.username, COUNT(f.followee_id) AS following_count
FROM users u
JOIN follows f ON u.id = f.follower_id
GROUP BY u.id
ORDER BY following_count DESC
LIMIT 1;

#17 Get the total number of comments made by each user
SELECT u.username, 
       (SELECT COUNT(*) FROM comments c WHERE c.user_id = u.id) AS comment_count
FROM users u;

#18 Find photos that have comments from at least 3 distinct users

SELECT p.id AS photo_id, p.image_url
FROM photos p
JOIN comments c ON p.id = c.photo_id
GROUP BY p.id, p.image_url
HAVING COUNT(DISTINCT c.user_id) >= 3
limit 3;

#19 List users who have never uploaded a photo or made a comment

SELECT u.username
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN comments c ON u.id = c.user_id
WHERE p.id IS NULL AND c.id IS NULL;

#20  Count the total number of likes each user has received on their photos

SELECT u.username, COUNT(l.user_id) AS total_likes
FROM users u
JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
GROUP BY u.id;

#21 Find tags that are associated with more than 10 photos

SELECT t.tag_name, COUNT(pt.photo_id) AS photo_count
FROM tags t
JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
HAVING COUNT(pt.photo_id) > 10;

#22  Find the top 3 users with the most followers

SELECT u.username, COUNT(f.followee_id) AS follower_count
FROM users u
JOIN follows f ON u.id = f.followee_id
GROUP BY u.id
ORDER BY follower_count DESC
LIMIT 3;

#23 Find users who like every photo uploaded by a specific user

SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT p.id
    FROM photos p
    WHERE p.user_id = (SELECT id FROM users WHERE username = 'specific_user')
    AND p.id NOT IN (
        SELECT l.photo_id
        FROM likes l
        WHERE l.user_id = u.id
    )
);

#24  List photos with the most comments

SELECT p.id AS photo_id, p.image_url, COUNT(c.id) AS comment_count
FROM photos p
JOIN comments c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY comment_count DESC
LIMIT 5;

#25 List users who have liked more than 50 photos

SELECT u.username, COUNT(l.photo_id) AS liked_photos
FROM users u
JOIN likes l ON u.id = l.user_id
GROUP BY u.id
HAVING COUNT(l.photo_id) > 50;
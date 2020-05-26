-- 1. Создать все необходимые внешние ключи и диаграмму отношений.


ALTER TABLE users 
  ADD CONSTRAINT users_status_id_fk
  FOREIGN KEY (status_id) REFERENCES user_statuses(id)
    ON DELETE SET NULL;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE profiles MODIFY COLUMN user_id INT UNSIGNED;
     
ALTER TABLE communities_users 
  ADD CONSTRAINT communities_users_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT communities_users_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

ALTER TABLE friendship 
  ADD CONSTRAINT friendship_status_id_fk 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
      ON DELETE CASCADE, 
  ADD CONSTRAINT friendship_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT friendship_friend_id_fk
    FOREIGN KEY (friend_id) REFERENCES users(id)
      ON DELETE CASCADE;
     
ALTER TABLE likes 
  ADD CONSTRAINT likes_target_type_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT likes__user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE SET NULL;
     
ALTER TABLE likes MODIFY COLUMN target_type_id INT UNSIGNED;
     
ALTER TABLE posts 
  ADD CONSTRAINT posts_media_id_fk 
    FOREIGN KEY (media_id) REFERENCES media(id)
      ON DELETE SET NULL, 
  ADD CONSTRAINT posts_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT posts__user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE SET NULL;
      
ALTER TABLE posts MODIFY COLUMN media_id INT UNSIGNED;

-- 2. Создать и заполнить таблицы лайков и постов.

SELECT COUNT(*) FROM likes 
  WHERE target_type_id = 2
    AND target_id IN (SELECT * FROM (
      SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
    ) AS sorted_profiles ) 
;

-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT
	(SELECT gender FROM profiles WHERE user_id = likes.user_id) AS like_user
    FROM likes;

SELECT
	(SELECT gender FROM profiles WHERE user_id = likes.user_id) AS like_user,
	COUNT(*) AS total
    FROM likes
    GROUP BY gender
    ORDER BY total DESC
    LIMIT 1; 

  -- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной 
-- сети.  
   
SELECT 
  CONCAT(first_name, ' ', last_name) AS user, 
	(SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) + 
	(SELECT COUNT(*) FROM media WHERE media.user_id = users.id) + 
	(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id) AS overall_activity 
	  FROM users
	  ORDER BY overall_activity
	  LIMIT 10;




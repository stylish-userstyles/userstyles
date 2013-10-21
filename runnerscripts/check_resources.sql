SELECT style_id, REPLACE(REPLACE(code, '\r', ''), '\n', '') 
FROM styles 
	INNER JOIN style_codes ON styles.id = style_id
WHERE obsolete = 0
ORDER BY styles.id;

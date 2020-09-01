SELECT C.name, M.text, U.name, M.ts FROM slack_message M
INNER JOIN slack_channel C ON C.id = M.[channel_id]
INNER JOIN slack_user U ON U.id = M.[user]
WHERE C.Name = 'ancora'
ORDER BY M.ts
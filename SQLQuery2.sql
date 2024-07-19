-- Primera consulta: Seleccionar DisplayName, Location y Reputation de los usuarios
SELECT TOP 200
DisplayName, 
Location, 
Reputation
FROM dbo.Users
ORDER BY Reputation DESC;

-- Segunda consulta: Seleccionar Title de Posts y DisplayName de Users
SELECT TOP 200
p.Title,
u.DisplayName
FROM dbo.Posts p
JOIN dbo.Users u ON p.OwnerUserId = u.Id
WHERE p.OwnerUserId IS NOT NULL;

-- Tercera consulta: Calcular el promedio de Score de los Posts por cada usuario
SELECT TOP 200 
u.DisplayName, 
AVG(p.Score) AS AverageScore
FROM dbo.Posts p
JOIN dbo.Users u ON p.OwnerUserId = u.Id
GROUP BY u.DisplayName
ORDER BY AverageScore DESC;

-- Cuarta consulta: Encontrar DisplayName de usuarios con más de 100 comentarios
SELECT TOP 200
u.DisplayName
FROM dbo.Users u
WHERE u.Id IN (
    SELECT c.UserId
    FROM dbo.Comments c
    GROUP BY c.UserId
    HAVING COUNT(c.Id) > 100
);

-- Quinta consulta: Actualizar Location vacío a "Desconocido"
UPDATE dbo.Users
SET Location = 'Desconocido'
WHERE Location IS NULL OR Location = '';

-- Mensaje de confirmación
PRINT 'La actualización se realizó correctamente.';

--Visualizar la tabla Users después de la actualización
SELECT  TOP 200
Id, 
DisplayName, 
Location, 
Reputation
FROM dbo.Users;

-- Sexta consulta: Eliminar todos los comentarios realizados por usuarios con menos de 100 de reputación

-- Eliminar los comentarios realizados por usuarios con menos de 100 de reputación
DECLARE @ComentariosEliminados INT;

-- Eliminar los comentarios realizados por usuarios con menos de 100 de reputación
DELETE FROM dbo.Comments
WHERE UserId IN (
    SELECT TOP 200
	Id
    FROM dbo.Users
    WHERE Reputation < 100
);

-- Obtener el número de comentarios eliminados
SET @ComentariosEliminados = @@ROWCOUNT;

-- Mostrar un mensaje con la cantidad de comentarios eliminados
PRINT 'Se eliminaron ' + CAST(@ComentariosEliminados AS VARCHAR(10)) + ' comentarios.';

-- Visualizar la tabla Comments después de la eliminación de comentarios, limitando a 200 registros
SELECT TOP 200
    *
FROM dbo.Comments
ORDER BY Id;  -- Ordenar por Id para una vista más estructurada

--Septima consulta: mostrar el número total de publicaciones, comentarios y medallas por usuario

WITH 
TotalPublicacionesPorUsuario AS (
    SELECT TOP 200
        OwnerUserId AS UserId,
        COUNT(*) AS TotalPosts
    FROM dbo.Posts
    GROUP BY OwnerUserId
),
TotalComentariosPorUsuario AS (
    SELECT TOP 200
        UserId,
        COUNT(*) AS TotalComments
    FROM dbo.Comments
    GROUP BY UserId
),
TotalMedallasPorUsuario AS (
    SELECT TOP 200
        UserId,
        COUNT(*) AS TotalBadges
    FROM dbo.Badges
    GROUP BY UserId
)

-- Consulta final que combina los resultados de los CTEs
SELECT  TOP 200
    u.DisplayName,
    ISNULL(tp.TotalPosts, 0) AS TotalPublicaciones,
    ISNULL(tc.TotalComments, 0) AS TotalComentarios,
    ISNULL(tm.TotalBadges, 0) AS TotalMedallas
FROM dbo.Users u
LEFT JOIN TotalPublicacionesPorUsuario tp ON u.Id = tp.UserId
LEFT JOIN TotalComentariosPorUsuario tc ON u.Id = tc.UserId
LEFT JOIN TotalMedallasPorUsuario tm ON u.Id = tm.UserId
ORDER BY u.DisplayName;

--Octava consulta: Mostrar las 10 publicaciones más populares basadas en la puntuación (Score)
SELECT TOP 10
    Title,
    Score
FROM dbo.Posts
ORDER BY Score DESC;

--Novena consulta: Mostrar los 5 comentarios más recientes basados en la fecha de creación
SELECT TOP 5
    Text,
    CreationDate
FROM dbo.Comments
ORDER BY CreationDate DESC;

USE Com5600G05
GO

-- Mostrar roles con sus respectivos miembros y el tipo de miembro (S para usuario R para rol anidado)
SELECT
	dp1.name AS Rol,
	ISNULL (dp2.name, 'Sin miembros') AS Miembro,
	dp2.type AS [Tipo de miembro]
FROM sys.database_role_members AS drm
RIGHT JOIN sys.database_principals AS dp1
	ON drm.role_principal_id = dp1.principal_id
LEFT JOIN sys.database_principals AS dp2
	ON drm.member_principal_id = dp2.principal_id
WHERE dp1.type = 'R'
ORDER BY Rol;

-- Mostrar roles con sus respectivos permisos
SELECT
	perm.permission_name AS [Tipo de permiso],
	obj.name AS Objeto,
	princ.name AS Rol
FROM sys.database_permissions perm
INNER JOIN sys.database_principals princ
	ON perm.grantee_principal_id = princ.principal_id
INNER JOIN sys.objects obj
	ON perm.major_id = obj.object_id
WHERE
	perm.permission_name <> 'ALTER' AND
	princ.type = 'R' AND
	perm.state_desc = 'GRANT'
ORDER BY perm.permission_name;
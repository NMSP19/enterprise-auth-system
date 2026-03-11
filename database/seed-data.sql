-- Insert Roles
INSERT INTO roles (name, description) VALUES 
  ('ADMIN', 'Administrator with full access'),
  ('USER', 'Regular user with limited access'),
  ('MANAGER', 'Manager with team management access')
ON CONFLICT (name) DO NOTHING;

-- Insert Permissions
INSERT INTO permissions (name, description) VALUES
  ('VIEW_USER', 'Can view user information'),
  ('CREATE_USER', 'Can create new users'),
  ('UPDATE_USER', 'Can update user information'),
  ('DELETE_USER', 'Can delete users'),
  ('MANAGE_ROLES', 'Can manage roles and permissions')
ON CONFLICT (name) DO NOTHING;

-- Assign permissions to ADMIN role (all permissions)
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

-- Assign limited permissions to USER role (view only)
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'USER' AND p.name = 'VIEW_USER'
ON CONFLICT DO NOTHING;

-- Assign manager permissions
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'MANAGER' AND p.name IN ('VIEW_USER', 'CREATE_USER', 'UPDATE_USER')
ON CONFLICT DO NOTHING;

-- Note: In production, user credentials should be hashed with BCrypt
-- For demo purposes, passwords are plain text but in production must be hashed
-- Admin: admin123 | User: user123 | Manager: manager123

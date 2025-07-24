-- Vision Week Virtual Exploration Database Schema
-- Optimized for performance, security, and data integrity

-- Enable UUID extension for PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table with comprehensive security features
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
    email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_uuid ON users(uuid);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Categories table for organizing content
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7), -- Hex color code
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO categories (name, slug, description, icon, color, sort_order) VALUES
('Nature', 'nature', 'Explore the wonders of nature', 'nature', '#4CAF50', 1),
('Animals', 'animals', 'Discover amazing wildlife', 'pets', '#FF9800', 2),
('Adventure', 'adventure', 'Thrilling adventures await', 'explore', '#F44336', 3),
('Education', 'education', 'Learn something new', 'school', '#2196F3', 4),
('Entertainment', 'entertainment', 'Fun and engaging content', 'movie', '#9C27B0', 5);

-- Animals table with detailed information
CREATE TABLE animals (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255),
    category_id INTEGER REFERENCES categories(id),
    description TEXT,
    habitat VARCHAR(255),
    diet VARCHAR(100),
    conservation_status VARCHAR(50),
    average_lifespan INTEGER, -- in years
    weight_range VARCHAR(100), -- e.g., "50-100 kg"
    height_range VARCHAR(100), -- e.g., "1.5-2.0 m"
    image_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    fun_facts TEXT[],
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate animals
    CONSTRAINT unique_animal_scientific_name UNIQUE (scientific_name),
    CONSTRAINT unique_animal_name_category UNIQUE (name, category_id)
);

-- Create indexes for animals
CREATE INDEX idx_animals_category_id ON animals(category_id);
CREATE INDEX idx_animals_name ON animals(name);
CREATE INDEX idx_animals_conservation_status ON animals(conservation_status);
CREATE INDEX idx_animals_is_featured ON animals(is_featured);
CREATE INDEX idx_animals_view_count ON animals(view_count);

-- Videos table for educational content
CREATE TABLE videos (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration INTEGER, -- in seconds
    category_id INTEGER REFERENCES categories(id),
    animal_id INTEGER REFERENCES animals(id),
    uploaded_by INTEGER REFERENCES users(id),
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    dislike_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    quality VARCHAR(20) DEFAULT 'HD' CHECK (quality IN ('SD', 'HD', '4K')),
    language VARCHAR(10) DEFAULT 'en',
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate videos
    CONSTRAINT unique_video_url UNIQUE (url),
    CONSTRAINT unique_video_title_category UNIQUE (title, category_id)
);

-- Create indexes for videos
CREATE INDEX idx_videos_category_id ON videos(category_id);
CREATE INDEX idx_videos_animal_id ON videos(animal_id);
CREATE INDEX idx_videos_uploaded_by ON videos(uploaded_by);
CREATE INDEX idx_videos_view_count ON videos(view_count);
CREATE INDEX idx_videos_is_featured ON videos(is_featured);
CREATE INDEX idx_videos_is_approved ON videos(is_approved);

-- Comments table for user feedback
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    video_id INTEGER REFERENCES videos(id) ON DELETE CASCADE,
    animal_id INTEGER REFERENCES animals(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    is_approved BOOLEAN DEFAULT FALSE,
    parent_id INTEGER REFERENCES comments(id), -- For nested comments
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure at least one reference (video or animal)
    CONSTRAINT check_comment_reference CHECK (
        (video_id IS NOT NULL AND animal_id IS NULL) OR 
        (video_id IS NULL AND animal_id IS NOT NULL)
    ),
    
    -- Prevent duplicate comments from same user on same content
    CONSTRAINT unique_user_video_comment UNIQUE (user_id, video_id, content),
    CONSTRAINT unique_user_animal_comment UNIQUE (user_id, animal_id, content)
);

-- Create indexes for comments
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_video_id ON comments(video_id);
CREATE INDEX idx_comments_animal_id ON comments(animal_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);

-- User favorites table
CREATE TABLE user_favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    video_id INTEGER REFERENCES videos(id) ON DELETE CASCADE,
    animal_id INTEGER REFERENCES animals(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure at least one reference (video or animal)
    CONSTRAINT check_favorite_reference CHECK (
        (video_id IS NOT NULL AND animal_id IS NULL) OR 
        (video_id IS NULL AND animal_id IS NOT NULL)
    ),
    
    -- Prevent duplicate favorites
    CONSTRAINT unique_user_video_favorite UNIQUE (user_id, video_id),
    CONSTRAINT unique_user_animal_favorite UNIQUE (user_id, animal_id)
);

-- Create indexes for favorites
CREATE INDEX idx_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_favorites_video_id ON user_favorites(video_id);
CREATE INDEX idx_favorites_animal_id ON user_favorites(animal_id);

-- User activity logs for analytics and security
CREATE TABLE user_activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50), -- 'video', 'animal', 'comment', etc.
    resource_id INTEGER,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for activity logs
CREATE INDEX idx_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX idx_activity_logs_action ON user_activity_logs(action);
CREATE INDEX idx_activity_logs_created_at ON user_activity_logs(created_at);
CREATE INDEX idx_activity_logs_ip_address ON user_activity_logs(ip_address);

-- Security logs for monitoring suspicious activities
CREATE TABLE security_logs (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    user_id INTEGER REFERENCES users(id),
    ip_address INET,
    user_agent TEXT,
    event_data JSONB,
    severity VARCHAR(20) DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'error', 'critical')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for security logs
CREATE INDEX idx_security_logs_event_type ON security_logs(event_type);
CREATE INDEX idx_security_logs_user_id ON security_logs(user_id);
CREATE INDEX idx_security_logs_severity ON security_logs(severity);
CREATE INDEX idx_security_logs_created_at ON security_logs(created_at);
CREATE INDEX idx_security_logs_ip_address ON security_logs(ip_address);

-- Search history for analytics
CREATE TABLE search_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    query VARCHAR(255) NOT NULL,
    category_filter VARCHAR(100),
    results_count INTEGER DEFAULT 0,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent excessive duplicate searches
    CONSTRAINT unique_user_query_day UNIQUE (user_id, query, DATE(created_at))
);

-- Create indexes for search history
CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_search_history_query ON search_history(query);
CREATE INDEX idx_search_history_created_at ON search_history(created_at);

-- System settings table
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string' CHECK (data_type IN ('string', 'integer', 'boolean', 'json')),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default system settings
INSERT INTO system_settings (key, value, description, data_type, is_public) VALUES
('app_name', 'Vision Week Virtual Exploration', 'Application name', 'string', true),
('app_version', '2.0.0', 'Current application version', 'string', true),
('maintenance_mode', 'false', 'Enable maintenance mode', 'boolean', false),
('max_upload_size', '10485760', 'Maximum file upload size in bytes', 'integer', false),
('allowed_file_types', '["jpg", "jpeg", "png", "gif", "webp"]', 'Allowed file extensions', 'json', false),
('rate_limit_requests', '100', 'Rate limit requests per minute', 'integer', false),
('session_timeout', '3600', 'Session timeout in seconds', 'integer', false);

-- File uploads table
CREATE TABLE file_uploads (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    original_filename VARCHAR(255) NOT NULL,
    stored_filename VARCHAR(255) UNIQUE NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_hash VARCHAR(64) UNIQUE NOT NULL, -- SHA-256 hash to prevent duplicates
    upload_type VARCHAR(50) NOT NULL, -- 'avatar', 'video_thumbnail', 'animal_image', etc.
    is_processed BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent duplicate files
    CONSTRAINT unique_file_hash UNIQUE (file_hash)
);

-- Create indexes for file uploads
CREATE INDEX idx_file_uploads_user_id ON file_uploads(user_id);
CREATE INDEX idx_file_uploads_file_hash ON file_uploads(file_hash);
CREATE INDEX idx_file_uploads_upload_type ON file_uploads(upload_type);
CREATE INDEX idx_file_uploads_created_at ON file_uploads(created_at);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_animals_updated_at BEFORE UPDATE ON animals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_videos_updated_at BEFORE UPDATE ON videos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create views for common queries
CREATE VIEW active_users AS
SELECT id, uuid, username, email, first_name, last_name, role, created_at, last_login_at
FROM users 
WHERE deleted_at IS NULL;

CREATE VIEW featured_content AS
SELECT 
    'animal' as content_type,
    a.id,
    a.uuid,
    a.name as title,
    a.description,
    a.image_url,
    a.view_count,
    c.name as category_name,
    a.created_at
FROM animals a
JOIN categories c ON a.category_id = c.id
WHERE a.is_featured = TRUE
UNION ALL
SELECT 
    'video' as content_type,
    v.id,
    v.uuid,
    v.title,
    v.description,
    v.thumbnail_url as image_url,
    v.view_count,
    c.name as category_name,
    v.created_at
FROM videos v
JOIN categories c ON v.category_id = c.id
WHERE v.is_featured = TRUE AND v.is_approved = TRUE
ORDER BY view_count DESC, created_at DESC;

-- Create materialized view for analytics (refresh periodically)
CREATE MATERIALIZED VIEW analytics_summary AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) as total_users,
    (SELECT COUNT(*) FROM animals) as total_animals,
    (SELECT COUNT(*) FROM videos WHERE is_approved = TRUE) as total_videos,
    (SELECT COUNT(*) FROM comments WHERE is_approved = TRUE) as total_comments,
    (SELECT SUM(view_count) FROM animals) as total_animal_views,
    (SELECT SUM(view_count) FROM videos) as total_video_views,
    CURRENT_TIMESTAMP as last_updated;

-- Create unique index on materialized view
CREATE UNIQUE INDEX idx_analytics_summary_last_updated ON analytics_summary(last_updated);

-- Function to refresh analytics
CREATE OR REPLACE FUNCTION refresh_analytics()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY analytics_summary;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed for your environment)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_user;


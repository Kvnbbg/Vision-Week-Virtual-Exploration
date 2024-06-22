-- Create Videos table
CREATE TABLE IF NOT EXISTS Videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    category VARCHAR(255),
    description TEXT,
    source_link VARCHAR(255),
    thumbnail_url VARCHAR(255)
);

-- Insert sample data into Videos table
INSERT INTO Videos (title, category, description, source_link, thumbnail_url) VALUES
('Deep Sea Dive', 'Deep-sea', 'Explore the depths of the ocean in this video.', 'https://example.com/deep-sea', 'https://example.com/thumbnails/1.jpg'),
('Space Odyssey', 'Space', 'Journey through space and beyond.', 'https://example.com/space', 'https://example.com/thumbnails/2.jpg'),
('Ancient Ruins', 'Archaeology', 'Discover ancient ruins and civilizations.', 'https://example.com/archaeology', 'https://example.com/thumbnails/3.jpg'),
('Nature\'s Wonders', 'Nature', 'Experience the beauty of nature.', 'https://example.com/nature', 'https://example.com/thumbnails/4.jpg');

CREATE TABLE toilets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    toilet_avail BOOLEAN DEFAULT FALSE,
    handicap_avail BOOLEAN DEFAULT FALSE,
    bidet_avail BOOLEAN DEFAULT FALSE,
    shower_avail BOOLEAN DEFAULT FALSE,
    sanitiser_avail BOOLEAN DEFAULT FALSE,
    crowd_level INT NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.0,
    image_url TEXT, -- Added to store toilet images
    report_count INT DEFAULT 0 -- Track number of reports for the toilet
);

-- 3. Reviews Table (With images and report count)
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    toilet_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_url TEXT, -- Added to store review images
    report_count INT DEFAULT 0, -- Track number of reports for the review
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (toilet_id) REFERENCES toilets(id) ON DELETE CASCADE
);

-- 4. Favorites Table
CREATE TABLE favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    toilet_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (toilet_id) REFERENCES toilets(id) ON DELETE CASCADE
);

USE AnimeDB

CREATE TABLE Anime (
    anime_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50),
    episodes INT NULL,
    rating FLOAT NULL,
    members INT
);

CREATE TABLE Genres (
    genre_id INT IDENTITY(1,1) PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Anime_Genres (
    anime_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(anime_id, genre_id),
    FOREIGN KEY (anime_id) REFERENCES Anime(anime_id),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);

CREATE TABLE User_Ratings (
    user_id INT NOT NULL,
    anime_id INT NOT NULL,
    rating INT,
    PRIMARY KEY(user_id, anime_id),
    FOREIGN KEY (anime_id) REFERENCES Anime(anime_id)
);

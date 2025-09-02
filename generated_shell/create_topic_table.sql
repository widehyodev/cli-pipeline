CREATE TABLE IF NOT EXISTS geeknews_topic (
        id int NOT NULL,
        url varchar(200) NOT NULL,
        title text NULL,
        "content" text NULL,
        CONSTRAINT geeknews_topic_pkey PRIMARY KEY (id)
);
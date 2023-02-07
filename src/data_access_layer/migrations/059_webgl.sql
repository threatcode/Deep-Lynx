ALTER TABLE IF EXISTS tags DROP COLUMN data_source_id;
ALTER TABLE IF EXISTS tags DROP CONSTRAINT tags_pkey;
ALTER TABLE IF EXISTS tags ADD CONSTRAINT tags_compkey PRIMARY KEY (id, created_at);
ALTER TABLE IF EXISTS tags ADD CONSTRAINT tags_tag_name_uniq UNIQUE (id, tag_name);
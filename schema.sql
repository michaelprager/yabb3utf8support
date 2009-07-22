CREATE TABLE IF NOT EXISTS Boards (
    id          INTEGER PRIMARY KEY, -- board id
    parent      INTEGER,             -- parent id, if applicable
    lft         INTEGER,             -- left value for nested set
    rgt         INTEGER,             -- right value for nested set
    name        VARCHAR(255),        -- name of the board
    description TEXT,                -- description of it
    img         TEXT                 -- url to image to display w/ desc.
);

CREATE TABLE IF NOT EXISTS Posts (
    id              INTEGER PRIMARY KEY, -- post id
    thread          INTEGER,             -- NULL if this is the first post in a
                                         -- thread, otherwise points to 1st
    parent          INTEGER,             -- for full threading, direct parent
    author_id       INTEGER,             -- user id of author, NULL for guest
    author_name     VARCHAR(255),        -- info for a guest author
    author_email    VARCHAR(255),        --
    title           VARCHAR(255),        -- title of post
    message         TEXT,                -- post itself
    time_created    NUMERIC(10,0),       -- Could be a problem at:
    time_modified   NUMERIC(10,0),       -- Sat, 20 Nov 2286 17:46:39 GMT
    flags           INTEGER              -- post flags
    -- Flags will have to be defined in the Perl code, we should probably have
    -- HAS_ATTACHMENTS - 0x01 - 0001
    -- HAS_POLL        - 0x02 - 0010
    -- NO_BBC          - 0x04 - 0100
    -- NO_SMILING      - 0x08 - 1000
    -- other things I haven't thought of yet
    -- I like bit fields, but is it the right answer?
);

CREATE TABLE IF NOT EXISTS Attachments (
    id          -- file id
    postid      -- post it is attached to
    filename    -- name of the file in
    location    -- where it's stored rel. to attachments directory
    filesize    -- 
);

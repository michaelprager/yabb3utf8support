-- holds boards
CREATE TABLE  Boards (
    id          INTEGER PRIMARY KEY, -- board id
    parent      INTEGER,             -- parent id, if applicable
    lft         INTEGER,             -- left value for nested set
    rgt         INTEGER,             -- right value for nested set
    name        VARCHAR(255),        -- name of the board
    description TEXT,                -- description of it
    img         TEXT                 -- url to image to display w/ desc.
);
CREATE INDEX ptt_left ON Boards (lft);
CREATE INDEX ptt_right ON Boards (rgt);

-- holds threads
CREATE TABLE  Threads (
    id              INTEGER PRIMARY KEY,
    boardid         INTEGER,
    replies         INTEGER,
    views           INTEGER,
    lastpost_userid INTEGER,
    lastpost_time   NUMERIC(10,0),
    flags           INTEGER
    -- LOCKED   - 0x01 - 0001
    -- STICKY   - 0x02 - 0010
    -- HAS_POLL - 0x03 - 0100
);
CREATE INDEX threads_board ON Threads (boardid);

-- holds posts
CREATE TABLE  Posts (
    id              INTEGER PRIMARY KEY, -- post id
    thread          INTEGER,             -- thread that this belongs to
    parent          INTEGER,             -- for full threading, direct parent
    author_userid   INTEGER,             -- user id of author, NULL for guest
    author_name     VARCHAR(255),        -- info for a guest author
    author_email    VARCHAR(255),        --
    author_ip       VARCHAR(15),         --
    title           VARCHAR(255),        -- title of post
    message         TEXT,                -- post itself
    created         NUMERIC(10,0),       -- (time) Could be a problem at:
    modified_time   NUMERIC(10,0),       -- Sat, 20 Nov 2286 17:46:39 GMT
    modified_userid INTEGER,             -- userid of message modifier
    icon            VARCHAR(15),         -- message icon
    flags           INTEGER              -- post flags
    -- Flags will have to be defined in the Perl code, we should probably have
    -- HAS_ATTACHMENTS - 0x01 - 0001
    -- NO_BBC          - 0x02 - 0010
    -- NO_SMILING      - 0x03 - 0100
    -- other things I haven't thought of yet
    -- I like bit fields, but is it the right answer?
);
CREATE INDEX post_threads ON Posts (thread);

-- holds attachements
CREATE TABLE  Attachments (
    id         INTEGER PRIMARY KEY, -- file id
    postid     INTEGER,             -- post it is attached to
    filename   VARCHAR(255),        -- name of the file when uploaded
    location   VARCHAR(255),        -- path & name within attachments directory
    filesize   INTEGER,             -- KB, usually a TB/attachment is sufficent
    downloads  INTEGER              -- # of times attchment has been d/l
);
CREATE INDEX attchment_posts ON Attachments (postid);

-- holds poll questions
CREATE TABLE  Polls (
    id          INTEGER PRIMARY KEY, -- ...
    threadid    INTEGER,             -- thread this poll is in
    question    TEXT,                -- 
    numchoices  INTEGER,             -- how many choices the user can vote for
    expires     NUMERIC(10,0),       -- when the poll is closed
    flags       INTEGER              -- 
    -- POSSIBLE FLAGS:
    -- SHOW_AFTER_VOTE  - 0x01 - 0001 - default is to show after expiration
    -- NEVER_SHOW       - 0x02 - 0010
    -- CAN_CHANGE   - do we want to allow this?
);
CREATE INDEX poll_posts ON Polls (postid);

-- holds poll answers
CREATE TABLE  PollAnswers (
    id      INTEGER PRIMARY KEY, --
    pollid  INTEGER,             --
    answer  TEXT,                --
    votes   INTEGER              -- votes for this choice
);
CREATE INDEX poll_answer ON PollAnswers (pollid);

-- TODO
-- pollvotes table needed so votes can be changed/audited

-- user data
-- this stuff is all just fundamental forum stuff that -everyone- has
CREATE TABLE  Users (
    id          INTEGER PRIMARY KEY, -- 
    username    VARCHAR(255),        --
    password    VARCHAR(64),         -- the hash representation of the pw
    name        VARCHAR(255),        --
    email       VARCHAR(255),        --
    signature   TEXT,                -- signature on messages
    registered  NUMERIC(10,0),       -- registration date
    posts       INTEGER,             -- number of posts this user has made
    last_online NUMERIC(10,0),       -- timestamp of last time online
    last_post   INTEGER,             -- postid of last post
    time_zone   VARCHAR(3),          -- time zone code
-- use abbreviations here:
-- http://publib.boulder.ibm.com/tividd/td/TWS/SC32-1274-02/en_US/HTML/SRF_mst273.htm
    time_dst    NUMERIC(1,0)         -- Daylight Savings Time?
    time_format VARCHAR(50),         -- formatting string for time
    avatar_type NUMERIC(2,0),        -- 0 = premade, 1 = upload, 2 = url
    avatar      VARCHAR(255),        -- avatar location depending on type
    customtext  VARCHAR(255),
    lang        VARCHAR(10),         -- user's preferred language
    permissions INTEGER,             -- permissions for user type things
    flags       INTEGER              -- user flags
);

-- other data that isn't critical, nice for extending profile
-- things like AIM, Facebook, and stuff like that go here
CREATE TABLE  UsersExtendedInfo (
    ufid       VARCHAR(45) PRIMARY KEY, -- since we don't support compound pk
                                        -- this is 'userid'.'fieldname'
    userid     INTEGER,                 --
    fieldname  VARCHAR(30),             -- the name of the field ie 'birthdate' 
    fieldvalue VARCHAR(255),            -- the value of the field ie 1986-08-10
);
CREATE INDEX user_info ON UsersExtendedInfo (userid);

-- TODO
--CREATE TABLE  MemberGroups ();

CREATE TABLE  BoardTracking (
    ubid        VARCHAR(30) PRIMARY KEY, -- since we don't support compound pk
                                         -- this is 'userid'.'boardid'
    userid      INTEGER,
    boardid     INTEGER,
    check_time  NUMERIC(10,0)
);
CREATE INDEX user_board_tracking ON BoardTracking (userid);

CREATE TABLE  ThreadTracking (
    utid        VARCHAR(30) PRIMARY KEY, -- since we don't support compound pk
                                         -- this is 'userid'.'threadid'
    userid      INTEGER,
    threadid    INTEGER,
    check_time  NUMERIC(10,0)
);
CREATE INDEX user_thread_tracking ON ThreadTracking (userid);

-- TODO
CREATE TABLE  BoardSubscriptions (
    id      INTEGER PRIMARY KEY, --
    boardid INTEGER,             -- board
    userid  INTEGER,             -- subscribed user
    sent    NUMERIC(10,0)        -- set to 1 after sending
    -- only send if value is 0, that way we don't super-spam them
);
CREATE INDEX board_subscriptions ON BoardSubscriptions (boardid);

--
CREATE TABLE  ThreadSubscriptions (
    id       INTEGER PRIMARY KEY, --
    threadid INTEGER,             -- thread
    userid   INTEGER,             -- subscribed user
    sent     NUMERIC(10,0)        -- set to 1 after sending
    -- only send if value is 0, that way we don't super-spam them
);
CREATE INDEX thread_subscriptions ON ThreadSubscriptions (threadid);

--CREATE TABLE  PMFolders ();

--CREATE TABLE  PMs ();

--CREATE TABLE  PMsUser ();

--CREATE TABLE  PMUserSettings ();

CREATE TABLE  Bans (
    id          INTEGER PRIMARY KEY, --
    ban_type    INTEGER,             -- ip=0, email=1, user=2
    ban_field   VARCHAR(255),        -- data dep. on type
    ban_length  NUMERIC(10,0),       -- expiration time; 0 = perm
    ban_by      INTEGER              -- userid of banner
    description TEXT                 -- comment on why
);

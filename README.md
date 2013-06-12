# Nyfyk

Nyfyk is a RSS Reader HTML5 app that will only work with very modern browsers, see <http://caniuse.com/#search=flex> for my definiton of modern. It's code is an adaptation of the wReader chrome app linked below. It uses postgresql as a backend. [Openresty](http://openresty.org) serves as the middleware between the database and the front end app, just because I love me some openresty. 

### Why ?

Why not? It's fun!

### What's with the name?

Nyfyk is a play on words in Norwegian where Ny means New and just like in english the start of the word for News. Fyk's literal meaning is "fly", also used about journalist slang "Bladfyk". This makes Nyfyk's meaning "Running after News", or "Running after New stuff", sort of.

### Attribution / Credits / Copyrights

This code is a fork off WReader by [Pete LePage](http://petelepage.com)
AngularJS port by [Eric Bidelma](http://ericbidelman.com), Vojta Jina.
Chrome Platform port by [Igor Minar](http://igorminar.com)
Newsbeuter backend switch, flex update and UI changes by [Tor Hveem](http://hveem.no/)


# Install
    create user nyfyk with password 'sasdf';
    create database nyfyk;
    grant all privileges on database nyfyk to nyfyk;

CREATE TABLE rss_feed (
        id SERIAL PRIMARY KEY NOT NULL,
        rssurl VARCHAR(1024),
        url VARCHAR(1024) NOT NULL,
        title VARCHAR(1024) NOT NULL ,
        author VARCHAR(1024) NOT NULL ,
        lastmodified timestamp,
        is_rtl BOOLEAN NOT NULL DEFAULT '0',
        etag VARCHAR(128));

    CREATE TABLE rss_item (  
            id SERIAL PRIMARY KEY NOT NULL, 
            rss_feed INTEGER references rss_feed(id), 
            guid VARCHAR(64) NOT NULL,  
            title VARCHAR(1024) NOT NULL,  
            author VARCHAR(1024) NOT NULL,  
            url VARCHAR(1024) NOT NULL,  
            feedurl VARCHAR(1024) NOT NULL,  
            pubDate timestamp NOT NULL,  
            content VARCHAR(65535) NOT NULL, 
            enclosure_url VARCHAR(1024), 
            enclosure_type VARCHAR(1024), 
            enqueued BOOLEAN NOT NULL DEFAULT '0', 
            flags VARCHAR(52), 
            base VARCHAR(128));

    CREATE INDEX idx_rssurl ON rss_feed(rssurl);

    CREATE TABLE email (
            email varchar(100) UNIQUE PRIMARY KEY NOT NULL,
            created_at timestamp DEFAULT current_timestamp NOT NULL
            );

    CREATE TABLE subscription (
        id SERIAL PRIMARY KEY NOT NULL,
        email varchar(100) references email(email),
        rss_feed INTEGER references rss_feed(id),
        created_at timestamp DEFAULT current_timestamp NOT NULL
    );

    CREATE INDEX idx_email ON subscription(email);

    create table rss_log (
        id SERIAL PRIMARY KEY NOT NULL,
        email varchar(100) references email(email),
        rss_item INTEGER references rss_item(id),
        read BOOLEAN NOT NULL DEFAULT '0', 
        deleted BOOLEAN NOT NULL DEFAULT '0', 
        starred BOOLEAN NOT NULL DEFAULT '0', 
        created_at timestamp DEFAULT current_timestamp NOT NULL,
        CONSTRAINT uq_log UNIQUE (email, rss_item)
    );

    CREATE INDEX idx_starred ON rss_log(starred);
    CREATE INDEX idx_read ON rss_log(read);


    CREATE TABLE session (
        sessionid varchar(32) PRIMARY KEY NOT NULL,
        email varchar(100) references email(email),
        created timestamp,
        expires timestamp
    );


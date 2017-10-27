Disclaimer
----------
Dear visitor. I first didn't dare to publish this repository, because it's dead old and surely **not a good representation** of my coding skills nowadays. But, everyone start's somewhere, right? And we did get an A, so... ;)

It is by no means "ready" for anything, rather a **toy example** to get some first hands-on experience in web development.

In our group of four, **I was responsible for** the backend, meaning **database model**, **server API** and such. A lot of time also went into setting up the development environment for everyone, **server administration**, or building the project structure in the first place.

#### The stack
- Linux VM hosted by University
- PostgreSQL database
- Ruby (not on Rails but with Sinatra, and Sequel as an ORM)
- ERB views, Bootstrap and Less

#### The features
- Online platform for children learning basic arithmetic with games
- Basic social network with personal profiles, "friendships" and achievement lists (and totally not encrypted passwords)
- **The special part:** Games are loaded dynamically, and are extensible. With an admin access (and knowledge of the technical requirements) you can upload additional games!
- Responsive and fancy design

<br>

... And from here on everything is as it was at the end of Semester 3 (2014). Should there be any questions, I'm glad to answer them.


Schnürchen
==========
Obacht!
-------
1. postgreSQL installieren, Datenbank schnuerchen_dev erstellen
2. pullen
3. /app/db/connect_muster.rb kopieren, connect.rb nennen
4. `<user>` durch euren DB-usernamen ersetzen
5. im Terminal in den Ordner */schnuerchen/app wechseln (später nur */schnuerchen)
6. rackup` laufen lassen
7. Fehler analysieren und beheben ;D


Struktur
--------
* db: Konfigurationen für Connection (connect.rb (.gitignored), scripts (verm. nicht notwendig), migrations (für DB Versionierung, später))
* lib:
* models: Models AKA DB-Tabellen, allgemein Datenteil
* public: Stuff fürs Interface, was eben dem Client zugänglich ist
* routes: GET / POST / usw URL Verarbeitung
* spec: Konfigurationen für Testläufe (mit rack-test soweit ich weiß)
* views: Seiten, eigentlich als .erb, mal sehen wie wirs dann machen (JavaScript?)
* Gemfile: Verwaltet required gems
* app.rb: Startpunkt
* config.ru: wichtig für rackup
* Rakefile: für Tests (spec) noch unwichtig

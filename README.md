Schnürchen
==========

motherfuckersoftwareprojekt


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

--> starten mit rackup

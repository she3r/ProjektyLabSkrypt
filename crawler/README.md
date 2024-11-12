# RubyCrawler Amazon

Następujący program spełnia funkcjonalności:
1. Podaje podstawowe dane:
   - Nazwa produktu,
   - Cena produktu,
   - Liczba ocen klientów

2. Dodatkowe funkcjonalności dostępne z konfiguracji **config.yaml**:
   - *keywords* (kolekcja): Wyszukuje elementy na stronie html zgodnie z id obiektu html. Przydatne do przeszukiwania zawartości spanów o konkretnym id.
   - *search_string* (kolekcja): Przeszukiwanie strony html po słowach kluczowych, działa na zasadzie przeszukiwania LIKE

    
## Instalacja
Projekt jest zależny od dwóch bibliotek: crawlbase, nokogiri

```bash
gem install crawlbase
gem install nokogiri
```

## Wykorzystanie

Konfiguracja:
Do poprawnego działania niezbędne będzie konto i token z serwisu crawlbase. Token podajemy w polu *crawlbase_token*\
W konfiguracji podajemy również, w polu url, adres url strony z aukcją.\
Przykładowy output jest dostępny w pliku **example_out.txt**
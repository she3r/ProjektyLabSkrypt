aby uruchomić, tworzymy dwa osobne środowiska wirtualne. Oba python=3.9 lub 3.10. Ja pracowałem na środowiskach wirtualnych anacondy.
Środowisko A:
pip install rasa

Środowisko B:
1. pip install rasa
2. Instalujemy zgodnie z instrukcją:
https://spacy.io/usage
Pobieramy model large:
python -m spacy download en_core_web_lg
3. Obniżamy wersję packaging
pip install --force-reinstall packaging==20.9

tworzymy bazę danych za pomocą skryptu create_db.py

Uruchamiamy serwer actions na środowisku B 
rasa run actions
W szczególności nie wykonujemy żadnych innych operacji przy projekcie za pomocą środowiska B. Grozi to utratą możliwości korzystania z projektu z niewiadomych mi powodów ( python :) )
Za pomocą środowiska A nie uda nam się za to uruchomić serwera akcji, który wymaga do działania biblioteki spacy.
Uruchamiamy uczenie za pomocą środowiska A
rasa train
Uruchamiamy klienta strzelającego do modelu zapytaniami użytkownika z konsoli za pomocą środowiska A
rasa shell
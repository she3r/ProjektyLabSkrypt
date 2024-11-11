A. aby uruchomić, tworzymy dwa osobne środowiska wirtualne. Oba python=3.9 lub 3.10. Ja pracowałem na środowiskach wirtualnych anacondy.
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

Uruchamiamy serwer actions na środowisku B 
rasa run actions
W szczególności nie wykonujemy żadnych innych operacji przy projekcie za pomocą środowiska B. Grozi to utratą możliwości korzystania z projektu z niewiadomych mi powodów
Za pomocą środowiska A nie uda nam się za to uruchomić serwera akcji, który wymaga do działania biblioteki spacy.
Uruchamiamy uczenie za pomocą środowiska A
rasa train
Uruchamiamy klienta strzelającego do modelu zapytaniami użytkownika z konsoli za pomocą środowiska A
rasa shell

B. Przed uruchomieniem należy stworzyć bazę. Do bazy zapisywane są zamówienia
	tworzymy bazę danych za pomocą skryptu create_db.py

Testy:
Można przetestować kolejne zaprogramowane akcje czata.
Składanie zamówienia:
I’d like to have a hot dog with chili and cheese. Please also add 3 portions for my friends.
Can I order a Tiramisu with grilled onions and BBQ sauce?
I would like a pizza with ham and pineapple, please. Don’t forget to add 2 portions for my companions.

Zapytanie o menu:
Could I see the menu, please?
What options do you have on the menu?
Can you show me the menu?

Zapytanie o godzinę otwarcia w konkretnej godzinie:
Is the restaurant open at 6 PM?
Does the restaurant stay open until 3 AM?
Can I come to the restaurant at 13:00?

Zapytanie o godziny otwarcia restauracji:
What time does the restaurant open?
Can you tell me the opening hours for the restaurant?
When does the restaurant start serving?
from typing import Any, Text, Dict, List
import json
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from datetime import datetime
import spacy
import sqlite3


class ActionHelloWorld(Action):
    def name(self) -> Text:
        return "action_hello_world"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(text="Hello World!")

        return []


class ActionCheckOpeningHoursGetter(Action):
    def name(self) -> Text:
        return "action_check_opening_hours"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(text="Checking opening hours...")
        parsed = dict()
        with open('.\opening_hours.json', 'r') as f:
            items = json.load(f)['items']
            response_text = ""
            for (dayname, dayinfo) in items.items():
                openhour = dayinfo['open']
                closehour = dayinfo['close']
                if openhour == closehour:
                    parsed.update({dayname: "closed"})
                    response_text += f"Day: {dayname}. Closed. \n"
                elif openhour > closehour:
                    raise Exception(f"invalid opening hours - day: {dayname}")
                else:
                    parsed.update({dayname: f"open from {openhour} to {closehour}."})
                    response_text += f"Day: {dayname}. Opened from: {openhour} to {closehour}. \n"
        dispatcher.utter_message(text=response_text)
        return []


def try_strptime(s):
    fmts = ['%I %p', '%I:%M %p', "%H:%M", "%H %M", "%H.%M"]
    for fmt in fmts:
        try:
            return datetime.strptime(s, fmt)
        except:
            continue
    return datetime.now()


class ActionOpeningHoursChecker(Action):
    def name(self) -> Text:
        return "action_opening_hours"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        request_hour = next(tracker.get_latest_entity_values("request_time"), None)
        request_day = next(tracker.get_latest_entity_values("request_day"), None)
        if request_hour is None:
            dispatcher.utter_message(
                text="I did not understand the information regarding the time you want to go to the restaurant. "
                     "Can you please repeat it?")
            return []
        request_hour = try_strptime(request_hour).time()
        if request_day is None or request_day.lower() not in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday',
                                                              'saturday', 'sunday']:
            today = datetime.now()
            request_day = today.strftime("%A")
            dispatcher.utter_message(text=f"Here's the timetable info for today...")
        else:
            dispatcher.utter_message(text=f"Here's your timetable info for {request_day}...")
        with open('.\opening_hours.json', 'r') as f:
            items = json.load(f)['items']
            opening_dict = items[request_day]
            opening_hour = datetime.strptime(str(opening_dict['open']), "%H").time()
            closing_hour = datetime.strptime(str(opening_dict['close']), "%H").time()
        if opening_hour and closing_hour and opening_hour != closing_hour and opening_hour <= request_hour < closing_hour:
            dispatcher.utter_message(text="The restaurant is open at that time")
        elif not opening_hour or not closing_hour:
            dispatcher.utter_message(text="Sorry, no info about restaurant's timetable on this day")
        elif opening_hour == closing_hour:
            dispatcher.utter_message(text="The restaurant is closed on this day")
        elif opening_hour > request_hour:
            dispatcher.utter_message(text="The restaurant is still closed on this day")
        elif closing_hour <= request_hour:
            dispatcher.utter_message(text="The restaurant is already closed on this day")
        return []


class ActionMenuGetter(Action):
    def name(self) -> Text:
        return "action_menu"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        parsed = dict()
        response_text = ""
        with open('.\menu.json', 'r') as f:
            items = json.load(f)['items']
            for menuitem in items:
                position_name = menuitem['name']
                price = menuitem['price']
                preparation_time = menuitem['preparation_time']
                text = f"Name: {position_name}. Time of preparation: {preparation_time}. Price: {price}"
                parsed.update({position_name: text})
                response_text += text
        dispatcher.utter_message(text=response_text)
        #return [SlotSet("menu", parsed)]
        return []


class ActionOrderPlacer(Action):
    # def __init__(self):
    #     self.nlp_engine = None

    def name(self) -> Text:
        return "action_order"

    def get_best_for_semantic_score(self, dish: str, list_to_score: list) -> tuple[float, str]:
        if not hasattr(self, 'nlp_engine') or self.nlp_engine is None:
            self.nlp_engine = spacy.load("en_core_web_lg")
        return max([(self.nlp_engine(dish).similarity(self.nlp_engine(other)), other) for other in list_to_score],
                   key=lambda t: t[0])

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        request_dish = next(tracker.get_latest_entity_values("request_dish"), None)
        if request_dish is None:
            dispatcher.utter_message(text="Nie zrozumiałem informacji dotyczącej wybranej pozycji zamówienia. "
                                          "Proszę, potwórz.")
        num_of_orders = next(tracker.get_latest_entity_values("num_of_orders"), None)
        if num_of_orders is None:
            num_of_orders = 1
        additional_stuff = next(tracker.get_latest_entity_values("additional_stuff"), None)
        if isinstance(additional_stuff, list):
            additional_stuff_asstring = ', '.join(s for s in additional_stuff)
        else:
            additional_stuff_asstring = additional_stuff
        list_of_menu_positions = []
        confidence, full_item, order_name = self.get_best_item(list_of_menu_positions, request_dish)
        threshold = 0.5
        if confidence < threshold:
            dispatcher.utter_message(text="Nie zrozumiałem informacji dotyczącej wybranej pozycji zamówienia. "
                                          "Proszę, potwórz.")
        else:
            preparation_time = full_item[2]
            single_item_price = full_item[1]
            dispatcher.utter_message(text=f"Składam zamówienie na {order_name}. Liczba porcji: {num_of_orders}. "
                                          f"Dodatkowe życzenia do zamówienia: {additional_stuff_asstring}"
                                          f"Wartość zamówienia: {int(single_item_price) * int(num_of_orders)}. "
                                          f"Czas oczekiwania powinien wynieść nie więcej niż: {preparation_time}")
            ActionOrderPlacer.save_order_to_db(num_of_orders, order_name, additional_stuff_asstring)
        return []

    def get_best_item(self, list_of_menu_positions, request_word):
        with open('.\menu.json', 'r') as f:
            items = json.load(f)['items']
            for menuitem in items:
                list_of_menu_positions.append((menuitem['name'], menuitem['price'], menuitem['preparation_time']))
        best_fit = self.get_best_for_semantic_score(request_word, [item[0] for item in list_of_menu_positions])
        confidence = best_fit[0]
        order_name = best_fit[1]
        full_item = next(item for item in list_of_menu_positions if item[0] == order_name)
        return confidence, full_item, order_name

    @staticmethod
    def get_num_of_fk(dish_name):
        conn = sqlite3.connect('orders.db')
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM dishes WHERE dish_name = (?)",
                       (dish_name,))
        return cursor.fetchone()

    @staticmethod
    def save_order_to_db(num_of_orders, order_name, additional_stuff):
        id = ActionOrderPlacer.get_num_of_fk(order_name)[0]
        conn = sqlite3.connect('orders.db')
        cursor = conn.cursor()
        cursor.execute('INSERT INTO orders (order_id, num_of_orders, additional_stuff) VALUES (?,?,?)',
                       (id, num_of_orders, additional_stuff))

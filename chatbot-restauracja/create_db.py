if __name__ == '__main__':
    import sqlite3

    conn = sqlite3.connect('orders.db')
    cursor = conn.cursor()

    cursor.execute('''  
    CREATE TABLE IF NOT EXISTS dishes (
    id INTEGER PRIMARY KEY,
    dish_name VARCHAR(255)
    );
    
    ''')

    cursor.execute("INSERT INTO dishes VALUES (null, 'Lasagne');")
    cursor.execute("INSERT INTO dishes VALUES (null, 'Pizza');")
    cursor.execute("INSERT INTO dishes VALUES (null, 'Hot-dog');")
    cursor.execute("INSERT INTO dishes VALUES (null, 'Burger');")
    cursor.execute("INSERT INTO dishes VALUES (null, 'Spaghetti Carbonara');")
    cursor.execute("INSERT INTO dishes VALUES (null, 'Tiramisu');")
    cursor.execute('''CREATE TABLE IF NOT EXISTS orders (  
        id INTEGER PRIMARY KEY,  
        order_id INTEGER, 
        num_of_orders INTEGER,  
        additional_stuff TEXT,  
        CONSTRAINT fk_dishes FOREIGN KEY (order_id) REFERENCES dishes(id)  
    );
    ''')
    conn.commit()

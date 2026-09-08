import csv
import random
from datetime import date, timedelta

random.seed(42)

OUT = "/home/claude/ba_sql_project"

# ---------- Reference data ----------
first_names = ["James","Mary","John","Patricia","Robert","Jennifer","Michael","Linda","William","Elizabeth",
               "David","Barbara","Richard","Susan","Joseph","Jessica","Thomas","Sarah","Charles","Karen",
               "Christopher","Nancy","Daniel","Lisa","Matthew","Betty","Anthony","Margaret","Mark","Sandra",
               "Donald","Ashley","Steven","Kimberly","Paul","Emily","Andrew","Donna","Joshua","Michelle",
               "Kenneth","Dorothy","Kevin","Carol","Brian","Amanda","George","Melissa","Timothy","Deborah"]
last_names = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
              "Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin",
              "Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson",
              "Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores"]

cities_by_region = {
    "North":  [("New York","NY"), ("Boston","MA"), ("Chicago","IL")],
    "South":  [("Houston","TX"), ("Miami","FL"), ("Atlanta","GA")],
    "West":   [("Los Angeles","CA"), ("San Francisco","CA"), ("Seattle","WA")],
    "East":   [("Philadelphia","PA"), ("Washington","DC"), ("Baltimore","MD")],
}
regions = list(cities_by_region.keys())
segments = ["Consumer", "Corporate", "Home Office"]

categories = {
    "Electronics": ["Headphones","Bluetooth Speaker","Webcam","Laptop Stand","USB-C Hub","Monitor","Keyboard","Mouse"],
    "Office Supplies": ["Notebook","Stapler","Desk Organizer","Sticky Notes","Pen Set","Printer Paper","Whiteboard"],
    "Furniture": ["Office Chair","Standing Desk","Bookshelf","Filing Cabinet","Desk Lamp"],
    "Home & Kitchen": ["Coffee Maker","Blender","Air Fryer","Cookware Set","Toaster"],
    "Sports": ["Yoga Mat","Dumbbell Set","Water Bottle","Resistance Bands","Running Shoes"],
}

def random_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

# ---------- Employees (Sales Reps) ----------
employees = []
for i in range(1, 16):
    region = regions[(i - 1) % len(regions)]
    hire_date = random_date(date(2019, 1, 1), date(2023, 6, 1))
    employees.append({
        "employee_id": i,
        "first_name": random.choice(first_names),
        "last_name": random.choice(last_names),
        "region": region,
        "hire_date": hire_date.isoformat(),
    })

# ---------- Customers ----------
customers = []
N_CUSTOMERS = 500
for i in range(1, N_CUSTOMERS + 1):
    region = random.choice(regions)
    city, state = random.choice(cities_by_region[region])
    fn, ln = random.choice(first_names), random.choice(last_names)
    signup = random_date(date(2021, 1, 1), date(2024, 12, 31))
    customers.append({
        "customer_id": i,
        "first_name": fn,
        "last_name": ln,
        "email": f"{fn.lower()}.{ln.lower()}{i}@example.com",
        "city": city,
        "state": state,
        "region": region,
        "segment": random.choice(segments),
        "signup_date": signup.isoformat(),
    })

# ---------- Products ----------
products = []
pid = 1
for cat, items in categories.items():
    for name in items:
        cost = round(random.uniform(5, 150), 2)
        margin = random.uniform(1.3, 2.2)
        products.append({
            "product_id": pid,
            "product_name": name,
            "category": cat,
            "cost_price": cost,
            "unit_price": round(cost * margin, 2),
        })
        pid += 1

# ---------- Orders + Order Items ----------
orders = []
order_items = []
order_id = 1
item_id = 1
start_date = date(2023, 1, 1)
end_date = date(2024, 12, 31)
statuses = ["Completed", "Completed", "Completed", "Completed", "Cancelled", "Returned"]

N_ORDERS = 3000
for _ in range(N_ORDERS):
    cust = random.choice(customers)
    region = cust["region"]
    region_employees = [e for e in employees if e["region"] == region]
    emp = random.choice(region_employees) if region_employees else random.choice(employees)
    order_date = random_date(start_date, end_date)
    status = random.choice(statuses)
    ship_date = order_date + timedelta(days=random.randint(1, 7)) if status != "Cancelled" else None

    orders.append({
        "order_id": order_id,
        "customer_id": cust["customer_id"],
        "employee_id": emp["employee_id"],
        "order_date": order_date.isoformat(),
        "ship_date": ship_date.isoformat() if ship_date else "",
        "order_status": status,
        "region": region,
    })

    n_items = random.randint(1, 4)
    chosen_products = random.sample(products, n_items)
    for p in chosen_products:
        qty = random.randint(1, 5)
        discount = random.choice([0, 0, 0, 0.05, 0.1, 0.15])
        order_items.append({
            "order_item_id": item_id,
            "order_id": order_id,
            "product_id": p["product_id"],
            "quantity": qty,
            "unit_price": p["unit_price"],
            "discount": discount,
        })
        item_id += 1

    order_id += 1

# ---------- Write CSVs ----------
def write_csv(filename, rows, fieldnames):
    with open(f"{OUT}/{filename}", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

write_csv("customers.csv", customers, ["customer_id","first_name","last_name","email","city","state","region","segment","signup_date"])
write_csv("products.csv", products, ["product_id","product_name","category","cost_price","unit_price"])
write_csv("employees.csv", employees, ["employee_id","first_name","last_name","region","hire_date"])
write_csv("orders.csv", orders, ["order_id","customer_id","employee_id","order_date","ship_date","order_status","region"])
write_csv("order_items.csv", order_items, ["order_item_id","order_id","product_id","quantity","unit_price","discount"])

print("Customers:", len(customers))
print("Products:", len(products))
print("Employees:", len(employees))
print("Orders:", len(orders))
print("Order items:", len(order_items))

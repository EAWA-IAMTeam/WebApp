import logging
from flask import Flask, jsonify, request, abort
from flask_cors import CORS
from argparse import ArgumentParser
import psycopg2
from psycopg2 import OperationalError

# Configure logging
logging.basicConfig(level=logging.DEBUG)

app = Flask(_name_)
CORS(app)

# Function to retrieve products by store_id
def get_products(store_id):
    try:
        # Connect to your PostgreSQL database
        with psycopg2.connect(
            host="192.168.0.235",  # Change according to database IP address
            port="5432",
            database="postgres",  # Replace with your database name
            user="postgres",
            password="postgres"
        ) as connection:
            with connection.cursor() as cursor:
                # SQL query to join StockItem and StoreProduct based on stock_item_id
                query = """
                    SELECT 
                        si.id AS stock_item_id, 
                        si.ref_price, 
                        si.ref_cost, 
                        si.quantity, 
                        sp.id AS store_product_id, 
                        sp.price, 
                        sp.discounted_price, 
                        sp.sku, 
                        sp.currency, 
                        sp.status 
                    FROM storeproduct sp
                    JOIN stockitem si ON sp.stock_item_id = si.id
                    WHERE sp.store_id = %s;
                """    
                cursor.execute(query, (store_id,))
                
                # Fetch all results
                results = cursor.fetchall()

                # Dictionary to store merged data by stock_item_id
                merged_data = {}

                for row in results:
                    stock_item_id, ref_price, ref_cost, quantity, store_product_id, price, discounted_price, sku, currency, status = row
                    
                    if stock_item_id not in merged_data:
                        merged_data[stock_item_id] = {
                            "stock_item_id": stock_item_id,
                            "ref_price": ref_price,
                            "ref_cost": ref_cost,
                            "quantity": quantity,
                            "store_products": []
                        }

                    merged_data[stock_item_id]["store_products"].append({
                        "id": store_product_id,
                        "price": price,
                        "discounted_price": discounted_price,
                        "sku": sku,
                        "currency": currency,
                        "status": status
                    })

                return list(merged_data.values())  # Convert dictionary values to list

    except OperationalError as e:
        logging.error(f"Error connecting to PostgreSQL: {e}")
        return None

def check_duplicate_sku(cursor, stock_item_id, sku):
    """ Check if the SKU already exists for the same stock_item_id """
    cursor.execute(
        "SELECT COUNT(*) FROM storeproduct WHERE stock_item_id = %s AND sku = %s;",
        (stock_item_id, sku)
    )
    count = cursor.fetchone()[0]
    return count > 0  # Returns True if duplicate exists

def insert_product(store_id, products):
    try:
        # Connect to your postgres DB
        with psycopg2.connect(
            host="192.168.0.235",  # Change according to database IP address
            port="5432",
            database="postgres",  # Replace with your database name
            user="postgres",
            password="postgres"
        ) as connection:
            with connection.cursor() as cursor:
                query = """
                    INSERT INTO storeproduct (store_id, stock_item_id, price, discounted_price, sku, currency, status)
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """
                
                # List to store valid products
                valid_products = []
                duplicate_skus = []

                for product in products:
                    stock_item_id = product['stock_item_id']
                    sku = product['sku']

                    # Check for duplicate SKU
                    if check_duplicate_sku(cursor, stock_item_id, sku):
                        duplicate_skus.append(sku)
                    else:
                        valid_products.append((
                            store_id,
                            stock_item_id,
                            product['price'],
                            product['discounted_price'],
                            sku,
                            product['currency'],
                            product['status']
                        ))

                # If there are valid products, insert them
                if valid_products:
                    cursor.executemany(query, valid_products)
                    connection.commit()
                    logging.info(f"{len(valid_products)} products inserted successfully.")
                
                return {"inserted": len(valid_products), "duplicates": duplicate_skus}

    except psycopg2.OperationalError as e:
        logging.error(f"Error connecting to PostgreSQL: {e}")
    except Exception as e:
        logging.error(f"Error: {e}")
    return {"inserted": 0, "duplicates": []}

@app.route('/api/products', methods=['POST'])
def api_insert_products():
    try:
        data = request.get_json()
        store_id = data.get('store_id')
        products = data.get('products')

        if not store_id or not products or not isinstance(products, list):
            return jsonify({'error': 'Missing required fields or invalid products format'}), 400

        for product in products:
            if not all(product.get(key) is not None for key in ['stock_item_id', 'price', 'discounted_price', 'sku', 'currency', 'status']):
                return jsonify({'error': 'One or more products have missing fields'}), 400

        result = insert_product(store_id, products)

        if result["inserted"] > 0:
            return jsonify({
                'message': f'{result["inserted"]} products inserted successfully',
                'duplicates': result["duplicates"]
            }), 201
        else:
            return jsonify({
                'error': 'Failed to insert products',
                'duplicates': result["duplicates"]
            }), 409 if result["duplicates"] else 500  # 409 Conflict if duplicates exist

    except Exception as e:
        logging.error(f"Error in /api/products: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/products/<int:store_id>', methods=['GET'])
def api_get_products(store_id):
    if not store_id:
        return jsonify({"error": "Store ID is required"}), 400

    products = get_products(store_id)
    if products is None:
        return jsonify({"error": "Unable to fetch products or store not found"}), 500

    return jsonify(products)

if _name_ == '_main_':
    parser = ArgumentParser()
    parser.add_argument('-p', '--port', default=5000, type=int, help='port to listen on')
    args = parser.parse_args()
    port = args.port
    app.run(debug=True, host='0.0.0.0', port=port)
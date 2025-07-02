from flask import Flask, request, jsonify, abort
import json
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

# Load and preprocess data
try:
    with open('products.json', 'r') as f:
        products = json.load(f)
    
    # Create DataFrame and process like notebook
    df = pd.DataFrame(products)
    df['combined_features'] = df['name'] + ' ' + df['ingredients'].apply(' '.join)
    df['combined_features'] = df['combined_features'].str.lower()
    df['allergens'] = df['allergens'].apply(lambda x: [a.lower().strip() for a in x])
    
    # Train TF-IDF model
    vectorizer = TfidfVectorizer(
        stop_words='english',
        ngram_range=(1, 2),
        min_df=2
    )
    tfidf_matrix = vectorizer.fit_transform(df['combined_features'])
    
except FileNotFoundError:
    print("Error: products.json not found. Using empty list.")
    df = pd.DataFrame()
    vectorizer = None
    tfidf_matrix = None

@app.route('/recommend', methods=['POST'])
def recommend():
    # Maintain original input format
    data = request.get_json()
    if not data:
        abort(400, "Request body must be JSON.")
    
    scanned_text = data.get("scanned_text", "").strip()
    user_allergies = [a.lower().strip() for a in data.get("user_allergies", [])]

    if not scanned_text:
        abort(400, "Field 'scanned_text' is required.")

    # Filter safe products (original logic)
    safe_products = []
    for product in products:
        allergens = [a.lower().strip() for a in product.get("allergens", [])]
        if not any(allergy in allergens for allergy in user_allergies):
            safe_products.append(product)

    if not safe_products:
        return jsonify({"error": "No safe matches found."})

    # Convert to DataFrame for TF-IDF processing
    safe_df = pd.DataFrame(safe_products)
    
    # Vectorize input text (from notebook)
    input_vector = vectorizer.transform([scanned_text.lower()])
    
    # Get indices of safe products
    safe_indices = df[df['barcode'].isin(safe_df['barcode'])].index
    
    # Calculate similarities
    similarities = cosine_similarity(input_vector, tfidf_matrix[safe_indices])[0]
    
    # Combine scores with products
    scored_products = sorted(
        zip(safe_products, similarities),
        key=lambda x: x[1],
        reverse=True
    )

    # Maintain original output format
    best_match = scored_products[0][0] if scored_products else None
    return jsonify(best_match) if best_match else jsonify({"error": "No safe matches found."})

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
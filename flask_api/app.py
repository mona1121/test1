import firebase_admin
from firebase_admin import credentials, firestore
import csv
import pandas as pd
from flask import Flask, request, jsonify
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np

# Initialize the Flask app
app = Flask(__name__)

# Firebase configuration
cred = credentials.Certificate('path/to/your/users-authentiation-firebase-adminsdk.json')
firebase_admin.initialize_app(cred)

# Access Firestore
db = firestore.client()
collection_ref = db.collection('products')
docs = collection_ref.stream()

# Create a list to store the data
data_list = []
for doc in docs:
    data_list.append(doc.to_dict())

# Write the data to a CSV file
csv_file = 'firebase_data.csv'
fieldnames = data_list[0].keys() if data_list else []

with open(csv_file, mode='w', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(data_list)

# Load the dataset
df = pd.read_csv(csv_file, usecols=['code', 'product', 'description', 'company', 'category', 'type'])

# Encode categorical features
type_encoder = LabelEncoder()
company_encoder = LabelEncoder()
category_encoder = LabelEncoder()

df['type_encoded'] = type_encoder.fit_transform(df['type'])
df['company_encoded'] = company_encoder.fit_transform(df['company'])
df['category_encoded'] = category_encoder.fit_transform(df['category'])

# Vectorize descriptions
tfidf_vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words='english')
description_vectors = tfidf_vectorizer.fit_transform(df['description'])

# Define feature weights
df['type_weighted'] = df['type_encoded'] * 8
df['category_weighted'] = df['category_encoded'] * 4
df['company_weighted'] = df['company_encoded'] * 2

# Combine feature vectors
weighted_features = df[['type_weighted', 'company_weighted', 'category_weighted']].values
combined_features = np.hstack((weighted_features, description_vectors.toarray()))
similarity_matrix = cosine_similarity(combined_features)

def get_recommendations(code, similarity_matrix, df, top_n=3):
    idx = df[df['code'] == code].index[0]
    similarity_scores = list(enumerate(similarity_matrix[idx]))
    similarity_scores = sorted(similarity_scores, key=lambda x: x[1], reverse=True)
    similarity_scores = [score for score in similarity_scores if score[0] != idx]
    top_recommendations = similarity_scores[:top_n]
    recommended_products = df.iloc[[rec[0] for rec in top_recommendations]]
    return recommended_products[['code', 'product', 'type', 'company', 'category']].to_dict(orient='records')

@app.route('/recommendations', methods=['GET'])
def recommend():
    code = request.args.get('code', type=int)
    if code is None:
        return jsonify({'error': 'Product code is required'}), 400

    recommendations = get_recommendations(code, similarity_matrix, df)
    return jsonify(recommendations)

if __name__ == '__main__':
    app.run(debug=True)
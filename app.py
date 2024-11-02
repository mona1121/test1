import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics import jaccard_score
from typing import List

# Initialize FastAPI application
app = FastAPI()

# Firebase Initialization
firebase_credentials_json = os.getenv('FIREBASE_CREDENTIALS')
if firebase_credentials_json:
    cred = credentials.Certificate(json.loads(firebase_credentials_json))
    firebase_admin.initialize_app(cred)
else:
    raise ValueError("Firebase credentials not found in environment variables.")

db = firestore.client()

# Load data from Firestore and prepare DataFrame
def load_data():
    collection_ref = db.collection('products')
    docs = collection_ref.stream()
    data_list = [doc.to_dict() for doc in docs]
    return pd.DataFrame(data_list)

# Prepare the DataFrame and compute Jaccard similarity
def prepare_similarity_matrix(df):
    categorical_columns = ['type', 'company', 'category']
    mlb = MultiLabelBinarizer()

    # Transform categorical data into a one-hot encoded format
    encoded_features = mlb.fit_transform(df[categorical_columns].values)
    encoded_df = pd.DataFrame(encoded_features, columns=mlb.classes_)
    combined_df = pd.concat([df[['code']], encoded_df], axis=1)

    return jaccard_similarity_matrix(combined_df)

def jaccard_similarity_matrix(encoded_df):
    """Compute the Jaccard similarity matrix for the encoded features."""
    num_products = encoded_df.shape[0]
    similarity_matrix = pd.DataFrame(index=encoded_df['code'], columns=encoded_df['code'])

    for i in range(num_products):
        for j in range(num_products):
            if i != j:
                similarity_matrix.iloc[i, j] = jaccard_score(
                    encoded_df.iloc[i, 1:],  # Skip the 'code' column
                    encoded_df.iloc[j, 1:],
                    average='binary'
                )
            else:
                similarity_matrix.iloc[i, j] = 1.0  # Similarity with self is 1

    return similarity_matrix

# Get recommendations based on Jaccard similarity
def get_recommendations(code, similarity_matrix, df, top_n=3):
    """Get top N recommendations based on Jaccard similarity."""
    try:
        idx = df[df['code'] == code].index[0]
        similarity_scores = similarity_matrix.iloc[idx].sort_values(ascending=False)
        top_recommendations = similarity_scores.index[1:top_n + 1]
        recommended_products = df[df['code'].isin(top_recommendations)]
        return recommended_products[['code', 'product', 'type', 'company', 'category']]
    except IndexError:
        return pd.DataFrame(columns=['code', 'product', 'type', 'company', 'category'])

# API endpoint to get recommendations
@app.get('/recommendations/{code}')
async def recommend(code: int):
    df = load_data()
    similarity_matrix = prepare_similarity_matrix(df)
    recommendations = get_recommendations(code, similarity_matrix, df)
    if recommendations.empty:
        raise HTTPException(status_code=404, detail="No recommendations found")
    return recommendations.to_dict(orient='records')

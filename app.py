import os
import json
import logging
import requests
import firebase_admin
from firebase_admin import credentials, firestore, initialize_app
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics import jaccard_score
from typing import List
from aiocache import cached

# Set up logging
logging.basicConfig(level=logging.INFO)

# Initialize FastAPI application
app = FastAPI()

# Read JSON content from the FIREBASE_CREDENTIALS environment variable
firebase_credentials_json = os.getenv("FIREBASE_CREDENTIALS")

if firebase_credentials_json:
    # Write the JSON content to a temporary file
    with open("/tmp/firebase_credentials.json", "w") as f:
        f.write(firebase_credentials_json)

    # Initialize Firebase using the file path
    cred = credentials.Certificate("/tmp/firebase_credentials.json")
    initialize_app(cred)
else:
    raise ValueError("Firebase credentials JSON not found in environment variables.")

# Initialize Firestore client
db = firestore.client()

# Jaccard Similarity Computation
def jaccard_similarity_matrix(encoded_df):
    """Compute the Jaccard similarity matrix for the encoded features."""
    num_products = encoded_df.shape[0]
    similarity_matrix = pd.DataFrame(index=encoded_df['code'], columns=encoded_df['code'])

    for i in range(num_products):
        for j in range(num_products):
            if i != j:
                y_true = encoded_df.iloc[i, 1:].astype(int).fillna(0).replace([np.inf, -np.inf], 0)
                y_pred = encoded_df.iloc[j, 1:].astype(int).fillna(0).replace([np.inf, -np.inf], 0)
                similarity_matrix.iloc[i, j] = jaccard_score(
                    y_true,
                    y_pred,
                    average='binary'
                )
            else:
                similarity_matrix.iloc[i, j] = 1.0  # Similarity with self is 1

    return similarity_matrix

# Get Recommendations
def get_recommendations(code, similarity_matrix, df, top_n=3):
    """Get top N recommendations based on Jaccard similarity."""
    try:
        idx = df[df['code'] == code].index[0]
        similarity_scores = similarity_matrix.iloc[idx].sort_values(ascending=False)
        top_recommendations = similarity_scores.index[1:top_n + 1]
        recommended_products = df[df['code'].isin(top_recommendations)]
        return recommended_products[['code', 'product', 'company', 'image', 'price']]
    except IndexError:
        return pd.DataFrame(columns=['code', 'product', 'company', 'image', 'price'])

# Recommendation Response Model
class Recommendation(BaseModel):
    code: str
    product: str
    company: str
    image: str
    price: float

# Recommendation Endpoint
@app.get('/recommendations/{code}', response_model=List[Recommendation])
@cached(ttl=300)
async def recommend(code: str):
    logging.info(f"Received request for recommendations with code: {code}")
    collection_ref = db.collection('products')
    docs = collection_ref.stream()
    data_list = [doc.to_dict() for doc in docs]
    data = pd.DataFrame(data_list, columns=['code', 'product', 'description', 'company', 'category', 'type', 'image', 'price'])
    
    categorical_columns = ['type', 'company', 'category']
    mlb = MultiLabelBinarizer()
    encoded_features = mlb.fit_transform(data[categorical_columns].values)
    encoded_df = pd.DataFrame(encoded_features, columns=mlb.classes_)
    combined_df = pd.concat([data[['code']], encoded_df], axis=1)
    
    similarity_matrix = jaccard_similarity_matrix(combined_df)
    recommendations = get_recommendations(code, similarity_matrix, data)

    if recommendations.empty:
        raise HTTPException(status_code=404, detail="No recommendations found")
    return recommendations.to_dict(orient='records')

# Payment Request Model
class PaymentRequest(BaseModel):
    amount: float
    currency: str
    description: str
    customer: dict
    redirect_url: str

# Tap Payment Endpoint
@app.post("/create_payment/")
async def create_payment(payment: PaymentRequest):
    url = "https://api.tap.company/v2/charges/"
    headers = {
        "accept": "application/json",
        "content-type": "application/json",
        "Authorization": "Bearer sk_test_AiEpUqHlcPgj28msDFIvRK7G"
    }
    payload = {
        "amount": payment.amount,
        "currency": payment.currency,
        "threeDSecure": True,
        "description": payment.description,
        "customer": payment.customer,
        "source": {"id": "src_all"},
        "redirect": {"url": payment.redirect_url}
    }

    try:
        logging.info("Sending payment request to Tap API")
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTP error occurred: {e}")
        raise HTTPException(status_code=response.status_code, detail=response.json())
    except Exception as e:
        logging.error(f"Error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

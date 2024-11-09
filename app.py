import os
import json
import logging
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics import pairwise_distances
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import jaccard_score
from typing import List
from aiocache import cached

# Set up logging
logging.basicConfig(level=logging.INFO)

# Initialize FastAPI application
app = FastAPI()

# Firebase Initialization
# firebase_credentials_json = os.getenv('FIREBASE_CREDENTIALS')
# if firebase_credentials_json:
#     cred = credentials.Certificate(json.loads(firebase_credentials_json))
#     firebase_admin.initialize_app(cred)
# else:
#     raise ValueError("Firebase credentials not found in environment variables.")

firebase_credentials_path = os.getenv("FIREBASE_CREDENTIALS")

if firebase_credentials_path:
    cred = credentials.Certificate(firebase_credentials_path)
else:
    raise ValueError("Firebase credentials path not found in environment variables.")

# Initialize Firestore client
db = firestore.client()

def jaccard_similarity_matrix(encoded_df):
    """Compute the Jaccard similarity matrix for the encoded features."""
    num_products = encoded_df.shape[0]
    similarity_matrix = pd.DataFrame(index=encoded_df['code'], columns=encoded_df['code'])

    for i in range(num_products):
        for j in range(num_products):
            if i != j:
                # Convert values to integers to ensure they are binary (0 or 1)
                # and replace any NaN or infinite values with 0
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

def get_recommendations(code, similarity_matrix, df, top_n=3):
    """Get top N recommendations based on Jaccard similarity."""
    try:
        # Get the index of the product ID using the 'code' column
        idx = df[df['code'] == code].index[0]

        # Get similarity scores for this product
        similarity_scores = similarity_matrix.iloc[idx]

        # Sort by similarity score, excluding the input product itself
        similarity_scores = similarity_scores.sort_values(ascending=False)
        top_recommendations = similarity_scores.index[1:top_n + 1]

        # Fetch product details of recommendations
        recommended_products = df[df['code'].isin(top_recommendations)]
        return recommended_products[['code', 'product', 'company', 'image', 'price']]
    except IndexError:
        return pd.DataFrame(columns=['code', 'product', 'company','image', 'price'])

# Define a Pydantic model for the response
class Recommendation(BaseModel):
    code: str
    product: str
    company: str
    image: str
    price: float

# API endpoint to get recommendations
@app.get('/recommendations/{code}', response_model=List[Recommendation])
@cached(ttl=300)  # Cache for 5 minutes (300 seconds)
async def recommend(code: str):
    logging.info(f"Received request for recommendations with code: {code}")
#    try:
    collection_ref = db.collection('products')
    docs = collection_ref.stream()

    # Create a list to store the data
    data_list = []
    for doc in docs:
        data_list.append(doc.to_dict())

    data = pd.DataFrame(data_list, columns=['code', 'product', 'description', 'company', 'category', 'type','image', 'price'])

    # First, prepare the categorical features
    categorical_columns = ['type', 'company', 'category']
    mlb = MultiLabelBinarizer()

    # Transform categorical data into a one-hot encoded format
    encoded_features = mlb.fit_transform(data[categorical_columns].values)

    # Create a DataFrame for the encoded features
    encoded_df = pd.DataFrame(encoded_features, columns=mlb.classes_)

    # Combine the encoded features with the original DataFrame
    combined_df = pd.concat([data[['code']], encoded_df], axis=1)

    # Calculate the Jaccard similarity matrix
    similarity_matrix = jaccard_similarity_matrix(combined_df)

    recommendations = get_recommendations(code, similarity_matrix, data)

    if recommendations.empty:
        raise HTTPException(status_code=404, detail="No recommendations found")
    return recommendations.to_dict(orient='records')
#     except Exception as e:
#         logging.error(f"Error occurred: {str(e)}")
#         raise HTTPException(status_code=500, detail=str(e))




# Define the PaymentRequest Pydantic model
class PaymentRequest(BaseModel):
    amount: float
    currency: str
    description: str
    customer: dict
    redirect_url: str

    # Add Tap Payment API endpoint
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
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()  # Raise exception if the request fails
        return response.json()
    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTP error occurred: {e}")
        raise HTTPException(status_code=response.status_code, detail=response.json())
    except Exception as e:
        logging.error(f"Error occurred: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")
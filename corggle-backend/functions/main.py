# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import firestore_fn, https_fn

# The Firebase Admin SDK to access Cloud Firestore.
from firebase_admin import initialize_app, firestore
import google.generativeai as genai
import os

from model import Message

app = initialize_app()

db = firestore.client()

# Gemini API キーの取得
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
genai.configure(api_key=GEMINI_API_KEY)

# Gemini モデルの初期化
model = genai.GenerativeModel('gemini-pro')

def generate_gemini_response(prompt):
  """Gemini にプロンプトを投げてレスポンスを生成する"""
  try:
    response = model.generate_content(prompt)
    return response.text
  except Exception as e:
    print(f"Error generating Gemini response: {e}")
    return None

def on_chat_message_created(change, context):

  message_data = change.new_value.to_dict()
  message_text = message_data.get('text')
    
  if not message_text:
    print("No text found in message.")
    return

  # Gemini に投げるプロンプトを作成
  prompt = f"チャットメッセージ: {message_text}\nこのメッセージについて、短く要約してください。"

  # Gemini にプロンプトを投げてレスポンスを取得
  gemini_response = generate_gemini_response(prompt)

  if gemini_response:
    # Firestore に Gemini のレスポンスを保存
    chat_id = context.params['chatId']
    message_id = context.params['messageId']
    response_ref = db.collection('chats').document(chat_id).collection('messages').document(message_id)
    response_ref.update({'geminiResponse': gemini_response})
    print(f"Gemini response saved to Firestore: {gemini_response}")
  else:
    print("Gemini response was empty or an error occurred.")

# Cloud Functions のトリガー設定
from firebase_functions import firestore_fn

@firestore_fn.on_document_created(document="chats/{chatId}")
def onchatcreated(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
  """Firestore のチャットが作成されたときに実行される関数"""
  chat_id = event.params['chatId']
  chat_data = event.data
  print(f"onchatcreated: {chat_data} in chat {chat_id}")

@firestore_fn.on_document_created(document="chats/{chatId}/messages/{messageId}")
def onchatmessagecreated(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
  """Firestore のチャットメッセージが作成されたときに実行される関数"""
  chat_id = event.params['chatId']
  message_id = event.params['messageId']
  message = Message.from_snapshot(event.data)
  print(f"onchatmessagecreated: {message.text} in chat {chat_id} with message {message_id}")
  # on_chat_message_created(event, event.params)
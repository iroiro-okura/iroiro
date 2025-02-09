from firebase_admin import initialize_app, credentials
from lib import initialize_db, initialize_gemini

initialize_app(credential=credentials.ApplicationDefault())

def setup():
  initialize_db()
  initialize_gemini()

from application import start_chat, reply_to_message
from model import SentMessage, Sender, Status, Chat

# Cloud Functions のトリガー設定
from firebase_functions import firestore_fn, options

@firestore_fn.on_document_created(document="chats/{chatId}", region="asia-northeast1", timeout_sec=300, memory=options.MemoryOption.GB_2)
def onchatcreated(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
  """Firestore のチャットが作成されたときに実行される関数"""
  print(f"onchatcreated: {event}")
  chat_id = event.params['chatId']
  chat = Chat.from_snapshot(event.data)
  setup()
  start_chat(chat_id, chat)
  
  print(f"onchatcreated: id: {chat_id}, data: {chat}")

@firestore_fn.on_document_created(document="chats/{chatId}/messages/{messageId}", region="asia-northeast1", timeout_sec=300, memory=options.MemoryOption.GB_4)
def onmessagecreated(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
  """Firestore のチャットメッセージが作成されたときに実行される関数"""
  print(f"onchatmessagecreated: {event}")
  chat_id = event.params['chatId']
  message_id = event.params['messageId']
  message = SentMessage.from_snapshot(event.data)
  if (message.sender == Sender.MODEL or message.status != Status.COMPLETED):
    print(f"onchatmessagecreated: skip")
    return
  setup()
  reply_to_message(chat_id, message_id, message)
  print(f"onchatmessagecreated: {message.text} in chat {chat_id} with message {message_id}")

if __name__ == '__main__':
  print("main.py: __main__")
  # ローカルでのテスト用
  chat_id = "qt29uSeRTqhv3hMniFEb"

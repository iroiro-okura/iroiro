from firebase_admin import firestore

from model import Message, SentMessage, Status, User

db = firestore.client()

def get_user(uid: str) -> User:
  """Firestore からユーザー情報を取得する"""
  user_ref = db.collection('users').document(uid).get()
  return User.from_snapshot(user_ref)

def get_messages(chat_id: str) -> list[Message]:
  """Firestore からチャットのメッセージを取得する"""
  messages = []
  messages_ref = db.collection('chats').document(chat_id).collection('messages').order_by('sentAt').get()
  for message in messages_ref:
    messages.append(Message.from_snapshot(message))
  return messages

def add_message(chat_id: str, message: SentMessage) -> None:
  """Firestore にメッセージを追加する"""
  message_ref = db.collection('chats').document(chat_id).collection('messages').add({
    'sender': message.sender.value,
    'status': message.status.value,
    'text': message.text,
    'sentAt': message.sent_at,
    'isReplyAllowed': message.is_reply_allowed,
    'answerOptions': message.answer_options
  })
  print(f"Message saved to Firestore: {message_ref.id}")

def update_message(chat_id: str, message_id: str, message: SentMessage) -> None:
  """Firestore のメッセージを更新する"""
  message_ref = db.collection('chats').document(chat_id).collection('messages').document(message_id)
  message_ref.update({
    'sender': message.sender.value,
    'status': message.status.value,
    'text': message.text,
    'sentAt': message.sent_at,
    'isReplyAllowed': message.is_reply_allowed,
    'answerOptions': message.answer_options
  })
  print(f"Message updated in Firestore. chat_id: {chat_id} messsage_id: {message_id} message: {message}")
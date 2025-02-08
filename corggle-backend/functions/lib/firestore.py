from firebase_admin import firestore
from model import Message, SentMessage, Status, User

def initialize_db():
  return Firestore()

class Firestore:
  _instance = None

  def __new__(cls, *args, **kwargs):
    if not cls._instance:
      cls._instance = super(Firestore, cls).__new__(cls, *args, **kwargs)
      cls._instance.db = firestore.client()
    return cls._instance

  @classmethod
  def get_user(cls, uid: str) -> User:
    """Firestore からユーザー情報を取得する"""
    user_ref = cls().db.collection('users').document(uid).get()
    if not user_ref.exists:
      return None
    return User.from_snapshot(uid, user_ref)
  
  @classmethod
  def get_messages(cls, chat_id: str) -> list[Message]:
    """Firestore からチャットのメッセージを取得する"""
    messages = []
    messages_ref = cls().db.collection('chats').document(chat_id).collection('messages').order_by('sentAt').get()
    for message in messages_ref:
      messages.append(Message.from_snapshot(message))
    return messages

  @classmethod
  def add_message(cls, chat_id: str, message: SentMessage) -> str:
    """Firestore にメッセージを追加する"""
    message_ref = cls().db.collection('chats').document(chat_id).collection('messages').add({
      'sender': message.sender.value,
      'status': message.status.value,
      'text': message.text,
      'sentAt': message.sent_at,
      'isReplyAllowed': message.is_reply_allowed,
      'answerOptions': message.answer_options
    })
    message_id = message_ref[1].id
    print(f"Message added to Firestore: chat_id: {chat_id} message_id: {message_id} message: {message}")
    return message_id

  @classmethod
  def update_message(cls, chat_id: str, message_id: str, message: SentMessage) -> None:
    """Firestore のメッセージを更新する"""
    message_ref = cls().db.collection('chats').document(chat_id).collection('messages').document(message_id)
    message_ref.update({
      'sender': message.sender.value,
      'status': message.status.value,
      'text': message.text,
      'sentAt': message.sent_at,
      'isReplyAllowed': message.is_reply_allowed,
      'answerOptions': message.answer_options
    })
    print(f"Message updated in Firestore. chat_id: {chat_id} messsage_id: {message_id} message: {message}")
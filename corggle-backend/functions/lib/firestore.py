from firebase_admin import firestore
from model import Chat, SeningMessage, SentMessage, User

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
  def get_chat(cls, chat_id: str) -> Chat:
    """Firestore からチャット情報を取得する"""
    chat_ref = cls().db.collection('chats').document(chat_id).get()
    if not chat_ref.exists:
      return None
    return Chat.from_snapshot(chat_ref)
  
  @classmethod
  def update_chat(cls, chat_id: str, chat: Chat) -> None:
    """Firestore のチャット情報を更新する"""
    chat_ref = cls().db.collection('chats').document(chat_id)
    chat_ref.update({
      'scene': chat.scene,
      'title': chat.title
    })
    print(f"Chat updated in Firestore: chat_id: {chat_id}")
  
  @classmethod
  def get_messages(cls, chat_id: str) -> list[SentMessage]:
    """Firestore からチャットのメッセージを取得する"""
    messages = []
    messages_ref = cls().db.collection('chats').document(chat_id).collection('messages').order_by('sentAt').get()
    for snapshot in messages_ref:
      messages.append(SentMessage.from_snapshot(snapshot))
    return messages

  @classmethod
  def add_message(cls, chat_id: str, message: SeningMessage) -> str:
    """Firestore にメッセージを追加する"""
    message_ref = cls().db.collection('chats').document(chat_id).collection('messages').add({
      'sender': message.sender.value,
      'status': message.status.value,
      'text': message.text,
      'sentAt': firestore.firestore.SERVER_TIMESTAMP,
      'isReplyAllowed': message.reply_allowed,
      'answerOptions': message.answer_options
    })
    message_id = message_ref[1].id
    print(f"Message added to Firestore: chat_id: {chat_id} message_id: {message_id} message: {message}")
    return message_id

  @classmethod
  def update_message(cls, chat_id: str, message_id: str, message: SeningMessage) -> None:
    """Firestore のメッセージを更新する"""
    message_ref = cls().db.collection('chats').document(chat_id).collection('messages').document(message_id)
    message_ref.update({
      'status': message.status.value,
      'text': message.text,
      'isReplyAllowed': message.reply_allowed,
      'answerOptions': message.answer_options
    })
    print(f"Message updated in Firestore. chat_id: {chat_id} messsage_id: {message_id} message: {message}")
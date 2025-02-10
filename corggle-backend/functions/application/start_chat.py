from model import Chat, SeningMessage
from lib import Firestore, Gemini, ResponseStatus

def start_chat(chat_id: str, chat: Chat):
  """新しいチャットを開始する"""
  user = Firestore.get_user(chat.uid)
  if (user is None):
    failedMessage = SeningMessage.failed("あなたはだれコギ？データベースに登録されていないみたいだね。")
    Firestore.add_message(chat_id, failedMessage)
    raise ValueError(f"User not found: {chat.uid}")

  print(f"Sending in-progress message")
  reply_message_id = Firestore.add_message(chat_id, SeningMessage.in_progress())

  print(f"Generating gemini response")
  response = Gemini.generate_response(user, chat, [], None)
  if (response.status == ResponseStatus.ERROR):
    message = SeningMessage.failed("こぎ美がエラーに遭遇したみたいだね。")
    Firestore.update_message(chat_id, reply_message_id, message)
  elif (response.status == ResponseStatus.SUCCESS):
    message = SeningMessage.completed(response.text, reply_allowed=True)
    Firestore.update_message(chat_id, reply_message_id, message)
  else:
    raise ValueError(f"Invalid response status: {response.status}")

  print(f"Generating answer options")
  answer_options = Gemini.suggest_answer_options(response.chat_session)
  if (answer_options):
    message = SeningMessage.from_message(message, reply_allowed=True, answer_options=answer_options)
    Firestore.update_message(chat_id, reply_message_id, message)

  print(f"Completed: starting chat {chat_id}")

__all__ = ['start_chat']

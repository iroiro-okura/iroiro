from model import Message, SeningMessage, Sender
from lib import Firestore, Gemini, ResponseStatus

def reply_to_message(chat_id: str, message_id: str, message: Message):
  chat = Firestore.get_chat(chat_id)
  if (chat is None):
    raise ValueError(f"Chat not found: {chat_id}")

  user = Firestore.get_user(chat.uid)
  if (user is None):
    failedMessage = SeningMessage.failed("あなたはだれコギ？データベースに登録されていないみたいだね。")
    Firestore.add_message(chat_id, failedMessage)
    raise ValueError(f"User not found: {chat.uid}")

  messages = Firestore.get_messages(chat_id)
  # messageが最新でない場合はスキップ
  if message.sent_at != max([msg.sent_at for msg in messages]):
    raise ValueError(f"Message is not the latest: {message_id}")

  print(f"Sending in-progress message")
  reply_message_id = Firestore.add_message(chat_id, SeningMessage.in_progress())
  # 現在のmessageを除いてhistoryを作成
  history = [msg for msg in messages if msg.message_id != message_id]

  print(f"Generating gemini response")
  response = Gemini.generate_response(user, chat, history, message)
  if (response.status == ResponseStatus.ERROR):
    message = SeningMessage.failed("こぎ美がエラーに遭遇したみたいだね。")
    Firestore.update_message(chat_id, reply_message_id, message)
  elif (response.status == ResponseStatus.SUCCESS):
    message = SeningMessage.completed(response.text, reply_allowed=True)
    Firestore.update_message(chat_id, reply_message_id, message)
  else:
    raise ValueError(f"Invalid response status: {response.status}")

  print(f"Generating answer options")
  chat_session = response.chat_session
  answer_options = Gemini.suggest_answer_options(chat_session)
  if (answer_options):
    message = SeningMessage.from_message(message, reply_allowed=True, answer_options=answer_options)
    Firestore.update_message(chat_id, reply_message_id, message)

  user_messages = [msg for msg in messages if msg.sender == Sender.USER]
  if len(user_messages) >= 3 and len(user_messages) % 3 == 0:
    print(f"Give a title to chat")
    title = Gemini.give_title_to_chat(chat_session)
    if title:
      chat.title = title
      Firestore.update_chat(chat_id, chat)

  print(f"Completed: reply to message {message_id}")

__all__ = ['reply_to_message']
from model import Chat, SeningMessage
from lib import Firestore, Gemini, ResponseStatus

def start_chat(chat_id: str, chat: Chat):
  """新しいチャットを開始する"""
  user = Firestore.get_user(chat.uid)
  if (user is None):
    failedMessage = SeningMessage.failed("あなたはだれコギ？データベースに登録されていないみたいだね。")
    Firestore.add_message(chat_id, failedMessage)
    raise ValueError(f"User not found: {chat.uid}")
  initial_message = SeningMessage.completed(
    create_initial_message_text(chat.scene),
    is_repliy_allowed=False
  )
  print(f"Sending initial message")
  Firestore.add_message(chat_id, initial_message)
  print(f"Sending in-progress message")
  reply_message_id = Firestore.add_message(chat_id, SeningMessage.in_progress())
  history = [initial_message]
  print(f"Generating gemini response")
  response = Gemini.send_message_to_gemini(user, chat, history, None)
  message = ""
  if (response.status == ResponseStatus.ERROR):
    message = SeningMessage.failed("コギ美がエラーに遭遇したみたいだね。")
    Firestore.update_message(chat_id, reply_message_id, message)
  elif (response.status == ResponseStatus.SUCCESS):
    message = SeningMessage.completed(response.text, is_repliy_allowed=True)
    Firestore.update_message(chat_id, reply_message_id, message)
  else:
    raise ValueError(f"Invalid response status: {response.status}")
  print(f"Sent response message {message}")

def create_initial_message_text(scene: str) -> str:
  initial_message = "Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n"
  if (scene):
    initial_message += f"今回は『{scene}』で話題を探しているんだね。\n"
  initial_message += "あなたや他の人のプロフィールや興味ありそうなことをもう少し教えてほしいな！"
  return initial_message

__all__ = ['start_chat']

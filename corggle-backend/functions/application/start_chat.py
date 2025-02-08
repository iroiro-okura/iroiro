from model import Chat, SentMessage
from lib import Firestore, Gemini, ResponseStatus

def start_chat(chat_id: str, chat: Chat):
  """新しいチャットを開始する"""
  user = Firestore.get_user(chat.uid)
  if (user is None):
    failedMessage = SentMessage.failed("あなたはだれコギ？データベースに登録されていないみたいだね。")
    Firestore.add_message(chat_id, failedMessage)
    raise ValueError(f"User not found: {chat.uid}")
  initial_message = SentMessage.completed(
    create_initial_message_text(chat.scene),
    is_repliy_allowed=False
  )
  print(f"sending initial message")
  Firestore.add_message(chat_id, initial_message)
  message = SentMessage.in_progress()
  print(f"sending in-progress message")
  in_progress_message_id = Firestore.add_message(chat_id, message)
  history = [initial_message]
  print(f"generating gemini response")
  response = Gemini.generate_gemini_response(user, chat, history, None)
  message = ""
  if (response.status == ResponseStatus.ERROR):
    message = SentMessage.failed("コギ美がエラーに遭遇したみたいだね。")
    Firestore.update_message(chat_id, in_progress_message_id, message)
  elif (response.status == ResponseStatus.SUCCESS):
    message = SentMessage.completed(response.text, is_repliy_allowed=True)
    Firestore.update_message(chat_id, in_progress_message_id, message)
  else:
    raise ValueError(f"Invalid response status: {response.status}")
  print(f"send response message {message}")

def create_initial_message_text(scene: str) -> str:
  initial_message = "Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n"
  if (scene):
    initial_message += f"今回は『{scene}』で話題を探しているんだね。\n"
  initial_message += "あなたや他の人のプロフィールや興味ありそうなことをもう少し教えてほしいな！"
  return initial_message

__all__ = ['start_chat']

from model import Chat, SentMessage
from lib import Firestore, Gemini

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
  print(f"send initial message")
  Firestore.add_message(chat_id, initial_message)
  message = SentMessage.in_progress()
  print(f"send in-progress message")
  in_progress_message_id = Firestore.add_message(chat_id, message)
  history = [initial_message]
  response = Gemini.generate_gemini_response(user, chat, history, None)

def create_initial_message_text(scene: str) -> str:
  initial_message = "Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n"
  if (scene):
    initial_message += f"今回は『{scene}』で話題を探しているんだね。\n"
  initial_message += "あなたや他の人のプロフィールや興味ありそうなことをもう少し教えてほしいな！"
  return initial_message

__all__ = ['start_chat']

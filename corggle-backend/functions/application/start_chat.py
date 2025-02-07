from model import Chat, Scene, SentMessage
from lib import get_user, add_message, get_messages

def create_initial_message_text(scene: Scene) -> str:
  initial_message = "Corggleへようこそ！AIコーギのコギ美がサポートするよ！\n"
  if (scene == Scene.DATING):
    initial_message += f"今回は『{Scene.display_name(scene)}』で話題を探しているんだね。\n最適な話題を見つけるためにも、お相手のことをもう少し教えてほしいな！"
  elif (scene == Scene.REUNION or scene == Scene.COMPANYGATHERING):
    initial_message += f"今回は『{Scene.display_name(scene)}』で話題を探しているんだね。\n最適な話題を見つけるためにも、他のみんなのことをもう少し教えてほしいな！"
  else:
    initial_message += ""
  return initial_message

def start_chat(chat_id: str, chat: Chat):
  """新しいチャットを開始する"""
  user = get_user(chat.uid)
  if (user is None):
    failedMessage = SentMessage.failed("あなたはだれコギ？データベースに登録されていないみたいだね。")
    add_message(chat_id, failedMessage)
    raise ValueError(f"User not found: {chat.uid}")
  initial_message = SentMessage.completed(
    create_initial_message_text(chat.scene),
    is_repliy_allowed=False
  )
  print(f"send initial message")
  add_message(chat_id, initial_message)
  in_progress_message = SentMessage.in_progress()
  print(f"send in-progress message")
  add_message(chat_id, in_progress_message)

__all__ = ['start_chat']

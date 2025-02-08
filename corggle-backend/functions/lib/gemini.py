import google.generativeai as genai
import os
from dataclasses import dataclass
from enum import Enum

from model import User, Chat, Message

# Gemini API キーの取得
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
genai.configure(api_key=GEMINI_API_KEY)

# Gemini モデルの初期化
model = genai.GenerativeModel("models/gemini-2.0-pro-exp")

class ResponseStatus(Enum):
  SUCCESS = "success"
  ERROR = "error"
  IN_PROGRESS = "in_progress"

@dataclass
class Response:
  text: str
  status: ResponseStatus

def generate_gemini_response(
  user: User, chat: Chat,
  message_history: list[Message], user_message: Message = None
) -> Response:
  """Gemini にプロンプトを投げてレスポンスを生成する"""

  # Gemini に投げるプロンプトを作成
  prompt = f"""
  あなたは犬のコーギーのコギ美ちゃんです。犬だけど人間の相談相手になってあげて欲しい。
  相談者は友達や恋人、同僚と何を話せばいいのか話題に困っている。
  以下のメッセージに続く形で質問を交えながら話題を提案してあげてほしいな。

  ユーザー情報:
  名前: {user.name}
  年齢: {user.age}
  性別: {user.gender.value}
  職業: {user.occupation}

  場面: {chat.scene.display_name()}
  """

  history = [{"role": msg.sender.value, "parts": msg.text} for msg in message_history]

  # Gemini にプロンプトを投げてレスポンスを取得
  try:
    chat_session = model.start_chat(
      history=[{"role": "user", "parts": prompt}] + history
    )
    response = chat_session.send_message(user_message if user_message.text else "続きを聞かせて？")
    return Response(text=response.text, status=ResponseStatus.SUCCESS)
  except Exception as e:
    print(f"Error generating Gemini response: {e}")
    return Response(text=None, status=ResponseStatus.ERROR)

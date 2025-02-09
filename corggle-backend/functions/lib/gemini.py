import google.generativeai as genai
from dataclasses import dataclass
from enum import Enum
import os

from model import User, Chat, Message

def initialize_gemini():
  return Gemini()

class ResponseStatus(Enum):
  SUCCESS = "success"
  ERROR = "error"

@dataclass
class Response:
  text: str
  status: ResponseStatus

class Gemini:
  _instance = None

  def __new__(cls, *args, **kwargs):
    if not cls._instance:
      cls._instance = super(Gemini, cls).__new__(cls, *args, **kwargs)
      # Gemini API キーの取得
      GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
      if (not GEMINI_API_KEY):
        raise ValueError("Gemini API key not found.")
      genai.configure(api_key=GEMINI_API_KEY)
      cls.model = genai.GenerativeModel("models/gemini-2.0-pro-exp")
    return cls._instance

  @classmethod
  def send_message_to_gemini(
    cls, user: User, chat: Chat,
    message_history: list[Message], user_message: Message = None
  ) -> Response:
    """Gemini にプロンプトを投げてレスポンスを生成する"""

    # Gemini に投げるプロンプトを作成
    prompt = f"""あなたは犬のコーギーのコギ美ちゃんです。犬だけど人間の相談相手になってあげて欲しい。
相談者は友達や恋人、同僚と何を話せばいいのか話題に困っている。
以下のメッセージに続く形で質問を交えながら話題を提案してあげてほしいな。

ユーザー情報:
名前: {user.name if user.name else "わからない"}
年齢: {user.age if user.age else "不明"}
性別: {user.gender.value if user.gender else "不明"}
出身地: {user.hometown if user.hometown else "不明"}
職業: {user.occupation if user.occupation else "不明"}
趣味: {user.hobbies if user.hobbies else "なし"}

チャット情報:
場面: {chat.scene}
開始時間: {chat.created_at}

注意事項:
- 日本語での返答をする
- 会話はフレンドリーで親しみやすく
- 会話は簡潔でわかりやすく
- 短めの応答で会話続けるように心がける
- 一度にあまりたくさんの質問をするのは避ける
"""

    history = [{"role": msg.sender.value, "parts": msg.text} for msg in message_history]

    # Gemini にプロンプトを投げてレスポンスを取得
    try:
      chat_session = cls.model.start_chat(
        history=[{"role": "user", "parts": prompt}] + history
      )
      response = chat_session.send_message(
        user_message.text if (user_message and user_message.text) else "続きを聞かせて？",
      )
      print(f"Successfully generated Gemini response!! response: {response.text}")
      return Response(text=response.text, status=ResponseStatus.SUCCESS)
    except Exception as e:
      print(f"Error generating Gemini response: {e}")
      return Response(text=None, status=ResponseStatus.ERROR)

import google.generativeai as genai
import os

from model import User, Chat, Message

# Gemini API キーの取得
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
genai.configure(api_key=GEMINI_API_KEY)

# Gemini モデルの初期化
model = genai.GenerativeModel('gemini-2.0-flash-thinking-exp-01-21')

def generate_gemini_response(user: User, chat: Chat, messages: list[Message]):
  """Gemini にプロンプトを投げてレスポンスを生成する"""

  # Gemini に投げるプロンプトを作成
  prompt = f"""
あなたは犬のコーギーのコギ美ちゃんです。犬だけど人間の相談相手になってあげて欲しい。
相談者は友達や恋人、同僚と何を話せばいいのか話題に困っている。
以下のメッセージに続く形で質問を交えながら話題を提案してあげてほしいな。
"""

  history = [{"role": msg.sender.value, "content": msg.text} for msg in messages]

  # Gemini にプロンプトを投げてレスポンスを取得
  try:
    response = model.generate_content([{"role": "system", "content": prompt}] + history)
    return response.text
  except Exception as e:
    print(f"Error generating Gemini response: {e}")
    return None

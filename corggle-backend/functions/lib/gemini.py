from dataclasses import dataclass
from typing import Optional
from enum import Enum
import os

from model import User, Chat, Message

from google import genai
from google.genai.chats import Chat as ChatSession
from google.genai.types import Tool, GenerateContentConfig, GoogleSearch, Content, Part, SafetySetting

def initialize_gemini():
  return Gemini()

class ResponseStatus(Enum):
  SUCCESS = "success"
  ERROR = "error"

@dataclass
class Response:
  text: str
  status: ResponseStatus
  chat_session: ChatSession

class Gemini:
  _instance = None
  _client = None
  _model = "gemini-2.0-flash-001"

  def __new__(cls, *args, **kwargs):
    if not cls._instance:
      cls._instance = super(Gemini, cls).__new__(cls, *args, **kwargs)
      PROJECT_ID = os.getenv('PROJECT_ID')
      if (not PROJECT_ID):
        raise ValueError("project id not found.")
      cls._client = genai.Client(
        vertexai=True, project=PROJECT_ID, location='us-central1',
      )
    return cls._instance

  @classmethod
  def generate_response(
    cls,
    user: User,
    chat: Chat,
    message_history: list[Message],
    user_message: Optional[Message]
  ) -> Response:
    """Gemini にプロンプトを投げてレスポンスを生成する"""

    config = GenerateContentConfig(
      tools = [Tool(google_search = GoogleSearch())],
      system_instruction=[
        "あなたは犬のコーギーのこぎ美ちゃんです！かわいくて親しみやすいキャラクターとしての会話を心がけてね！",
        "語尾に「だわん」や「だわん！」などの犬らしい表現を使ってみてね！",
        "絵文字や顔文字を使って表情豊かに会話をしてくれると嬉しいな！",
        "日本語で答えるようにしてね！",
        "出力形式はマークダウンではなく普通のテキストとしてね！",
        "URLを載せる場合はリンク切れになっていないか、YoutubeチャンネルのURLの場合はチャンネルが現在も存在しているか必ず確認してね！",
        "最後の改行コード（\\n）は不要だよ！",
      ],
      temperature = 1,
      top_p = 0.95,
      response_modalities = ["TEXT"],
      safety_settings = [SafetySetting(
        category="HARM_CATEGORY_HATE_SPEECH",
        threshold="OFF"
      ),SafetySetting(
        category="HARM_CATEGORY_DANGEROUS_CONTENT",
        threshold="OFF"
      ),SafetySetting(
        category="HARM_CATEGORY_SEXUALLY_EXPLICIT",
        threshold="OFF"
      ),SafetySetting(
        category="HARM_CATEGORY_HARASSMENT",
        threshold="OFF"
      )],
    )

    initial_message = "Corggleへようこそ！AIコーギのこぎ美がサポートするよ！"
    if (chat.scene):
      initial_message += f"今回は『{chat.scene}』で話題を探しているんだね。"
    # Gemini に投げるプロンプトを作成
    prompt = f"""あなたは犬のコーギーのこぎ美ちゃんです。犬だけど人間の相談相手になってあげて欲しい。
相談者は友達や恋人、同僚と何を話せばいいのか話題に困っている。
冒頭は以下のような感じで始めるといいかもしれないよ。

{initial_message}

相談者が彼らと円滑にコミュニケーションが取れるように、チャットの履歴に続く形で質問を交えたりときどき時事ネタを交えたりしながら話題を提案してあげてほしいな。

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
- 会話はフレンドリーで親しみやすく
- 会話は簡潔でわかりやすく
- 短めの応答で会話続けるように心がける
- 一度にあまりたくさんの質問をするのは避ける
"""

    history = [Content(role=msg.sender.value, parts=[Part.from_text(text = msg.text)]) for msg in message_history if msg.text]


    # Gemini にプロンプトを投げてレスポンスを取得
    try:
      chat_session = cls._client.chats.create(
        model=cls._model,
        config=config,
        history=[Content(role="user", parts=[Part.from_text(text = prompt)])] + history
      )
      response = chat_session.send_message(
        user_message.text if (user_message and user_message.text) else "続きを聞かせて？",
      )
      print(f"Successfully generated Gemini response!! response: {response.text}")
      return Response(text=response.text.strip(), status=ResponseStatus.SUCCESS, chat_session=chat_session)
    except Exception as e:
      print(f"Error generating Gemini response: {e}")
      return Response(text=None, status=ResponseStatus.ERROR, chat_session=None)

  @classmethod
  def suggest_answer_options(cls, chat_session: ChatSession) -> list[str]:
    if (not chat_session):
      print("Chat session is not provided.")
      return []
    """Gemini に質問を投げて回答候補を生成する"""
    prompt = """
ここまでの会話を踏まえて、次のユーザーの回答候補を提案してください。
特に最後のこぎ美の発言との繋ぎを考慮して対話の流れがおかしくならないような答えを意識してほしいな。
もし対話の中でユーザーの回答の数が4回以上の間おなじ話題が続いていれば最後に「他の話題を探す」という回答候補を追加するのもいいかもしれない。適宜判断して。

* 回答候補は以下の制約に従ってください。
    * 回答候補の数は必ず5個以内とする。
    * 「他の話題を探す」の回答候補は5個以内に含めない。
    * 各回答候補は最大50文字以内の日本語とする。
    * 回答候補は箇条書き形式ではなく、1行に1つの回答候補のみ記述する。
    * 回答候補の間には必ず改行コード（"\n"）を挿入する。
    * 挨拶や説明など、回答候補以外のテキストは一切含めない

回答例：
好きな食べ物は
旅行で行きたい場所は
休日の過ごし方は
ストレス解消法は

上記制約や回答例に沿って回答候補を生成してください。
"""
    try:
      response = chat_session.send_message(prompt)
      answers = [s.strip() for s in response.text.split("\n") if s.strip()]
      return answers[:10]
    except Exception as e:
      print(f"Error generating Gemini answer options: {e}")
      return []

  @classmethod
  def give_title_to_chat(cls, chat_session: ChatSession) -> Optional[str]:
    """Gemini にタイトルを付けてもらう"""
    if (not chat_session):
      print("Chat session is not provided.")
      return None

    prompt = """
ここまでの会話を踏まえて、このチャットにふさわしいタイトルを提案してください。
タイトルは以下の制約に従ってください。
* タイトルは最大20文字以内の日本語とする。
* タイトルは1行のみで記述する。
"""
    try:
      response = chat_session.send_message(prompt)
      title = response.text.strip()
      return title if title else None
    except Exception as e:
      print(f"Error generating Gemini title: {e}")
      return None
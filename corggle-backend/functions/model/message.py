import dataclasses
import datetime
from enum import Enum
from firebase_functions import firestore_fn

class Sender(Enum):
  MODEL = "model"
  USER = "user"
  UNKNOWN = "unknown"

  @classmethod
  def value_of(cls, value: str):
    for member in cls:
      if member.value == value:
        return member
    return cls.UNKNOWN

class Status(Enum):
  IN_PROGRESS = "inProgress"
  FAILED = "failed"
  COMPLETED = "completed"
  UNKNOWN = "unknown"

  @classmethod
  def value_of(cls, value: str):
    for member in cls:
      if member.value == value:
        return member
    return cls.UNKNOWN

@dataclasses.dataclass
class Message:
  sender: Sender
  status: Status
  text: str
  sent_at: datetime.datetime
  
@dataclasses.dataclass
class SentMessage(Message):
  message_id: str

  @classmethod
  def from_snapshot(cls, snapshot) -> 'SentMessage':
    """SnapshotからMessageインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    sent_at = data.get('sentAt')
    return cls(
      message_id=snapshot.id,
      sender=Sender.value_of(data.get('sender')),
      status=Status.value_of(data.get('status')),
      text=data.get('text', ''),
      sent_at=datetime.datetime.fromtimestamp(sent_at.timestamp())
    )


@dataclasses.dataclass
class SeningMessage(Message):
  reply_allowed: bool
  answer_options: list[str]

  @classmethod
  def in_progress(cls) -> 'SeningMessage':
    """読み込み中のメッセージを作成する"""
    return cls(
      sender=Sender.MODEL,
      status=Status.IN_PROGRESS,
      text="...(ちょっとまっててコギ)",
      sent_at=datetime.datetime.now(),
      reply_allowed=False,
      answer_options=[]
    )
  
  @classmethod
  def failed(cls, text=None) -> 'SeningMessage':
    """読み込み失敗のメッセージを作成する"""
    return cls(
      sender=Sender.MODEL,
      status=Status.FAILED,
      text=text if text else "読み込みに失敗しちゃったみたい...もう一度試してみてね！",
      sent_at=datetime.datetime.now(),
      reply_allowed=True,
      answer_options=[]
    )
  
  @classmethod
  def completed(cls, text: str, sender = Sender.MODEL, reply_allowed = True, answer_options: list[str] = []) -> 'SeningMessage':
    """完了のメッセージを作成する"""
    return cls(
      sender=sender,
      status=Status.COMPLETED,
      text=text,
      sent_at=datetime.datetime.now(),
      reply_allowed=reply_allowed,
      answer_options=answer_options
    )

  @classmethod
  def from_message(cls, message: Message, reply_allowed: bool, answer_options: list[str]) -> 'SeningMessage':
    """MessageインスタンスからSendingMessageインスタンスを作成する"""
    return cls(
      sender=message.sender,
      status=message.status,
      text=message.text,
      sent_at=message.sent_at,
      reply_allowed=reply_allowed,
      answer_options=answer_options
    )
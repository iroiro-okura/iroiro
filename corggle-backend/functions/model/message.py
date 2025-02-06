from enum import Enum
from firebase_functions import firestore_fn, https_fn

class Sender(Enum):
  MODEL = "model"
  USER = "user"

class Status(Enum):
  IN_PROGRESS = "inProgress"
  FAILED = "failed"
  COMPLETED = "completed"

class Message:
  def __init__(self, text: str, status: Status, sender: Sender):
    self.text = text
    self.status = status
    self.sender = sender

  @classmethod
  def from_snapshot(cls, snapshot: firestore_fn.DocumentSnapshot) -> 'Message':
    """SnapshotからMessageインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    return cls(
      text=data.get('text', ''),
      status=Status(data.get('status')),
      sender=Sender(data.get('sender'))
    )

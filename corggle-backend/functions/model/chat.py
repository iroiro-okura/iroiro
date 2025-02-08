import dataclasses
from enum import Enum 
from firebase_functions import firestore_fn

@dataclasses.dataclass
class Chat:
  uid: str
  scene: str
  
  @classmethod
  def from_snapshot(cls, snapshot: firestore_fn.DocumentSnapshot) -> 'Chat':
    """SnapshotからChatインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    return cls(
      uid=data.get('uid'),
      scene=data.get('scene'),
    )

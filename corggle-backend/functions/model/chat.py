import dataclasses
import datetime
from typing import Optional
from firebase_functions import firestore_fn

@dataclasses.dataclass
class Chat:
  uid: str
  scene: str
  created_at: Optional[datetime.datetime]
  
  @classmethod
  def from_snapshot(cls, snapshot: firestore_fn.DocumentSnapshot) -> 'Chat':
    """SnapshotからChatインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    created_at = data.get('createdAt')
    return cls(
      uid=data.get('uid'),
      scene=data.get('scene') if data.get('scene') else '',
      created_at=datetime.datetime.fromtimestamp(created_at.timestamp) if created_at else None
    )

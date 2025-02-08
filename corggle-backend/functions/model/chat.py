import dataclasses
from enum import Enum 
from firebase_functions import firestore_fn

class Scene(Enum):
  """シーンを表すEnum"""
  DATING = "dating"
  REUNION= "reunion"
  COMPANYGATHERING = "companyGathering"
  TBD = "tbd"
  UNKNOWN = "unknown"

  @classmethod
  def value_of(cls, value: str):
    for member in cls:
      if member.value == value:
        return member
      elif member.value == "":
        return cls.TBD
    return cls.UNKNOWN
  
  @classmethod
  def display_name(cls, scene: 'Scene') -> str:
    """シーンの表示名を取得する"""
    if scene == cls.DATING:
      return "デート"
    elif scene == cls.REUNION:
      return "同窓会"
    elif scene == cls.COMPANYGATHERING:
      return "会社の懇親会"
    else:
      return None

@dataclasses.dataclass
class Chat:
  uid: str
  scene: Scene
  
  @classmethod
  def from_snapshot(cls, snapshot: firestore_fn.DocumentSnapshot) -> 'Chat':
    """SnapshotからChatインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    return cls(
      uid=data.get('uid'),
      scene=Scene.value_of(data.get('scene')),
    )

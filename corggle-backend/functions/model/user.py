import dataclasses
from enum import Enum
from firebase_functions import firestore_fn

class Gender(Enum):
  MALE = "male"
  FEMALE = "female"
  OTHER = "other"

  @classmethod
  def value_of(cls, value: str):
    for member in cls:
      if member.value == value:
        return member
    return cls.OTHER

@dataclasses.dataclass
class User:
  uid: str
  name: str
  age: int
  gender: Gender
  occupation: str

  @classmethod
  def from_snapshot(cls, uid: str, snapshot: firestore_fn.DocumentSnapshot) -> 'User':
    """SnapshotからUserインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    return cls(
      uid=uid,
      name=data.get('name'),
      age=data.get('age'),
      gender=Gender.value_of(data.get('gender')),
      occupation=data.get('occupation')
    )

import dataclasses
from enum import Enum
from typing import Optional
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
  name: Optional[str]
  age: Optional[int]
  gender: Optional[Gender]
  hometown: Optional[str]
  occupation: Optional[str]
  hobbies: list[str]

  @classmethod
  def from_snapshot(cls, uid: str, snapshot: firestore_fn.DocumentSnapshot) -> 'User':
    """SnapshotからUserインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    hobbies = data.get('hobbies')
    return cls(
      uid=uid,
      name=data.get('name'),
      age=data.get('age'),
      gender=Gender.value_of(data.get('gender')),
      hometown=data.get('hometown'),
      occupation=data.get('occupation'),
      hobbies=hobbies if hobbies else [],
    )

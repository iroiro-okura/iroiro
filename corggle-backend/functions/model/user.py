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

class User:
  def __init__(self, uid: str, email: str, name: str, age: int, gender: Gender, occupation: str):
    self.uid = uid
    self.email = email
    self.name = name
    self.age = age
    self.gender = gender
    self.occupation = occupation

  @classmethod
  def from_snapshot(cls, snapshot: firestore_fn.DocumentSnapshot) -> 'User':
    """SnapshotからUserインスタンスを作成するファクトリメソッド"""
    data = snapshot.to_dict()
    return cls(
      uid=data.get('uid'),
      email=data.get('email'),
      name=data.get('name'),
      age=data.get('age'),
      gender=Gender.value_of(data.get('gender')),
      occupation=data.get('occupation')
    )

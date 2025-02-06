from enum import Enum 

class Scene(Enum):
  """シーンを表すEnum"""
  DATING = "dating"
  REUNION= "reunion"
  COMPANYGATHERING = "companyGathering"

class Chat:
  def __init__(self, chatId: str, uid: str, scene: Scene):
    self.chatId = chatId
    self.uid = uid
    self.scene = scene
  
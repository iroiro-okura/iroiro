import unittest
from unittest.mock import patch, MagicMock

# The Firebase Admin SDK to access Cloud Firestore.
from firebase_admin import initialize_app, get_app, _apps

app = initialize_app()

from lib.firestore import get_user, get_messages, add_message, update_message
from model import User, SeningMessage, Sender, Status


class TestFirestoreFunctions(unittest.TestCase):

  @patch('lib.firestore.db')
  def test_get_user_exists(self, mock_db):
    mock_user_ref = MagicMock()
    mock_user_ref.exists = True
    mock_db.collection.return_value.document.return_value.get.return_value = mock_user_ref
    user = get_user('test_uid')
    self.assertIsInstance(user, User)

  @patch('lib.firestore.db')
  def test_get_user_not_exists(self, mock_db):
    mock_user_ref = MagicMock()
    mock_user_ref.exists = False
    mock_db.collection.return_value.document.return_value.get.return_value = mock_user_ref
    mock_db.collection.return_value.document.return_value.get.return_value.to_dict.return_value = None
    user = get_user('test_uid')
    self.assertIsNone(user)

  @patch('lib.firestore.db')
  def test_get_messages(self, mock_db):
    mock_message_ref = MagicMock()
    mock_db.collection.return_value.document.return_value.collection.return_value.order_by.return_value.get.return_value = [mock_message_ref]
    messages = get_messages('test_chat_id')
    self.assertEqual(len(messages), 1)

  @patch('lib.firestore.db')
  def test_add_message(self, mock_db):
    message = SeningMessage(
      sender=Sender.USER,
      status=Status.COMPLETED,
      text="Test message",
      sent_at=None,
      reply_allowed=True,
      answer_options=[]
    )
    add_message('test_chat_id', message)
    mock_db.collection.return_value.document.return_value.collection.return_value.add.assert_called_once()

  @patch('lib.firestore.db')
  def test_update_message(self, mock_db):
    message = SeningMessage(
      sender=Sender.USER,
      status=Status.COMPLETED,
      text="Updated message",
      sent_at=None,
      reply_allowed=True,
      answer_options=[]
    )
    update_message('test_chat_id', 'test_message_id', message)
    mock_db.collection.return_value.document.return_value.collection.return_value.document.return_value.update.assert_called_once()

if __name__ == '__main__':
    unittest.main()

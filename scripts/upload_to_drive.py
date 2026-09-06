#!/usr/bin/env python3
"""
Google Drive へのファイルアップロード処理
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# Google Drive API の定義
DRIVE_SCOPES = ['https://www.googleapis.com/auth/drive.file']

def authenticate_drive(service_account_key):
    """Google Drive API 認証"""
    try:
        credentials = service_account.Credentials.from_service_account_info(
            service_account_key, scopes=DRIVE_SCOPES
        )
        return build('drive', 'v3', credentials=credentials)
    except Exception as e:
        print(f"❌ Google Drive 認証エラー: {e}")
        sys.exit(1)

def upload_file(service, file_path, folder_id, file_name=None):
    """ファイルを Google Drive にアップロード"""
    if not os.path.exists(file_path):
        print(f"⚠️  ファイルが見つかりません: {file_path}")
        return None

    if file_name is None:
        file_name = os.path.basename(file_path)

    try:
        file_metadata = {
            'name': f"{file_name}",
            'parents': [folder_id]
        }

        media = MediaFileUpload(
            file_path, mimetype='application/octet-stream', resumable=True
        )

        file = service.files().create(
            body=file_metadata,
            media_body=media,
            fields='id, webViewLink'
        ).execute()

        print(f"✅ アップロード成功: {file_name}")
        print(f"   Drive Link: {file['webViewLink']}")
        return file['id']
    except Exception as e:
        print(f"❌ アップロード失敗 {file_name}: {e}")
        return None

def main():
    # 環境変数から設定を読み込み
    service_account_key_json = os.getenv('GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY')
    folder_id = os.getenv('GOOGLE_DRIVE_FOLDER_ID', '1kqPMiEnGtF7sRNiYsds9_9YvuPsT1Rfu')

    if not service_account_key_json:
        print("❌ エラー: GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY 環境変数が設定されていません")
        sys.exit(1)

    # JSON キーをパース
    try:
        service_account_key = json.loads(service_account_key_json)
    except json.JSONDecodeError as e:
        print(f"❌ JSON パースエラー: {e}")
        sys.exit(1)

    # Google Drive API 認証
    service = authenticate_drive(service_account_key)

    # アップロード対象ファイル
    files_to_upload = [
        ('build/app/outputs/apk/release/app-release.apk', 'eigo_release.apk'),
        ('build/app/outputs/bundle/release/app-release.aab', 'eigo_release.aab'),
    ]

    print(f"\n📁 Google Drive へのアップロード開始")
    print(f"   フォルダID: {folder_id}")
    print(f"   タイムスタンプ: {datetime.now().isoformat()}\n")

    uploaded_files = []
    for file_path, upload_name in files_to_upload:
        if os.path.exists(file_path):
            file_id = upload_file(service, file_path, folder_id, upload_name)
            if file_id:
                uploaded_files.append({
                    'name': upload_name,
                    'path': file_path,
                    'id': file_id
                })
        else:
            print(f"⚠️  スキップ: {file_path} (存在しません)")

    print(f"\n📊 アップロード完了: {len(uploaded_files)} ファイル")

    if len(uploaded_files) == 0:
        print("⚠️  アップロードするファイルがありません")
        sys.exit(1)

    return 0

if __name__ == '__main__':
    sys.exit(main())

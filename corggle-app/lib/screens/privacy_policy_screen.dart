import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: 'プライバシーポリシー\n',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '\nはじめに\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'Corggleへようこそ！本プライバシーポリシーは、当社のモバイルアプリケーション（以下「アプリ」）をご利用いただく際に、ユーザーの情報をどのように収集、使用、開示、および保護するかを説明するものです。本プライバシーポリシーの内容に同意いただけない場合は、アプリへのアクセスをお控えください。\n\n',
                ),
                TextSpan(
                  text: '当社が収集する情報\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '当社は、以下の方法でユーザーに関する情報を収集する場合があります。\n\n',
                ),
                TextSpan(
                  text: '個人データ\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'ユーザーがアプリに登録する際、またはチャットなど、アプリに関連するさまざまな活動に参加する際に、自発的に提供される氏名、メールアドレスなどの個人を特定できる情報。\n\n',
                ),
                TextSpan(
                  text: '利用データ\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'ユーザーがアプリにアクセスした際に、サーバーが自動的に収集する情報。これには、デバイスのIPアドレス、ブラウザの種類、オペレーティングシステム、アクセス時間、アプリへのアクセス前後に閲覧したページなどが含まれます。\n\n',
                ),
                TextSpan(
                  text: 'モバイルデバイスへのアクセス\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社は、ユーザーのモバイルデバイスのカメラ、連絡先、マイク、ストレージなどの特定の機能へのアクセスや許可を求める場合があります。アクセスや許可を変更したい場合は、デバイスの設定から行うことができます。\n\n',
                ),
                TextSpan(
                  text: 'モバイルデバイスデータ\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'モバイルデバイスのID、モデル、製造元、デバイスの位置情報などの情報。\n\n',
                ),
                TextSpan(
                  text: '情報の利用方法\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '正確な情報を取得することで、ユーザーに円滑で効率的かつカスタマイズされた体験を提供できます。具体的には、以下の目的で情報を使用する場合があります。\n\n',
                ),
                TextSpan(
                  text:
                      '- アカウントの作成および管理。\n - チャットサービスの提供および管理。\n- アプリおよびユーザー体験の改善。\n- 利用状況や傾向の監視および分析によるユーザー体験の向上。\n- アプリに関する更新情報やその他の情報の送信。\n\n',
                ),
                TextSpan(
                  text: '情報の開示\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社は、特定の状況下で収集した情報を共有する場合があります。ユーザーの情報は、以下の方法で開示されることがあります。\n\n',
                ),
                TextSpan(
                  text: '法律による開示または権利保護のための開示\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社が、ユーザーに関する情報の開示が法的手続きに対応するため、当社のポリシーの潜在的な違反を調査または是正するため、または他者の権利、財産、安全を保護するために必要であると判断した場合、適用される法律、規則、規制に従って情報を共有することがあります。\n\n',
                ),
                TextSpan(
                  text: 'サードパーティのサービスプロバイダー\n',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社は、データ分析、ホスティングサービス、カスタマーサービス、当社に代わってサービスを提供する第三者とユーザーの情報を共有することがあります。\n\n',
                ),
                TextSpan(
                  text: '情報のセキュリティ\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社は、ユーザーの個人情報を保護するために、管理的、技術的、物理的なセキュリティ対策を講じています。しかし、当社の努力にもかかわらず、いかなるセキュリティ対策も完全または侵入不可能ではなく、いかなるデータ伝送方法も傍受やその他の不正使用から完全に保護されることは保証できません。\n\n',
                ),
                TextSpan(
                  text: '本プライバシーポリシーの変更\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '当社は、実務の変更やその他の運用上、法的、規制上の理由を反映するために、本プライバシーポリシーを随時更新することがあります。新しいプライバシーポリシーはこのページに掲載することで通知いたします。本プライバシーポリシーを定期的にご確認ください。\n\n',
                ),
                TextSpan(
                  text: 'お問い合わせ\n',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '本プライバシーポリシーに関するご質問やご意見がある場合は、mogura004@gmail.com お気軽にお問い合わせください。\n\n',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

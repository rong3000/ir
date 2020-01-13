import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/main_screen/settings_page/contact_screen/contact.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

import '../../user_repository.dart';

class ContactMenuCard extends StatelessWidget {
  final UserRepository _userRepository;

  ContactMenuCard({Key key, @required UserRepository userRepository,})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return ContactUs(userRepository: _userRepository);
          }),
        )
      },
      child: Card(
        child: ListTile(
          title: AutoSizeText(
            allTranslations.text('app.settings-page.contact-us-menu-item-title'),
            style: TextStyle(fontSize: 18),
            minFontSize: 8,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

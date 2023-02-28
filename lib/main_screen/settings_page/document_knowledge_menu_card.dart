import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/main_screen/settings_page/documents_screen/documents_screen.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class DocumentKnowledgeMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return DocumentsScreen();
          }),
        )
      },
      child: Card(
        child: ListTile(
          title: AutoSizeText(
            allTranslations.text('app.settings-page.document-knowledge-menu-item-title'),
            style: TextStyle(fontSize: 18),
            minFontSize: 8,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    ;
  }
}

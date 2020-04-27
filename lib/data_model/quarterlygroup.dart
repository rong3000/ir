import 'package:json_annotation/json_annotation.dart';
import 'data_result.dart';
import 'ir_repository.dart';
import "../user_repository.dart";
import 'package:synchronized/synchronized.dart';
import "webservice.dart";
import 'report.dart';

part 'quarterlygroup.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class QuarterlyGroup {
  int id;
  String groupName;
  String groupDescription;
  DateTime startDatetime;
  DateTime endDatetime;

  QuarterlyGroup();

  factory QuarterlyGroup.fromJson(Map<String, dynamic> json) => _$QuarterlyGroupFromJson(json);
  Map<String, dynamic> toJson() => _$QuarterlyGroupToJson(this);
}

class QuarterlyGroupRepository extends IRRepository {
  List<QuarterlyGroup> quarterlyGroups = new List<QuarterlyGroup>();
  Lock _lock = new Lock();
  bool _dataFetched = false;
  QuarterlyGroupRepository(UserRepository userRepository) : super(userRepository);

  QuarterlyGroup getQuarterGroupById(int quarterlyGroupId) {
    for (int i = 0; i < quarterlyGroups.length; i++) {
      if (quarterlyGroups[i].id == quarterlyGroupId) {
        return quarterlyGroups[i];
      }
    }
    return null;
  }

  Future<DataResult> getQuarterlyGroups() async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched) {
        result = DataResult.success(quarterlyGroups);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetQuarterlyGroups, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          quarterlyGroups = l.map((model) => QuarterlyGroup.fromJson(model)).toList();
          result.obj = quarterlyGroups;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> getQuarterlyGroup(int quarterlyGroupId) async {
    DataResult result = await webserviceGet(Urls.GetQuarterlyGroupById + quarterlyGroupId.toString(), await getToken(), timeout: 2000);
    if (result.success) {
      Report quarterlyGroup = Report.fromJson(result.obj);
      result.obj = quarterlyGroup;
    }

    return result;
  }
}
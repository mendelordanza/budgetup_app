// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_bill_txn_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecurringBillTxnEntityCollection on Isar {
  IsarCollection<RecurringBillTxnEntity> get recurringBillTxnEntitys =>
      this.collection();
}

const RecurringBillTxnEntitySchema = CollectionSchema(
  name: r'RecurringBillTxnEntity',
  id: 7934311563278913625,
  properties: {
    r'datePaid': PropertySchema(
      id: 0,
      name: r'datePaid',
      type: IsarType.dateTime,
    ),
    r'isPaid': PropertySchema(
      id: 1,
      name: r'isPaid',
      type: IsarType.bool,
    )
  },
  estimateSize: _recurringBillTxnEntityEstimateSize,
  serialize: _recurringBillTxnEntitySerialize,
  deserialize: _recurringBillTxnEntityDeserialize,
  deserializeProp: _recurringBillTxnEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'recurringBill': LinkSchema(
      id: -5865226100651288858,
      name: r'recurringBill',
      target: r'RecurringBillEntity',
      single: true,
      linkName: r'recurringBillTxns',
    )
  },
  embeddedSchemas: {},
  getId: _recurringBillTxnEntityGetId,
  getLinks: _recurringBillTxnEntityGetLinks,
  attach: _recurringBillTxnEntityAttach,
  version: '3.1.0+1',
);

int _recurringBillTxnEntityEstimateSize(
  RecurringBillTxnEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _recurringBillTxnEntitySerialize(
  RecurringBillTxnEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.datePaid);
  writer.writeBool(offsets[1], object.isPaid);
}

RecurringBillTxnEntity _recurringBillTxnEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecurringBillTxnEntity();
  object.datePaid = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.isPaid = reader.readBool(offsets[1]);
  return object;
}

P _recurringBillTxnEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recurringBillTxnEntityGetId(RecurringBillTxnEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recurringBillTxnEntityGetLinks(
    RecurringBillTxnEntity object) {
  return [object.recurringBill];
}

void _recurringBillTxnEntityAttach(
    IsarCollection<dynamic> col, Id id, RecurringBillTxnEntity object) {
  object.id = id;
  object.recurringBill.attach(
      col, col.isar.collection<RecurringBillEntity>(), r'recurringBill', id);
}

extension RecurringBillTxnEntityQueryWhereSort
    on QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QWhere> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecurringBillTxnEntityQueryWhere on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QWhereClause> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecurringBillTxnEntityQueryFilter on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QFilterCondition> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'datePaid',
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'datePaid',
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'datePaid',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'datePaid',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'datePaid',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> datePaidBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'datePaid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> isPaidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaid',
        value: value,
      ));
    });
  }
}

extension RecurringBillTxnEntityQueryObject on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QFilterCondition> {}

extension RecurringBillTxnEntityQueryLinks on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QFilterCondition> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> recurringBill(FilterQuery<RecurringBillEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'recurringBill');
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity,
      QAfterFilterCondition> recurringBillIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'recurringBill', 0, true, 0, true);
    });
  }
}

extension RecurringBillTxnEntityQuerySortBy
    on QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QSortBy> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      sortByDatePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePaid', Sort.asc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      sortByDatePaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePaid', Sort.desc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      sortByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      sortByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }
}

extension RecurringBillTxnEntityQuerySortThenBy on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QSortThenBy> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenByDatePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePaid', Sort.asc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenByDatePaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datePaid', Sort.desc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QAfterSortBy>
      thenByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }
}

extension RecurringBillTxnEntityQueryWhereDistinct
    on QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QDistinct> {
  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QDistinct>
      distinctByDatePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'datePaid');
    });
  }

  QueryBuilder<RecurringBillTxnEntity, RecurringBillTxnEntity, QDistinct>
      distinctByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaid');
    });
  }
}

extension RecurringBillTxnEntityQueryProperty on QueryBuilder<
    RecurringBillTxnEntity, RecurringBillTxnEntity, QQueryProperty> {
  QueryBuilder<RecurringBillTxnEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecurringBillTxnEntity, DateTime?, QQueryOperations>
      datePaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'datePaid');
    });
  }

  QueryBuilder<RecurringBillTxnEntity, bool, QQueryOperations>
      isPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaid');
    });
  }
}

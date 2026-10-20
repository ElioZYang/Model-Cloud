// Run with mongosh authenticated against the admin database.
// Collection names come from the backend's @Document annotations.
{
  const applicationDb = db.getSiblingDB("model_cloud");
  const collections = [
    "bs_model_params",
    "bs_component_parse_meta",
    "bs_component_parse_meta_omc",
  ];

  for (const name of collections) {
    if (applicationDb.getCollectionInfos({ name }).length === 0) {
      const result = applicationDb.createCollection(name);
      if (result.ok !== 1) {
        throw new Error(`Cannot create collection: ${name}`);
      }
      print(`Created: model_cloud.${name}`);
    } else {
      print(`Exists: model_cloud.${name}`);
    }
  }

  // MongoDB creates the _id index itself. The backend uses class names as
  // metadata IDs; do not insert placeholder documents or additional constraints.
  print("MongoDB initialization complete. Existing documents were preserved.");
}

db.createUser(
    {
        user: "athmos",
        pwd: "password",
        roles: [
            {
                role: "readWrite",
                db: "plugin-db"
            }
        ]
    });
db.createCollection('projects');
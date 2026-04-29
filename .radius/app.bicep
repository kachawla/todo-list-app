extension radius 'br:biceptypes.azurecr.io/radius:latest'
extension radiusCompute 'br:biceptypes.azurecr.io/radiuscompute:latest'
extension radiusSecurity 'br:biceptypes.azurecr.io/radiussecurity:latest'
extension radiusData 'br:biceptypes.azurecr.io/radiusdata:latest'

param environment string
@secure()
param password string
@description('The full container image reference to build and push. Must be lowercase.')
param image string

resource todoApp 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'todo-list-app'
  properties: {
    environment: environment
  }
}

resource database 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'mysql'
  properties: {
    application: todoApp.id
    environment: environment
    database: 'todos'
    version: '8.0'
    secretName: dbSecret.name
  }
}

resource dbSecret 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'dbsecret'
  properties: {
    application: todoApp.id
    environment: environment
    data: {
      USERNAME: {
        value: 'todo_list_app_user'
      }
      PASSWORD: {
        value: password
      }
    }
  }
}

resource demoImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'demo-image'
  properties: {
    application: todoApp.id
    environment: environment
    image: image
    build: {
      context: '/app/demo'
    }
  }
}

resource todoContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'todo-list-frontend'
  properties: {
    application: todoApp.id
    environment: environment
    containers: {
      todo: {
        image: demoImage.properties.image
        ports: {
          web: {
            containerPort: 3000
          }
        }
      }
    }
    connections: {
      mysqldb: {
        source: database.id
      }
      demoContainerImage: {
        source: demoImage.id
      }
    }
  }
}

// DEPRECATED: Este archivo y sus consultas han sido reemplazados por la integración con Supabase
// Se mantiene para compatibilidad con código antiguo que aún no ha sido migrado

const String meQuery = r'''
query Me {
  me {
    id
    username
    email
    role {
      name
      description
    }
  }
  centers {
    data {
      id
      attributes {
        name
        category
        species
        ACS
        SIEP
        water
        enterprise {
          data {
            attributes {
              name
              nickname
            }
          }
        }
        cages {
          data {
            id
            attributes {
              name
            }
          }
        }
      }
    }
  }
}
''';

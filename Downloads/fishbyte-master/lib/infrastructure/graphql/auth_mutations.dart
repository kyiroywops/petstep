// DEPRECATED: Este archivo y sus mutaciones han sido reemplazados por la integración con Supabase
// Se mantiene para compatibilidad con código antiguo que aún no ha sido migrado

const loginMutation = r'''
mutation Login($identifier: String!, $password: String!) {
  login(input: { identifier: $identifier, password: $password }) {
    jwt
    user {
      id
      username
      email
    }
  }
}
''';

const registerMutation = r'''
mutation Register($username: String!, $email: String!, $password: String!) {
  register(input: { username: $username, email: $email, password: $password }) {
    jwt
    user {
      id
      username
      email
    }
  }
}
''';

const saveReportMutation = r'''
mutation SAVE_REPORT($data: ReportInput!) {
  createReport(data: $data) {
    data {
      id
    }
  }
}
''';

const uploadImageMutation = r'''
mutation UPLOAD_IMAGE($file: Upload!) {
  upload(file: $file) {
    data {
      id
    }
  }
}
''';



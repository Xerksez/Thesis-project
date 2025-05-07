class AppConfig {
  static const String backendIP = "10.0.2.2"; // Change to your IP if needed
  static const String backendPort = "5159";
  static const String backendChatPort = "5088";

  // S3 Base URL for images
  static const String s3BaseUrl = "https://buildbuddybucket.s3.amazonaws.com";

  // Base URLs
  static String getBaseUrl() => "http://$backendIP:$backendPort";
  static String getChatUrl() => "http://$backendIP:$backendChatPort";

  // API Endpoints
  static String getLoginEndpoint() => "${getBaseUrl()}/api/User/login";
  static String getTeamsEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/teams";
  static String getProfileEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";
  static String getInventoryEndpoint(int addressId) =>
      "${getBaseUrl()}/api/BuildingArticles/address/$addressId";
  static String getTeammatesEndpoint(int teamId) => "${getBaseUrl()}/api/Team/$teamId/users";
    static String getTeammByAddressIdEndpoint(int addressId) => "${getBaseUrl()}/api/Address/$addressId/teammembers";
  static String getChatListEndpoint(int userId) =>
      '${getBaseUrl()}/api/Conversation/user/$userId/conversations';
  static String createConversationEndpoint() => '${getBaseUrl()}/api/Conversation/create';
  
  static String registerEndpoint() => '${getBaseUrl()}/api/User/register';
    static String updateInventoryItemEndpoint(int itemId) =>
      '${getBaseUrl()}/api/BuildingArticles/$itemId';
static String getUpdateInventoryEndpoint(int itemId) =>
    "${getBaseUrl()}/api/BuildingArticles/$itemId";
  static String getAllTeamsEndpoint() => '${getBaseUrl()}/api/Team';
  static String getConversationsEndpoint() => '${getBaseUrl()}/api/Conversation/all';
    static String getAddressInfoEndpoint(int addressId) =>
    "${getBaseUrl()}/api/Address/$addressId";

  static String getRoleInfoEndpoint(int roleId) =>"${getBaseUrl()}/api/Roles/$roleId";
  // Nowe endpointy
  static String exitChatEndpoint(int conversationId, int userId) => 
      '${getBaseUrl()}/api/Chat/exit-chat?conversationId=$conversationId&userId=$userId';
  
  static String unreadCountEndpoint(int conversationId, int userId) =>
      '${getBaseUrl()}/api/Chat/unread-count?conversationId=$conversationId&userId=$userId';

  // Endpoints for Job Actualization
  static String getJobActualizationEndpoint(int jobId) =>
      '${getBaseUrl()}/api/JobActualization/$jobId';
  static String postAddImageEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/add-image';
  static String deleteImageEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/delete-image';
  static String getImagesEndpoint(int jobActualizationId) =>
      '${getBaseUrl()}/api/JobActualization/$jobActualizationId/images';

  // User Endpoints
  static String getUserJobEndpoint(int userId) => '${getBaseUrl()}/api/Job/user/$userId';
  static String postJobActualizationEndpoint() => '${getBaseUrl()}/api/JobActualization';

  static String uploadUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/upload-image";
  static String getUserImageEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId/image";
  static String patchUserEndpoint(int userId) => "${getBaseUrl()}/api/User/$userId";

  // New Endpoint for Job Actualization by User ID and Address
  static String getUserJobActualizationByAddress(int userId, int addressId) =>
      '${getBaseUrl()}/api/Job/user/$userId/address/$addressId';
}

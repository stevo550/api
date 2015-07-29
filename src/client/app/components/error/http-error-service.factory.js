(function() {
  'use strict';

  angular.module('app.components')
    .factory('HttpErrorService', HttpErrorServiceFactory);

  /** @ngInject */
  function HttpErrorServiceFactory() {
    var service = {
      logError: logError,
      clearError: clearError,
      errors: [],
      lastError: null
    };

    return service;

    function logError(error) {
      var errorCode = error.status;
      service.errors[errorCode] = typeof service.errors[errorCode] === 'undefined' ? 1 : service.errors[errorCode] + 1;
      service.lastError = error;
    }

    function clearError() {
      if (service.lastError !== null) {
        service.errors[service.lastError.status] = null;
        service.lastError = null;
      }
    }
  }
})();

(function() {
  'use strict';

  angular.module('app.components')
    .run(appRun);

  /** @ngInject */
  function appRun($rootScope, $state, HttpErrorService, jQuery) {
    activate();

    function activate() {
    }

    $rootScope.$on('$stateChangeStart', function(toState, toParams) {
      console.log('httpError::$stateChangeStart');
    });

    // catch any error in resolve in state
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
      console.log('httpError::$stateChangeError');

      // Increment the error counter for the status code
      // var errorArray = (SessionService.errors === undefined) ? [] : SessionService.errors;
      // errorArray[error.status] = (errorArray[error.status] === undefined) ? 1 : errorArray[error.status] + 1;
      // SessionService.errors = errorArray;
      // SessionService.lastError = error.status;
      HttpErrorService.logError(error);

      event.preventDefault();

      console.log(HttpErrorService.errors);
      $state.go('error', { error: error, errorCount: HttpErrorService.errors });
    });

    $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
      console.log('httpError::$stateChangeSuccess');

      // Reset the error counter on success
      if (toParams.error === undefined && fromParams.error === undefined && HttpErrorService.lastError !== undefined) {
        // HttpErrorService.errors.splice(HttpErrorService.errors.indexOf(HttpErrorService.lastError, 1));
        // HttpErrorService.lastError = null;
        HttpErrorService.clearError();
      }

      jQuery('html, body').animate({scrollTop: 0}, 200);
    });

    $rootScope.$on('$stateNotFound', function(event) {
      console.log('httpError::$stateNotFound');
      event.preventDefault();
    });
  }
})();

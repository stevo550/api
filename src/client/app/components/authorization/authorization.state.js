(function() {
  'use strict';

  angular.module('app.components')
    .run(appRun);

  /** @ngInject */
  function appRun($rootScope, $state, AuthenticationService, AuthorizationService, logger, jQuery, SessionService) {
    activate();

    function activate() {
    }

    // Authorzation and Authentication when switching Pages.
    $rootScope.$on('$stateChangeStart', function(toState, toParams) {
      // If an unauthenticated user attempts to navigate within app, return them to login
      // if (!AuthenticationService.isAuthenticated()) {
      //  logger.error('Improper authentication, redirecting to login page.');
      //  $state.transitionTo('public.login');
      // }
      // vm.authorizedRoles = next.data.authorizedRoles;
      // if (!AuthorizationService.isAuthorized( vm.authorizedRoles)) {
      // if (AuthorizationService.isAuthenticated()) {
      //   $state.transitionTo('base.errors.unauthorized');
      // } else {
      //   $state.transitionTo('errors.sorry');
      // }
      // }
    });

    // catch any error in resolve in state
    $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
      // Increment the error counter for the status code
      var errorArray = (SessionService.errorCount === undefined) ? [] : SessionService.errorCount;
      errorArray[error.status] = (errorArray[error.status] === undefined) ? 1 : errorArray[error.status] + 1;
      SessionService.errorCount = errorArray;
      SessionService.lastError = error.status;

      // If a 401 is encountered during a state change, then kick the user back to the login
      if (401 === error.status) {
        if (AuthorizationService.isAuthenticated()) {
          $state.transitionTo('logout');
        } else if ('login' !== toState.name) {
          $state.transitionTo('login');
        }
      } else if (403 === error.status) {
        logger.error('An error has prevent the page from loading. Please try again later.');
        if ('dashboard' !== fromState.name) {
          $state.transitionTo('dashboard');
        }
      } else {
        $state.go('error', { error: error, errorCount: SessionService.errorCount });
        logger.error('Unhandled State Change Error occurred: ' + (error.statusText || error.message));
      }

      event.preventDefault();
    });

    $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
      // Reset the error counter on success
      if (toParams.error === undefined && fromParams.error === undefined && SessionService.lastError !== undefined) {
        SessionService.errorCount.splice(SessionService.errorCount.indexOf(SessionService.lastError, 1));
        SessionService.lastError = null;
      }

      jQuery('html, body').animate({scrollTop: 0}, 200);
    });

    $rootScope.$on('$stateNotFound', function(event) {
      event.preventDefault();
      // if (AuthorizationService.isAuthenticated()) {
      //  $state.transitionTo('base.errors.not-found');
      // } else {
      //  $state.transitionTo('errors.sorry');
      //     }
    });
  }
})();

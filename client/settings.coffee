usernameFormMessages = new FormMessages()
passwordFormMessages = new FormMessages()
passwordReadyForValidation = false
passwordConfirmationReadyForValidation = false
usernameReadyForValidation = false

resetUsernameForm = ->
  usernameFormMessages.resetMessages()
  usernameReadyForValidation = false

resetPasswordForm = ->
  passwordFormMessages.resetMessages()
  $('#current-password').val('')
  $('#new-password').val('')
  $('#new-password-confirmation').val('')
  passwordReadyForValidation = false
  passwordConfirmationReadyForValidation = false

# Reset forms when settings page becomes active
Deps.autorun ->
  if Session.get 'settingsActive'
    resetUsernameForm()
    resetPasswordForm()

Template.settings.person = ->
  Meteor.person()

# Username settings
Template.settingsUsername.events =
  'click button.set-username': (event, template) ->
    usernameReadyForValidation = true
    usernameFormMessages.resetMessages()
    event.preventDefault()
    username = $('#username').val()
    try
      User.validateUsername username, 'username'
      usernameFormMessages.resetMessages 'username'
      Meteor.call 'set-username', username, (error) ->
        if error
          usernameFormMessages.setError error
        else
          resetUsernameForm()
          usernameFormMessages.setInfoMessage "Username set successfully"
    catch error
      usernameFormMessages.setError error

    return # Make sure CoffeeScript does not return anything

  'blur input#username': (event, template) ->
    usernameReadyForValidation = true
    username = $('#username').val()
    validateUsername username, 'username'

    return # Make sure CoffeeScript does not return anything

  'keyup input#username': (event, template) ->
    username = $('#username').val()
    validateUsername username, 'username'

    return # Make sure CoffeeScript does not return anything

Template.settings.usernameExists = ->
  !!Meteor.person().user?.username

Template.settingsUsername.message = (field, options) ->
  field = null unless options
  usernameFormMessages.get field

Template.settingsUsername.isValid = (field, options) ->
  field = null unless options
  !usernameFormMessages.getErrorMessage field

validateUsername = (username, messageField) ->
  return unless usernameReadyForValidation
  try
    User.validateUsername username, messageField
    usernameFormMessages.resetMessages messageField
  catch error
    usernameFormMessages.setError error

# Password settings
Template.settingsPassword.events =
  'click button.change-password': (event, template) ->
    passwordReadyForValidation = true
    passwordConfirmationReadyForValidation = true
    passwordFormMessages.resetMessages()
    event.preventDefault()
    currentPassword = $('#current-password').val()
    newPassword = $('#new-password').val()
    newPasswordConfirmation = $('#new-password-confirmation').val()

    changePassword currentPassword, newPassword, newPasswordConfirmation, (error) ->
      if error
        passwordFormMessages.setError error
      else
        resetPasswordForm()
        passwordFormMessages.setInfoMessage "Password changed sucessfully"

    return # Make sure CoffeeScript does not return anything

  'blur input#new-password': (event, template) ->
    passwordReadyForValidation = true
    newPassword = $('#new-password').val()
    validatePassword newPassword, "new-password"

    return # Make sure CoffeeScript does not return anything

  'focus input#new-password-confirmation': (event, template) ->
    passwordConfirmationReadyForValidation = true

    return # Make sure CoffeeScript does not return anything

  'keyup input#new-password': (event, template) ->
    newPassword = $('#new-password').val()
    newPasswordConfirmation = $('#new-password-confirmation').val()
    validatePassword newPassword, "new-password"
    validatePasswordConfirmation newPassword, newPasswordConfirmation, "new-password-confirmation"

    return # Make sure CoffeeScript does not return anything

  'keyup input#new-password-confirmation': (event, template) ->
    newPassword = $('#new-password').val()
    newPasswordConfirmation = $('#new-password-confirmation').val()
    validatePasswordConfirmation newPassword, newPasswordConfirmation, "new-password-confirmation"

    return # Make sure CoffeeScript does not return anything

Template.settingsPassword.message = (field, options) ->
  field = null unless options
  passwordFormMessages.get field

Template.settingsPassword.isValid = (field, options) ->
  field = null unless options
  !passwordFormMessages.getErrorMessage field

validatePassword = (newPassword, messageField) ->
  return unless passwordReadyForValidation
  try
    User.validatePassword newPassword, messageField
    passwordFormMessages.resetMessages messageField
  catch error
    passwordFormMessages.setError error

validatePasswordConfirmation = (newPassword, newPasswordConfirmation, messageField) ->
  return unless passwordConfirmationReadyForValidation
  if newPassword isnt newPasswordConfirmation
    error = new FormError 400, "Passwords do not match.", messageField
    passwordFormMessages.setError error
  else
    passwordFormMessages.resetMessages messageField

changePassword = (currentPassword, newPassword, newPasswordConfirmation, callback) ->
  try
    User.validatePassword newPassword, "new-password"
    validatePasswordConfirmation newPassword, newPasswordConfirmation, "new-password-confirmation"
    Accounts.changePassword currentPassword, newPassword, callback
  catch error
    callback error


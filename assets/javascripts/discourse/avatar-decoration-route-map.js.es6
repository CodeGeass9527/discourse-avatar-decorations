export default function() {
    this.route('preferences.account', function() {
      this.route('avatar-decoration');
    });
    
    this.route('adminPlugins', function() {
      this.route('avatar-decorations');
      this.route('avatar-decoration-groups');
    });
  }
  
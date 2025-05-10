import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "extend-for-avatar-decorations",
  before: "inject-discourse-objects",
  
  initialize() {
    withPluginApi("0.8.31", api => {
      api.modifyClass("model:user", {
        hasAvatarDecoration: function() {
          return this.get("avatar_decoration_url") !== undefined;
        }.property("avatar_decoration_url")
      });
    });
  }
};

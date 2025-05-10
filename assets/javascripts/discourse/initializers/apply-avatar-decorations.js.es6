import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "apply-avatar-decorations",

  initialize() {
    withPluginApi("0.8.31", api => {
      api.decorateWidget("avatar", dec => {
        const attrs = dec.attrs;
        if (!attrs.user || !attrs.user.avatar_decoration_url) {
          return;
        }
        
        return dec.h("div.avatar-decoration", {
          attributes: {
            style: `background-image: url('${attrs.user.avatar_decoration_url}')`
          }
        });
      });
    });
  }
};

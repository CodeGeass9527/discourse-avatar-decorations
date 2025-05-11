import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { alias } from "@ember/object/computed";
import I18n from "I18n";

export default {
  name: "badge-avatar-frame-setup",
  initialize() {
    withPluginApi("0.8.31", (api) => {
      // 扩展徽章编辑界面，添加头像框设置
      api.modifyClass("controller:admin-badges-show", {
        avatarFrameEnabled: alias("model.avatar_frame_enabled"),
        avatarFrameUrl: alias("model.avatar_frame_url"),

        actions: {
          save() {
            // 注入你插件管理的数据（比如从组件传来的值）
            const extraAttrs = {
              avatar_frame_url: this.get("model.avatar_frame_url"),
              avatar_frame_display: this.get("model.avatar_frame_display"),
            };

            // 合并到 `model`，这样请求才会带上
            this.model.setProperties(extraAttrs);

            // 调用原有 save 方法（super 可能不行，这里直接复用内容）
            this._super(...arguments);
          },

          uploadAvatarFrame() {
            const fileInput = document.createElement("input");
            fileInput.type = "file";
            fileInput.accept = "image/*";

            fileInput.addEventListener("change", () => {
              const file = fileInput.files[0];

              if (file) {
                const formData = new FormData();
                formData.append("file", file);

                ajax(
                  `/admin/badges/${this.get("model.id")}/avatar_frame/upload`,
                  {
                    type: "POST",
                    processData: false,
                    contentType: false,
                    data: formData,
                  }
                )
                  .then((result) => {
                    this.set("avatarFrameUrl", result.url);
                  })
                  .catch(popupAjaxError);
              }
            });

            fileInput.click();
          },
        },
      });

      // 装饰帖子头像
      api.decorateWidget("post-avatar::after", (helper) => {
        const attrs = helper.attrs;

        if (attrs.user_id) {
          const user = attrs.user;

          if (user && user.avatar_frame_url) {
            return helper.h("div.badge-avatar-frame", {
              attributes: {
                style: `background-image: url('${user.avatar_frame_url}')`,
              },
            });
          }
        }
      });
    });
  },
};

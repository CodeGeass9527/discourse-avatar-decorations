import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  dialog: service(),
  
  init() {
    this._super(...arguments);
    this.loadDecorations();
  },
  
  loadDecorations() {
    this.set("loading", true);
    
    ajax("/admin/avatar_decorations")
      .then(result => {
        this.set("decorations", result.decorations);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("loading", false);
      });
  },
  
  @action
  newDecoration() {
    this.dialog.modal({
      title: I18n.t("avatar_decorations.admin.add_new"),
      modalClass: "avatar-decoration-modal",
      model: {
        isNew: true
      },
      component: "admin-avatar-decoration-form",
      afterClosed: () => {
        this.loadDecorations();
      }
    });
  },
  
  @action
  editDecoration(decoration) {
    this.dialog.modal({
      title: I18n.t("avatar_decorations.admin.edit"),
      modalClass: "avatar-decoration-modal",
      model: {
        isNew: false,
        decoration
      },
      component: "admin-avatar-decoration-form",
      afterClosed: () => {
        this.loadDecorations();
      }
    });
  },
  
  @action
  deleteDecoration(decoration) {
    this.dialog.confirm({
      message: I18n.t("avatar_decorations.admin.confirm_delete"),
      didConfirm: () => {
        ajax(`/admin/avatar_decorations/${decoration.id}`, {
          type: "DELETE"
        })
          .then(() => {
            this.loadDecorations();
          })
          .catch(popupAjaxError);
      }
    });
  }
});

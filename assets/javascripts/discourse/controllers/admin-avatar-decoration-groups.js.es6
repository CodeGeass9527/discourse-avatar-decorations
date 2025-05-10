import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  dialog: service(),
  
  init() {
    this._super(...arguments);
    this.loadGroups();
    this.loadDecorations();
  },
  
  loadGroups() {
    this.set("loadingGroups", true);
    
    ajax("/admin/avatar_decoration_groups")
      .then(result => {
        this.set("groups", result.groups);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("loadingGroups", false);
      });
  },
  
  loadDecorations() {
    ajax("/admin/avatar_decorations")
      .then(result => {
        this.set("availableDecorations", result.decorations);
      })
      .catch(popupAjaxError);
  },
  
  @action
  createGroup() {
    this.dialog.modal({
      title: I18n.t("avatar_decorations.admin.create_group"),
      modalClass: "avatar-decoration-group-modal",
      model: {
        isNew: true,
        decorations: this.availableDecorations
      },
      component: "admin-avatar-decoration-group-form",
      afterClosed: () => {
        this.loadGroups();
      }
    });
  },
  
  @action
  editGroup(group) {
    ajax(`/admin/avatar_decoration_groups/${group.id}`)
      .then(result => {
        this.dialog.modal({
          title: I18n.t("avatar_decorations.admin.edit_group"),
          modalClass: "avatar-decoration-group-modal",
          model: {
            isNew: false,
            group: result.group,
            decorations: this.availableDecorations
          },
          component: "admin-avatar-decoration-group-form",
          afterClosed: () => {
            this.loadGroups();
          }
        });
      })
      .catch(popupAjaxError);
  },
  
  @action
  deleteGroup(group) {
    this.dialog.confirm({
      message: I18n.t("avatar_decorations.admin.confirm_delete_group"),
      didConfirm: () => {
        ajax(`/admin/avatar_decoration_groups/${group.id}`, {
          type: "DELETE"
        })
          .then(() => {
            this.loadGroups();
          })
          .catch(popupAjaxError);
      }
    });
  },
  
  @action
  manageUsers(group) {
    this.dialog.modal({
      title: I18n.t("avatar_decorations.admin.manage_users", { name: group.name }),
      modalClass: "avatar-decoration-group-users-modal",
      model: {
        group
      },
      component: "admin-avatar-decoration-group-users",
      afterClosed: () => {
        this.loadGroups();
      }
    });
  }
});

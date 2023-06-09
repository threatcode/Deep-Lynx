<template>
  <div>
    <error-banner :message="errorMessage"></error-banner>
    <success-banner :message="inviteSuccess"></success-banner>
    <v-data-table
      :headers="headers"
      :items="users"
      sort-by="calories"
      class="elevation-1"
    >

      <template v-slot:top>
        <v-toolbar flat color="white">
          <v-toolbar-title>{{$t("home.containerUsersDescription")}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <invite-user-to-container-dialog :containerID="containerID" @userInvited="flashSuccess"></invite-user-to-container-dialog>
        </v-toolbar>
      </template>
      <template v-slot:[`item.role`]="{ item }">
        <div v-if="$store.getters.activeContainer.created_by === item.id">Owner</div>
        <div v-else>{{retrieveUserRole(item)}} {{item.role}}</div>
      </template>

      <template v-slot:[`item.actions`]="{ item }">
        <v-tooltip top>
          <template v-slot:activator="{on, attrs}">
            <v-icon
                v-if="$store.getters.activeContainer.created_by !== item.id || item.id !== $auth.CurrentUser().id"
                small
                class="mr-2"
                @click="editUser(item)"
                v-bind="attrs"
                v-on="on"
            >
              mdi-pencil
            </v-icon>
          </template>
          <span>{{$t('home.editUser')}}</span>
        </v-tooltip>

        <v-tooltip top>
          <template v-slot:activator="{on, attrs}">
            <v-icon
                v-if="$store.getters.activeContainer.created_by !== item.id || item.id !== $auth.CurrentUser().id"
                small
                class="mr-2"
                @click="deleteUser(item)"
                v-bind="attrs"
                v-on="on"
            >
              mdi-account-multiple-minus
            </v-icon>
          </template>
          <span>{{$t('home.deleteUser')}}</span>
        </v-tooltip>

      </template>
    </v-data-table>
    
    <v-dialog v-model="editDialog" max-width="900px" @click:outside="clear()">
      <v-card class="pt-1 pb-3 px-2">
        <v-card-title>
          <span class="headline text-h3">{{$t("containerUsers.editUserTitle")}}</span>
        </v-card-title>
        <v-card-text>
          <v-row>
            <v-col v-if="toEdit !== null" :cols="12">
              <success-banner :message="successMessage"></success-banner>
              <v-form
                ref="form"
                lazy-validation
              >
                <v-row>
                  <v-col :cols="6">
                    <v-text-field
                      v-model="toEdit.display_name"
                      :label="$t('containerUsers.name')"
                      required
                      disabled
                    ></v-text-field>
                    <v-select @input="assignRole" v-model="selectedRole" :items="roles" :label="$t('users.role')"></v-select>
                  </v-col>

                  <v-col :cols="6">
                    <v-text-field
                      v-model="toEdit.email"
                      :label="$t('containerUsers.email')"
                      required
                      disabled
                    ></v-text-field>
                  </v-col>
                </v-row>
              </v-form>
            </v-col>
          </v-row>
          <v-row>
          </v-row>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text @click="editDialog = false">{{$t("containerUsers.close")}}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script lang="ts">
  import {Component, Prop, Vue} from 'vue-property-decorator'
  import {UserT} from "@/auth/types";
  import {AssignRolePayloadT} from "@/api/types";
  import InviteUserToContainerDialog from "@/components/accessManagement/inviteUserToContainerDialog.vue";
  @Component({
    components: {InviteUserToContainerDialog}
  })
  export default class ContainerUsers extends Vue {
    @Prop({required: true})
    readonly containerID!: string;

    dialog = false
    editDialog = false
    users: UserT[] = []
    newUser = {
      display_name: "",
      email: "",
      password: "",
      identity_provider: "username_password"
    }
    toEdit: UserT | null = null
    selectedRole = ""
    roles = ["user", "editor", "admin"]
    errorMessage = ''
    successMessage = ''
    inviteSuccess = ''

    get headers() {
      return  [
        { text: this.$t("containerUsers.name"), value: 'display_name' },
        { text: this.$t("containerUsers.email"), value: 'email'},
        { text: this.$t("containerUsers.role"), value: 'role'},
        { text: this.$t("containerUsers.actions"), value: 'actions', sortable: false }
      ]
    }

    mounted() {
      this.refreshUsers()
    }

    refreshUsers() {
      this.$client.listUsersInContainer(this.containerID)
        .then(users => {
          this.users = users
        })
        .catch(e => this.errorMessage = e)
    }

    clearNewUser() {
      this.dialog = false
      this.newUser = {
        display_name: "",
        email: "",
        password: "",
        identity_provider: "username_password"
      }
    }

    retrieveUserRole(user: UserT) {
        this.$client.retrieveUserRoles(this.containerID, user.id)
            .then(roles => {
              if(roles.length > 0) {
                user.role = roles[0]
              }

              // needed in order to get the user object to update with the roles
              this.$forceUpdate()
            })
            .catch(e => this.errorMessage = e)
    }


    retrieveUserRoles(user: UserT) {
      if(this.toEdit) {
        this.$client.retrieveUserRoles(this.containerID, user.id)
        .then(roles => {
          if(roles.length > 0) {
            this.selectedRole = roles[0]
          }

        })
        .catch(e => this.errorMessage = e)
      }
    }

    editUser(user: UserT) {
        this.editDialog = true
        this.toEdit = user
        this.retrieveUserRoles(user)
    }

    deleteUser(user: UserT) {
      this.$client.removeAllUserRoles(this.containerID, user.id!)
          .then(() => {
            this.refreshUsers();
          })
          .catch(e => this.errorMessage = e)
    }

    flashSuccess(){
      this.inviteSuccess = this.$t('containerUsers.successfullyInvited') as string
    }

    assignRole(role: string) {
      if(this.toEdit ) {
        const assignRolePayload: AssignRolePayloadT = {
          user_id: this.toEdit.id,
          container_id: this.containerID,
          role_name: role
        }

        this.$client.assignRoleToUser(this.containerID, assignRolePayload)
        .then(() => {
          this.successMessage = this.$t('containerUsers.successfullySetRole') as string

          setTimeout(() => {
            this.successMessage = ''
          }, 6000)

          if(this.toEdit){
            this.retrieveUserRoles(this.toEdit)
          }
        })
        .catch(e => this.errorMessage = e)
      }

    }

    clear() {
      this.toEdit = null
      this.selectedRole = ""
    }
  }
</script>

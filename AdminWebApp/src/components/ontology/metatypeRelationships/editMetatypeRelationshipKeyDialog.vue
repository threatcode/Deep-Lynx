<template>
  <v-dialog v-model="dialog" @click:outside="dialog = false" max-width="60%">
    <template v-slot:activator="{ on }">
      <v-icon
          v-if="icon"
          small
          class="mr-2"
          v-on="on"
      >mdi-pencil</v-icon>
      <v-btn v-if="!icon" color="primary" dark class="mt-2" v-on="on">{{$t("editMetatypeRelationshipKey.editMetatypeKey")}}</v-btn>
    </template>

    <v-card v-if="selectedMetatypeRelationshipKey">
      <v-card-text>
        <v-container>
          <error-banner :message="errorMessage"></error-banner>
          <span class="headline">{{ $t('editMetatypeRelationshipKey.edit') }} {{ selectedMetatypeRelationshipKey.name }}</span>
          <v-row>
            <v-col v-if="comparisonRelationshipKey" :cols="6">

              <v-form class="disabled">
                <v-text-field
                    v-model="comparisonRelationshipKey.name"
                    disabled
                >
                  <template v-slot:label>{{$t('editMetatypeKey.name')}} <small style="color:red" >*</small></template>
                </v-text-field>

                <v-text-field
                    v-model="comparisonRelationshipKey.property_name"
                    disabled
                >
                  <template v-slot:label>{{$t('editMetatypeKey.propertyName')}} <small style="color:red" >*</small></template>
                  <template slot="append-outer"><info-tooltip :message="$t('ontology.propertyName')"></info-tooltip> </template>
                </v-text-field>
                <v-select
                    v-model="comparisonRelationshipKey.data_type"
                    :items="dataTypes"
                    disabled
                >
                  <template v-slot:label>{{$t('editMetatypeKey.dataType')}} <small style="color:red" >*</small></template>
                </v-select>
                <v-checkbox
                    disabled
                    v-model="comparisonRelationshipKey.required"
                >
                  <template v-slot:label>{{$t('editMetatypeKey.required')}} <small style="color:#ff0000" >*</small></template>
                </v-checkbox>
                <v-textarea
                    v-model="comparisonRelationshipKey.description"
                    :rows="2"
                    disabled
                >
                  <template v-slot:label>{{$t('editMetatypeKey.description')}} <small style="color:#ff0000" >*</small></template>
                </v-textarea>

                <h3>{{$t('editMetatypeKey.validation')}}</h3>
                <v-text-field
                    v-model="comparisonRelationshipKey.validation.regex"
                    disabled
                    :label="$t('editMetatypeKey.regex')"
                >
                  <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeKey.regexHelp')"></info-tooltip></template>
                </v-text-field>
                <v-text-field
                    v-model.number="comparisonRelationshipKey.validation.max"
                    type="number"
                    :label="$t('editMetatypeKey.max')"
                    disabled
                >
                  <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeKey.maxHelp')"></info-tooltip></template>
                </v-text-field>
                <v-text-field
                    v-model.number="comparisonRelationshipKey.validation.min"
                    disabled
                    type="number"
                    :label="$t('editMetatypeKey.min')"
                >
                  <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeKey.minHelp')"></info-tooltip></template>
                </v-text-field>



                <!-- default value and options should be comboboxes when set to enumeration -->
                <div v-if="comparisonRelationshipKey.data_type === 'enumeration'" >
                  <v-combobox
                      v-model="comparisonRelationshipKey.default_value"
                      multiple
                      chips
                      clearable
                      disabled
                      deletable-chips
                  ></v-combobox>
                </div>

                <div v-if="comparisonRelationshipKey.data_type !== 'enumeration'" >
                  <v-text-field
                      v-if="comparisonRelationshipKey.data_type === 'number'"
                      v-model="comparisonRelationshipKey.default_value"
                      type="number"
                      disabled
                      :label="$t('editMetatypeKey.defaultValue')"
                  ></v-text-field>
                  <v-select
                      v-else-if="comparisonRelationshipKey.data_type === 'boolean'"
                      v-model="comparisonRelationshipKey.default_value"
                      disabled
                      :label="$t('editMetatypeKey.defaultValue')"
                      :items="booleanOptions"
                      required
                  >
                  </v-select>
                  <v-text-field
                      v-else
                      disabled
                      v-model="comparisonRelationshipKey.default_value"
                      :label="$t('editMetatypeKey.defaultValue')"
                  ></v-text-field>
                </div>

                <v-combobox
                    v-model="comparisonRelationshipKey.options"
                    :label="$t('editMetatypeKey.options')"
                    multiple
                    clearable
                    disabled
                    chips
                    deletable-chips
                ></v-combobox>
              </v-form>
            </v-col>

            <v-col :cols="(comparisonRelationshipKey) ? 6 : 12">
              <v-form
                  ref="form"
                  v-model="formValid"
              >
                <v-text-field
                    v-model="selectedMetatypeRelationshipKey.name"
                    :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.name !== comparisonRelationshipKey.name) ? 'edited-field' : ''"
                    :rules="[v => !!v || $t('editMetatypeRelationshipKey.nameRequired')]"
                >
                  <template v-slot:label>{{$t('editMetatypeRelationshipKey.name')}} <small style="color:red" >*</small></template>
                </v-text-field>

                <v-text-field
                    v-model="selectedMetatypeRelationshipKey.property_name"
                    :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.property_name !== comparisonRelationshipKey.property_name) ? 'edited-field' : ''"
                    :rules="[v => !!v || $t('editMetatypeRelationshipKey.propertyNameRequired')]"
                    required
                >
                  <template v-slot:label>{{$t('editMetatypeRelationshipKey.propertyName')}} <small style="color:red" >*</small></template>
                </v-text-field>
                <v-select
                    v-model="selectedMetatypeRelationshipKey.data_type"
                    :items="dataTypes"
                    @change="selectedMetatypeRelationshipKey.default_value = undefined"
                    :rules="[v => !!v || $t('editMetatypeRelationshipKey.dataTypeRequired')]"
                    :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.data_type !== comparisonRelationshipKey.data_type) ? 'edited-field' : ''"
                    required
                >
                  <template v-slot:label>{{$t('editMetatypeRelationshipKey.dataType')}} <small style="color:red" >*</small></template>
                </v-select>
                <v-checkbox
                    v-model="selectedMetatypeRelationshipKey.required"
                >
                  <template v-slot:label>{{$t('editMetatypeRelationshipKey.required')}}</template>
                </v-checkbox>
                <v-textarea
                    v-model="selectedMetatypeRelationshipKey.description"
                    :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.description !== comparisonRelationshipKey.description) ? 'edited-field' : ''"
                    :rows="2"
                    :rules="[v => !!v || $t('editMetatypeRelationshipKey.descriptionRequired')]"
                >
                  <template v-slot:label>{{$t('editMetatypeRelationshipKey.description')}} <small style="color:#ff0000" >*</small></template>
                </v-textarea>

                <div v-if="selectedMetatypeRelationshipKey.validation">
                  <h3>{{$t('editMetatypeRelationshipKey.validation')}}</h3>
                  <v-text-field
                      v-model="selectedMetatypeRelationshipKey.validation.regex"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.validation.regex !== comparisonRelationshipKey.validation.regex) ? 'edited-field' : ''"
                      :label="$t('editMetatypeRelationshipKey.regex')"
                  >
                    <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeRelationshipKey.regexHelp')"></info-tooltip></template>
                  </v-text-field>
                  <v-text-field
                      v-model.number="selectedMetatypeRelationshipKey.validation.max"
                      :disabled="selectedMetatypeRelationshipKey.validation.regex === ''"
                      type="number"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.validation.max !== comparisonRelationshipKey.validation.max) ? 'edited-field' : ''"
                      :label="$t('editMetatypeRelationshipKey.max')"
                  >
                    <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeRelationshipKey.maxHelp')"></info-tooltip></template>
                  </v-text-field>
                  <v-text-field
                      v-model.number="selectedMetatypeRelationshipKey.validation.min"
                      :disabled="selectedMetatypeRelationshipKey.validation.regex === ''"
                      type="number"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.validation.min !== comparisonRelationshipKey.validation.min) ? 'edited-field' : ''"
                      :label="$t('editMetatypeRelationshipKey.min')"
                  >
                    <template slot="append-outer"> <info-tooltip :message="$t('editMetatypeRelationshipKey.minHelp')"></info-tooltip></template>
                  </v-text-field>
                </div>

                <!-- default value and options should be comboboxes when set to enumeration -->
                <div v-if="selectedMetatypeRelationshipKey.data_type === 'enumeration'" >
                  <v-combobox
                      v-model="selectedMetatypeRelationshipKey.default_value"
                      multiple
                      clearable
                      deletable-chips
                      chips
                  ></v-combobox>

                  <v-combobox
                      v-model="selectedMetatypeRelationshipKey.options"
                      :label="$t('editMetatypeRelationshipKey.options')"
                      multiple
                      clearable
                      deletable-chips
                      chips
                  >
                    <template slot="append-outer"><info-tooltip :message="$t('ontology.optionsHelp')"></info-tooltip> </template>
                  </v-combobox>
                </div>

                <div v-if="selectedMetatypeRelationshipKey.data_type !== 'enumeration'" >
                  <v-text-field
                      v-if="selectedMetatypeRelationshipKey.data_type === 'number'"
                      v-model="selectedMetatypeRelationshipKey.default_value"
                      type="number"
                      :label="$t('editMetatypeRelationshipKey.defaultValue')"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.default_value !== comparisonRelationshipKey.default_value) ? 'edited-field' : ''"
                  ></v-text-field>
                  <v-select
                      v-else-if="selectedMetatypeRelationshipKey.data_type === 'boolean'"
                      v-model="selectedMetatypeRelationshipKey.default_value"
                      :label="$t('editMetatypeRelationshipKey.defaultValue')"
                      :items="booleanOptions"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.data_type !== comparisonRelationshipKey.data_type) ? 'edited-field' : ''"
                      required
                  >
                  </v-select>
                  <v-text-field
                      v-else
                      v-model="selectedMetatypeRelationshipKey.default_value"
                      :label="$t('editMetatypeRelationshipKey.defaultValue')"
                      :class="(comparisonRelationshipKey && selectedMetatypeRelationshipKey.default_value !== comparisonRelationshipKey.default_value) ? 'edited-field' : ''"
                  ></v-text-field>
                </div>

              </v-form>
              <p><span style="color:red">*</span> = {{$t('editMetatypeRelationshipKey.requiredField')}}</p>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>

      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="blue darken-1" text @click="dialog = false" >{{$t("editMetatypeRelationshipKey.cancel")}}</v-btn>
        <v-btn color="blue darken-1" :disabled="!formValid" text @click="editMetatypeKey()">{{$t("editMetatypeRelationshipKey.save")}}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts">
import {Component, Prop, Watch, Vue} from 'vue-property-decorator'
import {MetatypeRelationshipKeyT, MetatypeRelationshipT} from "../../../api/types";

@Component
export default class EditMetatypeRelationshipKeyDialog extends Vue {
  @Prop({required: true})
  metatypeRelationship!: MetatypeRelationshipT;

  @Prop({required: true})
  metatypeRelationshipKey!: MetatypeRelationshipKeyT;

  @Prop({required: false, default: undefined})
  comparisonRelationshipKey!: MetatypeRelationshipKeyT | undefined;

  @Prop({required: false})
  readonly icon!: boolean

  errorMessage = ""
  dialog = false
  formValid = false
  selectedMetatypeRelationshipKey: MetatypeRelationshipKeyT | null  = null
  dataTypes = ["number", "number64", "float", "float64", "date", "string", "boolean", "enumeration", "file"]
  booleanOptions = [true, false]

  @Watch('dialog', {immediate: true})
  onDialogChange() {
    if(this.dialog){
      this.selectedMetatypeRelationshipKey = JSON.parse(JSON.stringify(this.metatypeRelationshipKey))

      if(this.selectedMetatypeRelationshipKey && !this.selectedMetatypeRelationshipKey.validation) {
        this.selectedMetatypeRelationshipKey.validation = {regex: "", min: 0, max: 0}
      }
    }
  }

  mounted() {
    // have to do this to avoid mutating properties
    this.selectedMetatypeRelationshipKey = JSON.parse(JSON.stringify(this.metatypeRelationshipKey))

    if(this.selectedMetatypeRelationshipKey && !this.selectedMetatypeRelationshipKey.validation) {
      this.selectedMetatypeRelationshipKey.validation = {regex: "", min: 0, max: 0}
    }
  }

  editMetatypeKey() {
    if(this.selectedMetatypeRelationshipKey) {
      this.selectedMetatypeRelationshipKey.container_id = this.metatypeRelationship.container_id;
      this.$client.updateMetatypeRelationshipKey(this.metatypeRelationship.container_id,this.metatypeRelationship.id!, this.selectedMetatypeRelationshipKey?.id!, this.selectedMetatypeRelationshipKey)
          .then(result => {
            if(!result) {
              this.errorMessage = this.$t('editMetatypeRelationshipKey.errorUpdatingAPI') as string
            } else {
              this.dialog = false
              this.$emit('metatypeKeyEdited')
            }
          })
          .catch(e => this.errorMessage = this.$t('editMetatypeRelationshipKey.errorUpdatingAPI') as string + e)
    }
  }
}
</script>

<style lang="scss">
.disabled input {
  color: black !important;
}

.disabled textarea {
  color: black !important;
}

.disabled .v-select__selection{
  color: black !important;
}

.edited-field {
  input {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  textarea {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  .v-select__slot {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }

  .v-select__selection {
    background: #CD7F32;
    color: white !important;
    box-shadow: -5px 0 0 #CD7F32;
  }
}
</style>

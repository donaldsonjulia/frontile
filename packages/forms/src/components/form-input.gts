import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { concat } from '@ember/helper';
import { on } from '@ember/modifier';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import FormField from './form-field';

export interface FormInputArgs {
  /**
   * The value to be used in the input.
   * You must also pass `onChange` or `onInput` to update its value.
   */
  value: string | undefined;

  /**
   * The input type
   * @defaultValue 'text'
   */
  type?: string;

  /** The group label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /** If the form has been submitted, used to force displaying errors */
  hasSubmitted?: boolean;
  /** If has errors */
  hasError?: boolean;
  /** Force displaying errors */
  showError?: boolean;
  /** A list of errors or a single text describing the error */
  errors?: string[] | string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';

  /** Callback when oninput is triggered */
  onInput?: (value: string, event: InputEvent) => void;

  /** Callback when onchange is triggered */
  onChange?: (value: string, event: InputEvent) => void;

  /** Callback when onfocus is triggered */
  onFocusIn?: (event: FocusEvent) => void;

  /** Callback when onblur is triggered */
  onFocusOut?: (event: FocusEvent) => void;
}

export interface FormInputBaseSignature {
  Args: FormInputArgs;
}

export interface FormInputSignature extends FormInputBaseSignature {
  Element: HTMLInputElement;
  Blocks: {
    default: [];
  };
}

export class FormInputBase<
  T extends FormInputBaseSignature
> extends Component<T> {
  @tracked shouldShowErrorFeedback = false;

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.showError ||
        this.args.hasSubmitted ||
        this.shouldShowErrorFeedback) &&
      this.args.errors &&
      this.args.errors.length > 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  @action handleFocusIn(event: FocusEvent): void {
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onFocusIn === 'function') {
      this.args.onFocusIn(event);
    }
  }

  @action handleFocusOut(event: FocusEvent): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(event);
    }
  }
}

export default class FormInput extends FormInputBase<FormInputSignature> {
  <template>
    <FormField
      @size={{@size}}
      class={{useFrontileClass "form-input" @size class=@containerClass}}
      as |f|
    >
      {{#if @label}}
        <f.Label class={{useFrontileClass "form-input" @size part="label"}}>
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint class={{useFrontileClass "form-input" @size part="hint"}}>
          {{@hint}}
        </f.Hint>
      {{/if}}

      <f.Input
        {{on "focus" this.handleFocusIn}}
        {{on "blur" this.handleFocusOut}}
        @onInput={{@onInput}}
        @onChange={{@onChange}}
        @value={{@value}}
        @type={{@type}}
        class={{useFrontileClass "form-input" @size part="input"}}
        aria-invalid={{if this.showErrorFeedback "true"}}
        aria-describedby="{{if @hint f.hintId}}{{if
          this.showErrorFeedback
          (concat " " f.feedbackId)
        }}"
        ...attributes
      />

      {{yield}}

      {{#if this.showErrorFeedback}}
        <f.Feedback
          class={{useFrontileClass "form-input" @size part="feedback"}}
          @errors={{@errors}}
        />
      {{/if}}
    </FormField>
  </template>
}

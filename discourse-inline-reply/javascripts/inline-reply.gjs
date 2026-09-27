import { service } from "@ember/service";
import Component from "@glimmer/component";
import DButton from "discourse/components/d-button";
import Composer from "discourse/models/composer";

const themeSetting = (name, fallback) => settings.get?.(name) ?? settings[name] ?? fallback;

class InlineReplyComposer extends Component {
  @service composer;
  get topic() {
    return this.args.outletArgs?.topic ?? this.args.outletArgs?.model;
  }

  get placeholder() {
    return themeSetting("placeholder", "Write a reply...");
  }

  get label() {
    return themeSetting("label", "Reply");
  }

  get hint() {
    return themeSetting("hint", "The native Discourse editor will open to publish your reply.");
  }

  @action
  openNativeComposer(event) {
    if (event?.type === "keydown" && !["Enter", " "].includes(event.key)) {
      return;
    }

    if (!this.topic) {
      return;
    }

    this.composer.open({
      action: Composer.REPLY,
      topic: this.topic,
      draftKey: `topic_${this.topic.id}`,
    });
  }

  <template>
    <section class="inline-reply-composer" aria-label={{this.label}}>
      <span class="inline-reply-composer__label">{{this.label}}</span>
      <div
        class="inline-reply-composer__surface"
        role="button"
        tabindex="0"
        {{on "click" this.openNativeComposer}}
        {{on "keydown" this.openNativeComposer}}
      >
        <span class="inline-reply-composer__placeholder">{{this.placeholder}}</span>
        <DButton
          class="inline-reply-composer__button btn-primary"
          @label="inline_reply.reply"
          @action={{this.openNativeComposer}}
        />
      </div>
      <p class="inline-reply-composer__hint">{{this.hint}}</p>
    </section>
  </template>
}

export default {
  name: "inline-reply-composer",

  initialize(container) {
    const api = container.lookup("service:plugin-api");
    if (!themeSetting("enabled", true)) {
      return;
    }

    // Conecta no outlet oficial do rodapé do tópico, antes dos botões de ação.
    api.renderInOutlet("topic-footer-main-buttons-before", InlineReplyComposer);

    api.onPageChange(() => {
      document.body.classList.toggle(
        "inline-reply-composer-show-mobile",
        themeSetting("show_on_mobile", true)
      );
    });

    api.decorateCookedElement(
      (element) => element.classList.add("inline-reply-composer-topic-content"),
      { id: "inline-reply-composer-cooked" }
    );
  },
};

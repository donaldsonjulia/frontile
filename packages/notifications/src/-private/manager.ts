import Notification from './notification';
import Timer from './timer';
import { getConfigOption } from './get-config';
import { tracked } from '@glimmer/tracking';
import { later } from '@ember/runloop';
import type { NotificationOptions } from './types';

export default class NotificationsManager {
  @tracked notifications: Notification[] = [];

  add(message: string, options: NotificationOptions = {}): Notification {
    const notification = new Notification(message, options);
    this.notifications = [...this.notifications, notification];

    let preserve =
      typeof options.preserve === 'undefined'
        ? getConfigOption('preserve', false)
        : options.preserve;

    // if default config has set skipTimer to true, we will preserve the
    // notification, therefore skiping the timer
    if (getConfigOption('skipTimer', false) === true) {
      preserve = true;
    }

    if (preserve === false) {
      this.setupAutoRemoval(notification, notification.duration);
    }
    return notification;
  }

  remove(notification?: Notification): void {
    if (!notification) {
      return;
    }

    notification.remove();

    later(
      this,
      () => {
        this.notifications = this.notifications.filter((n) => {
          return n !== notification;
        });
      },
      notification.transitionDuration
    );
  }

  removeAll(): void {
    this.notifications.forEach((notification) => {
      this.remove(notification);
    });
  }

  private setupAutoRemoval(notification: Notification, duration: number): void {
    notification.timer = new Timer(duration, () => {
      this.remove(notification);
    });
  }
}

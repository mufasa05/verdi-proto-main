import { Injectable } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  findAll() {
    return [{ id: 'notif-1', message: 'Welcome to Verdi' }];
  }
}

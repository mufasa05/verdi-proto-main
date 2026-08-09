import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  private readonly users = [
    { id: 'user-1', email: 'demo@verdi.app', name: 'Demo User' },
  ];

  findAll() {
    return this.users;
  }

  create(dto: CreateUserDto) {
    const user = {
      id: `user-${Date.now()}`,
      email: dto.email,
      name: dto.name,
    };

    this.users.push(user);
    return user;
  }
}

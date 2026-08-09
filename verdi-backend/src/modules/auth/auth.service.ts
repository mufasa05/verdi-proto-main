import { Injectable } from '@nestjs/common';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  private users = new Map<string, any>();

  async login(dto: LoginDto) {
    const existing = this.users.get(dto.email.toLowerCase().trim());

    return {
      token: `token_${Date.now()}`,
      user: {
        id: existing?.id || `usr_${Date.now()}`,
        fullName: existing?.fullName || (dto.email.includes('@') ? dto.email.split('@')[0] : 'Verdi Operator'),
        email: dto.email.trim(),
        role: existing?.role || 'farmer',
      },
    };
  }

  async register(dto: RegisterDto) {
    const user = {
      id: `usr_${Date.now()}`,
      fullName: dto.fullName.trim(),
      email: dto.email.trim().toLowerCase(),
      role: dto.role || 'farmer',
    };

    this.users.set(user.email, user);

    return {
      token: `token_${Date.now()}`,
      user,
    };
  }
}

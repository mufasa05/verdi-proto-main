import { Injectable } from '@nestjs/common';
import { CreateOrganizationDto } from './dto/create-organization.dto';

@Injectable()
export class OrganizationsService {
  private readonly organizations = [
    { id: 'org-1', name: 'Demo Organization', slug: 'demo-org' },
  ];

  findAll() {
    return this.organizations;
  }

  create(dto: CreateOrganizationDto) {
    const organization = {
      id: `org-${Date.now()}`,
      name: dto.name,
      slug: dto.slug,
    };

    this.organizations.push(organization);
    return organization;
  }
}

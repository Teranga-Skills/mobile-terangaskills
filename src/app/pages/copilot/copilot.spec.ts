import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Copilot } from './copilot';

describe('Copilot', () => {
  let component: Copilot;
  let fixture: ComponentFixture<Copilot>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Copilot],
    }).compileComponents();

    fixture = TestBed.createComponent(Copilot);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

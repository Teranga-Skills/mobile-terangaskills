import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Citoyens } from './citoyens';

describe('Citoyens', () => {
  let component: Citoyens;
  let fixture: ComponentFixture<Citoyens>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Citoyens],
    }).compileComponents();

    fixture = TestBed.createComponent(Citoyens);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

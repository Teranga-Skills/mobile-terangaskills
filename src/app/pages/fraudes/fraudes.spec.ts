import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Fraudes } from './fraudes';

describe('Fraudes', () => {
  let component: Fraudes;
  let fixture: ComponentFixture<Fraudes>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Fraudes],
    }).compileComponents();

    fixture = TestBed.createComponent(Fraudes);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

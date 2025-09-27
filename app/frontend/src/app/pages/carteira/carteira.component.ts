import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { CarteiraService } from '../../services/carteira.service';
import { Acao } from '../../models/acao.model';

@Component({
  selector: 'app-carteira',
  templateUrl: './carteira.component.html',
  styleUrls: ['./carteira.component.css']
})
export class CarteiraComponent implements OnInit {
  cpf: string = '';
  carteira: Acao[] = [];

  constructor(private route: ActivatedRoute, private carteiraService: CarteiraService) {}

  ngOnInit(): void {
    this.cpf = this.route.snapshot.paramMap.get('cpf') || '';
    this.carteiraService.getCarteira(this.cpf).subscribe(data => this.carteira = data);
  }
}


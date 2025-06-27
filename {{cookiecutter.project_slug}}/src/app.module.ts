import { Module } from '@nestjs/common';
import { AppConfigModule } from './config';
import { {{ cookiecutter.function_name_pascal }}Module } from './{{ cookiecutter.function_name_kebab }}';

@Module({
  imports: [AppConfigModule, {{ cookiecutter.function_name_pascal }}Module],
  controllers: [],
  providers: [],
})
export class AppModule { }

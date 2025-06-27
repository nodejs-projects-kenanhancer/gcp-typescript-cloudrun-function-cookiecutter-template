import { Module } from '@nestjs/common';
import { {{ cookiecutter.function_name_pascal }}Service } from './{{ cookiecutter.function_name_kebab }}.service';

@Module({
    providers: [{{ cookiecutter.function_name_pascal }}Service],
    exports: [{{ cookiecutter.function_name_pascal }}Service],
})
export class {{ cookiecutter.function_name_pascal }}Module { }
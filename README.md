# Cached Submodules

This Capistrano extension provides yet another way to manage your application’s git submodules.
Symlink to already fetched git submodules, rather than fetching it on every deploy.

<!--
Этот плагин является расширением для Capistrano и предостовляет еще один способ деплоть git субмодули вашего приложения.
При стандартном деплое checkout субмодулей пороисходит при каждый раз, даже если из версии не изменилсь. Этот плагин позволяет избежать этого. Однажды задеплоенный субмодуль помещается в папку `shared/submodules/#{submodule_name}/#{submodule_revision}` а в релизе приложения создается ссылка на эту папку. Код субмодуля не загружается при очередном делое если нужная ревизия уже есть на диске.
-->

## Dependencies

- Capistrano 2 or later ([capify.org](http://capify.org))

## Usage

All you need to do is install this as a plugin in your application.

    $ script/plugin install git://github.com/nicck/cached_submodules.git

Next, tell Capistrano fetch submodules before finalizing code update.

    # file: config/deploy.rb
    before "deploy:finalize_update", "cached_submodules:fetch"

Also make sure `git_enable_submodules` var not set or set to `false`.

    set :git_enable_submodules, false

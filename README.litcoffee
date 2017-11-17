# PouchDB Manager Registry

[![Travis Build][travis]](https://travis-ci.org/nhz-io/nhz-io-pouch-db-manager-registry)
[![NPM Version][npm]](https://www.npmjs.com/package/@nhz.io/pouch-db-manager-registry)

## Install

```bash
npm i -S @nhz.io/pouch-db-manager-registry
```

## Usage
```js
const Registry = require('@nhz.io/pouch-db-manager-registry')

...
```

## Literate Source

### Imports

    { urlname, allpass } = require '@nhz.io/pouch-db-manager-helpers'

### Resource

    class Resource

      constructor: ({ @uid, @type, @queue, @name, @local, @remote }) ->
        ['uid', 'type', 'queue' ].forEach (name) =>
          throw TypeError "Missing #{ name }" unless @[name]

        throw TypeError 'Missing name' unless @name or @local

### Registry

    class Registry

      @Resource = Resource

      constructor: ({ @resources = {}, @types, @queues }) ->

        throw TypeError 'Missing types' unless @types?.length
        throw TypeError 'Missing queues' unless @queues?.length

      sanitize: (resource) ->

        ['uid', 'type', 'queue' ].forEach (name) ->
          throw TypeError "Missing resource #{ name }" unless resource[name]

        throw TypeError 'Unknown resource type: #{ resource.type }' unless resource.type in @types

        throw TypeError 'Unknown resource queue: #{ resource.queue }' unless resource.queue in @queues

        { name, local, remote } = resource

        resource.local ?= resource.name

        if resource.local.match /^\s*https?:\/\//

          resource.remote = resource.local

          resource.name = resource.local = urlname resource.local

      register: (resource) ->

        resource = @sanitize resource

        return existing if existing = @resources[resource.uid]

        @resources[resource.uid] = resource

      unregister: (resource) ->

        uid = resource.uid or resource

        return unless resource = @resources[uid]

        delete @resources[uid]

        resource

      find: (query, predicates = []) ->

        match = allpass [

          if query.type then (resource) -> resource.type?.match query.type

          if query.queue then (resource) -> resource.queue?.match query.queue

          if query.name then (resource) -> resource.name?.match query.name

          if query.local then (resource) -> resource.local?.match query.local

          if query.remote then (resource) -> resource.remote?.match query.remote

          if query.job then (resource) -> resource.job is job

          predicates...

        ]

        resources = (Object.keys @resources).map (uid) => @resources[uid]

        resources.find (resource) -> match resource

### Exports

    module.exports = Registry

## Tests

    test = require 'tape-async'

    test 'Resource constructor', (t) ->

      t.plan 6

      t.throws -> new Resource {}

      t.throws -> new Resource { uid: 1 }

      t.throws -> new Resource { uid: 1, name: 'foo' }

      t.throws -> new Resource { uid: 1, name: 'foo', type: 'a' }


      t.ok new Resource { uid: 1, name: 'foo', type: 'a', queue: 'b' }

      t.ok new Resource { uid: 1, local: 'foo', type: 'a', queue: 'b' }


    test 'Registry constructor', (t) ->

      t.plan 4

      t.throws -> new Registry {}

      t.throws -> new Registry { types: [] }

      t.throws -> new Registry { types: [], queues: [] }

      t.ok new Registry { types: ['a'], queues: ['b'] }


## Version 0.0.0

## License [MIT](LICENSE)

[travis]: https://img.shields.io/travis/nhz-io/nhz-io-pouch-db-manager-registry.svg?style=flat
[npm]: https://img.shields.io/npm/v/@nhz.io/pouch-db-manager-registry.svg?style=flat

Durmand Priory
=============

**Durmand Priory** - An Objective C API for the Guild Wars 2 REST API, using the ARC memory model. This is a work in progress. As it stands it's not strictly a framework. Grab the source, open in Xcode and run. All 'framework' code is included in the GW2API group. In time I'll move this into a more reusable format, perhaps a static lib. But for now the code is easy to reuse and working. All endpoints are represented, however there may be a few pieces of missing data until I get around to fleshing everything out.

Dependencies
-------------
AFNetworking (https://github.com/AFNetworking/AFNetworking). Grab a copy and drag it into the project.

Adding Durmand Priory to your project
-------------
For now simply drag and drop the files under the 'DurmandPriory' directory into your project window.


Overview
-------------
This is a _domain first_ framework; you deal with the domain first and foremost. Services are fully abstracted from the client and you never deal with endpoints, server addresses, rest versions or parameters unless you absolutely want to.
 
The pattern is rather simple; domain classes provide class-level methods to manage data. For example
GW2Item has;
```objective-c
    + (NSArray *)items;
    + (GW2Item *)itemById:(NSString *)item_id;
    + (void)parse:(id)data;
```
In order to populate items simply ask the API to fetch them;
```objective-c
[DurmandPriory fetch:[GW2Item class] completionBlock:^(id domain) {
   // Called once the API has finished fetching it's data.
}];
```
 
The GW2 Rest service's items endpoint returns all known item IDs, so each item in the collection
returned by [GW2Item items] contains an ID, but no real data.
 
In order to get the details of a specific item simply pass that item back to the API;
```objective-c
GW2Item * item = [[GW2Item items] lastObject];
[DurmandPriory fetch:item completionBlock:^(id domain) {
   // Called once the API has finished fetching your item's data.
}];
```

This _pattern_ is repeated throughout the API. You take the same approach with recipes, 
World Vs World matches, events... etc. Pass the CLASS to populate the collections of data, pass
an instance to populate the details.
 

 

Fetching multiple sets of data in one operation
----------

The API also provides a higher-level fetch scheme. You can collect collections of data. A collection is an area of the domain that makes sense and may be comprised of several domain objects. For example the WvW collection will fetch Worlds and Match data, events also fetch maps, etc.

```objective-c
[DurmandPriory fetchCollection:GW2APIDomainCollectionWorldVsWorld
                   completionBlock:^(GW2APIDomainCollection collection) {
   
   // WvW data is available. As a GW2World for it's matchup, and then pass that matchup to the API to get
   // details such as score...
   GW2World * myWorld = ...;
   [DurmandPriory fetch:myWorld.matchup completionBlock:^(id domain) {
       // myWorld.matchup now has scores, etc.
   }
}];
```

Current collections
##########

 * GW2APIDomainCollectionEverything
 * GW2APIDomainCollectionWorldVsWorld
 * GW2APIDomainCollectionItems
 * GW2APIDomainCollectionRecipes
 * GW2APIDomainCollectionEvents

A note on GW2APIDomainCollectionEverything; this collection represents a short-hand way of fetching all _other_ collections in a manner that is efficient and in an order that guarantees completeness... it does not mean that all DETAILS for all objects will be returned too. The pattern remains; if you want details of an item, recipe, match or event you must ask the API to fetch it by passing the instance you want details for.

I currently have no plans to provide an API to fetch all instances with details, as I think this is something that is easily achieved in your own code and open for _abuse_.

 
How does it work?
-------------

For each domain class (GW2Item, GW2Event, GW2Recipe... etc) there's a corresponding configuration 
file (GW2Item.json, GW2Event.json, GW2Recipe.json... etc) that defines a number of configuration values
to enable the API to map that class, and it's instances, to reset service endpoints. It establishes
which data is needed and which endpoint to hit.

Let's take a look at a simple example; the GW2World class. A World in GW2 is a server that people play on.
The GW2World class represents, at the class level, all worlds, and at instance level a specific world.

The configuration file (GW2World.json) for this class simply defines the endpoint;
```json
{
    "endpoint":"world_names.json"
}
```

When you call [DurmandPriory fetch:[GW2World class] ...] the API reads this configuration, builds a request,
parses the response and passes the data to the GW2World's +parse: method. +parse takes that data and builds
a collection of worlds from it.

You can access these worlds with [GW2World worlds].

This is the pattern you'll use throughout the API. Need to get items?

```objective-c
[DurmandPriory fetch:[GW2Item class] completionBlock:^(id domain) {
    // Grab your items from [GW2Item items];
}];
```

It's that simple. Again, the API receives the class and opens the GW2Item.json configuration file, which contains;
```json
{
    "endpoint":"items.json",
    "details_endpoint":"item_details.json",
    "parameters":["item_id"]
}
```

So we have a collection of all items in the system but we know want to know more about a specific item.
The configuration file provides a "details_endpoint" and establishes that "item_id" is a required parameter.
So we simply pass our item INSTANCE to the API, which reads the configuration for the class and as it's an
instance knows that it needs to fetch details. It builds an endpoint for the details_endpoint address and asks
the instance for a value for "item_id"...

```objective-c
GW2Item * myItem = [GW2Item itemById:@"12345"];
[DurmandPriory fetch:myItem completionBlock:^(id domain) {
    // 'myItem' has now been populated with all data from the item_details endpoint.
}];
```

And that's it. Pass a class to get knowledge of WHAT items/recipes/events/matches and 
pass an INSTANCE to get specific details for that specific item/recipe/event/matche. That's the pattern.


Relationships between objects.
-------------

Some objects only make sense when they're constructed with other areas of the domain. For example a recipe only makes sense when we know the item is makes, and the items required to make it. Being a remote service that litterally offers tens of thousands of items, recipes and combinations thereof, how can we guarantee that when we fetch a recipe it makes sense? That we have the items we need for it?

Well, it does. That's the important point. If you're looking to use this API and want to know that those relationships are handled, then rest assured that they are. If you want to know HOW, read on.

Every domain object implements a protocol called GW2APIServiceBackedObject which establishes an optional method named -requiredDomainObjects. This is protocol is defined in GW2API.h.

requiredDomainObjects allows domain objects to tell the API of additional domain objects that are integral and required. GW2Recipe implements this method, which returns instances of GW2Item in an array. These item instances are likely 'dumb', which is to say they hold IDs and have yet to have their details fetched from the server. When you pass an instance of recipe to the API the API will ask the recipe whether it has any objects that are required too by calling this method. The API will iterate the collection passing the item  to it's fetch method for any item that is dumb. Once all required items are fetched it'll fetch the remaining details for the recipe.


Restricting the API by world.
-------------

Some of GW2's rest services do not require a world to limit data. For example, you can fetch the status of ALL events across ALL worlds. This is a pretty large resultset. You may only care about a specific world, and let's be honest most apps will likely deal with world-level data. That is, ultimately what users will care about; "what's happening on my world".

The API does support API-wide request parameters. For example, the API for events will fetch all events;

```objective-c
[DurmandPriory fetch:[GW2Event class] ...];
```

However if you wish to only see events for your world you can tell the API that;

```objective-c
GW2World * myWorld = [GW2World worldByName:@"Gandara"];
[DurmandPriory addRequestParameter:kGW2APIRequestParameterWorldID value:myWorld.world_id];
[DurmandPriory fetch:[GW2Event class] ...];
```

Now the fetch for GW2Event will be restricted by your world. How does it know? It's defined in the GW2Event.json configuration file;
```json
{
    "restrictions":["world_id"],
    "endpoint":"events.json",
    "names_endpoint":"event_names.json",
    "details_endpoint":"events.json",
    "parameters":["event_id"]
}
```

Usage considerations
----------

Be aware that Anet's GW2 API is very loose. In order to make the most of Durmand Priory you should have a little knowledge of how their data relates to one another. It's important also to ensure that you fetch data in an appropriate order, for example ensure that GW2Item has been fetched before dealing with GW2Recipe as recipes only make sense with items.

GW2API is the main API class. It's a singleton; you access the shared instance using the +sharedAPI
class method. For your convience you can simply use the 'DurmandPriory' definition...
 
[DurmandPriory fetch:...] is the same as [[GW2API sharedAPI] fetch:...]

GW2API.h/m is the key API class. Take a look at example iPhone application, and to use this framework just import DurmandPriory.h.



Further reading
----------
GW2 API Wiki - http://wiki.guildwars2.com/wiki/API
GW2 API Documentation - https://forum-en.guildwars2.com/forum/community/api/API-Documentation/first#post2028044

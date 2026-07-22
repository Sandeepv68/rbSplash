<p align="center">
  <img src="assets/logo.png" alt="RbSplash" width="200">
</p>

# RbSplash v1.0.0

[![license](https://img.shields.io/github/license/SandeepVattapparambil/rb_splash.svg)](https://github.com/SandeepVattapparambil/rb_splash/blob/master/LICENSE) ![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg) ![Gem Version](https://badge.fury.io/rb/rb_splash.svg) ![GitHub issues](https://img.shields.io/github/issues/SandeepVattapparambil/rb_splash.svg) ![GitHub forks](https://img.shields.io/github/forks/SandeepVattapparambil/rb_splash.svg) ![GitHub stars](https://img.shields.io/github/stars/SandeepVattapparambil/rb_splash.svg)

RbSplash is a promise-based API wrapper for the popular [Unsplash](https://unsplash.com/) platform, written in **Ruby** and ported from [wrapsplash](https://github.com/SandeepVattapparambil/wrapsplash) (TypeScript). It uses [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) for futures and [Faraday](https://github.com/lostisland/faraday) for HTTP requests.

Unsplash provides beautiful high quality free images and photos that you can download and use for any project without any attribution.

Before using the Unsplash API, you need to **register as a developer** and **read the API Guidelines.**

> **Note:** Every application must abide by the [API Guidelines](https://unsplash.com/documentation). Specifically, remember to hotlink images and trigger a download when appropriate.

## Table of Contents
<!--ts-->
* [About](#rbSplash-v100)
* [Installation](#installation)
* [Sample Usage](#sample-usage)
* [Development](#development)
* [New API Aliases](#new-api-aliases)
* [Dependencies](#dependencies)
* [API Documentation](#api-documentation)
    * [Schema](#schema)
        * [Location](#location)
        * [Summary Objects](#summary-objects)
        * [Error Messages](#error-messages)
    * [Authorization](#authorization)
        * [Public Actions](#public-actions)
        * [User Authentication](#user-authentication)
        * [RbSplash init()](#rbsplash-init)
        * [Generate Bearer Token](#generate-bearer-token)
    * [Users APIs](#users-apis)
        * [Get User's Public Profile](#get-users-public-profile)
        * [Get User's Portfolio Link](#get-users-portfolio-link)
        * [Get User's Photos](#get-users-photos)
        * [Get User Liked Photos](#get-user-liked-photos)
        * [Get User's Collections](#get-users-collections)
        * [Get User's Statistics](#get-users-statistics)
    * [Photos APIs](#photos-apis)
        * [List Photos](#list-photos)
        * [List Curated Photos](#list-curated-photos)
        * [Get a Photo by Id](#get-a-photo-by-id)
        * [Get a Random Photo](#get-a-random-photo)
        * [Get a Photo's Statistics](#get-a-photos-statistics)
        * [Get a Photo's Download Link](#get-a-photos-download-link)
        * [Update a Photo](#update-a-photo)
        * [Like a Photo](#like-a-photo)
        * [Unlike a Photo](#unlike-a-photo)
    * [Search APIs](#search-apis)
        * [Search Photos](#search-photos)
        * [Search Collections](#search-collections)
        * [Search Users](#search-users)
    * [Current User APIs](#current-user-apis)
        * [Get the User's Profile](#get-users-profile)
        * [Update User's Profile](#update-users-profile)
    * [Stats APIs](#stats-apis)
        * [Stats Totals](#stats-totals)
        * [Stats Month](#stats-month)
    * [Collections APIs](#collections-apis)
        * [Link Relations](#link-relations)
        * [List Collections](#list-collections)
        * [List Featured Collections](#list-featured-collections)
        * [List Curated Collections](#list-curated-collections)
        * [Get a Collection](#get-a-collection)
        * [Get a Curated Collection](#get-a-curated-collection)
        * [Get a Collection's Photos](#get-a-collections-photos)
        * [Get a Curated Collection's Photos](#get-a-curated-collections-photos)
        * [List a Collection's Related Collections](#list-a-collections-related-collections)
        * [Create a New Collection](#create-a-new-collection)
        * [Update an Existing Collection](#update-an-existing-collection)
        * [Delete a Collection](#delete-a-collection)
        * [Add a Photo to a Collection](#add-a-photo-to-a-collection)
        * [Remove a Photo from a Collection](#remove-a-photo-from-a-collection)
* [Tests](#tests)
* [License](#license)
* [Acknowledgements](#acknowledgements)
<!--te-->

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rb_splash"
```

Then execute:

```sh
bundle install
```

Or install it directly:

```sh
gem install rb_splash
```

## Sample Usage

```ruby
require "rb_splash"

api = RbSplash::WrapSplashApi.new

# Initialize with a bearer token
api.init(bearer_token: "your-bearer-token")

# Or initialize with access key credentials
api.init(
  access_key: "your-access-key",
  secret_key: "your-secret-key",
  redirect_uri: "https://example.com/callback",
  code: "authorization-code"
)

# Get the current user profile
profile = api.get_current_user_profile.value!

# Search for photos
results = api.search("nature", per_page: 5).value!

# Get a random photo
photo = api.get_random_photo(orientation: "landscape").value!
```

All API methods return a `Concurrent::Promises::Future`. Call `.value!` to get the result or raise on error.

## Development

```sh
git clone https://github.com/SandeepVattapparambil/rb_splash.git
cd rb_splash
bundle install
bundle exec rspec
```

## New API Aliases

The library includes more descriptive convenience methods such as `get_photo`, `get_random_photo`, `create_collection`, and `update_collection`. The original method names remain available for backward compatibility.

```ruby
# Original names
api.get_a_photo("photo-id")
api.get_a_random_photo(orientation: "landscape")
api.create_new_collection("My Collection")
api.update_existing_collection("cid", "Title")

# Convenience aliases
api.get_photo("photo-id")
api.get_random_photo(orientation: "landscape")
api.create_collection("My Collection")
api.update_collection("cid", "Title")
```

## Dependencies

This library depends on:
- [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) - for promise-based async futures
- [faraday](https://github.com/lostisland/faraday) - for HTTP requests
- [faraday-net_http](https://github.com/lostisland/faraday-net_http) - Net::HTTP adapter for Faraday

## API Documentation

### Schema

#### Location
The API base URL is `https://api.unsplash.com/`. Responses are sent as JSON.

#### Summary Objects
When retrieving a list of objects, an abbreviated or summary version of that object is returned - i.e., a subset of its attributes. To get a full detailed version of that object, fetch it individually.

#### Error Messages
If an error occurs, whether on the server or client side, the error message(s) will be returned in an `errors` array.

For example:
```
422 Unprocessable Entity
```
```json
{
  "errors": ["Username is missing", "Password cannot be blank"]
}
```

### Authorization

#### Public Actions
Many actions can be performed without requiring authentication from a specific user. For example, downloading a photo does not require a user to log in.

To authenticate requests in this way, pass your application's access key via the HTTP `Authorization` header:
```
Authorization: Client-ID YOUR_ACCESS_KEY
```

If only your access key is sent, attempting to perform non-public actions that require user authorization will result in a `401 Unauthorized response`.

#### User Authentication
The Unsplash API uses OAuth2 to authenticate and authorize Unsplash users. Unsplash's OAuth2 paths live at `https://unsplash.com/oauth/`.

Before using RbSplash:
- Developers are required to create a developer account from [Unsplash](https://unsplash.com/developers).
- Create a new App from Your Apps page.
- Get the `Access Key`, `Secret Key`, `Callback URLs`, and `Authorization code`.
- If you have a Bearer Token, then its super, or else you can generate it using **RbSplash**.

> **Note:** `Authorization code` can be obtained by clicking the `Authorize` link next to `Callback URLs`. Also `Authorization code` is a one-time use code, you have to generate it again if the action fails!

#### RbSplash init()
The RbSplash instance has to be initialized with your credentials obtained from the Unsplash developer account for programmatic access. These credentials are passed to the `init()` function as options. The following example shows all the available options.

```ruby
api.init(
  access_key: '<api-key>',
  secret_key: '<secret-key>',
  redirect_uri: '<callback-url>',
  code: '<authorization-code>',
  bearer_token: '<bearer-token>'
)
```

If you have a `bearer_token`, then only the bearer token has to be passed in.

```ruby
api.init(bearer_token: '<bearer-token>')
```

#### Generate Bearer Token
A method to generate a Bearer Token for `write_access` to private data. The `init()` method in this case requires `access_key`, `secret_key`, `redirect_uri`, and `code`.

> **Note:** No parameters are required for this method.

```ruby
api = RbSplash::WrapSplashApi.new

api.init(
  access_key: '<api-key>',
  secret_key: '<secret-key>',
  redirect_uri: '<callback-url>',
  code: '<authorization-code>'
)

result = api.generate_bearer_token.value!
puts result
```

If successful, the response body will be a JSON representation of your user's access token a.k.a bearer token:

```json
{
  "access_token": "091343ce13c8ae780065ecb3b13dc903475dd22cb78a05503c2e0c69c5e98044",
  "token_type": "bearer",
  "scope": "public read_photos write_photos",
  "created_at": 1436544465
}
```

And once you have your `bearer_token` you can use it in your app like this:

```ruby
api.init(bearer_token: '<bearer-token>')
```

### Users APIs

#### Get User's Public Profile
A promise factory to retrieve public details on a given user.
```
GET /users/:username
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |
| **width** | *number* | Width of the profile picture in pixels | yes | |
| **height** | *number* | Height of the profile picture in pixels | yes | |

> **Note:** When optional **height** & **width** are specified the profile image will be included in the "profile_image" object as "custom".

```ruby
api.get_public_profile('<username>', width: 600, height: 600)
```

#### Get User's Portfolio Link
A promise factory to retrieve a single user's portfolio link.
```
GET /users/:username/portfolio
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |

```ruby
api.get_user_portfolio('<username>')
```

#### Get User's Photos
A promise factory to get a list of photos uploaded by a particular user.
```
GET /users/:username/photos
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |
| **stats** | *boolean* | Show the stats for each user's photo | yes | false |
| **resolution** | *string* | The frequency of the stats | yes | days |
| **quantity** | *number* | The amount for each stat | yes | 30 |
| **order_by** | *string* | How to sort the photos. (`Valid values: latest, oldest, popular`) | yes | latest |

```ruby
api.get_user_photos('<username>', page: 1, per_page: 10, order_by: 'latest')
```

#### Get User Liked Photos
A promise factory to get a list of photos liked by a user.
```
GET /users/:username/likes
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |
| **order_by** | *string* | How to sort the photos. (`Valid values: latest, oldest, popular`) | yes | latest |

```ruby
api.get_user_liked_photos('<username>', page: 1, per_page: 10, order_by: 'latest')
```

#### Get User's Collections
A promise factory to get a list of collections created by the user.
```
GET /users/:username/collections
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.get_user_collections('<username>', page: 1, per_page: 10)
```

#### Get User's Statistics
A promise factory to get a user's account statistics.
```
GET /users/:username/statistics
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the particular user | no | |
| **resolution** | *string* | The frequency of the stats | yes | days |
| **quantity** | *number* | The amount for each stat | yes | 30 |

```ruby
api.get_user_statistics('<username>', resolution: 'days', quantity: 30)
```

### Photos APIs

#### List Photos
A promise factory to get a single page from the list of all photos.
```
GET /photos
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |
| **order_by** | *string* | How to sort the photos. (`Valid values: latest, oldest, popular`) | yes | latest |

```ruby
api.list_photos(page: 1, per_page: 10, order_by: 'latest')
```

#### List Curated Photos
A promise factory to get a single page from the list of the curated photos.
```
GET /photos/curated
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |
| **order_by** | *string* | How to sort the photos. (`Valid values: latest, oldest, popular`) | yes | latest |

```ruby
api.list_curated_photos(page: 1, per_page: 10, order_by: 'latest')
```

#### Get a Photo by Id
A promise factory to retrieve a single photo.
```
GET /photos/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |
| **width** | *number* | Image width in pixels | yes | |
| **height** | *number* | Image height in pixels | yes | |
| **rect** | *string* | 4 comma-separated integers representing x, y, width, height of the cropped rectangle | yes | |

> **Note:** Supplying the optional **width** or **height** parameters will result in the custom photo URL being added to the urls object.

```ruby
api.get_a_photo('<photo-id>', width: 500, height: 500, rect: '0,0,500,500')
# or use the alias
api.get_photo('<photo-id>', width: 500, height: 500)
```

#### Get a Random Photo
A promise factory to retrieve a single random photo, given optional filters.
```
GET /photos/random
```

##### Parameters

> **Note:** All parameters are optional, and can be combined to narrow the pool of photos from which a random one will be chosen.

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **collections** | *string* | The public collection ID('s) to filter selection. If multiple, comma-separated | yes | |
| **featured** | *boolean* | Limit selection to featured photos | yes | false |
| **username** | *string* | Limit selection to a single user | yes | |
| **query** | *string* | Limit selection to photos matching a search term | yes | |
| **width** | *number* | The image width in pixels | yes | |
| **height** | *number* | The image height in pixels | yes | |
| **orientation** | *string* | Filter search results by photo orientation. (`Valid values: landscape, portrait, squarish`) | yes | landscape |
| **count** | *number* | The number of photos to return. (`max: 30`) | yes | 1 |

> **Note:** You can't use the collections and query parameters in the same request.
> When supplying a **count** parameter - and only then - the response will be an array of photos, even if the value of **count** is 1.

```ruby
api.get_a_random_photo(orientation: 'landscape', count: 5)
# or use the alias
api.get_random_photo(orientation: 'portrait')
```

#### Get a Photo's Statistics
A promise factory to retrieve total number of downloads, views and likes of a single photo, as well as the historical breakdown of these stats in a specific timeframe (default is 30 days).
```
GET /photos/:id/statistics
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |
| **resolution** | *string* | The frequency of the stats | yes | days |
| **quantity** | *number* | The amount for each stat | yes | 30 |

> **Note:** Currently, the only resolution param supported is "days". The quantity param can be any number between 1 and 30.

```ruby
api.get_photo_statistics('<photo-id>', resolution: 'days', quantity: 10)
```

#### Get a Photo's Download Link
A promise factory to retrieve a single photo's download link. Preferably hit this endpoint if a photo is downloaded in your application for use (example: to be displayed on a blog article, to be shared on social media, to be remixed, etc).
```
GET /photos/:id/download
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |

> **Note:** This is different than the concept of a view, which is tracked automatically when you hotlink an image.

```ruby
api.get_photo_link('<photo-id>')
```

#### Update a Photo
A promise factory to update a photo on behalf of the logged-in user. This requires the `write_photos` scope and `bearer_token`.
```
PUT /photos/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |
| **location** | *hash* | The location hash holding location data | yes | |
| **exif** | *hash* | The exif hash holding exif data | yes | |

> **Note:** **Exchangeable image file format** (officially Exif, according to JEIDA/JEITA/CIPA specifications) is a standard that specifies the formats for images, sound, and ancillary tags used by digital cameras (including smartphones), scanners and other systems handling image and sound files recorded by digital cameras. [Read more](https://en.wikipedia.org/wiki/Exif)

##### location & exif hashes

| Hash Key | Description |
| --------- | ----------- |
| location[:latitude] | The photo location's latitude (Optional) |
| location[:longitude] | The photo location's longitude (Optional) |
| location[:name] | The photo location's name (Optional) |
| location[:city] | The photo location's city (Optional) |
| location[:country] | The photo location's country (Optional) |
| location[:confidential] | The photo location's confidentiality (Optional) |
| exif[:make] | Camera's brand (Optional) |
| exif[:model] | Camera's model (Optional) |
| exif[:exposure_time] | Camera's exposure time (Optional) |
| exif[:aperture_value] | Camera's aperture value (Optional) |
| exif[:focal_length] | Camera's focal length (Optional) |
| exif[:iso_speed_ratings] | Camera's iso (Optional) |

```ruby
api.update_photo('<photo-id>', location: { country: 'INDIA' }, exif: { make: 'Canon' })
```

#### Like a Photo
A promise factory to like a photo on behalf of the logged-in user. This requires the `write_likes` scope.
```
POST /photos/:id/like
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |

> **Note:** This action is idempotent; sending the POST request to a single photo multiple times has no additional effect.

```ruby
api.like_photo('<photo-id>')
```

#### Unlike a Photo
A promise factory to remove a user's like of a photo.
```
DELETE /photos/:id/like
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The photo's ID | no | |

> **Note:** This action is idempotent; sending the DELETE request to a single photo multiple times has no additional effect.

```ruby
api.unlike_photo('<photo-id>')
```

### Search APIs

#### Search Photos
A promise factory to get a single page of photo results for a particular query.
```
GET /search/photos
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **query** | *string* | The search query | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |
| **collections** | *string* | Collection ID('s) to narrow search. If multiple, comma-separated. | yes | |
| **orientation** | *string* | Filter search results by photo orientation. (`Valid values: landscape, portrait, squarish`) | yes | |

```ruby
api.search('cars', page: 1, per_page: 10, orientation: 'landscape')
```

#### Search Collections
A promise factory to get a single page of collection results for a query.
```
GET /search/collections
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **query** | *string* | The search query | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.search_collections('cars', page: 1, per_page: 10)
```

#### Search Users
A promise factory to get a single page of user results for a query.
```
GET /search/users
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **query** | *string* | The search query | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.search_users('<search-keyword>', page: 1, per_page: 10)
```

### Current User APIs

#### Get User's Profile
A promise factory to get the current user's profile. To access a user's private data, the user is required to authorize the `read_user` scope. Without it, this request will return a `403 Forbidden response`.
```
GET /me
```

> **Note:** No parameters are required.

> **Note:** Without a Bearer token (i.e. using a `Client-ID token`) this request will return a `401 Unauthorized` response.

```ruby
api.get_current_user_profile
```

#### Update User's Profile
A promise factory to update the current user's profile.
```
PUT /me
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **username** | *string* | The username of the current user | yes | |
| **first_name** | *string* | The first name of the current user | yes | |
| **last_name** | *string* | The last name of the current user | yes | |
| **email** | *string* | The email of the current user | yes | |
| **url** | *string* | The portfolio/personal URL of the current user | yes | |
| **location** | *string* | The location of the current user | yes | |
| **bio** | *string* | The about/bio of the current user | yes | |
| **instagram_username** | *string* | The Instagram username of the current user | yes | |

> **Note:** This action requires the `write_user` scope. Without it, it will return a `403 Forbidden response`.

```ruby
api.update_current_user_profile(username: 'mock-user', first_name: 'Mock', bio: 'Testing')
```

### Stats APIs

#### Stats Totals
A promise factory to get a list of counts for all of Unsplash.
```
GET /stats/total
```

```ruby
api.get_stats_totals
```

##### Response
```
200 OK
```
```json
{
  "total_stats": {
    "photos": 10000,
    "downloads": 2000,
    "views": 5000,
    "likes": 800,
    "photographers": 100,
    "pixels": 200000,
    "downloads_per_second": 10,
    "views_per_second": 20,
    "developers": 20,
    "applications": 50,
    "requests": 8000
  }
}
```

#### Stats Month
A promise factory to get the overall Unsplash stats for the past 30 days.
```
GET /stats/month
```

```ruby
api.get_stats_month
```

##### Response
```
200 OK
```
```json
{
  "month_stats": {
    "downloads": 20,
    "views": 200,
    "likes": 60,
    "new_photos": 10,
    "new_photographers": 5,
    "new_pixels": 2000,
    "new_developers": 8,
    "new_applications": 5,
    "new_requests": 100
  }
}
```

### Collections APIs

#### Link Relations
Collections have the following link relations:

| rel | Description |
| --- | ----------- |
| `self` | API location of this collection |
| `html` | HTML location of this collection |
| `photos` | API location of this collection's photos |
| `related` | API location of this collection's related collections (Non-curated collections only) |
| `download` | Download location of this collection's zip file (Curated collections only) |

#### List Collections
A promise factory to get a single page from the list of all collections.
```
GET /collections
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.list_collections(page: 1, per_page: 10)
```

#### List Featured Collections
A promise factory to get a single page from the list of featured collections.
```
GET /collections/featured
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.list_featured_collections(page: 1, per_page: 10)
```

#### List Curated Collections
A promise factory to get a single page from the list of curated collections.
```
GET /collections/curated
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.list_curated_collections(page: 1, per_page: 10)
```

#### Get a Collection
A promise factory to retrieve a single collection. To view a user's private collections, the `read_collections` scope is required.
```
GET /collections/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |

```ruby
api.get_collection('<collection-id>')
```

#### Get a Curated Collection
A promise factory to retrieve a single curated collection. To view a user's private collections, the `read_collections` scope is required.
```
GET /collections/curated/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |

```ruby
api.get_curated_collection('<curated-collection-id>')
```

#### Get a Collection's Photos
A promise factory to retrieve a collection's photos.
```
GET /collections/:id/photos
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.get_collection_photos('<collection-id>', page: 1, per_page: 10)
```

#### Get a Curated Collection's Photos
A promise factory to retrieve a curated collection's photos.
```
GET /collections/curated/:id/photos
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |
| **page** | *number* | Page number to retrieve | yes | 1 |
| **per_page** | *number* | Number of items per page | yes | 10 |

```ruby
api.get_curated_collection_photos('<curated-collection-id>', page: 1, per_page: 10)
```

#### List a Collection's Related Collections
A promise factory to retrieve a list of collections related to this one.
```
GET /collections/:id/related
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |

```ruby
api.list_related_collections('<collection-id>')
```

#### Create a New Collection
A promise factory to create a new collection. This requires the `write_collections` scope.
```
POST /collections
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **title** | *string* | The title of the collection | no | |
| **description** | *string* | The collection's description | yes | |
| **private_collection** | *boolean* | Whether to make this collection private | yes | false |

```ruby
api.create_new_collection('My Collection', description: 'desc', private_collection: true)
# or use the alias
api.create_collection('My Collection')
```

#### Update an Existing Collection
A promise factory to update an existing collection belonging to the logged-in user. This requires the `write_collections` scope.
```
PUT /collections/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |
| **title** | *string* | The title of the collection | yes | |
| **description** | *string* | The collection's description | yes | |
| **private_collection** | *boolean* | Whether to make this collection private | yes | false |

```ruby
api.update_existing_collection('<collection-id>', 'New Title', description: 'Updated')
# or use the alias
api.update_collection('<collection-id>', 'New Title')
```

#### Delete a Collection
A promise factory to delete a collection belonging to the logged-in user. This requires the `write_collections` scope.
```
DELETE /collections/:id
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **id** | *string* | The collection ID | no | |

```ruby
api.delete_collection('<collection-id>')
```

#### Add a Photo to a Collection
A promise factory to add a photo to one of the logged-in user's collections. Requires the `write_collections` scope.
```
POST /collections/:collection_id/add
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **collection_id** | *string* | The collection ID | no | |
| **photo_id** | *string* | The photo ID | no | |

> **Note:** If the photo is already in the collection, this action has no effect.

```ruby
api.add_photo_to_collection('<collection-id>', '<photo-id>')
```

#### Remove a Photo from a Collection
A promise factory to remove a photo from one of the logged-in user's collections. Requires the `write_collections` scope.
```
DELETE /collections/:collection_id/remove
```

##### Parameters

| Parameter | Type | Description | Optional | Default |
| --------- | ---- | ----------- | -------- | ------- |
| **collection_id** | *string* | The collection ID | no | |
| **photo_id** | *string* | The photo ID | no | |

```ruby
api.remove_photo_from_collection('<collection-id>', '<photo-id>')
```

## Tests

RbSplash uses [RSpec](https://rspec.info/) as the testing framework with [WebMock](https://github.com/bblimke/webmock) for HTTP stubbing. Test files are available in the `spec/` folder.

```sh
bundle exec rspec
```

## License

The MIT License

Copyright (c) 2026 Sandeep Vattapparambil

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Acknowledgements

Thanks, and Kudos to team [Unsplash](https://unsplash.com/) for creating a wonderful platform for sharing beautiful high quality free images and photos.

Made with :heart: by [Sandeep Vattapparambil](https://github.com/SandeepVattapparambil).

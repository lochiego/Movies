# Project 1 - *On Screen*

**On Screen** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **7.5** hours spent in total

## User Stories

The following **required** functionality is complete:

- [X] User can view a list of movies currently playing in theaters from The Movie Database.
- [X] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [X] User sees a loading state while waiting for the movies API.
- [X] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [X] User sees an error message when there's a networking error.
- [X] Movies are displayed using a CollectionView instead of a TableView.
- [ ] User can search for a movie.
- [X] All images fade in as they are loading.
- [X] Customize the UI.

The following **additional** features are implemented:

- [X] User can toggle between table view and grid view
- [X] User can view details on movie by selecting it
- [X] Text sizes based on accessibility setting
- [X] Sort by release date or rating

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Managing multiple 'pages' of RESTful data
2. Popups

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/XcFQw2r.gif?1' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

Switching between table layout and grid layout (hiding and showing the text) was a problem for a while, until I realized the default settings for the repositioning made sense. I also had to learn how to work with the flow layouts to get the toggle effect I wanted. I also had to look for how I might get the poster to fade in, and don't know if there was a better way to do it than what I did.

## License

    Copyright 2016 Eric Gonzalez

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


# Project 2 - *On Screen*

**On Screen** is a movies app displaying box office and top rental DVDs using [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **3** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can view movie details by tapping on a cell.
- [X] User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- [X] Customize the selection effect of the cell.

The following **optional** features are implemented:

- [X] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [X] Customize the navigation bar.

The following **additional** features are implemented:

- [X] Added a "mirror" view to the back drop, larger poster view

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. 
2. 

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

Copyright [yyyy] [name of copyright owner]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
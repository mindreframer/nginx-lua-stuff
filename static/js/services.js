var services = angular.module('Nyfyk.services', []);

function Item(entry, feedTitle, feedId) {
  //this.read = false;
  this.starred = false;
  this.selected = false;
  this.feedTitle = feedTitle;
  this.feedId = feedId;
  this.date = new Date(entry.pubdate*1000);
  //this.read = entry.unread == false;

  angular.extend(this, entry);
}

function Feed(title, id) {
    this.unreadCount = 0;
    this.readCount = 0;
    this.title = title;
    this.feedid = id;
    this.selected = false;
}


Item.prototype.$$hashKey = function() {
  return this.id;
}


/**
 * ViewModel service representing all feed entries the state of the UI.
 */
services.factory('items', ['$http', function($http) {
  var items = {
    all: [],
    feeds: [],
    feedhash: {},
    filtered: [],
    selected: null,
    selectedIdx: null,
    readCount: 0,
    feedCount: 0,
    starredCount: 0,


    getItemsFromBackend: function() {
        /*
      $http.get('/nyfyk/api/items/').success(function(data) {
          console.log(data);
        $scope.feed = data;
      });
      //feedStore.getAll().then(function(feeds) {
      feedStore.getAll().then(function(feeds) {
      */
      $http.get('/nyfyk/api/items/').then(function(data) {
        var i = 0;

        items.all = [];
        items.feeds = [];
        items.feedhash = {};
        feed = data.data;

        angular.forEach(feed, function(entry) {
            var item = new Item(entry, entry.title, entry.url);
            items.all.push(item);
            i++;
            // maintain unique list of feed titles
            var feed;
            if(items.feedhash[entry.feedid] == undefined) {
                feed = new Feed(entry.feedtitle, entry.feedid);
                items.feedhash[entry.feedid] = feed;
                items.feeds.push(feed);

            }else {
                feed = items.feedhash[entry.feedid];
            }
            if(item.read)   feed.readCount++;
            else feed.unreadCount++;
        });
        console.log("Entries loaded from backend:", i);

        items.all.sort(function(entryA, entryB) {
            return entryB.pubdate - entryA.pubdate;
        });
        // Sort feeds
        //items.feeds.sort();

        // Default show unread
        items.filtered = items.all.filter(function(item) {
            return item.read === false;
        });

        items.readCount = items.all.reduce(function(count, item) { return item.read ? ++count : count; }, 0);
        items.starredCount = items.all.reduce(function(count, item) { return item.starred ? ++count : count; }, 0);
        items.selected = items.selected
            ? items.all.filter(function(item) { return item.id == items.selected.id; })[0]
            : null;
        items.reindexSelectedItem();
      });
    },

    addFeed: function(url, cat) {
      $http.put('/nyfyk/api/addfeed/', {url:url, cat:cat}).then(function(data) {
          console.log('addFeed backend said:', data);
          // Add feeds after succesfull parse. FIXME: error handling
          items.refreshFeeds()
       });
    },

    prev: function() {
      if (items.hasPrev()) {
        items.selectItem(items.selected ? items.selectedIdx - 1 : 0);
      }
    },


    next: function() {
      if (items.hasNext()) {
        items.selectItem(items.selected ? items.selectedIdx + 1 : 0);
      }
    },


    hasPrev: function() {
      if (!items.selected) {
        return true;
      }
      return items.selectedIdx > 0;
    },


    hasNext: function() {
      if (!items.selected) {
        return true;
      }
      return items.selectedIdx < items.filtered.length - 1;
    },


    selectItem: function(idx) {
      // Unselect previous selection.
      if (items.selected) {
        items.selected.selected = false;
      }

      items.selected = items.filtered[idx];
      items.selectedIdx = idx;
      items.selected.selected = true;

      if (!items.selected.read) items.toggleRead();

    },


    toggleRead: function() {
      var item = items.selected,
          read = !item.read; // toggle status

      item.read = read; // Update to new status
      $http.put('/nyfyk/api/items/'+item.id, {'read': read ? 1 : 0}).success(function(data) {
          console.log('Toggleread backend said', data);
      });
      items.readCount += read ? 1 : -1;

      items.feedhash[item.feedid].unreadCount += read ? -1 : 1;
      items.feedhash[item.feedid].readCount += read ? 1 : -1;
    },


    toggleStarred: function() {
      var item = items.selected,
          starred = !item.starred;
      $http.put('/nyfyk/api/items/'+item.id, {'starred': starred ? 1 : 0}).success(function(data) {
          console.log('Togglestarred backend said', data);
      });

      item.starred = starred;
      items.starredCount += starred ? 1 : -1;
    },


    markAllRead: function() {
      var ids = [];
      items.filtered.forEach(function(item) {
        ids.push(item.id);
        item.read = true;
        // FIXME check for current status and use ternary check
        items.feedhash[item.feedid].unreadCount--;
        items.feedhash[item.feedid].readCount++;
        items.readCount++;
      });
      $http.put('/nyfyk/api/items/', {'items': ids}).success(function(data) {
          console.log('MarkAllRead backend said', data);
      });
    },


    filterBy: function(key, value) {
      items.filtered = items.all.filter(function(item) {
        return item[key] === value;
      });
      items.reindexSelectedItem();
    },

    selectFeed: function(idx) {
      var feed = items.feedhash[idx];
      items.feeds.forEach(function(feed) {
          feed.selected = false;
      });
      feed.selected = true;
      
      items.filtered = items.all.filter(function(item) {
        return item.feedid == feed.feedid;
      });
      items.reindexSelectedItem();
    },


    clearFilter: function() {
      items.filtered = items.all;
      items.reindexSelectedItem();
    },


    reindexSelectedItem: function() {
      if (items.selected) {
        var idx = items.filtered.indexOf(items.selected);

        if (idx === -1) {
          if (items.selected) items.selected.selected = false;

          items.selected = null;
          items.selectedIdx = null;
        } else {
          items.selectedIdx = idx;
          items.selected.selected = true;
        }
      }
    },

    refreshFeeds: function() {
        $http.get('/nyfyk/api/refresh/').then(function(data) {
            items.getItemsFromBackend();
        });
    }
  };

  //items.getItemsFromBackend();

  return items;
}]);


/**
 * Service that is in charge of scrolling in the app.
 */
services.factory('scroll', function($timeout) {
  return {
    pageDown: function() {
      var itemHeight = $('.entry.active').height() + 60;
      var winHeight = $(window).height();
      var curScroll = $('.entries').scrollTop();
      var scroll = curScroll + winHeight;

      if (scroll < itemHeight) {
        $('.entries').scrollTop(scroll);
        return true;
      }

      // already at the bottom
      return false;
    },

    toCurrent: function() {
      // Need the setTimeout to prevent race condition with item being selected.
      $timeout(function() {
        var curScrollPos = $('.summaries').scrollTop();
        var itemTop = $('.summary.active').offset().top - 60;
        $('.summaries').animate({'scrollTop': curScrollPos + itemTop}, 200);
        $('.entries article.active')[0].scrollIntoView();
      }, 0, false);
    }
  };
});


/**
 * Background page service.
 */
services.factory('bgPage', function() {
  return {
    /**
     * Initiates feed refresh.
     */
    refreshFeeds: function() {
      $http.get('/nyfyk/api/refresh/').then(function(data) {
          console.log(data);
      });
    }
  };
});

services.factory("personaSvc", ["$http", "$q", function ($http, $q) {

  return {
        verify:function () {
            var deferred = $q.defer();
            navigator.id.get(function (assertion) {
                $http.post("/nyfyk/api/persona/verify", {assertion:assertion})
                    .then(function (response) {
                        if (response.data.status != "okay") {
                            deferred.reject(response.data.reason);
                        } else {
                            deferred.resolve(response.data.email);
                        }
                    });
            });
            return deferred.promise;
        },
        logout:function () {
            return $http.post("/nyfyk/api/persona/logout").then(function (response) {
                if (response.data.status != "okay") {
                    $q.reject(response.data.reason);
                }
                return response.data.email;
            });
        },
        status:function () {
            return $http.post("/nyfyk/api/persona/status").then(function (response) {
                return response.data;
            });
        }
    };
}]);

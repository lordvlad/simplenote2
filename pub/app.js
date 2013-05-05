// Generated by CoffeeScript 1.6.2
(function() {
  var Node, SimpleNote, Tag, delay, hash, intersect, interval, isArr, isDate, isFn, isNum, isObj, isStr, koMap, maxScreenWidthForMobile, now, obs, revive, sizeOf, store, time, timeout, uuid,
    __hasProp = {}.hasOwnProperty,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  maxScreenWidthForMobile = 480;

  isFn = jQuery.isFunction;

  isArr = jQuery.isArray;

  isObj = jQuery.isPlainObject;

  isNum = jQuery.isNumeric;

  isStr = function(v) {
    return typeof v === "string";
  };

  isDate = function(v) {
    if (Object.prototype.toString.call(v) !== '[object Date]') {
      return false;
    } else {
      return !isNaN(v.getTime());
    }
  };

  timeout = {
    set: function(ms, fn) {
      return setTimeout(fn, ms);
    },
    clear: function(t) {
      return clearTimeout(t);
    }
  };

  interval = {
    set: function(ms, fn) {
      return setInterval(fn, ms);
    },
    clear: function(i) {
      return clearInterval(i);
    }
  };

  delay = function(fn) {
    return timeout.set(1, fn);
  };

  store = {
    set: function(key, val) {
      return localStorage.setItem(key, (isStr(val) ? val : JSON.stringify(val)));
    },
    get: function(key) {
      return JSON.parse(localStorage.getItem(key), revive);
    },
    remove: function(key) {
      return localStorage.removeItem(key);
    }
  };

  revive = function(key, value) {
    var c;

    if (value && value.__constructor && (c = window[value.__constructor] || revive.constructors[value["class"]]) && typeof c.fromJSON === "function") {
      return c.fromJSON(value);
    } else {
      return value;
    }
  };

  revive.constructors = [];

  obs = function(value, owner) {
    switch (false) {
      case !(value && (value.call || value.read || value.write)):
        return ko.computed(value);
      case !(value && value.map):
        return ko.observableArray(value, owner || this);
      default:
        return ko.observable(value);
    }
  };

  uuid = (function() {
    var id, ids;

    ids = [];
    id = function(a) {
      if (a) {
        return (a ^ Math.random() * 16 >> a / 4).toString(16);
      } else {
        return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, id);
      }
    };
    return function() {
      var e;

      while (true) {
        e = id();
        if (!~ids.indexOf(e)) {
          break;
        }
      }
      ids.push(e);
      return e;
    };
  })();

  now = function() {
    return new Date();
  };

  time = (function() {
    var a;

    a = obs(0);
    interval.set(1e3, function() {
      return a(now());
    });
    return a;
  })();

  sizeOf = function(v) {
    var k;

    switch (false) {
      case !isNum(v):
        return v.split("").length;
      case !isStr(v || isArr(v)):
        return v.length;
      case !isObj(v):
        return ((function() {
          var _results;

          _results = [];
          for (k in v) {
            if (!__hasProp.call(v, k)) continue;
            _results.push(k);
          }
          return _results;
        })()).length;
      default:
        return null;
    }
  };

  koMap = function(model, map) {
    var key, value;

    for (key in map) {
      value = map[key];
      if (ko.isWriteableObservable(model[key])) {
        model[key](value);
      } else {
        model[key] = value;
      }
    }
    return model;
  };

  hash = window.hash = (function() {
    var h, s;

    h = obs("");
    s = function() {
      return h(location.hash.replace(/#/, "") || "");
    };
    $(window).on("hashchange", s);
    h.subscribe(function(v) {
      return location.hash = v;
    });
    s();
    return h;
  })();

  intersect = window.intersect = function(a, b) {
    return a.filter(function(n) {
      return ~b.indexOf(n);
    });
  };

  $.extend(true, window, {
    ESC: 27,
    ENTER: 13,
    TAB: 9,
    BACKSPACE: 8,
    SPACE: 32,
    UP: 38,
    DOWN: 40,
    LEFT: 37,
    RIGHT: 39,
    DEL: 46,
    HOME: 36,
    PGUP: 33,
    PGDOWN: 34,
    END: 35
  });

  /*
  @class Tag
  */


  Tag = (function() {
    Tag.fromJSON = function(data) {
      var instance, tag;

      if (tag = SimpleNote.activeInstance.tags.find('id', data.id)) {
        return tag;
      }
      delete data.__constructor;
      instance = new Tag();
      return koMap(instance, data);
    };

    function Tag(options) {
      this.toggleInFilter = __bind(this.toggleInFilter, this);
      this._delete = __bind(this._delete, this);
      this.remove = __bind(this.remove, this);
      this.edit = __bind(this.edit, this);
      this.toJSON = __bind(this.toJSON, this);
      var _this = this;

      this.id = uuid();
      this.model = SimpleNote.activeInstance;
      this.name = obs((options != null ? options.name : void 0) || "");
      this.color = obs((options != null ? options.color : void 0) || "white");
      this.fgColor = obs(function() {
        var c, x;

        x = [];
        c = (x[0] = new RGBColor(_this.color())).foreground();
        delete x[0];
        return c;
      });
      this.count = obs(function() {
        return Node.nodes.filter(function(n) {
          return n.tags.has(_this);
        }).length;
      });
      this.model.tags.push(this);
      this.model.save();
    }

    Tag.prototype.toJSON = function() {
      return {
        __constructor: 'Tag',
        id: this.id,
        name: this.name(),
        color: this.color()
      };
    };

    Tag.prototype.edit = function() {
      this.name(prompt("change name from " + (this.name()) + " to ...", this.name()));
      this.color(prompt("change color from " + (this.color()) + " to ...", this.color()));
      return this.model.save();
    };

    Tag.prototype.remove = function() {
      if (confirm("really delete tag '" + (this.name()) + "'?")) {
        return this._delete;
      }
    };

    Tag.prototype._delete = function() {
      var node, _i, _len, _ref, _results;

      this.model.tags.remove(this);
      _ref = this.model.nodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.tags.remove(this));
      }
      return _results;
    };

    Tag.prototype.toggleInFilter = function(i, e) {
      console.log(arguments);
      if ($(e.target).is('.icon-trash, .icon-pencil')) {
        return;
      }
      if (this.model.searchFilter().match('#' + this.name())) {
        this.model.searchFilter(this.model.searchFilter().replace('#' + this.name(), '').replace(/\s{2,}/g, " ").replace(/^\s*|\s*$/g, "") + " ");
      } else {
        this.model.searchFilter((this.model.searchFilter() + " #" + this.name()).replace(/\s{2,}/g, " ").replace(/^\s*|\s*$/g, "") + " ");
      }
      return this.model.editingFilter(true);
    };

    return Tag;

  }).call(this);

  /*
  * @class Node
  */


  Node = (function() {
    function Node(options) {
      this.toJSON = __bind(this.toJSON, this);
      this.editFiles = __bind(this.editFiles, this);
      this.editListType = __bind(this.editListType, this);
      this.editDeadline = __bind(this.editDeadline, this);
      this.editTags = __bind(this.editTags, this);
      this.toggleBookmarked = __bind(this.toggleBookmarked, this);
      this.toggleExpanded = __bind(this.toggleExpanded, this);
      this.toggleSelected = __bind(this.toggleSelected, this);
      this.makeActive = __bind(this.makeActive, this);
      this.alarm = __bind(this.alarm, this);
      this._delete = __bind(this._delete, this);
      this.remove = __bind(this.remove, this);
      var active,
        _this = this;

      this.model = SimpleNote.activeInstance;
      this.id = uuid();
      this.title = obs("").extend({
        parse: Node.parseHeadline
      });
      this.notes = obs("").extend({
        parse: Node.parseNote
      });
      this.deadline = obs(null).extend({
        parse: Node.parseDate
      });
      active = obs(false);
      this.bookmarked = obs(false);
      this.selected = obs(false);
      this.done = obs(false);
      this.archived = obs(false);
      this.realExpanded = obs(false);
      this.expanded = obs({
        read: function() {
          if (window.innerWidth < maxScreenWidthForMobile) {
            return false;
          } else {
            return _this.realExpanded();
          }
        },
        write: this.realExpanded
      });
      this.listStyleType = obs([]);
      this.editingTitle = obs(false);
      this.editingNote = obs(false);
      this.children = obs([]);
      this.tags = obs([]);
      this.tags.extend({
        pickFrom: {
          array: this.model.tags,
          key: "name"
        }
      });
      this.files = obs([]);
      this.visibleChildren = obs(function() {
        return _this.children.filter('visible');
      });
      this.visible = obs(function() {
        var f;

        f = _this.model.realFilter();
        return _this.model.current === _this || _this.visibleChildren().length || Node.checkFilter(_this, f);
      });
      this.active = obs({
        read: active,
        write: function(v) {
          var node, _i, _len, _ref;

          if (v === active() || v === false) {
            return active(v);
          }
          _ref = _this.model.nodes();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            node.active(false);
          }
          return active(true);
        }
      });
      this.hasNote = obs(function() {
        return _this.notes().length;
      });
      this.hasChildren = obs(function() {
        return _this.children().length;
      });
      this.cssClass = obs(function() {
        return _this.listStyleType().concat("node").filter(Boolean).join(" ");
      });
      this.bullet = obs(function() {
        return ((_this.hasNote() || _this.hasChildren()) && ((!_this.expanded() && Node.bullets.right) || (_this.expanded() && Node.bullets.down))) || Node.bullets.round;
      });
      this.parent = obs(function() {
        return _this.model.nodes.find(function(n) {
          return n.children.has(_this);
        });
      });
      this.parents = obs(function() {
        var p, x;

        if (_this.parent() === null) {
          return [];
        }
        p = [_this.parent()];
        while ((x = p[0].parent()) !== null) {
          p.unshift(x);
        }
        return p;
      });
      this.deadlineDisplay = (function() {
        var personalTimer, subscribed, subscription;

        personalTimer = obs(null);
        subscribed = obs(false);
        subscription = null;
        subscribed.subscribe(function(v) {
          if (v === true) {
            return subscription = time.subscribe(function(w) {
              return personalTimer(w);
            });
          } else {
            return typeof subscription.dispose === "function" ? subscription.dispose() : void 0;
          }
        });
        return obs(function() {
          var d;

          personalTimer();
          d = _this.deadline();
          if (d === null) {
            return "";
          }
          if (d > now()) {
            subscribed(true);
            return moment(d).fromNow();
          }
          subscribed(false);
          _this.alarm();
          return "";
        }).extend({
          throttle: 1
        });
      })();
      this.model.nodes.push(this);
      Node.nodes.push(this);
      if (options != null ? options.parent : void 0) {
        options.parent.children.push(this);
      }
      this;
    }

    Node.prototype.open = function() {
      return hash(this.id);
    };

    Node.prototype.remove = function() {
      if (confirm('really delete this node?')) {
        return this._delete();
      }
    };

    Node.prototype._delete = function() {
      if (this === this.model.current()) {
        this.model.current(this.parent());
      }
      this.parent().children.remove(this);
      this.model.nodes.remove(this);
      return this.model.save();
    };

    Node.prototype.alarm = function() {
      var _base;

      this.deadline(null);
      this.model.save();
      if (typeof (_base = this.model.pop).play === "function") {
        _base.play();
      }
      return alert(this.title());
    };

    Node.prototype.makeActive = function() {
      return this.active(true);
    };

    Node.prototype.toggleSelected = function() {
      return this.selected(!this.selected());
    };

    Node.prototype.toggleExpanded = function() {
      if (window.innerWidth < maxScreenWidthForMobile) {
        return this.open();
      }
      return this.expanded(!this.expanded());
    };

    Node.prototype.toggleBookmarked = function() {
      return this.bookmarked(!this.bookmarked());
    };

    Node.prototype.editTags = function(n, e) {
      this.active(true);
      return this.model.$tagsMenu.trigger('call', [n, e]);
    };

    Node.prototype.editDeadline = function() {
      return this.deadline((prompt('set a deadline', new Date())) || null);
    };

    Node.prototype.editListType = function() {};

    Node.prototype.editFiles = function() {};

    Node.prototype.toJSON = function() {
      return {
        __constructor: 'Node',
        id: this.id,
        title: escape(this.title()),
        notes: escape(this.notes()),
        deadline: this.deadline(),
        bookmarked: this.bookmarked(),
        done: this.done(),
        expanded: this.realExpanded(),
        listStyleType: this.listStyleType(),
        children: this.children(),
        tags: this.tags()
      };
    };

    Node.fromJSON = function(data) {
      var instance;

      delete data.__constructor;
      instance = new Node();
      return koMap(instance, data);
    };

    Node.parseNote = function(v) {
      return v.replace(/(<br>|\n|\r)$/i, "");
    };

    Node.parseHeadline = function(v) {
      return v.replace(/<br>|\n|\r/ig, "");
    };

    Node.parseDate = function(v) {
      var x;

      if (v === null) {
        return null;
      }
      if (isDate(x = new Date(v)) || isDate(x = new Date(parseInt(v))) || isDate(x = Date.intelliParse(v))) {
        return x;
      }
      return null;
    };

    Node.checkFilter = function(node, filter) {
      var r;

      r = false;
      r = (!filter.tags.length) || intersect(node.tags.map('name'), filter.tags).length;
      r = r && ((!filter.words.length) || (node.title() + " " + node.notes()).match(new RegExp(filter.words.join('|'), 'i')));
      return r;
    };

    Node.bullets = {
      right: "&#9658;",
      down: "&#9660",
      round: "&#9679;"
    };

    Node.nodes = obs([]);

    return Node;

  })();

  /*
  @class simpleNote
  */


  SimpleNote = (function() {
    SimpleNote.instances = [];

    function SimpleNote(element) {
      this.clearSearchFilter = __bind(this.clearSearchFilter, this);
      this.removeAlert = __bind(this.removeAlert, this);
      this.removeNotification = __bind(this.removeNotification, this);
      this.removeTag = __bind(this.removeTag, this);
      this.addTag = __bind(this.addTag, this);
      this.openNode = __bind(this.openNode, this);
      this.insertNodeAfter = __bind(this.insertNodeAfter, this);
      this.addNodeHere = __bind(this.addNodeHere, this);
      this.addNodeTo = __bind(this.addNodeTo, this);
      this.selectionEditTags = __bind(this.selectionEditTags, this);
      this.selectionRemove = __bind(this.selectionRemove, this);
      this.selectionRemoveDeadlines = __bind(this.selectionRemoveDeadlines, this);
      this.selectionArchive = __bind(this.selectionArchive, this);
      this.selectionInvert = __bind(this.selectionInvert, this);
      this.selectionUnselect = __bind(this.selectionUnselect, this);
      this.save = __bind(this.save, this);
      this.revive = __bind(this.revive, this);
      this.toJSON = __bind(this.toJSON, this);
      this.attachElements = __bind(this.attachElements, this);
      var _this = this;

      SimpleNote.instances.push(this);
      this.timeout = null;
      this.interval = null;
      this.root = null;
      this.element = null;
      this.pop = null;
      this.searchFilter = obs("");
      this.editingFilter = obs(false);
      this.current = obs(null);
      this.alerts = obs([]);
      this.notifications = obs([]);
      this.nodes = obs([]);
      this.tags = obs([]);
      this.realFilter = obs(function() {
        var f, _ref;

        f = _this.searchFilter().split(/\s+/);
        if (!f[0] || ((_ref = f[0]) != null ? _ref[0] : void 0) === '!') {
          return {
            tags: [],
            times: [],
            words: []
          };
        }
        return {
          tags: f.filter(function(n) {
            return n.match(/^#/);
          }).map(function(n) {
            return n.replace(/#/, '');
          }),
          times: f.filter(function(n) {
            return n.match(/^@/);
          }).map(function(n) {
            return n.replace(/@/, '');
          }),
          words: f.filter(function(n) {
            return n.match(/^[^#@]/);
          })
        };
      }).extend({
        debounce: 500
      });
      this.selectedNodes = obs(function() {
        return _this.nodes.filter('selected');
      });
      this.bookmarkedNodes = obs(function() {
        return _this.nodes.filter('bookmarked');
      });
      this.breadcrumbs = obs(function() {
        var _ref;

        _this.current();
        return ((_ref = _this.current()) != null ? typeof _ref.parents === "function" ? _ref.parents().concat([_this.current()]) : void 0 : void 0) || [];
      });
      hash.subscribe(function(id) {
        var _ref;

        _this.current((id && id.length && _this.nodes.find("id", id)) || _this.root);
        return (_ref = _this.current()) != null ? _ref.editingNote(true) : void 0;
      });
    }

    SimpleNote.prototype.attachElements = function(view) {
      this.$view = $(view);
      this.view = this.$view[0];
      this.pop = $('audio', view)[0];
      this.$tagsMenu = $('#tagsMenu', view);
      return SimpleNote.connectionStatus.valueHasMutated();
    };

    SimpleNote.prototype.toJSON = function() {
      return {
        root: this.root,
        tags: this.tags()
      };
    };

    SimpleNote.prototype.revive = function() {
      var data, root;

      data = store.get('simpleNote');
      if (data && data.root) {
        this.root = data.root;
        this.tags(data.tags || []);
      } else {
        root = new Node();
        root.id = 'simpleNoteRoot';
        root.title('home');
        root.visible = function() {
          return true;
        };
        this.root = root;
      }
      hash.valueHasMutated();
      return this;
    };

    SimpleNote.prototype.save = function() {
      var _this = this;

      timeout.clear(this.timeout);
      this.timeout = timeout.set(100, function() {
        return store.set("simpleNote", _this.toJSON());
      });
      return this;
    };

    SimpleNote.prototype.applyEvents = function() {
      var _this = this;

      this.$view.on("click", ".headline", function(e) {
        var $t;

        $t = $(e.target);
        if (!$t.is(".bullet, .action, .ellipsis, .additional")) {
          return $t.parents(".headline").find("title").focus();
        }
      });
      this.$view.on("keyup, click", function() {
        return _this.save();
      });
      return this;
    };

    SimpleNote.prototype.startPeriodicalSave = function() {
      this.interval = interval.set(6e4, this.save);
      return this;
    };

    SimpleNote.prototype.stopPeriodicalSave = function() {
      interval.clear(this.interval);
      return this;
    };

    SimpleNote.prototype.selectionUnselect = function() {
      var node, _i, _len, _ref, _results;

      _ref = this.selectedNodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.selected(false));
      }
      return _results;
    };

    SimpleNote.prototype.selectionInvert = function() {
      var node, _i, _len, _ref, _results;

      _ref = this.nodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.selected(!node.selected()));
      }
      return _results;
    };

    SimpleNote.prototype.selectionArchive = function() {
      var node, _i, _len, _ref, _results;

      _ref = this.selectedNodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.archived(true));
      }
      return _results;
    };

    SimpleNote.prototype.selectionRemoveDeadlines = function() {
      var node, _i, _len, _ref, _results;

      _ref = this.selectedNodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.deadline(null));
      }
      return _results;
    };

    SimpleNote.prototype.selectionRemove = function() {
      var node, _i, _len, _ref, _results;

      if (confirm("really delete " + (this.selectedNodes().length) + " selected outlines? ATTENTION! Children Nodes will be deleted with their parents!")) {
        _ref = this.selectedNodes();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          _results.push(node._delete());
        }
        return _results;
      }
    };

    SimpleNote.prototype.selectionEditTags = function() {};

    SimpleNote.prototype.addNodeTo = function(parent, options) {
      return (new Node($.extend((isObj(options) ? options : {}), {
        parent: parent
      }))).editingTitle(true);
    };

    SimpleNote.prototype.addNodeHere = function(options) {
      return this.addNodeTo(this.current(), options);
    };

    SimpleNote.prototype.insertNodeAfter = function(node, options) {
      return this.addNodeTo(this.current().parent(), options);
    };

    SimpleNote.prototype.openNode = function(el) {
      var _ref;

      return hash((el && el.id) || ((_ref = el && el[0] && ko.dataFor(el[0])) != null ? _ref.id : void 0) || el || this.root.id);
    };

    SimpleNote.prototype.addTag = function() {
      return new Tag({
        name: prompt('set a name', '')
      });
    };

    SimpleNote.prototype.removeTag = function(item) {
      var node, _i, _len, _ref, _results;

      if (!confirm("really delete the tag named " + (item.name()) + "?")) {
        return;
      }
      this.tags.remove(item);
      _ref = this.nodes();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        _results.push(node.tags.remove(item));
      }
      return _results;
    };

    SimpleNote.prototype.fadeIn = function(el) {
      return $(el).hide().fadeIn('slow');
    };

    SimpleNote.prototype.fadeOut = function(el) {
      return $(el).fadeOut(function() {
        return $(el).remove();
      });
    };

    SimpleNote.prototype.removeNotification = function(item) {
      return this.notifications.remove(item);
    };

    SimpleNote.prototype.removeAlert = function(item) {
      return this.alerts.remove(item);
    };

    SimpleNote.prototype.clearSearchFilter = function() {
      return this.searchFilter('');
    };

    return SimpleNote;

  })();

  SimpleNote.connectionStatus = obs(null);

  SimpleNote.connectionStatus.subscribe(function(v) {
    $('#indicate_' + (v ? 'online' : 'offline')).show();
    return $('#indicate_' + (v ? 'offline' : 'online')).hide();
  });

  SimpleNote.liststyletypes = [
    {
      name: "none",
      value: []
    }, {
      name: "1, 2, 3",
      value: ["decimal"]
    }, {
      name: "1., 2., 3.",
      value: ["decimal", "dot"]
    }, {
      name: "1.1, 1.2, 1.3",
      value: ["decimal", "dot", "add"]
    }, {
      name: "a, b, c",
      value: ["lowerAlpha"]
    }, {
      name: "(a), (b), (c)",
      value: ["lowerAlpha", "dot"]
    }, {
      name: "A, B, C",
      value: ["upperAlpha"]
    }, {
      name: "(A), (B), (C)",
      value: ["upperAlpha", "dot"]
    }
  ];

  $(function() {
    return (function() {
      var checkConnection, long, numShortChecks, offlineCount, short;

      offlineCount = 0;
      numShortChecks = 5;
      short = 2;
      long = 60;
      checkConnection = function() {
        return $.get('online/online.json').error(function() {
          SimpleNote.connectionStatus(false);
          return timeout.set((offlineCount++ < numShortChecks ? short : long) * 1e3, checkConnection);
        }).done(function() {
          SimpleNote.connectionStatus(true);
          offlineCount = 0;
          return timeout.set(long * 1e3, checkConnection);
        });
      };
      return checkConnection();
    })();
  });

  (function($, view, model) {
    applicationCache.onchecking = function() {
      return $.holdReady(true);
    };
    applicationCache.ondownloading = function() {
      return $.holdReady(true);
    };
    applicationCache.onerror = function() {
      $.holdReady(false);
      return SimpleNote.connectionStatus(false);
    };
    applicationCache.onnoupdate = function() {
      $.holdReady(false);
      return SimpleNote.connectionStatus(true);
    };
    applicationCache.onprogress = function() {
      return delay(function() {
        return $('#curtain').find('i').after('.');
      });
    };
    applicationCache.onupdateready = function() {
      delay(function() {
        return location.href = 'index.html';
      });
      return timeout.set(1000, function() {
        return $('#curtain').find('i').after("<br>there is a new version of this app.<br>please <a style='color:cyan' href='index.html'>reload the page manually</a>").find('a').focus();
      });
    };
    return $(function() {
      $.extend(true, window, {
        SimpleNote: SimpleNote,
        note: SimpleNote.activeInstance,
        Node: Node,
        Tag: Tag
      });
      ko.applyBindings(model, model.view);
      model.attachElements(view);
      model.revive();
      model.applyEvents();
      model.startPeriodicalSave();
      $('#tagsMenu', view).data('node', null).on('dismiss', function() {
        return $(this).fadeOut('fast', function() {
          return $(this).css({
            top: '',
            left: ''
          });
        });
      }).on('call', function(e, node, o) {
        var $this;

        $(document).off('click.tagsmenu');
        $this = $(this).position({
          my: 'right top',
          at: 'right bottom',
          of: o.target
        }).fadeIn('fast').data('node', node);
        $this.find('input').focus();
        return $(document).on('click.tagsmenu', function(e) {
          if (e.timeStamp === o.timeStamp || $(e.target).parents('#tagsMenu').length !== 0) {
            return;
          }
          $(document).off('click.tagsmenu');
          return $this.trigger('dismiss');
        });
      }).on('click', 'li.list', function() {
        var node, tag;

        tag = ko.dataFor(this);
        node = $(this).parents('#tagsMenu').data('node');
        if (node.tags.remove(tag).length === 0) {
          return node.tags.push(tag);
        }
      }).on('click', 'i.icon-plus', function() {
        var name;

        if (!(name = $(this).next().val())) {
          return;
        }
        $(this).parents('#tagsMenu').data('node').tags.push(new Tag({
          name: name
        }));
        return $(this).next().val('').focus();
      }).on('keydown', 'input', function(e) {
        if (e.which === ESC) {
          $(this).parents('#tagsMenu').trigger('dismiss');
        }
        if (e.which !== ENTER) {
          return;
        }
        return $(this).prev().trigger('click');
      });
      $('#search > div >.icon-tags', view).click(function(e) {
        model.editingFilter(true);
        if ($('#tags').is('visible')) {
          return $('#tags').slideUp();
        }
        $('#tags').slideDown('fast');
        return $(document).on('click.tagsfilter', function(f) {
          if (e.timeStamp === f.timeStamp || $(f.target).is('.icon-trash')) {
            return;
          }
          $(document).off('click.tagsfilter');
          return $('#tags').slideUp('fast');
        });
      });
      $('#search > div >.icon-star', view).click(function(e) {
        model.editingFilter(true);
        if ($('#bookmarks').is('visible')) {
          return $('#bookmarks').slideUp();
        }
        $('#bookmarks').slideDown('fast');
        return $(document).on('click.bookmarks', function(f) {
          if (e.timeStamp === f.timeStamp || $(f.target).is('.icon-star-half')) {
            return;
          }
          $(document).off('click.bookmarks');
          return $('#bookmarks').slideUp('fast');
        });
      });
      delay(function() {
        return $("#curtain").fadeOut("slow", function() {
          return $('body').css('overflow', 'auto');
        });
      });
      return null;
    });
  })(jQuery, "body", SimpleNote.activeInstance = new SimpleNote());

  (function($, view, model) {
    var a, b, c, d, e, f, g, node, _i, _len, _ref, _results,
      _this = this;

    a = new Node();
    a.id = 'help';
    a.title('help');
    a.parents = function() {
      return [model.root];
    };
    a.notes("welcome to simplenote help.<br>\n\nhere, i will try to help you getting startet with this awesome little outliner.<br><br>\n\ndoubleclick the title or click ( details... ) to open the first node titled 'first steps'\n");
    c = new Node();
    c.id = 'firstStep';
    c.title('first step');
    c.parents = function() {
      return [model.root, a];
    };
    c.notes("you opened your first node, YAY!<br><br>\nsee how the breadcrumbs above got updated? they provide you a path back to the root.<br><br>\ntry to get back to the 'help' page!");
    d = new Node();
    d.id = 'secondStep';
    d.title('second step');
    d.parents = function() {
      return [model.root, a];
    };
    d.notes("you can also use the little triangles ( " + Node.bullets.right + " ) on the side to unfold items <b>if</b> they have more content to them.\nnote that on mobile devices this will not unfold but open the item.");
    e = new Node();
    e.id = 'withoutcontent';
    e.title('i\'m empty :(');
    e.parents = function() {
      return [model.root, a, d];
    };
    f = new Node();
    f.id = 'withcontent';
    f.title('i have more to show');
    f.parents = function() {
      return [model.root, a, d];
    };
    f.notes("see? i have some details ");
    g = new Node();
    g.id = 'withcontentcontent';
    g.title('and another subnote');
    g.parents = function() {
      return [model.root, a, d, f];
    };
    b = new Node();
    b.id = 'offline';
    b.title('working offline');
    b.parents = function() {
      return [model.root, a];
    };
    b.notes("simplenote is capable of working offline, too, because all data is saved only in your browser anyway!<br><br>\non the bottom of the page, there is a small identifier which will update if you loose or gain an internet connection");
    a.children([c, d, b]);
    d.children([e, f]);
    f.children([g]);
    _ref = [a, b, c, d, e, f, g];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      _results.push((function() {
        node.remove = function() {
          return alert('cannot delete this node');
        };
        node._delete = function() {
          return null;
        };
        return node.readonly = true;
      })());
    }
    return _results;
  })(jQuery, "body", SimpleNote.activeInstance);

}).call(this);

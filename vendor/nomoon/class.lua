local Class = {
    _VERSION     = '0.6.1',
    _DESCRIPTION = 'Very simple class definition helper',
    _URL         = 'https://github.com/nomoon',
    _LONGDESC    = [[

        Simply define a class with the syntax:
            `MyClass = Class.new(classname, [existing_table])`
        Classname must start with a letter and consist of letters and
        numbers with no spaces. If 'existing_table' is provided, class features
        will be added to that table.
        The class constructor returns `Class, Metatable`.

        Then, define a function `MyClass:initialize(params)`. When you call
        `MyClass.new(params)` an instance is created and
        `.initialize(self, params)` is called with the new instance. You need
        not return anything from .initialize(), as the constructor will return
        the object once the function is finished.

        For private(ish) class and instance variables, you can call
        Class:private() or self:private() to retrieve a table reference.
        Passing a table into the private() method will set the private store to
        that table.

        You can also instantiate as a singleton via .newSingleton(...). This
        enforces one instance only, and allows instance methods to be called
        without `self` syntactic sugar (e.g. `.method(params)`).

        Each instance's unique object ID can be retrieved via :getID()

        Complete Example:
            local Class = require('class')
            local Animal = Class.new('animal') -- also Class()

            function Animal:initialize(kind)
                self.kind = kind
            end

            function Animal:getKind()
                return self.kind
            end

            local mrEd = Animal.new("horse") -> Instance of Animal
            mrEd:getKind() -> "horse"

    ]],
    _LICENSE = [[
        Copyright 2014 Tim Bellefleur

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

           http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
    ]]
}

local function __NULL__() end

----------------------
-- Class Constructor
----------------------

function Class.new(class_name, existing_table)
    if(not class_name:match("^%a%w*$")) then return end
    class_name = class_name:gsub("^%l", string.upper)

    -- Define a base class table.
    local class = type(existing_table) == 'table' and existing_table or {}
    local id = '{C}'..tostring(class):gsub('^table', class_name)

    -- Create or retrieve the base class' metatable
    local class_mt = getmetatable(class) or {}
    setmetatable(class, class_mt)

    -- Define the metatable for instances of the class.
    local instance_mt = {__index = class,
        __tostring = function(obj) return obj.getID() end}

    -- Reflection/typecheck methods
    function class.getID() return id end
    function class.isInstance(obj) return getmetatable(obj) == instance_mt end
    function class.class() return class end
    function class.className() return class_name end
    class.initialize = __NULL__

    -- Weak table to store all of the instances of the class
    local instances = setmetatable({}, {__mode = 'v'})
    function class.classInstanceCount()
        local count = 0
        for _,_ in pairs(instances) do count = count + 1 end
        return count
    end

    -- Private store and accessor method
    local private = setmetatable({class = {}}, {__mode = "k"})
    function class.private(obj, val)
        if(class.isInstance(obj) or obj == class) then
            if(type(val) == 'table') then private[obj] = val end
            return private[obj]
        end
    end

    -- Class constructor
    function class.new(...)
        -- Return singleton if it exists
        if instances['singleton'] then return instances['singleton'] end

        -- Instantiate new class and make id from pointer
        local instance = {}
        local id = '{I}'..tostring(instance):gsub('^table', class_name)
        function instance.getID() return id end

        -- Now that we have the id, we can attach the metatable
        -- (in case __tostring got overwritten)
        setmetatable(instance, instance_mt)

        -- Add to the instances list
        table.insert(instances, instance)

        -- Create an empty private store for the instance
        private[instance] = {}

        -- Run user-defined constructor
        class.initialize(instance, ...)

        -- Override .initialize on instance to prevent re-initializing
        instance.initialize = __NULL__

        return instance
    end

    -- Singleton constructor
    function class.newSingleton(...)
        -- Return singleton if it exists
        if instances['singleton'] then return instances['singleton'] end

        -- Singleton only permitted if it's the only instance
        if(class.classInstanceCount() > 0) then return end

        -- Create internal instance
        local instance = class.new(...)
        local id = instance.getID():gsub('{I}','{S}')
        function instance.getID() return id end

        -- Create singleton metatable that proxies to internal instance
        local singleton_mt = {
            __index = function(t, k)
                local val = instance[k]
                if(type(val) == 'function') then
                    return function(...) return val(instance, ...) end
                end
                return val
            end,
            __newindex = function(t, k, v)
                instance[k] = v
            end
        }

        -- Delegate metamethods to internal instance
        for _,v in ipairs({'__call', '__add', '__sub', '__mul', '__div',
            '__mod', '__pow', '__unm', '__concat', '__len', '__eq', '__lt',
            '__le', '__ipairs', '__pairs', '__gc', '__tostring'}) do
            singleton_mt[v] = function(_, ...)
                return getmetatable(instance)[v](instance, ...)
            end
        end

        -- Create singleton table, store as a weak reference so it's possible
        --  to GC the class back to pristine state
        local singleton = setmetatable({}, singleton_mt)
        instances['singleton'] = singleton

        return singleton
    end

    return class, instance_mt
end
setmetatable(Class, {__call = function(_, ...) return Class.new(...) end})

--
--  Helper function for parameter table with defaults
--
function Class.defaults(defaults, params)
    local mt = {__index = defaults}
    return setmetatable(params or {}, mt)
end

---------------
-- Unit Tests
---------------
--[[
do
    local WrongClassName = Class('1Classname')
    assert(WrongClassName == nil)

    local Animal = Class('Animal')

    function Animal:initialize(kind)
        self.kind = kind
    end

    function Animal:getKind()
        return self.kind
    end

    local mrEd = Animal.new('horse')
    assert(mrEd:getKind() == 'horse')

    assert(Animal.class() == Animal)
    assert(Animal:class() == Animal)
    assert(mrEd:class() == Animal)
    assert(mrEd:className() == "Animal")

    local gunther = Animal.new('penguin')
    assert(gunther:initialize() == nil)
    assert(gunther:getKind() == 'penguin')

    local Plant = Class.new('Plant')

    function Plant:initialize(edible) self.edible = edible end

    function Plant:isEdible() return self.edible end

    local stella = Plant.new(false)
    assert(not stella:isEdible())
    assert(stella:className() == "Plant")

    assert(not stella.getKind)
    assert(not Animal.isInstance(nil))
    assert(not Animal.isInstance(stella))

    assert(stella:getID():match('^{I}Plant: 0x[0-9a-f]+$'))
    assert(stella:getID() == tostring(stella))
    assert(Plant.classInstanceCount() == 1)

    local Sing = Class.new('Singleton')
    assert(Sing.new())
    assert(Sing.newSingleton() == nil)

    local Sing2 = Class('Singleton2')
    local sing2i = Sing2.newSingleton()
    assert(sing2i)
    assert(Sing2.new() == sing2i)
    assert(sing2i:getID():match('{S}Singleton2: 0x[0-9a-f]+$'))
    assert(sing2i:getID() == tostring(sing2i))
    assert(sing2i.class() == Sing2)
end
-- This should clean up the instance/private tables from the tests
collectgarbage()
-- End Debug Comments ]]--

--

return Class

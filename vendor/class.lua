local Class = {
    _VERSION     = '0.4.6',
    _DESCRIPTION = 'Very simple class definition helper',
    _URL         = 'https://github.com/nomoon',
    _LONGDESC    = [[

        Simply define a class with the syntax:
            `MyClass = Class(classname, [existing_table])`
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

        Each instance's unique object ID can be retrieved via :getID()

        Complete Example:
            local Class = require('class')
            local Animal = Class('animal')

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

----------------------
-- Class Constructor
----------------------

setmetatable(Class, {__call = function(_, class_name, existing_table)
    if(not class_name:match("^%a%w*$")) then
        return nil, "Illegal class name."
    end
    class_name = class_name:gsub("^%l", string.upper)

    -- Define a base class table.
    local base_class
    if(type(existing_table) == 'table') then
        base_class = existing_table
    else
        base_class = {}
    end

    -- Define the metatable for instances of the class.
    local metatable = {
        __name = class_name,
        __index = base_class
    }
    function base_class.getMetatable() return metatable end

    -- Define a basic type checker
    function base_class.isInstance(obj)
        return (getmetatable(obj) == metatable)
    end
    -- Alias type-checker to function .is{ClassName}()
    base_class['is'..class_name] = base_class.isInstance

    function base_class.class() return base_class end
    function base_class.className(obj) return metatable.__name end
    function base_class.initialize() end

    -- Define private store and accessor method
    local private = setmetatable({}, {__mode = "k"})
    private[base_class] = {}
    function base_class.private(instance, value)
        if(base_class.isInstance(instance) or instance == base_class) then
            if(value and type(value) == 'table') then
                private[instance] = value
            end
            return private[instance]
        end
    end

    -- Setup class metatable for Class(params) constructor
    function base_class.new(...)
        -- Instantiate new class and make id from pointer
        local new_instance = {}
        local id = tostring(new_instance):match('0x[0-9a-f]+$')
        function new_instance.getID() return id end

        -- Now that we have the id, we can attach the metatable
        -- (in case __tostring got overwritten)
        setmetatable(new_instance, metatable)

        -- Create an empty private store for the instance
        private[new_instance] = {}

        -- Run user-defined constructor
        base_class.initialize(new_instance, ...)

        -- Override .initialize on instance to prevent re-initializing
        function new_instance.initialize() return end

        return new_instance
    end

    return base_class, metatable
end
})

---------------
-- Unit Tests
---------------
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

    assert(Animal.isInstance(mrEd))
    assert(Animal.isAnimal(mrEd))
    assert(mrEd:className() == "Animal")

    local gunther = Animal.new('penguin')
    assert(gunther:initialize() == nil)
    assert(gunther:getKind() == 'penguin')

    local Plant = Class('Plant')

    function Plant:initialize(edible)
        self.edible = edible
    end

    function Plant:isEdible()
        return self.edible
    end

    local stella = Plant.new(false)
    assert(not stella:isEdible())
    assert(stella:className() == "Plant")
    assert(Plant.isPlant(stella))

    assert(not stella.getKind)
    assert(not Animal.isInstance(nil))
    assert(not Animal.isInstance(stella))

    assert(stella:getID():match('0x[0-9a-f]+$'))
end

--

return Class

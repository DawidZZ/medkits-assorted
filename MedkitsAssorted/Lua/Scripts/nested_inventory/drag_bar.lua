local MA = MedkitsAssorted

local inventoryDescriptor = LuaUserData.RegisterType("Barotrauma.Inventory")
LuaUserData.MakeFieldAccessible(inventoryDescriptor, "movableFrameRect")

local function fixMovableFrame(container)
    local slots = {}
    MA.ForEach(container.Inventory.visualSlots, function(visualSlot) table.insert(slots, visualSlot.Rect) end)
    local count = #slots
    if count < 2 then return end

    local columns = 1
    while columns < count and slots[columns + 1].Y == slots[1].Y do columns = columns + 1 end
    if columns >= count or count % columns == 0 then return end

    local rowStep = slots[columns + 1].Y - slots[1].Y
    local frame = container.Inventory.movableFrameRect
    container.Inventory.movableFrameRect = Rectangle(
        slots[1].X - math.floor(10 * Inventory.UIScale), frame.Y + rowStep, frame.Width, frame.Height)
end

Hook.Patch("Barotrauma.Inventory", "UpdateSubInventory", { "System.Single", "System.Int32", "Barotrauma.Camera" },
    function(instance, ptable)
        local ok, err = pcall(function()
            local item = instance.GetItemAt(ptable["slotIndex"])
            if item == nil or string.sub(item.Prefab.Identifier.Value, 1, 4) ~= "mka_" then return end
            local container = item.GetComponentString("ItemContainer")
            if container ~= nil and container.MovableFrame then fixMovableFrame(container) end
        end)
        if not ok then MA.ReportOnce("frame", "Error while positioning the window's drag bar: " .. tostring(err)) end
    end, Hook.HookMethodType.After)

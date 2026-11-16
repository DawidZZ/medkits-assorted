local MA = MedkitsAssorted
local N = MA.Nested

local GAP = 20

local function estimateWidth(container, slotWidth)
    local columns = math.floor(math.sqrt(container.Inventory.Capacity))
    columns = math.max(1, math.min(columns, container.SlotsPerRow))
    return slotWidth * columns + 10 * Inventory.UIScale * (columns - 1)
end

local function horizontalExtent(inventory)
    local minX, maxX
    MA.ForEach(inventory.visualSlots, function(visualSlot)
        local rect = visualSlot.Rect
        if minX == nil or rect.X < minX then minX = rect.X end
        if maxX == nil or rect.Right > maxX then maxX = rect.Right end
    end)
    return minX, maxX
end

local function measureWidth(container)
    local minX, maxX = horizontalExtent(container.Inventory)
    if minX == nil then return nil end
    return maxX - minX
end

function N.UpdateBesidePocket(entry, pocket, deltaTime, cam)
    local visualSlot = entry.slot.Slot
    local original = visualSlot.Rect
    local scale = Inventory.UIScale

    local width = entry.width or estimateWidth(entry.container, original.Width)
    local pocketLeft = horizontalExtent(pocket) or original.X
    local targetStartX = pocketLeft - GAP * scale - width
    local dx = (targetStartX + width / 2) - original.Center.X

    local currentStartY
    if visualSlot.SubInventoryDir < 0 then
        currentStartY = visualSlot.EquipButtonRect.Y - original.Height - 35 * scale
    else
        currentStartY = visualSlot.EquipButtonRect.Bottom + 10 * scale
    end
    local targetStartY = original.Y + visualSlot.DrawOffset.Y
    local dy = targetStartY - currentStartY

    visualSlot.Rect = Rectangle(
        math.floor(original.X + dx + 0.5), math.floor(original.Y + dy + 0.5), original.Width, original.Height)
    local ok, err = pcall(function()
        pocket.UpdateSubInventory(deltaTime, entry.slot.SlotIndex, cam)
    end)
    visualSlot.Rect = original
    if not ok then error(err) end

    entry.width = measureWidth(entry.container) or width
end

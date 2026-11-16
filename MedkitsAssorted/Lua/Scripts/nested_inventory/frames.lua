local N = MedkitsAssorted.Nested

function N.FreezeFrame(container)
    if container.MovableFrame then
        container.MovableFrame = false
        N.Frozen[container.Item.ID] = container
    end
end

function N.RestoreFrames(character)
    for id, container in pairs(N.Frozen) do
        local item = container.Item
        if item == nil or item.Removed or not N.IsInCharactersPocket(item, character) then
            if item ~= nil and not item.Removed then container.MovableFrame = true end
            N.Frozen[id] = nil
            N.Open[id] = nil
        end
    end
end

local Block = toybox.Object("Block")

function Block:create()
    self:set_box()
    self.static = true
end

return Block
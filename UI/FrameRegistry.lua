

RGXProf.FrameRegistry = {}

function RGXProf.FrameRegistry:Register(frame, data)
    self[frame] = data
end

function RGXProf.FrameRegistry:Get(frame)
    return self[frame]
end

function RGXProf.FrameRegistry:Clear(frame)
    self[frame] = nil
end
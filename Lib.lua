local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScriptHub = {}

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.IgnoreGuiInset = true
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 400)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabHolder.Size = UDim2.new(0, 140, 1, 0)
TabHolder.Name = "Tabs"
Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 6)

local ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ContentHolder.Position = UDim2.new(0, 140, 0, 0)
ContentHolder.Size = UDim2.new(1, -140, 1, 0)
ContentHolder.Name = "Content"
Instance.new("UICorner", ContentHolder).CornerRadius = UDim.new(0, 6)

local TabLayout = Instance.new("UIListLayout", TabHolder)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 8)

local Tabs = {}

function ScriptHub:CreateTab(name)
    local TabButton = Instance.new("TextButton", TabHolder)
    TabButton.Size = UDim2.new(1, -16, 0, 38)
    TabButton.Position = UDim2.new(0, 8, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    TabButton.Text = name
    TabButton.Name = name
    TabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 18
    TabButton.AutoButtonColor = false
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)

    TabButton.MouseEnter:Connect(function()
        TabButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    end)
    TabButton.MouseLeave:Connect(function()
        TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)

    local TabFrame = Instance.new("ScrollingFrame", ContentHolder)
    TabFrame.Size = UDim2.new(1, -16, 1, -16)
    TabFrame.Position = UDim2.new(0, 8, 0, 8)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 6
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    local UIList = Instance.new("UIListLayout", TabFrame)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
    end)

    TabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        TabFrame.Visible = true
    end)

    Tabs[name] = TabFrame
end

function ScriptHub:AddToggleWithDropdown(tabName, text, callback)
    local ToggleFrame = Instance.new("Frame", Tabs[tabName])
    ToggleFrame.Size = UDim2.new(1, 0, 0, 34)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

    local ToggleBtn = Instance.new("TextButton", ToggleFrame)
    ToggleBtn.Size = UDim2.new(0.8, -6, 1, 0)
    ToggleBtn.Position = UDim2.new(0, 6, 0, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    ToggleBtn.Font = Enum.Font.Gotham
    ToggleBtn.TextSize = 17
    ToggleBtn.Name = text
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local DotsBtn = Instance.new("TextButton", ToggleFrame)
    DotsBtn.Size = UDim2.new(0.2, 0, 1, 0)
    DotsBtn.Position = UDim2.new(0.8, 0, 0, 0)
    DotsBtn.Text = "⋮"
    DotsBtn.BackgroundTransparency = 1
    DotsBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    DotsBtn.Font = Enum.Font.GothamBold
    DotsBtn.TextSize = 20

    local Dropdown = Instance.new("Frame", Tabs[tabName])
    Dropdown.Size = UDim2.new(1, 0, 0, 60)
    Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Dropdown.Visible = false
    Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 4)

    local state = Settings[text] or false
    ToggleBtn.Text = text .. (state and ": ON" or ": OFF")
    callback(state)

    local function updateToggleVisual(on)
        if on then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.BackgroundTransparency = 0
        else
            ToggleBtn.BackgroundColor3 = Color3.new(0, 0, 0, 0)
            ToggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            ToggleBtn.BackgroundTransparency = 1
        end
    end
    updateToggleVisual(state)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Settings[text] = state
        SaveSettings()
        ToggleBtn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
        updateToggleVisual(state)
    end)

    DotsBtn.MouseButton1Click:Connect(function()
        Dropdown.Visible = not Dropdown.Visible
    end)

    return Dropdown
end

function ScriptHub:AddSimpleToggle(tabName, text, callback)
    local ToggleFrame = Instance.new("Frame", Tabs[tabName])
    ToggleFrame.Size = UDim2.new(1, 0, 0, 34)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

    local ToggleBtn = Instance.new("TextButton", ToggleFrame)
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    ToggleBtn.Font = Enum.Font.Gotham
    ToggleBtn.TextSize = 17
    ToggleBtn.Name = text
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local state = Settings[text] or false
    ToggleBtn.Text = text .. (state and ": ON" or ": OFF")
    callback(state)

    local function updateToggleVisual(on)
        if on then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.BackgroundTransparency = 0
        else
            ToggleBtn.BackgroundColor3 = Color3.new(0, 0, 0, 0)
            ToggleBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            ToggleBtn.BackgroundTransparency = 1
        end
    end
    updateToggleVisual(state)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Settings[text] = state
        SaveSettings()
        ToggleBtn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
        updateToggleVisual(state)
    end)
end

function ScriptHub:AddSliderInDropdown(dropdownFrame, text, min, max, callback)
    local SliderLabel = Instance.new("TextLabel", dropdownFrame)
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 16
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local BarBack = Instance.new("Frame", dropdownFrame)
    BarBack.Position = UDim2.new(0, 10, 0, 30)
    BarBack.Size = UDim2.new(1, -20, 0, 10)
    BarBack.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", BarBack).CornerRadius = UDim.new(0, 3)

    local BarFill = Instance.new("Frame", BarBack)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 3)

    local dragging = false
    local value = Settings[text] or min

    local function UpdateSlider(inputX)
        local relativeX = math.clamp((inputX - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X, 0, 1)
        value = math.floor((relativeX * (max - min) + min) + 0.5)
        BarFill.Size = UDim2.new(relativeX, 0, 1, 0)
        SliderLabel.Text = text .. ": " .. tostring(value)
        Settings[text] = value
        SaveSettings()
        callback(value)
    end

    BarBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateSlider(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local initialPercent = (value - min) / (max - min)
    BarFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    SliderLabel.Text = text .. ": " .. tostring(value)
    callback(value)
end

function ScriptHub:AddDropdownInDropdown(dropdownFrame, text, options, callback)
    local Label = Instance.new("TextLabel", dropdownFrame)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 45)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text .. ": " .. (Settings[text] or options[1])

    local DropButton = Instance.new("TextButton", dropdownFrame)
    DropButton.Size = UDim2.new(1, -20, 0, 24)
    DropButton.Position = UDim2.new(0, 10, 0, 70)
    DropButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DropButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    DropButton.Font = Enum.Font.Gotham
    DropButton.TextSize = 16
    DropButton.Text = "Select"
    Instance.new("UICorner", DropButton).CornerRadius = UDim.new(0, 4)

    local OptionsFrame = Instance.new("Frame", dropdownFrame)
    OptionsFrame.Position = UDim2.new(0, 10, 0, 100)
    OptionsFrame.Size = UDim2.new(1, -20, 0, #options * 24)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    OptionsFrame.Visible = false
    Instance.new("UICorner", OptionsFrame).CornerRadius = UDim.new(0, 4)

    local Layout = Instance.new("UIListLayout", OptionsFrame)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 4)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton", OptionsFrame)
        OptBtn.Size = UDim2.new(1, 0, 0, 20)
        OptBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 15
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

        OptBtn.MouseButton1Click:Connect(function()
            Settings[text] = opt
            SaveSettings()
            Label.Text = text .. ": " .. opt
            callback(opt)
            OptionsFrame.Visible = false
        end)
    end

    DropButton.MouseButton1Click:Connect(function()
        OptionsFrame.Visible = not OptionsFrame.Visible
    end)
end

function ScriptHub:Notify(title, text, duration)
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("SendNotification", {
        Title = title or "ScriptHub",
        Text = text or "",
        Duration = duration or 5
    })
end

local function CreateOpenButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptHubOpenButton"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false

    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 120, 0, 40)
    openBtn.Position = UDim2.new(0, 10, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    openBtn.Text = "UI:"
    openBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    openBtn.Font = Enum.Font.GothamSemibold
    openBtn.TextSize = 18
    openBtn.Parent = screenGui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

    openBtn.MouseEnter:Connect(function()
        openBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    openBtn.MouseLeave:Connect(function()
        openBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)

    openBtn.MouseButton1Click:Connect(function()
        local mainFrame = MainFrame
        if mainFrame then
            mainFrame.Visible = not mainFrame.Visible
            openBtn.Text = mainFrame.Visible and "UI:" or "UI;"
        end
    end)
end

CreateOpenButton()

return ScriptHub

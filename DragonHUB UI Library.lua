--[[
    DragonUI Library
    Uma biblioteca de interface simples e leve para scripts Lua
    Versão: 1.0
]]

local DragonUI = {}
DragonUI.__index = DragonUI

-- Cores padrão e configurações
local config = {
    background = Color3.fromRGB(30, 30, 30),
    foreground = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(255, 70, 70),
    text = Color3.fromRGB(255, 255, 255),
    font = Enum.Font.SourceSansBold,
    titleSize = 14,
    textSize = 12,
    padding = 5,
    cornerRadius = 5,
    toggleSpeed = 0.2
}

-- Criar a janela principal
function DragonUI.new(title, position)
    local self = setmetatable({}, DragonUI)
    
    -- Propriedades principais
    self.title = title or "DragonUI"
    self.position = position or UDim2.new(0.5, -125, 0.5, -100)
    self.size = UDim2.new(0, 250, 0, 30) -- Começa pequeno, expande com elementos
    self.elements = {}
    self.currentY = 30 -- Posição Y inicial após o título
    self.dragging = false
    self.dragStart = nil
    self.startPos = nil
    
    -- Criar a interface
    self:CreateUI()
    
    return self
end

-- Criar a interface principal
function DragonUI:CreateUI()
    -- Criar o ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "DragonUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Verificar se existe CoreGui
    local parent = game:GetService("CoreGui")
    if not pcall(function() self.gui.Parent = parent end) then
        self.gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame principal
    self.main = Instance.new("Frame")
    self.main.Name = "Main"
    self.main.Size = self.size
    self.main.Position = self.position
    self.main.BackgroundColor3 = config.background
    self.main.BorderSizePixel = 0
    self.main.Active = true
    self.main.Draggable = false -- Implementamos arrastar customizado
    self.main.Parent = self.gui
    
    -- Arredondamento das bordas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.cornerRadius)
    corner.Parent = self.main
    
    -- Título da janela
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.Position = UDim2.new(0, 0, 0, 0)
    self.titleBar.BackgroundColor3 = config.accent
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, config.cornerRadius)
    titleCorner.Parent = self.titleBar
    
    -- Texto do título
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = self.title
    titleText.TextColor3 = config.text
    titleText.TextSize = config.titleSize
    titleText.Font = config.font
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = self.titleBar
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = config.text
    closeButton.TextSize = config.textSize
    closeButton.Font = config.font
    closeButton.Parent = self.titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, config.cornerRadius - 2)
    closeCorner.Parent = closeButton
    
    -- Container para elementos
    self.container = Instance.new("Frame")
    self.container.Name = "Container"
    self.container.Size = UDim2.new(1, -10, 1, -35)
    self.container.Position = UDim2.new(0, 5, 0, 30)
    self.container.BackgroundTransparency = 1
    self.container.BackgroundColor3 = config.background
    self.container.BorderSizePixel = 0
    self.container.Parent = self.main
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Configurar arrastar
    self:SetupDragging()
end

-- Configurar arrastamento da janela
function DragonUI:SetupDragging()
    local UserInputService = game:GetService("UserInputService")
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = self.main.Position
        end
    end)
    
    self.titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging then
            local delta = input.Position - self.dragStart
            self.main.Position = UDim2.new(
                self.startPos.X.Scale, 
                self.startPos.X.Offset + delta.X, 
                self.startPos.Y.Scale, 
                self.startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Adicionar um botão
function DragonUI:AddButton(text, callback)
    -- Criar botão
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, self.currentY)
    button.BackgroundColor3 = config.foreground
    button.Text = text
    button.TextColor3 = config.text
    button.TextSize = config.textSize
    button.Font = config.font
    button.Parent = self.container
    
    -- Arredondamento
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.cornerRadius - 2)
    corner.Parent = button
    
    -- Efeito hover
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = config.accent
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = config.foreground
    end)
    
    -- Callback
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    -- Atualizar posição Y para o próximo elemento
    self.currentY = self.currentY + 35
    
    -- Atualizar tamanho da janela
    self:UpdateSize()
    
    return button
end

-- Adicionar um toggle (botão de alternância)
function DragonUI:AddToggle(text, default, callback)
    -- Container para o toggle
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "Toggle_" .. text
    toggleContainer.Size = UDim2.new(1, 0, 0, 30)
    toggleContainer.Position = UDim2.new(0, 0, 0, self.currentY)
    toggleContainer.BackgroundColor3 = config.foreground
    toggleContainer.BorderSizePixel = 0
    toggleContainer.Parent = self.container
    
    -- Arredondamento
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.cornerRadius - 2)
    corner.Parent = toggleContainer
    
    -- Texto do toggle
    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "Text"
    toggleText.Size = UDim2.new(1, -50, 1, 0)
    toggleText.Position = UDim2.new(0, 10, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = text
    toggleText.TextColor3 = config.text
    toggleText.TextSize = config.textSize
    toggleText.Font = config.font
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleContainer
    
    -- Botão do toggle
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "Button"
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleContainer
    
    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(0, 10)
    toggleButtonCorner.Parent = toggleButton
    
    -- Indicador do toggle
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleButton
    
    local toggleIndicatorCorner = Instance.new("UICorner")
    toggleIndicatorCorner.CornerRadius = UDim.new(0, 8)
    toggleIndicatorCorner.Parent = toggleIndicator
    
    -- Estado do toggle
    local toggled = default or false
    
    -- Função para atualizar o estado visual
    local function updateToggle()
        if toggled then
            toggleButton.BackgroundColor3 = config.accent
            toggleIndicator:TweenPosition(
                UDim2.new(1, -18, 0.5, -8),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                config.toggleSpeed
            )
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            toggleIndicator:TweenPosition(
                UDim2.new(0, 2, 0.5, -8),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                config.toggleSpeed
            )
        end
        
        if callback then callback(toggled) end
    end
    
    -- Definir estado inicial
    updateToggle()
    
    -- Evento de clique
    toggleContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            updateToggle()
        end
    end)
    
    -- Efeito hover
    toggleContainer.MouseEnter:Connect(function()
        toggleContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    toggleContainer.MouseLeave:Connect(function()
        toggleContainer.BackgroundColor3 = config.foreground
    end)
    
    -- Atualizar posição Y para o próximo elemento
    self.currentY = self.currentY + 35
    
    -- Atualizar tamanho da janela
    self:UpdateSize()
    
    -- Interface para controlar o toggle externamente
    local toggleInterface = {
        Set = function(value)
            toggled = value
            updateToggle()
        end,
        Get = function()
            return toggled
        end,
        Toggle = function()
            toggled = not toggled
            updateToggle()
        end
    }
    
    return toggleInterface
end

-- Adicionar um texto simples
function DragonUI:AddLabel(text)
    -- Criar label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, self.currentY)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = config.text
    label.TextSize = config.textSize
    label.Font = config.font
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = self.container
    
    -- Atualizar posição Y para o próximo elemento
    self.currentY = self.currentY + 25
    
    -- Atualizar tamanho da janela
    self:UpdateSize()
    
    -- Interface para atualizar o texto
    local labelInterface = {
        SetText = function(newText)
            label.Text = newText
        end,
        GetText = function()
            return label.Text
        end
    }
    
    return labelInterface
end

-- Atualizar o tamanho da janela com base no conteúdo
function DragonUI:UpdateSize()
    self.main.Size = UDim2.new(0, 250, 0, self.currentY + 10)
end

-- Destruir a interface
function DragonUI:Destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return DragonUI

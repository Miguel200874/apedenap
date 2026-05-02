--[[
╔══════════════════════════════════════════════════════════════════╗
║          🐾 SEU PET CONTROLA VOCÊ - ROBLOX SCRIPT 🐾            ║
║                  Versão Ultra Complexa v2.0                      ║
║         Cole este script em: ServerScriptService                 ║
╚══════════════════════════════════════════════════════════════════╝

INSTRUÇÕES DE INSTALAÇÃO:
1. Abra o Roblox Studio
2. Vá em ServerScriptService
3. Crie um novo Script
4. Cole TODO este código
5. Também crie um LocalScript em StarterPlayerScripts para a UI
--]]

-- ============================================================
-- SERVIÇOS PRINCIPAIS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local PathfindingService = game:GetService("PathfindingService")
local TextService = game:GetService("TextService")
local Teams = game:GetService("Teams")

-- ============================================================
-- DATA STORES
-- ============================================================
local PlayerDataStore = DataStoreService:GetDataStore("PetControlaVoce_V2")
local PetDataStore = DataStoreService:GetDataStore("PetInventory_V2")

-- ============================================================
-- REMOTE EVENTS & FUNCTIONS
-- ============================================================
local RemoteFolder = Instance.new("Folder")
RemoteFolder.Name = "PetControlaVoceRemotes"
RemoteFolder.Parent = ReplicatedStorage

local function createRemote(name, isFunction)
	if isFunction then
		local rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = RemoteFolder
		return rf
	else
		local re = Instance.new("RemoteEvent")
		re.Name = name
		re.Parent = RemoteFolder
		return re
	end
end

local RE_PetAction       = createRemote("PetAction")
local RE_UpdateUI        = createRemote("UpdateUI")
local RE_ShowNotification = createRemote("ShowNotification")
local RE_PetPossess      = createRemote("PetPossess")
local RE_MissionUpdate   = createRemote("MissionUpdate")
local RE_EggHatch        = createRemote("EggHatch")
local RE_ShopPurchase    = createRemote("ShopPurchase")
local RE_ChaosEvent      = createRemote("ChaosEvent")
local RE_PetSpeak        = createRemote("PetSpeak")
local RE_PlayerEffect    = createRemote("PlayerEffect")
local RF_GetPlayerData   = createRemote("GetPlayerData", true)
local RF_BuyItem         = createRemote("BuyItem", true)

-- ============================================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================================
local CONFIG = {
	-- Pets disponíveis
	PETS = {
		CACHORRO = {
			name = "Cachorro",
			emoji = "🐶",
			rarity = "Comum",
			color = Color3.fromRGB(139, 90, 43),
			personality = "Energético",
			basePrice = 0,
			robuxPrice = 0,
			actions = {"correr", "latir", "buscar", "rolar", "pular_loucamente"},
			actionInterval = {min=3, max=8},
			chaosLevel = 3,
			description = "Faz você correr sem parar! Impossível ficar quieto!",
		},
		GATO = {
			name = "Gato",
			emoji = "🐱",
			rarity = "Comum",
			color = Color3.fromRGB(200, 200, 200),
			personality = "Preguiçoso/Destruidor",
			basePrice = 0,
			robuxPrice = 0,
			actions = {"derrubar_coisas", "deitar", "ignorar_missao", "arranhar", "empurrar_objetos"},
			actionInterval = {min=5, max=12},
			chaosLevel = 4,
			description = "Derruba tudo e dorme na hora errada!",
		},
		PAPAGAIO = {
			name = "Papagaio",
			emoji = "🦜",
			rarity = "Incomum",
			color = Color3.fromRGB(0, 200, 50),
			personality = "Falador",
			basePrice = 100,
			robuxPrice = 0,
			actions = {"falar_aleatorio", "imitar", "gritar", "revelar_segredo", "cantar"},
			actionInterval = {min=2, max=6},
			chaosLevel = 5,
			description = "Faz você falar coisas aleatórias e embaraçosas!",
		},
		HAMSTER = {
			name = "Hamster",
			emoji = "🐹",
			rarity = "Incomum",
			color = Color3.fromRGB(255, 200, 150),
			personality = "Explorador",
			basePrice = 150,
			robuxPrice = 0,
			actions = {"entrar_buraco", "girar_roda", "esconder", "cavar", "aparecer_surpresa"},
			actionInterval = {min=4, max=10},
			chaosLevel = 4,
			description = "Te manda para buracos secretos e esconderijos!",
		},
		MACACO = {
			name = "Macaco",
			emoji = "🐒",
			rarity = "Raro",
			color = Color3.fromRGB(150, 100, 50),
			personality = "Troll",
			basePrice = 500,
			robuxPrice = 49,
			actions = {"ativar_armadilha", "jogar_banana", "trocar_lugar", "confundir", "roubar_item"},
			actionInterval = {min=3, max=7},
			chaosLevel = 8,
			description = "O maior troll! Ativa armadilhas e rouba seus itens!",
		},
		DRAGAO = {
			name = "Dragão Bebê",
			emoji = "🐉",
			rarity = "Épico",
			color = Color3.fromRGB(255, 50, 50),
			personality = "Destruidor de Fogo",
			basePrice = 1000,
			robuxPrice = 99,
			actions = {"cuspir_fogo", "voar_sem_controle", "assustar_npcs", "queimar_missao", "rugir"},
			actionInterval = {min=2, max=5},
			chaosLevel = 9,
			description = "Cospe fogo sem avisar e destrói tudo ao redor!",
		},
		UNICORNIO = {
			name = "Unicórnio",
			emoji = "🦄",
			rarity = "Lendário",
			color = Color3.fromRGB(255, 100, 255),
			personality = "Mágico Caótico",
			basePrice = 5000,
			robuxPrice = 299,
			actions = {"teletransportar", "arco_iris_caos", "transformar_mundo", "magia_aleatoria", "possuir_jogador"},
			actionInterval = {min=1, max=4},
			chaosLevel = 10,
			description = "Magia pura e caos total! O mais raro de todos!",
		},
		ALIEN = {
			name = "Alien Pet",
			emoji = "👽",
			rarity = "Mítico",
			color = Color3.fromRGB(0, 255, 150),
			personality = "Invasor",
			basePrice = 10000,
			robuxPrice = 499,
			actions = {"abducao", "controle_mental", "gravidade_zero", "clone_jogador", "invasao_total"},
			actionInterval = {min=1, max=3},
			chaosLevel = 10,
			description = "MÍTICO! Controle mental total e abdução!",
		},
	},

	-- Missões disponíveis
	MISSIONS = {
		{id="escola", name="Ir para a Escola", emoji="🏫", reward=50, time=120, difficulty="Fácil"},
		{id="trabalho", name="Ir Trabalhar", emoji="💼", reward=100, time=180, difficulty="Médio"},
		{id="delivery", name="Fazer Delivery", emoji="🛵", reward=75, time=90, difficulty="Fácil"},
		{id="professora", name="Escapar da Professora", emoji="👩‍🏫", reward=150, time=60, difficulty="Difícil"},
		{id="shopping", name="Sobreviver no Shopping", emoji="🛍️", reward=200, time=240, difficulty="Épico"},
		{id="banco", name="Não Ser Expulso do Banco", emoji="🏦", reward=300, time=120, difficulty="Épico"},
		{id="cinema", name="Assistir o Filme Inteiro", emoji="🎬", reward=125, time=180, difficulty="Médio"},
		{id="parque", name="Passear no Parque", emoji="🌳", reward=80, time=150, difficulty="Fácil"},
	},

	-- Frases do Papagaio
	PAPAGAIO_FRASES = {
		"EU AMO BANANA!",
		"POLLY QUER BISCOITO!",
		"SOCORRO ME AJUDA!",
		"SQUAWK SQUAWK!",
		"EU SOU UM HUMANO!",
		"MEU PET ME CONTROLA!",
		"ALGUÉM ME SALVA!",
		"CACAU CACAU!",
		"EU NÃO QUERO IR PRA ESCOLA!",
		"MINHA MÃE VAI SABER DISSO!",
		"SQUAWK! SQUAWK! SQUAWK!",
		"EU SOU UM PAPAGAIO HUMANO!",
		"REPITO TUDO QUE OUÇO!",
		"BLAH BLAH BLAH!",
		"SOCORRO O PET FUGIU!",
	},

	-- Produtos Robux (Game Passes e Developer Products)
	GAMEPASSES = {
		CONTROLE_TOTAL = 123456789, -- Substitua pelo ID real
		PET_LENDARIO   = 123456790,
		CAOS_DUPLO     = 123456791,
		VIP            = 123456792,
	},

	DEV_PRODUCTS = {
		OVO_COMUM    = 1234567890,
		OVO_RARO     = 1234567891,
		OVO_EPICO    = 1234567892,
		OVO_LENDARIO = 1234567893,
		CONTROLE_5MIN = 1234567894,
		MOEDAS_1000  = 1234567895,
	},

	-- Raridades e chances de ovo
	EGG_CHANCES = {
		COMUM = {
			{pet="CACHORRO", chance=40},
			{pet="GATO", chance=35},
			{pet="PAPAGAIO", chance=15},
			{pet="HAMSTER", chance=10},
		},
		RARO = {
			{pet="PAPAGAIO", chance=30},
			{pet="HAMSTER", chance=25},
			{pet="MACACO", chance=30},
			{pet="DRAGAO", chance=15},
		},
		EPICO = {
			{pet="MACACO", chance=25},
			{pet="DRAGAO", chance=40},
			{pet="UNICORNIO", chance=30},
			{pet="ALIEN", chance=5},
		},
		LENDARIO = {
			{pet="DRAGAO", chance=20},
			{pet="UNICORNIO", chance=40},
			{pet="ALIEN", chance=40},
		},
	},
}

-- ============================================================
-- SISTEMA DE DADOS DO JOGADOR
-- ============================================================
local PlayerData = {}

local DEFAULT_DATA = {
	coins = 100,
	robux_spent = 0,
	activePet = "CACHORRO",
	ownedPets = {"CACHORRO"},
	petLevel = {CACHORRO=1},
	petXP = {CACHORRO=0},
	missionsCompleted = 0,
	missionsFailed = 0,
	totalChaosEvents = 0,
	possessionsGiven = 0,
	possessionsReceived = 0,
	achievements = {},
	currentMission = nil,
	missionProgress = 0,
	controlPowerup = false,
	controlPowerupExpiry = 0,
	joinDate = os.time(),
	lastLogin = os.time(),
	totalPlaytime = 0,
	vip = false,
	eggInventory = {},
	stats = {
		timesRan = 0,
		thingsKnockedOver = 0,
		randomPhrasesSaid = 0,
		secretHolesEntered = 0,
		trapsActivated = 0,
		fireBreaths = 0,
		teleports = 0,
		possessions = 0,
	}
}

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function loadPlayerData(player)
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync("Player_" .. player.UserId)
	end)
	if success and data then
		-- Merge com defaults para novos campos
		local merged = deepCopy(DEFAULT_DATA)
		for k, v in pairs(data) do
			merged[k] = v
		end
		PlayerData[player.UserId] = merged
	else
		PlayerData[player.UserId] = deepCopy(DEFAULT_DATA)
	end
	return PlayerData[player.UserId]
end

local function savePlayerData(player)
	if not PlayerData[player.UserId] then return end
	local success, err = pcall(function()
		PlayerDataStore:SetAsync("Player_" .. player.UserId, PlayerData[player.UserId])
	end)
	if not success then
		warn("Erro ao salvar dados de " .. player.Name .. ": " .. tostring(err))
	end
end

-- ============================================================
-- SISTEMA DE PETS - NÚCLEO
-- ============================================================
local ActivePetSystems = {} -- {[userId] = {petThread, currentAction, ...}}

local function getPetConfig(petKey)
	return CONFIG.PETS[petKey]
end

local function getPlayerPetConfig(player)
	local data = PlayerData[player.UserId]
	if not data then return CONFIG.PETS.CACHORRO end
	return CONFIG.PETS[data.activePet] or CONFIG.PETS.CACHORRO
end

-- Notificação para o jogador
local function notify(player, title, message, petEmoji, duration)
	RE_ShowNotification:FireClient(player, {
		title = title,
		message = message,
		emoji = petEmoji or "🐾",
		duration = duration or 4,
	})
end

-- ============================================================
-- AÇÕES DOS PETS (SERVIDOR)
-- ============================================================

-- 🐶 CACHORRO - Ações
local function cachorro_correr(player, character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	local data = PlayerData[player.UserId]
	
	-- Aumenta velocidade drasticamente
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 50
	humanoid.JumpPower = 80
	
	notify(player, "🐶 CACHORRO ENLOUQUECEU!", "CORRE! CORRE! CORRE! Sem parar!", "🐶", 3)
	RE_PlayerEffect:FireClient(player, {effect="run_crazy", duration=8})
	
	if data then data.stats.timesRan = (data.stats.timesRan or 0) + 1 end
	
	-- Força movimento aleatório via efeito no cliente
	task.delay(8, function()
		if character and character.Parent and humanoid and humanoid.Parent then
			humanoid.WalkSpeed = originalSpeed
			humanoid.JumpPower = 50
		end
	end)
end

local function cachorro_latir(player, character)
	notify(player, "🐶 AU AU AU!", "Seu cachorro está latindo! Todo mundo olhou pra você!", "🐶", 3)
	RE_PetSpeak:FireAllClients(player, "AU AU AU! AU AU! AUUUUU!", "🐶")
	
	-- Assusta NPCs próximos
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, obj in pairs(Workspace:GetChildren()) do
			if obj:IsA("Model") and obj ~= character then
				local npcHRP = obj:FindFirstChild("HumanoidRootPart")
				local npcHum = obj:FindFirstChild("Humanoid")
				if npcHRP and npcHum and (hrp.Position - npcHRP.Position).Magnitude < 20 then
					-- Faz NPC fugir
					local direction = (npcHRP.Position - hrp.Position).Unit
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = direction * 30
					bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
					bodyVelocity.Parent = npcHRP
					game:GetService("Debris"):AddItem(bodyVelocity, 1)
				end
			end
		end
	end
end

local function cachorro_buscar(player, character)
	notify(player, "🐶 BUSCA!", "Seu cachorro jogou algo longe e quer que você busque!", "🐶", 4)
	RE_PlayerEffect:FireClient(player, {effect="fetch_mode", duration=10})
	
	-- Cria um objeto para "buscar"
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local ball = Instance.new("Part")
		ball.Name = "FetchBall_" .. player.UserId
		ball.Size = Vector3.new(1, 1, 1)
		ball.Shape = Enum.PartType.Ball
		ball.BrickColor = BrickColor.new("Bright red")
		ball.Material = Enum.Material.SmoothPlastic
		ball.Position = hrp.Position + Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
		ball.Parent = Workspace
		
		-- Adiciona brilho
		local light = Instance.new("PointLight")
		light.Brightness = 5
		light.Color = Color3.fromRGB(255, 100, 100)
		light.Parent = ball
		
		game:GetService("Debris"):AddItem(ball, 15)
		
		-- Verifica se jogador chegou perto
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not character or not character.Parent or not ball or not ball.Parent then
				connection:Disconnect()
				return
			end
			local dist = (hrp.Position - ball.Position).Magnitude
			if dist < 5 then
				notify(player, "🐶 BUSCOU!", "Boa! Seu cachorro ficou feliz! +10 moedas!", "🐶", 3)
				PlayerData[player.UserId].coins = (PlayerData[player.UserId].coins or 0) + 10
				RE_UpdateUI:FireClient(player, PlayerData[player.UserId])
				ball:Destroy()
				connection:Disconnect()
			end
		end)
	end
end

local function cachorro_pular_loucamente(player, character)
	local humanoid = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end
	
	notify(player, "🐶 PULA! PULA! PULA!", "Seu cachorro quer pular em tudo!", "🐶", 3)
	
	-- Força pulos repetidos
	local jumpCount = 0
	local jumpThread = task.spawn(function()
		while jumpCount < 8 do
			if not character or not character.Parent then break end
			humanoid.Jump = true
			task.wait(0.8)
			jumpCount = jumpCount + 1
		end
	end)
end

-- 🐱 GATO - Ações
local function gato_derrubar_coisas(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = PlayerData[player.UserId]
	if data then data.stats.thingsKnockedOver = (data.stats.thingsKnockedOver or 0) + 1 end
	
	notify(player, "🐱 DERRUBOU TUDO!", "Seu gato empurrou tudo que estava na mesa!", "🐱", 4)
	RE_PlayerEffect:FireClient(player, {effect="knock_things", duration=5})
	
	-- Derruba objetos próximos
	local knockCount = 0
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < 15 and knockCount < 10 then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(
					math.random(-20, 20),
					math.random(5, 15),
					math.random(-20, 20)
				)
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = obj
				game:GetService("Debris"):AddItem(bv, 0.5)
				knockCount = knockCount + 1
			end
		end
	end
	
	-- Efeito sonoro
	RE_ChaosEvent:FireAllClients({
		type = "sound",
		sound = "crash",
		position = hrp.Position,
	})
end

local function gato_deitar(player, character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	notify(player, "🐱 HORA DA SONECA!", "Seu gato decidiu dormir AGORA. Você também vai!", "🐱", 5)
	
	-- Força animação de deitar
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	RE_PlayerEffect:FireClient(player, {effect="sleep", duration=6})
	
	task.delay(6, function()
		if character and character.Parent and humanoid and humanoid.Parent then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			notify(player, "🐱 Acordou!", "Seu gato acordou... por enquanto.", "🐱", 2)
		end
	end)
end

local function gato_empurrar_objetos(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	notify(player, "🐱 EMPURRANDO...", "Seu gato está empurrando coisas da beira!", "🐱", 3)
	
	-- Encontra objeto próximo e empurra
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < 10 then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(0, -50, 0) -- Empurra para baixo
				bv.MaxForce = Vector3.new(0, 1e5, 0)
				bv.Parent = obj
				game:GetService("Debris"):AddItem(bv, 0.3)
				break
			end
		end
	end
end

-- 🦜 PAPAGAIO - Ações
local function papagaio_falar(player, character)
	local data = PlayerData[player.UserId]
	if data then data.stats.randomPhrasesSaid = (data.stats.randomPhrasesSaid or 0) + 1 end
	
	local frase = CONFIG.PAPAGAIO_FRASES[math.random(1, #CONFIG.PAPAGAIO_FRASES)]
	
	notify(player, "🦜 SQUAWK!", "Seu papagaio fez você gritar: " .. frase, "🦜", 4)
	RE_PetSpeak:FireAllClients(player, frase, "🦜")
	
	-- Cria chat bubble
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 60)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = false
		billboard.Parent = hrp
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
		label.TextColor3 = Color3.fromRGB(0, 0, 0)
		label.Text = "🦜 " .. frase
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
		
		game:GetService("Debris"):AddItem(billboard, 4)
	end
end

local function papagaio_imitar(player, character)
	-- Imita o jogador mais próximo
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local closestPlayer = nil
	local closestDist = math.huge
	
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherHRP then
				local dist = (hrp.Position - otherHRP.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = otherPlayer
				end
			end
		end
	end
	
	if closestPlayer then
		notify(player, "🦜 IMITANDO!", "Seu papagaio está imitando " .. closestPlayer.Name .. "!", "🦜", 4)
		RE_PetSpeak:FireAllClients(player, "EU SOU " .. closestPlayer.Name:upper() .. "! SQUAWK!", "🦜")
	else
		papagaio_falar(player, character)
	end
end

local function papagaio_revelar_segredo(player, character)
	local segredos = {
		player.Name .. " tem medo de aranhas!",
		player.Name .. " ainda dorme com ursinho!",
		player.Name .. " comeu cola na escola!",
		player.Name .. " chora assistindo Toy Story!",
		player.Name .. " fala dormindo!",
		player.Name .. " tem 47 tabs abertas no navegador!",
		player.Name .. " nunca terminou o Minecraft!",
	}
	local segredo = segredos[math.random(1, #segredos)]
	
	notify(player, "🦜 SEGREDO REVELADO!", "Seu papagaio contou: " .. segredo, "🦜", 5)
	RE_PetSpeak:FireAllClients(player, "SQUAWK! " .. segredo:upper() .. " SQUAWK!", "🦜")
end

-- 🐹 HAMSTER - Ações
local function hamster_buraco(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = PlayerData[player.UserId]
	if data then data.stats.secretHolesEntered = (data.stats.secretHolesEntered or 0) + 1 end
	
	notify(player, "🐹 BURACO SECRETO!", "Seu hamster encontrou um buraco secreto! Entrando...", "🐹", 4)
	
	-- Teletransporta para posição aleatória (simula buraco)
	local randomOffset = Vector3.new(
		math.random(-50, 50),
		0,
		math.random(-50, 50)
	)
	
	-- Efeito de desaparecer
	RE_PlayerEffect:FireClient(player, {effect="tunnel", duration=2})
	
	task.delay(1, function()
		if character and character.Parent and hrp and hrp.Parent then
			-- Teletransporta
			local newPos = hrp.Position + randomOffset
			hrp.CFrame = CFrame.new(newPos + Vector3.new(0, 5, 0))
			
			task.delay(1, function()
				notify(player, "🐹 SAIU DO BURACO!", "Você emergiu em um lugar misterioso!", "🐹", 3)
			end)
		end
	end)
end

local function hamster_girar_roda(player, character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	notify(player, "🐹 RODA GIRATÓRIA!", "Seu hamster quer girar! Você está correndo em círculos!", "🐹", 4)
	RE_PlayerEffect:FireClient(player, {effect="spin_circle", duration=8})
	
	-- Aumenta velocidade mas força rotação
	humanoid.WalkSpeed = 30
	task.delay(8, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = 16
		end
	end)
end

local function hamster_aparecer_surpresa(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Aparece do nada em frente a outro jogador
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			if otherHRP then
				hrp.CFrame = CFrame.new(otherHRP.Position + Vector3.new(0, 0, 3))
				notify(player, "🐹 SURPRESA!", "Seu hamster te teletransportou na frente de " .. otherPlayer.Name .. "!", "🐹", 3)
				notify(otherPlayer, "😱 SUSTO!", player.Name .. " apareceu do nada!", "🐹", 3)
				break
			end
		end
	end
end

-- 🐒 MACACO - Ações
local function macaco_armadilha(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = PlayerData[player.UserId]
	if data then data.stats.trapsActivated = (data.stats.trapsActivated or 0) + 1 end
	
	notify(player, "🐒 ARMADILHA ATIVADA!", "Seu macaco ativou uma armadilha! Cuidado!", "🐒", 4)
	
	-- Cria armadilha de banana
	local trap = Instance.new("Part")
	trap.Name = "BananaTrap"
	trap.Size = Vector3.new(3, 0.2, 3)
	trap.BrickColor = BrickColor.new("Bright yellow")
	trap.Material = Enum.Material.SmoothPlastic
	trap.Anchored = true
	trap.Position = hrp.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
	trap.Parent = Workspace
	
	-- Decal de banana
	local decal = Instance.new("Decal")
	decal.Texture = "rbxassetid://1234567" -- Substitua por textura real
	decal.Face = Enum.NormalId.Top
	decal.Parent = trap
	
	-- Detecta jogadores que pisam
	local trapConnection
	trapConnection = RunService.Heartbeat:Connect(function()
		if not trap or not trap.Parent then
			trapConnection:Disconnect()
			return
		end
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character then
				local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
				if pHRP and (pHRP.Position - trap.Position).Magnitude < 3 then
					local pHum = p.Character:FindFirstChild("Humanoid")
					if pHum then
						-- Escorrega!
						local bv = Instance.new("BodyVelocity")
						bv.Velocity = Vector3.new(math.random(-20, 20), 10, math.random(-20, 20))
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = pHRP
						game:GetService("Debris"):AddItem(bv, 0.5)
						notify(p, "🍌 ESCORREGOU!", "Você pisou na casca de banana do macaco!", "🐒", 3)
					end
				end
			end
		end
	end)
	
	game:GetService("Debris"):AddItem(trap, 20)
	task.delay(20, function() trapConnection:Disconnect() end)
end

local function macaco_trocar_lugar(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Troca de lugar com jogador aleatório
	local otherPlayers = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(otherPlayers, p)
		end
	end
	
	if #otherPlayers > 0 then
		local target = otherPlayers[math.random(1, #otherPlayers)]
		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
		
		local pos1 = hrp.CFrame
		local pos2 = targetHRP.CFrame
		
		hrp.CFrame = pos2
		targetHRP.CFrame = pos1
		
		notify(player, "🐒 TROCOU DE LUGAR!", "Seu macaco trocou você com " .. target.Name .. "!", "🐒", 4)
		notify(target, "🐒 TROCOU DE LUGAR!", player.Name .. " trocou de lugar com você! Culpa do macaco!", "🐒", 4)
	end
end

local function macaco_roubar_item(player, character)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	-- Rouba moedas
	local roubado = math.random(10, 50)
	if data.coins >= roubado then
		data.coins = data.coins - roubado
		notify(player, "🐒 ROUBOU!", "Seu macaco roubou " .. roubado .. " moedas suas! 😂", "🐒", 4)
		RE_UpdateUI:FireClient(player, data)
		
		-- Dá para jogador aleatório
		local others = Players:GetPlayers()
		if #others > 1 then
			local target = others[math.random(1, #others)]
			if target ~= player and PlayerData[target.UserId] then
				PlayerData[target.UserId].coins = (PlayerData[target.UserId].coins or 0) + roubado
				notify(target, "🐒 PRESENTE!", "O macaco de " .. player.Name .. " te deu " .. roubado .. " moedas!", "🐒", 4)
				RE_UpdateUI:FireClient(target, PlayerData[target.UserId])
			end
		end
	end
end

-- 🐉 DRAGÃO - Ações
local function dragao_fogo(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = PlayerData[player.UserId]
	if data then data.stats.fireBreaths = (data.stats.fireBreaths or 0) + 1 end
	
	notify(player, "🐉 FOGO SEM AVISAR!", "Seu dragão cuspiu fogo! Tudo está pegando fogo!", "🐉", 4)
	RE_PlayerEffect:FireClient(player, {effect="fire_breath", duration=5})
	
	-- Cria partículas de fogo
	local fireAttachment = Instance.new("Attachment")
	fireAttachment.Parent = hrp
	
	local fire = Instance.new("Fire")
	fire.Size = 10
	fire.Heat = 25
	fire.Color = Color3.fromRGB(255, 100, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 0)
	fire.Parent = fireAttachment
	
	-- Dano a jogadores próximos (sem matar)
	local fireThread = task.spawn(function()
		for i = 1, 5 do
			task.wait(1)
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player and p.Character then
					local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
					local pHum = p.Character:FindFirstChild("Humanoid")
					if pHRP and pHum and (pHRP.Position - hrp.Position).Magnitude < 15 then
						pHum:TakeDamage(5)
						notify(p, "🔥 QUEIMANDO!", player.Name .. "'s dragão te acertou com fogo!", "🐉", 2)
					end
				end
			end
		end
	end)
	
	game:GetService("Debris"):AddItem(fireAttachment, 5)
end

local function dragao_voar(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end
	
	notify(player, "🐉 VOANDO SEM CONTROLE!", "Seu dragão está voando! Você não controla a direção!", "🐉", 5)
	RE_PlayerEffect:FireClient(player, {effect="fly_chaos", duration=8})
	
	-- Força voo caótico
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVelocity.Parent = hrp
	
	local elapsed = 0
	local flyThread
	flyThread = RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= 8 or not character or not character.Parent then
			bodyVelocity:Destroy()
			flyThread:Disconnect()
			return
		end
		bodyVelocity.Velocity = Vector3.new(
			math.sin(elapsed * 2) * 20,
			math.abs(math.sin(elapsed)) * 15 + 5,
			math.cos(elapsed * 1.5) * 20
		)
	end)
end

local function dragao_rugir(player, character)
	notify(player, "🐉 RUGIDO ÉPICO!", "Seu dragão rugiu! Todos os jogadores próximos foram empurrados!", "🐉", 4)
	RE_ChaosEvent:FireAllClients({type="roar", player=player.Name})
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Empurra todos os jogadores próximos
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
			if pHRP and (pHRP.Position - hrp.Position).Magnitude < 30 then
				local direction = (pHRP.Position - hrp.Position).Unit
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = direction * 40 + Vector3.new(0, 20, 0)
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = pHRP
				game:GetService("Debris"):AddItem(bv, 0.5)
				notify(p, "🐉 RUGIDO!", "O dragão de " .. player.Name .. " te empurrou!", "🐉", 3)
			end
		end
	end
end

-- 🦄 UNICÓRNIO - Ações
local function unicornio_teletransportar(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local data = PlayerData[player.UserId]
	if data then data.stats.teleports = (data.stats.teleports or 0) + 1 end
	
	notify(player, "🦄 TELETRANSPORTE MÁGICO!", "Seu unicórnio te teletransportou para lugar aleatório!", "🦄", 4)
	RE_PlayerEffect:FireClient(player, {effect="rainbow_teleport", duration=2})
	
	task.delay(0.5, function()
		if character and character.Parent and hrp and hrp.Parent then
			hrp.CFrame = CFrame.new(
				math.random(-200, 200),
				50,
				math.random(-200, 200)
			)
		end
	end)
end

local function unicornio_arco_iris(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	notify(player, "🦄 ARCO-ÍRIS DO CAOS!", "Seu unicórnio pintou o mundo de arco-íris!", "🦄", 5)
	RE_ChaosEvent:FireAllClients({type="rainbow_chaos", player=player.Name})
	RE_PlayerEffect:FireClient(player, {effect="rainbow_world", duration=10})
	
	-- Cria partes coloridas ao redor
	local colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 165, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(238, 130, 238),
	}
	
	for i = 1, 20 do
		local part = Instance.new("Part")
		part.Size = Vector3.new(2, 2, 2)
		part.Color = colors[math.random(1, #colors)]
		part.Material = Enum.Material.Neon
		part.Anchored = false
		part.Position = hrp.Position + Vector3.new(
			math.random(-20, 20),
			math.random(0, 20),
			math.random(-20, 20)
		)
		part.Parent = Workspace
		game:GetService("Debris"):AddItem(part, 8)
	end
end

local function unicornio_possuir_jogador(player, character)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	-- Encontra jogador aleatório para possuir
	local targets = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			table.insert(targets, p)
		end
	end
	
	if #targets == 0 then
		notify(player, "🦄 SEM ALVO!", "Não há outros jogadores para possuir!", "🦄", 3)
		return
	end
	
	local target = targets[math.random(1, #targets)]
	data.stats.possessions = (data.stats.possessions or 0) + 1
	
	notify(player, "🦄 POSSESSÃO!", "Seu unicórnio está possuindo " .. target.Name .. " por 10 segundos!", "🦄", 5)
	notify(target, "🦄 POSSUÍDO!", player.Name .. "'s unicórnio está te controlando! Resistência inútil!", "🦄", 5)
	
	RE_PetPossess:FireClient(target, {
		possessor = player.Name,
		duration = 10,
		petType = "UNICORNIO",
	})
	
	-- Força ações aleatórias no jogador possuído
	local possessThread = task.spawn(function()
		for i = 1, 5 do
			task.wait(2)
			if target.Character then
				local targetHum = target.Character:FindFirstChild("Humanoid")
				local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
				if targetHum and targetHRP then
					-- Ação aleatória
					local actions = {
						function() targetHum.Jump = true end,
						function() targetHum.WalkSpeed = 40 end,
						function()
							local bv = Instance.new("BodyVelocity")
							bv.Velocity = Vector3.new(math.random(-20,20), 15, math.random(-20,20))
							bv.MaxForce = Vector3.new(1e5,1e5,1e5)
							bv.Parent = targetHRP
							game:GetService("Debris"):AddItem(bv, 0.5)
						end,
					}
					actions[math.random(1, #actions)]()
				end
			end
		end
		if target.Character then
			local targetHum = target.Character:FindFirstChild("Humanoid")
			if targetHum then targetHum.WalkSpeed = 16 end
		end
		notify(target, "🦄 LIVRE!", "A possessão acabou! Você está livre!", "🦄", 3)
	end)
end

-- 👽 ALIEN - Ações
local function alien_abducao(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	notify(player, "👽 ABDUÇÃO!", "Seu alien está te abduzindo! Você está subindo!", "👽", 5)
	RE_PlayerEffect:FireClient(player, {effect="abduction_beam", duration=5})
	
	-- Puxa para cima
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 50, 0)
	bv.MaxForce = Vector3.new(0, 1e5, 0)
	bv.Parent = hrp
	
	task.delay(3, function()
		if bv and bv.Parent then
			bv:Destroy()
		end
		-- Cai de volta
		task.delay(2, function()
			notify(player, "👽 DEVOLVIDO!", "O alien te devolveu... em outro lugar!", "👽", 3)
			if hrp and hrp.Parent then
				hrp.CFrame = CFrame.new(
					math.random(-100, 100),
					50,
					math.random(-100, 100)
				)
			end
		end)
	end)
end

local function alien_gravidade_zero(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end
	
	notify(player, "👽 GRAVIDADE ZERO!", "Seu alien desativou a gravidade! Você está flutuando!", "👽", 5)
	RE_PlayerEffect:FireClient(player, {effect="zero_gravity", duration=10})
	
	-- Simula gravidade zero
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.MaxForce = Vector3.new(0, 1e4, 0)
	bv.Parent = hrp
	
	humanoid.WalkSpeed = 5
	
	task.delay(10, function()
		if bv and bv.Parent then bv:Destroy() end
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = 16
		end
		notify(player, "👽 Gravidade voltou!", "Cuidado com a queda!", "👽", 2)
	end)
end

local function alien_clone(player, character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	notify(player, "👽 CLONE CRIADO!", "Seu alien criou um clone seu que vai atrapalhar todos!", "👽", 5)
	
	-- Cria clone visual (parte simples)
	local clone = Instance.new("Model")
	clone.Name = "Clone_" .. player.Name
	
	local cloneBody = Instance.new("Part")
	cloneBody.Size = Vector3.new(2, 5, 1)
	cloneBody.BrickColor = BrickColor.new("Bright green")
	cloneBody.Material = Enum.Material.Neon
	cloneBody.CFrame = hrp.CFrame + Vector3.new(5, 0, 0)
	cloneBody.Parent = clone
	
	local cloneHead = Instance.new("Part")
	cloneHead.Size = Vector3.new(2, 2, 2)
	cloneHead.BrickColor = BrickColor.new("Bright green")
	cloneHead.Material = Enum.Material.Neon
	cloneHead.CFrame = cloneBody.CFrame + Vector3.new(0, 3.5, 0)
	cloneHead.Parent = clone
	
	local nameTag = Instance.new("BillboardGui")
	nameTag.Size = UDim2.new(0, 150, 0, 40)
	nameTag.StudsOffset = Vector3.new(0, 2, 0)
	nameTag.Parent = cloneHead
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "👽 " .. player.Name .. " (CLONE)"
	nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = nameTag
	
	clone.Parent = Workspace
	
	-- Move clone aleatoriamente
	local cloneThread
	cloneThread = RunService.Heartbeat:Connect(function()
		if not clone or not clone.Parent then
			cloneThread:Disconnect()
			return
		end
		if cloneBody and cloneBody.Parent then
			cloneBody.CFrame = cloneBody.CFrame * CFrame.new(
				math.random(-1, 1) * 0.1,
				0,
				math.random(-1, 1) * 0.1
			)
		end
	end)
	
	game:GetService("Debris"):AddItem(clone, 15)
	task.delay(15, function() cloneThread:Disconnect() end)
end

local function alien_invasao_total(player, character)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	notify(player, "👽 INVASÃO TOTAL!", "Seu alien está invadindo TODOS os jogadores simultaneamente!", "👽", 6)
	RE_ChaosEvent:FireAllClients({type="alien_invasion", player=player.Name})
	
	-- Afeta todos os jogadores
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
			local pHum = p.Character:FindFirstChild("Humanoid")
			if pHRP and pHum then
				-- Efeito aleatório em cada jogador
				local effects = {
					function()
						pHum.WalkSpeed = 0
						task.delay(5, function()
							if pHum and pHum.Parent then pHum.WalkSpeed = 16 end
						end)
					end,
					function()
						local bv = Instance.new("BodyVelocity")
						bv.Velocity = Vector3.new(0, 30, 0)
						bv.MaxForce = Vector3.new(0, 1e5, 0)
						bv.Parent = pHRP
						game:GetService("Debris"):AddItem(bv, 1)
					end,
					function()
						pHum.WalkSpeed = 50
						task.delay(5, function()
							if pHum and pHum.Parent then pHum.WalkSpeed = 16 end
						end)
					end,
				}
				effects[math.random(1, #effects)]()
				notify(p, "👽 INVASÃO ALIEN!", player.Name .. "'s alien está te controlando!", "👽", 4)
				RE_PetPossess:FireClient(p, {
					possessor = player.Name,
					duration = 5,
					petType = "ALIEN",
				})
			end
		end
	end
end

-- ============================================================
-- MAPEAMENTO DE AÇÕES
-- ============================================================
local PET_ACTIONS = {
	CACHORRO = {
		correr = cachorro_correr,
		latir = cachorro_latir,
		buscar = cachorro_buscar,
		rolar = function(p, c) 
			notify(p, "🐶 ROLANDO!", "Seu cachorro está rolando no chão!", "🐶", 3)
			RE_PlayerEffect:FireClient(p, {effect="roll", duration=3})
		end,
		pular_loucamente = cachorro_pular_loucamente,
	},
	GATO = {
		derrubar_coisas = gato_derrubar_coisas,
		deitar = gato_deitar,
		ignorar_missao = function(p, c)
			notify(p, "🐱 IGNORANDO MISSÃO!", "Seu gato decidiu ignorar a missão atual. Típico.", "🐱", 4)
			if PlayerData[p.UserId] then
				PlayerData[p.UserId].missionProgress = math.max(0, (PlayerData[p.UserId].missionProgress or 0) - 20)
				RE_MissionUpdate:FireClient(p, PlayerData[p.UserId])
			end
		end,
		arranhar = function(p, c)
			notify(p, "🐱 ARRANHOU!", "Seu gato arranhou tudo! Que vergonha!", "🐱", 3)
			RE_PlayerEffect:FireClient(p, {effect="scratch", duration=2})
		end,
		empurrar_objetos = gato_empurrar_objetos,
	},
	PAPAGAIO = {
		falar_aleatorio = papagaio_falar,
		imitar = papagaio_imitar,
		gritar = function(p, c)
			notify(p, "🦜 GRITANDO!", "SQUAWK SQUAWK SQUAWK!!!", "🦜", 3)
			RE_PetSpeak:FireAllClients(p, "SQUAWK SQUAWK SQUAWK SQUAWK!!!", "🦜")
		end,
		revelar_segredo = papagaio_revelar_segredo,
		cantar = function(p, c)
			local musicas = {"🎵 LA LA LA LA LA!", "🎵 PARABÉNS PRA VOCÊ!", "🎵 BABY SHARK DO DO DO!", "🎵 DESPACITO!"}
			local musica = musicas[math.random(1, #musicas)]
			notify(p, "🦜 CANTANDO!", "Seu papagaio começou a cantar: " .. musica, "🦜", 4)
			RE_PetSpeak:FireAllClients(p, musica, "🦜")
		end,
	},
	HAMSTER = {
		entrar_buraco = hamster_buraco,
		girar_roda = hamster_girar_roda,
		esconder = function(p, c)
			notify(p, "🐹 ESCONDENDO!", "Seu hamster se escondeu e você ficou invisível por 5s!", "🐹", 4)
			RE_PlayerEffect:FireClient(p, {effect="invisible", duration=5})
		end,
		cavar = function(p, c)
			notify(p, "🐹 CAVANDO!", "Seu hamster está cavando! Você está afundando!", "🐹", 3)
			RE_PlayerEffect:FireClient(p, {effect="dig", duration=3})
		end,
		aparecer_surpresa = hamster_aparecer_surpresa,
	},
	MACACO = {
		ativar_armadilha = macaco_armadilha,
		jogar_banana = function(p, c)
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			notify(p, "🐒 BANANA VOANDO!", "Seu macaco jogou uma banana em alguém!", "🐒", 3)
			-- Cria banana física
			local banana = Instance.new("Part")
			banana.Size = Vector3.new(0.5, 1, 0.5)
			banana.BrickColor = BrickColor.new("Bright yellow")
			banana.Shape = Enum.PartType.Cylinder
			banana.Position = hrp.Position + Vector3.new(0, 2, 0)
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.new(math.random(-20,20), 15, math.random(-20,20))
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bv.Parent = banana
			banana.Parent = Workspace
			game:GetService("Debris"):AddItem(banana, 5)
		end,
		trocar_lugar = macaco_trocar_lugar,
		confundir = function(p, c)
			notify(p, "🐒 CONFUSÃO TOTAL!", "Seu macaco inverteu seus controles por 8 segundos!", "🐒", 4)
			RE_PlayerEffect:FireClient(p, {effect="invert_controls", duration=8})
		end,
		roubar_item = macaco_roubar_item,
	},
	DRAGAO = {
		cuspir_fogo = dragao_fogo,
		voar_sem_controle = dragao_voar,
		assustar_npcs = function(p, c)
			notify(p, "🐉 ASSUSTANDO NPCs!", "Seu dragão assustou todos os NPCs da área!", "🐉", 4)
			RE_ChaosEvent:FireAllClients({type="scare_npcs", player=p.Name})
		end,
		queimar_missao = function(p, c)
			notify(p, "🐉 MISSÃO QUEIMADA!", "Seu dragão queimou o progresso da missão! -30%", "🐉", 4)
			if PlayerData[p.UserId] then
				PlayerData[p.UserId].missionProgress = math.max(0, (PlayerData[p.UserId].missionProgress or 0) - 30)
				RE_MissionUpdate:FireClient(p, PlayerData[p.UserId])
			end
		end,
		rugir = dragao_rugir,
	},
	UNICORNIO = {
		teletransportar = unicornio_teletransportar,
		arco_iris_caos = unicornio_arco_iris,
		transformar_mundo = function(p, c)
			notify(p, "🦄 MUNDO TRANSFORMADO!", "Seu unicórnio transformou o mundo por 15 segundos!", "🦄", 5)
			RE_ChaosEvent:FireAllClients({type="transform_world", player=p.Name, duration=15})
		end,
		magia_aleatoria = function(p, c)
			-- Executa ação aleatória de qualquer pet
			local allActions = {}
			for petKey, actions in pairs(PET_ACTIONS) do
				for actionName, actionFunc in pairs(actions) do
					table.insert(allActions, actionFunc)
				end
			end
			if #allActions > 0 then
				local randomAction = allActions[math.random(1, #allActions)]
				notify(p, "🦄 MAGIA ALEATÓRIA!", "Seu unicórnio usou magia aleatória!", "🦄", 3)
				randomAction(p, c)
			end
		end,
		possuir_jogador = unicornio_possuir_jogador,
	},
	ALIEN = {
		abducao = alien_abducao,
		controle_mental = function(p, c)
			notify(p, "👽 CONTROLE MENTAL!", "Seu alien está controlando sua mente!", "👽", 5)
			RE_PlayerEffect:FireClient(p, {effect="mind_control", duration=8})
		end,
		gravidade_zero = alien_gravidade_zero,
		clone_jogador = alien_clone,
		invasao_total = alien_invasao_total,
	},
}

-- ============================================================
-- SISTEMA DE LOOP DO PET
-- ============================================================
local function startPetSystem(player)
	local userId = player.UserId
	
	-- Para sistema anterior se existir
	if ActivePetSystems[userId] then
		ActivePetSystems[userId].active = false
	end
	
	local system = {active = true}
	ActivePetSystems[userId] = system
	
	task.spawn(function()
		-- Aguarda personagem
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end
		
		-- Aguarda dados carregarem
		local attempts = 0
		while not PlayerData[userId] and attempts < 20 do
			task.wait(0.5)
			attempts = attempts + 1
		end
		
		if not PlayerData[userId] then return end
		
		-- Notificação inicial
		local petConfig = getPlayerPetConfig(player)
		notify(player, 
			petConfig.emoji .. " " .. petConfig.name .. " ATIVADO!",
			"Seu pet " .. petConfig.name .. " está no controle! Boa sorte! 😂",
			petConfig.emoji,
			5
		)
		
		-- Loop principal do pet
		while system.active and player.Parent and PlayerData[userId] do
			local data = PlayerData[userId]
			
			-- Verifica se tem controle temporário ativo
			if data.controlPowerup and os.time() < data.controlPowerupExpiry then
				task.wait(1)
				continue
			elseif data.controlPowerup and os.time() >= data.controlPowerupExpiry then
				data.controlPowerup = false
				notify(player, "⏰ CONTROLE EXPIROU!", "Seu pet voltou ao controle! 😈", "🐾", 4)
				RE_UpdateUI:FireClient(player, data)
			end
			
			-- Pega configuração atual do pet
			local currentPetKey = data.activePet or "CACHORRO"
			local petCfg = CONFIG.PETS[currentPetKey]
			if not petCfg then
				task.wait(5)
				continue
			end
			
			-- Intervalo aleatório baseado no pet
			local interval = math.random(petCfg.actionInterval.min, petCfg.actionInterval.max)
			task.wait(interval)
			
			-- Verifica se personagem ainda existe
			character = player.Character
			if not character then continue end
			humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end
			
			-- Escolhe ação aleatória
			local actions = petCfg.actions
			if not actions or #actions == 0 then continue end
			
			local actionName = actions[math.random(1, #actions)]
			local petActions = PET_ACTIONS[currentPetKey]
			
			if petActions and petActions[actionName] then
				-- Executa ação com proteção de erro
				local success, err = pcall(function()
					petActions[actionName](player, character)
				end)
				if not success then
					warn("Erro na ação " .. actionName .. " do pet " .. currentPetKey .. ": " .. tostring(err))
				end
				
				-- Atualiza estatísticas
				data.totalChaosEvents = (data.totalChaosEvents or 0) + 1
				
				-- Verifica conquistas
				checkAchievements(player)
			end
		end
	end)
end

-- ============================================================
-- SISTEMA DE MISSÕES
-- ============================================================
local ActiveMissions = {} -- {[userId] = {missionId, startTime, thread}}

local function startMission(player, missionId)
	local data = PlayerData[player.UserId]
	if not data then return false, "Dados não encontrados" end
	
	-- Verifica se já tem missão ativa
	if data.currentMission then
		return false, "Você já tem uma missão ativa!"
	end
	
	-- Encontra missão
	local mission = nil
	for _, m in pairs(CONFIG.MISSIONS) do
		if m.id == missionId then
			mission = m
			break
		end
	end
	
	if not mission then return false, "Missão não encontrada" end
	
	data.currentMission = missionId
	data.missionProgress = 0
	
	notify(player, 
		mission.emoji .. " MISSÃO INICIADA!",
		mission.name .. " - Recompensa: " .. mission.reward .. " moedas",
		mission.emoji,
		5
	)
	
	RE_MissionUpdate:FireClient(player, data)
	
	-- Thread da missão
	local missionSystem = {active = true}
	ActiveMissions[player.UserId] = missionSystem
	
	task.spawn(function()
		local elapsed = 0
		local progressInterval = mission.time / 100 -- Tempo para cada 1% de progresso
		
		while missionSystem.active and elapsed < mission.time do
			task.wait(progressInterval)
			elapsed = elapsed + progressInterval
			
			if not PlayerData[player.UserId] then break end
			local currentData = PlayerData[player.UserId]
			
			-- Progresso base (pode ser reduzido pelo pet)
			currentData.missionProgress = math.min(100, (currentData.missionProgress or 0) + 1)
			
			-- Atualiza UI a cada 10%
			if math.floor(currentData.missionProgress) % 10 == 0 then
				RE_MissionUpdate:FireClient(player, currentData)
			end
			
			-- Verifica se missão foi cancelada
			if currentData.currentMission ~= missionId then
				missionSystem.active = false
				break
			end
		end
		
		if not missionSystem.active then return end
		
		local finalData = PlayerData[player.UserId]
		if not finalData then return end
		
		-- Verifica resultado
		if finalData.missionProgress >= 100 then
			-- SUCESSO!
			finalData.coins = (finalData.coins or 0) + mission.reward
			finalData.missionsCompleted = (finalData.missionsCompleted or 0) + 1
			finalData.currentMission = nil
			finalData.missionProgress = 0
			
			notify(player,
				"🎉 MISSÃO COMPLETA!",
				mission.name .. " concluída! +" .. mission.reward .. " moedas!",
				"🎉",
				6
			)
		else
			-- FALHA
			finalData.missionsFailed = (finalData.missionsFailed or 0) + 1
			finalData.currentMission = nil
			finalData.missionProgress = 0
			
			notify(player,
				"💀 MISSÃO FALHOU!",
				"Seu pet atrapalhou demais! Tente novamente!",
				"😭",
				5
			)
		end
		
		RE_UpdateUI:FireClient(player, finalData)
		RE_MissionUpdate:FireClient(player, finalData)
		savePlayerData(player)
	end)
	
	return true, "Missão iniciada!"
end

-- ============================================================
-- SISTEMA DE OVOS
-- ============================================================
local function rollEgg(eggType)
	local chances = CONFIG.EGG_CHANCES[eggType]
	if not chances then return "CACHORRO" end
	
	local roll = math.random(1, 100)
	local cumulative = 0
	
	for _, entry in pairs(chances) do
		cumulative = cumulative + entry.chance
		if roll <= cumulative then
			return entry.pet
		end
	end
	
	return chances[#chances].pet
end

local function hatchEgg(player, eggType)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	-- Verifica inventário de ovos
	if not data.eggInventory[eggType] or data.eggInventory[eggType] <= 0 then
		notify(player, "❌ SEM OVOS!", "Você não tem ovos " .. eggType .. "!", "🥚", 3)
		return
	end
	
	data.eggInventory[eggType] = data.eggInventory[eggType] - 1
	
	-- Rola o pet
	local petKey = rollEgg(eggType)
	local petConfig = CONFIG.PETS[petKey]
	
	-- Adiciona ao inventário se não tiver
	local alreadyOwned = false
	for _, owned in pairs(data.ownedPets) do
		if owned == petKey then
			alreadyOwned = true
			break
		end
	end
	
	if not alreadyOwned then
		table.insert(data.ownedPets, petKey)
		data.petLevel[petKey] = 1
		data.petXP[petKey] = 0
	end
	
	-- Notifica resultado
	RE_EggHatch:FireClient(player, {
		petKey = petKey,
		petConfig = {
			name = petConfig.name,
			emoji = petConfig.emoji,
			rarity = petConfig.rarity,
			color = {petConfig.color.R, petConfig.color.G, petConfig.color.B},
		},
		isNew = not alreadyOwned,
	})
	
	notify(player,
		"🥚 OVO CHOCOU!",
		"Você ganhou: " .. petConfig.emoji .. " " .. petConfig.name .. " (" .. petConfig.rarity .. ")!",
		petConfig.emoji,
		6
	)
	
	RE_UpdateUI:FireClient(player, data)
	savePlayerData(player)
end

-- ============================================================
-- SISTEMA DE CONQUISTAS
-- ============================================================
local ACHIEVEMENTS = {
	{id="first_chaos", name="Primeiro Caos", desc="Sofra sua primeira ação do pet", emoji="🎉", condition=function(d) return (d.totalChaosEvents or 0) >= 1 end, reward=50},
	{id="chaos_100", name="Mestre do Caos", desc="100 ações do pet", emoji="🌪️", condition=function(d) return (d.totalChaosEvents or 0) >= 100 end, reward=500},
	{id="missions_10", name="Trabalhador", desc="Complete 10 missões", emoji="💼", condition=function(d) return (d.missionsCompleted or 0) >= 10 end, reward=300},
	{id="possessed", name="Possuído!", desc="Seja possuído por um pet", emoji="👻", condition=function(d) return (d.possessionsReceived or 0) >= 1 end, reward=100},
	{id="runner", name="Maratonista", desc="Corra 50 vezes pelo cachorro", emoji="🏃", condition=function(d) return (d.stats and d.stats.timesRan or 0) >= 50 end, reward=200},
	{id="parrot_100", name="Papagaio Humano", desc="Diga 100 frases aleatórias", emoji="🦜", condition=function(d) return (d.stats and d.stats.randomPhrasesSaid or 0) >= 100 end, reward=400},
	{id="fire_50", name="Bombeiro Necessário", desc="Cuspa fogo 50 vezes", emoji="🔥", condition=function(d) return (d.stats and d.stats.fireBreaths or 0) >= 50 end, reward=350},
	{id="teleport_20", name="Teletransportador", desc="Teletransporte 20 vezes", emoji="✨", condition=function(d) return (d.stats and d.stats.teleports or 0) >= 20 end, reward=250},
}

function checkAchievements(player)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	if not data.achievements then data.achievements = {} end
	
	for _, achievement in pairs(ACHIEVEMENTS) do
		if not data.achievements[achievement.id] then
			if achievement.condition(data) then
				data.achievements[achievement.id] = true
				data.coins = (data.coins or 0) + achievement.reward
				
				notify(player,
					"🏆 CONQUISTA DESBLOQUEADA!",
					achievement.emoji .. " " .. achievement.name .. " - +" .. achievement.reward .. " moedas!",
					"🏆",
					6
				)
				
				RE_UpdateUI:FireClient(player, data)
			end
		end
	end
end

-- ============================================================
-- SISTEMA DE LOJA / MONETIZAÇÃO
-- ============================================================
local function processPurchase(player, productId)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	-- Ovos
	if productId == CONFIG.DEV_PRODUCTS.OVO_COMUM then
		data.eggInventory = data.eggInventory or {}
		data.eggInventory.COMUM = (data.eggInventory.COMUM or 0) + 1
		notify(player, "🥚 OVO COMUM!", "Você comprou um Ovo Comum! Vá ao inventário para chocar!", "🥚", 5)
		
	elseif productId == CONFIG.DEV_PRODUCTS.OVO_RARO then
		data.eggInventory = data.eggInventory or {}
		data.eggInventory.RARO = (data.eggInventory.RARO or 0) + 1
		notify(player, "🥚 OVO RARO!", "Você comprou um Ovo Raro! Boa sorte!", "🥚", 5)
		
	elseif productId == CONFIG.DEV_PRODUCTS.OVO_EPICO then
		data.eggInventory = data.eggInventory or {}
		data.eggInventory.EPICO = (data.eggInventory.EPICO or 0) + 1
		notify(player, "🥚 OVO ÉPICO!", "Você comprou um Ovo Épico! Incrível!", "🥚", 5)
		
	elseif productId == CONFIG.DEV_PRODUCTS.OVO_LENDARIO then
		data.eggInventory = data.eggInventory or {}
		data.eggInventory.LENDARIO = (data.eggInventory.LENDARIO or 0) + 1
		notify(player, "🥚 OVO LENDÁRIO!", "OVO LENDÁRIO! Você é incrível!", "🥚", 6)
		
	elseif productId == CONFIG.DEV_PRODUCTS.CONTROLE_5MIN then
		data.controlPowerup = true
		data.controlPowerupExpiry = os.time() + 300 -- 5 minutos
		notify(player, "🎮 CONTROLE TOTAL!", "Você tem controle total por 5 minutos! Aproveite!", "🎮", 6)
		
	elseif productId == CONFIG.DEV_PRODUCTS.MOEDAS_1000 then
		data.coins = (data.coins or 0) + 1000
		notify(player, "💰 +1000 MOEDAS!", "Você recebeu 1000 moedas!", "💰", 5)
	end
	
	RE_UpdateUI:FireClient(player, data)
	savePlayerData(player)
end

-- Callback de compra
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local success, err = pcall(function()
		processPurchase(player, receiptInfo.ProductId)
	end)
	
	if success then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("Erro ao processar compra: " .. tostring(err))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- ============================================================
-- SISTEMA DE LEVEL DO PET
-- ============================================================
local function addPetXP(player, petKey, xp)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	if not data.petXP then data.petXP = {} end
	if not data.petLevel then data.petLevel = {} end
	
	data.petXP[petKey] = (data.petXP[petKey] or 0) + xp
	
	-- Verifica level up
	local currentLevel = data.petLevel[petKey] or 1
	local xpNeeded = currentLevel * 100
	
	if data.petXP[petKey] >= xpNeeded then
		data.petXP[petKey] = data.petXP[petKey] - xpNeeded
		data.petLevel[petKey] = currentLevel + 1
		
		local petConfig = CONFIG.PETS[petKey]
		notify(player,
			"⬆️ PET LEVEL UP!",
			petConfig.emoji .. " " .. petConfig.name .. " chegou ao nível " .. data.petLevel[petKey] .. "!",
			petConfig.emoji,
			5
		)
		
		RE_UpdateUI:FireClient(player, data)
	end
end

-- ============================================================
-- SISTEMA MULTIPLAYER - POSSESSÃO
-- ============================================================
local PossessionCooldowns = {} -- {[userId] = lastPossessionTime}

local function canPossess(player)
	local lastTime = PossessionCooldowns[player.UserId] or 0
	return os.time() - lastTime >= 60 -- 60 segundos de cooldown
end

-- ============================================================
-- REMOTE EVENT HANDLERS
-- ============================================================

-- Compra de item na loja
RE_ShopPurchase.OnServerEvent:Connect(function(player, itemType, itemId)
	local data = PlayerData[player.UserId]
	if not data then return end
	
	if itemType == "pet" then
		local petConfig = CONFIG.PETS[itemId]
		if not petConfig then return end
		
		-- Verifica se já tem
		for _, owned in pairs(data.ownedPets) do
			if owned == itemId then
				notify(player, "❌ JÁ TEM!", "Você já possui este pet!", "🐾", 3)
				return
			end
		end
		
		-- Verifica moedas
		if data.coins >= petConfig.basePrice then
			data.coins = data.coins - petConfig.basePrice
			table.insert(data.ownedPets, itemId)
			data.petLevel[itemId] = 1
			data.petXP[itemId] = 0
			
			notify(player, "✅ PET COMPRADO!", petConfig.emoji .. " " .. petConfig.name .. " adicionado!", petConfig.emoji, 5)
			RE_UpdateUI:FireClient(player, data)
			savePlayerData(player)
		else
			notify(player, "❌ SEM MOEDAS!", "Você precisa de " .. petConfig.basePrice .. " moedas!", "💰", 3)
		end
		
	elseif itemType == "egg" then
		hatchEgg(player, itemId)
		
	elseif itemType == "changePet" then
		-- Troca pet ativo
		local owned = false
		for _, p in pairs(data.ownedPets) do
			if p == itemId then owned = true break end
		end
		
		if owned then
			data.activePet = itemId
			local petConfig = CONFIG.PETS[itemId]
			notify(player, "🔄 PET TROCADO!", petConfig.emoji .. " " .. petConfig.name .. " agora está no controle!", petConfig.emoji, 4)
			RE_UpdateUI:FireClient(player, data)
			savePlayerData(player)
			
			-- Reinicia sistema do pet
			startPetSystem(player)
		end
	end
end)

-- Missão
RE_MissionUpdate.OnServerEvent:Connect(function(player, action, missionId)
	if action == "start" then
		local success, msg = startMission(player, missionId)
		if not success then
			notify(player, "❌ ERRO!", msg, "❌", 3)
		end
	elseif action == "abandon" then
		local data = PlayerData[player.UserId]
		if data and data.currentMission then
			if ActiveMissions[player.UserId] then
				ActiveMissions[player.UserId].active = false
			end
			data.currentMission = nil
			data.missionProgress = 0
			data.missionsFailed = (data.missionsFailed or 0) + 1
			notify(player, "🚫 MISSÃO ABANDONADA!", "Você abandonou a missão.", "🚫", 3)
			RE_MissionUpdate:FireClient(player, data)
		end
	end
end)

-- Dados do jogador
RF_GetPlayerData.OnServerInvoke = function(player)
	return PlayerData[player.UserId] or DEFAULT_DATA
end

-- ============================================================
-- EVENTOS DE JOGADOR
-- ============================================================
Players.PlayerAdded:Connect(function(player)
	-- Carrega dados
	local data = loadPlayerData(player)
	data.lastLogin = os.time()
	
	-- Aguarda personagem
	player.CharacterAdded:Connect(function(character)
		-- Pequeno delay para garantir que tudo carregou
		task.wait(2)
		
		-- Envia dados iniciais
		RE_UpdateUI:FireClient(player, PlayerData[player.UserId])
		
		-- Inicia sistema do pet
		startPetSystem(player)
		
		-- Mensagem de boas-vindas
		local petConfig = getPlayerPetConfig(player)
		notify(player,
			"🎮 BEM-VINDO!",
			"Seu pet " .. petConfig.emoji .. " " .. petConfig.name .. " está no controle! Boa sorte! 😂",
			petConfig.emoji,
			6
		)
	end)
	
	-- Carrega personagem inicial se já existir
	if player.Character then
		task.wait(2)
		RE_UpdateUI:FireClient(player, PlayerData[player.UserId])
		startPetSystem(player)
	end
	
	-- Auto-save a cada 5 minutos
	task.spawn(function()
		while player.Parent do
			task.wait(300)
			if PlayerData[player.UserId] then
				PlayerData[player.UserId].totalPlaytime = (PlayerData[player.UserId].totalPlaytime or 0) + 300
				savePlayerData(player)
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	-- Para sistema do pet
	if ActivePetSystems[player.UserId] then
		ActivePetSystems[player.UserId].active = false
	end
	if ActiveMissions[player.UserId] then
		ActiveMissions[player.UserId].active = false
	end
	
	-- Salva dados
	savePlayerData(player)
	
	-- Limpa memória
	PlayerData[player.UserId] = nil
	ActivePetSystems[player.UserId] = nil
	ActiveMissions[player.UserId] = nil
	PossessionCooldowns[player.UserId] = nil
end)

-- ============================================================
-- EVENTOS DE SERVIDOR PERIÓDICOS
-- ============================================================

-- Evento de caos global a cada 5 minutos
task.spawn(function()
	while true do
		task.wait(300)
		local playerList = Players:GetPlayers()
		if #playerList >= 2 then
			-- Evento especial aleatório
			local events = {
				{
					name = "🌪️ TEMPESTADE DE CAOS!",
					desc = "Todos os pets enlouqueceram ao mesmo tempo!",
					action = function()
						for _, p in pairs(playerList) do
							if p.Character and PlayerData[p.UserId] then
								local petKey = PlayerData[p.UserId].activePet or "CACHORRO"
								local petCfg = CONFIG.PETS[petKey]
								if petCfg then
									local actions = petCfg.actions
									local actionName = actions[math.random(1, #actions)]
									local petActions = PET_ACTIONS[petKey]
									if petActions and petActions[actionName] then
										pcall(function()
											petActions[actionName](p, p.Character)
										end)
									end
								end
							end
						end
					end
				},
				{
					name = "🔄 TROCA GERAL!",
					desc = "Todos os jogadores trocaram de lugar!",
					action = function()
						local positions = {}
						for _, p in pairs(playerList) do
							if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
								table.insert(positions, p.Character.HumanoidRootPart.CFrame)
							end
						end
						-- Embaralha posições
						for i = #positions, 2, -1 do
							local j = math.random(1, i)
							positions[i], positions[j] = positions[j], positions[i]
						end
						local idx = 1
						for _, p in pairs(playerList) do
							if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and positions[idx] then
								p.Character.HumanoidRootPart.CFrame = positions[idx]
								idx = idx + 1
							end
						end
					end
				},
				{
					name = "💰 CHUVA DE MOEDAS!",
					desc = "Todos ganharam 50 moedas!",
					action = function()
						for _, p in pairs(playerList) do
							if PlayerData[p.UserId] then
								PlayerData[p.UserId].coins = (PlayerData[p.UserId].coins or 0) + 50
								RE_UpdateUI:FireClient(p, PlayerData[p.UserId])
							end
						end
					end
				},
			}
			
			local event = events[math.random(1, #events)]
			RE_ChaosEvent:FireAllClients({
				type = "global_event",
				name = event.name,
				desc = event.desc,
			})
			
			pcall(event.action)
		end
	end
end)

-- ============================================================
-- LEADERBOARD / RANKING
-- ============================================================
local function updateLeaderboard()
	-- Cria leaderboard de moedas
	local leaderboard = Instance.new("Folder")
	leaderboard.Name = "Leaderboard"
	leaderboard.Parent = ReplicatedStorage
	
	-- Atualiza a cada 30 segundos
	task.spawn(function()
		while true do
			task.wait(30)
			local rankings = {}
			for _, player in pairs(Players:GetPlayers()) do
				if PlayerData[player.UserId] then
					table.insert(rankings, {
						name = player.Name,
						coins = PlayerData[player.UserId].coins or 0,
						missions = PlayerData[player.UserId].missionsCompleted or 0,
						chaos = PlayerData[player.UserId].totalChaosEvents or 0,
						pet = PlayerData[player.UserId].activePet or "CACHORRO",
					})
				end
			end
			
			-- Ordena por moedas
			table.sort(rankings, function(a, b) return a.coins > b.coins end)
			
			-- Envia para todos
			for _, player in pairs(Players:GetPlayers()) do
				RE_UpdateUI:FireClient(player, {leaderboard = rankings})
			end
		end
	end)
end

updateLeaderboard()

-- ============================================================
-- SISTEMA DE CHAT PERSONALIZADO
-- ============================================================
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local data = PlayerData[player.UserId]
		if not data then return end
		
		-- Comandos de chat
		if message:lower() == "/pet" then
			local petConfig = getPlayerPetConfig(player)
			notify(player, 
				"🐾 SEU PET ATUAL",
				petConfig.emoji .. " " .. petConfig.name .. " | Nível: " .. (data.petLevel[data.activePet] or 1) .. " | Personalidade: " .. petConfig.personality,
				petConfig.emoji,
				5
			)
		elseif message:lower() == "/moedas" then
			notify(player, "💰 SUAS MOEDAS", "Você tem " .. (data.coins or 0) .. " moedas!", "💰", 3)
		elseif message:lower() == "/missoes" then
			notify(player, "📋 MISSÕES", "Completas: " .. (data.missionsCompleted or 0) .. " | Falhas: " .. (data.missionsFailed or 0), "📋", 4)
		elseif message:lower() == "/caos" then
			notify(player, "🌪️ ESTATÍSTICAS DE CAOS", "Total de eventos: " .. (data.totalChaosEvents or 0), "🌪️", 4)
		elseif message:lower() == "/ajuda" then
			notify(player, "❓ COMANDOS", "/pet /moedas /missoes /caos /ajuda", "❓", 5)
		end
	end)
end)

-- ============================================================
-- INICIALIZAÇÃO FINAL
-- ============================================================
print([[
╔══════════════════════════════════════════════════════════════════╗
║          🐾 SEU PET CONTROLA VOCÊ - CARREGADO! 🐾               ║
║                                                                  ║
║  Pets disponíveis: 8 (Cachorro, Gato, Papagaio, Hamster,        ║
║                       Macaco, Dragão, Unicórnio, Alien)         ║
║  Missões: 8 tipos diferentes                                     ║
║  Sistema de ovos: 4 raridades                                    ║
║  Conquistas: 8 desbloqueáveis                                    ║
║  Eventos globais: Ativados                                       ║
║  DataStore: Ativo                                                ║
║  Monetização: Configurada                                        ║
╚══════════════════════════════════════════════════════════════════╝
]])

-- ============================================================
-- LOCAL SCRIPT (Cole em StarterPlayerScripts)
-- ============================================================
--[[
ATENÇÃO: O código abaixo é um LocalScript separado!
Cole em: StarterPlayerScripts > Novo LocalScript

=== INÍCIO DO LOCAL SCRIPT ===

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

-- Aguarda remotes
local RemoteFolder = ReplicatedStorage:WaitForChild("PetControlaVoceRemotes", 30)
if not RemoteFolder then return end

local RE_ShowNotification = RemoteFolder:WaitForChild("ShowNotification")
local RE_UpdateUI = RemoteFolder:WaitForChild("UpdateUI")
local RE_PetPossess = RemoteFolder:WaitForChild("PetPossess")
local RE_MissionUpdate = RemoteFolder:WaitForChild("MissionUpdate")
local RE_EggHatch = RemoteFolder:WaitForChild("EggHatch")
local RE_ChaosEvent = RemoteFolder:WaitForChild("ChaosEvent")
local RE_PetSpeak = RemoteFolder:WaitForChild("PetSpeak")
local RE_PlayerEffect = RemoteFolder:WaitForChild("PlayerEffect")
local RE_ShopPurchase = RemoteFolder:WaitForChild("ShopPurchase")
local RE_MissionUpdate_Send = RemoteFolder:WaitForChild("MissionUpdate")
local RF_GetPlayerData = RemoteFolder:WaitForChild("GetPlayerData")

-- ============================================================
-- CRIAÇÃO DA UI PRINCIPAL
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetControlaVoceUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

-- Função para criar frame estilizado
local function createFrame(parent, size, position, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = transparency or 0.1
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    return frame
end

local function createLabel(parent, text, size, position, color, fontSize)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = parent
    return label
end

-- ============================================================
-- PAINEL PRINCIPAL (HUD)
-- ============================================================
local hudFrame = createFrame(screenGui,
    UDim2.new(0, 280, 0, 120),
    UDim2.new(0, 10, 0, 10),
    Color3.fromRGB(20, 20, 35),
    0.05
)

-- Gradiente
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 80)),
})
gradient.Rotation = 45
gradient.Parent = hudFrame

-- Borda colorida
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 50, 255)
stroke.Thickness = 2
stroke.Parent = hudFrame

-- Pet atual
local petLabel = createLabel(hudFrame, "🐾 Carregando...", UDim2.new(1, -10, 0, 35), UDim2.new(0, 5, 0, 5), Color3.fromRGB(255, 200, 50))

-- Moedas
local coinsLabel = createLabel(hudFrame, "💰 0 moedas", UDim2.new(0.5, -5, 0, 25), UDim2.new(0, 5, 0, 45), Color3.fromRGB(255, 220, 0))

-- Missão
local missionLabel = createLabel(hudFrame, "📋 Sem missão", UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, 75), Color3.fromRGB(100, 200, 255))

-- Barra de progresso da missão
local progressBg = createFrame(hudFrame, UDim2.new(1, -10, 0, 8), UDim2.new(0, 5, 0, 105), Color3.fromRGB(50, 50, 70), 0)
local progressBar = createFrame(progressBg, UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(100, 255, 100), 0)

-- ============================================================
-- SISTEMA DE NOTIFICAÇÕES
-- ============================================================
local notificationQueue = {}
local isShowingNotification = false

local notifFrame = createFrame(screenGui,
    UDim2.new(0, 350, 0, 100),
    UDim2.new(0.5, -175, 0, -110),
    Color3.fromRGB(20, 20, 35),
    0.05
)
notifFrame.ZIndex = 10

local notifGradient = Instance.new("UIGradient")
notifGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 20, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 60, 120)),
})
notifGradient.Rotation = 90
notifGradient.Parent = notifFrame

local notifStroke = Instance.new("UIStroke")
notifStroke.Color = Color3.fromRGB(200, 100, 255)
notifStroke.Thickness = 2
notifStroke.Parent = notifFrame

local notifEmoji = createLabel(notifFrame, "🐾", UDim2.new(0, 60, 0, 60), UDim2.new(0, 5, 0, 20), Color3.fromRGB(255, 255, 255))
local notifTitle = createLabel(notifFrame, "Título", UDim2.new(1, -80, 0, 35), UDim2.new(0, 70, 0, 10), Color3.fromRGB(255, 220, 50))
local notifMessage = createLabel(notifFrame, "Mensagem", UDim2.new(1, -80, 0, 45), UDim2.new(0, 70, 0, 45), Color3.fromRGB(200, 200, 255))
notifMessage.TextScaled = false
notifMessage.TextSize = 14
notifMessage.TextWrapped = true

local function showNextNotification()
    if isShowingNotification or #notificationQueue == 0 then return end
    isShowingNotification = true
    
    local notif = table.remove(notificationQueue, 1)
    notifEmoji.Text = notif.emoji or "🐾"
    notifTitle.Text = notif.title or ""
    notifMessage.Text = notif.message or ""
    
    -- Cor baseada no emoji
    local colors = {
        ["🐶"] = Color3.fromRGB(255, 150, 50),
        ["🐱"] = Color3.fromRGB(200, 200, 255),
        ["🦜"] = Color3.fromRGB(50, 255, 100),
        ["🐹"] = Color3.fromRGB(255, 200, 150),
        ["🐒"] = Color3.fromRGB(200, 150, 50),
        ["🐉"] = Color3.fromRGB(255, 50, 50),
        ["🦄"] = Color3.fromRGB(255, 100, 255),
        ["👽"] = Color3.fromRGB(50, 255, 150),
        ["🎉"] = Color3.fromRGB(255, 220, 0),
        ["🏆"] = Color3.fromRGB(255, 200, 0),
    }
    notifStroke.Color = colors[notif.emoji] or Color3.fromRGB(200, 100, 255)
    
    -- Animação de entrada
    local tweenIn = TweenService:Create(notifFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -175, 0, 10)}
    )
    tweenIn:Play()
    
    task.delay(notif.duration or 4, function()
        local tweenOut = TweenService:Create(notifFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -175, 0, -110)}
        )
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            isShowingNotification = false
            showNextNotification()
        end)
    end)
end

RE_ShowNotification.OnClientEvent:Connect(function(data)
    table.insert(notificationQueue, data)
    showNextNotification()
end)

-- ============================================================
-- EFEITOS VISUAIS DO JOGADOR
-- ============================================================
local activeEffects = {}

RE_PlayerEffect.OnClientEvent:Connect(function(effectData)
    local effect = effectData.effect
    local duration = effectData.duration or 5
    
    if effect == "run_crazy" then
        -- Efeito visual de corrida louca
        camera.FieldOfView = 90
        task.delay(duration, function()
            TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = 70}):Play()
        end)
        
    elseif effect == "sleep" then
        -- Tela escurece
        local sleepFrame = Instance.new("Frame")
        sleepFrame.Size = UDim2.new(1, 0, 1, 0)
        sleepFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 20)
        sleepFrame.BackgroundTransparency = 0.7
        sleepFrame.ZIndex = 5
        sleepFrame.Parent = screenGui
        
        local zzzLabel = Instance.new("TextLabel")
        zzzLabel.Size = UDim2.new(0, 200, 0, 100)
        zzzLabel.Position = UDim2.new(0.5, -100, 0.3, 0)
        zzzLabel.BackgroundTransparency = 1
        zzzLabel.Text = "💤 ZZZ..."
        zzzLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        zzzLabel.TextScaled = true
        zzzLabel.Font = Enum.Font.GothamBold
        zzzLabel.ZIndex = 6
        zzzLabel.Parent = screenGui
        
        task.delay(duration, function()
            sleepFrame:Destroy()
            zzzLabel:Destroy()
        end)
        
    elseif effect == "rainbow_teleport" then
        -- Flash colorido
        local flashFrame = Instance.new("Frame")
        flashFrame.Size = UDim2.new(1, 0, 1, 0)
        flashFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
        flashFrame.BackgroundTransparency = 0
        flashFrame.ZIndex = 10
        flashFrame.Parent = screenGui
        
        TweenService:Create(flashFrame, TweenInfo.new(duration), {BackgroundTransparency = 1}):Play()
        task.delay(duration, function() flashFrame:Destroy() end)
        
    elseif effect == "fire_breath" then
        -- Tela com efeito de fogo
        local fireFrame = Instance.new("Frame")
        fireFrame.Size = UDim2.new(1, 0, 1, 0)
        fireFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        fireFrame.BackgroundTransparency = 0.6
        fireFrame.ZIndex = 5
        fireFrame.Parent = screenGui
        
        task.delay(duration, function()
            TweenService:Create(fireFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
            task.delay(1, function() fireFrame:Destroy() end)
        end)
        
    elseif effect == "abduction_beam" then
        -- Raio de abdução
        local beamFrame = Instance.new("Frame")
        beamFrame.Size = UDim2.new(0.3, 0, 1, 0)
        beamFrame.Position = UDim2.new(0.35, 0, 0, 0)
        beamFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        beamFrame.BackgroundTransparency = 0.5
        beamFrame.ZIndex = 5
        beamFrame.Parent = screenGui
        
        task.delay(duration, function()
            TweenService:Create(beamFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.delay(0.5, function() beamFrame:Destroy() end)
        end)
        
    elseif effect == "zero_gravity" then
        -- Efeito de gravidade zero
        camera.FieldOfView = 85
        local gravFrame = Instance.new("Frame")
        gravFrame.Size = UDim2.new(1, 0, 1, 0)
        gravFrame.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
        gravFrame.BackgroundTransparency = 0.8
        gravFrame.ZIndex = 3
        gravFrame.Parent = screenGui
        
        task.delay(duration, function()
            TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = 70}):Play()
            gravFrame:Destroy()
        end)
    end
end)

-- ============================================================
-- EFEITO DE POSSESSÃO
-- ============================================================
RE_PetPossess.OnClientEvent:Connect(function(data)
    -- Overlay de possessão
    local possessFrame = Instance.new("Frame")
    possessFrame.Size = UDim2.new(1, 0, 1, 0)
    possessFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
    possessFrame.BackgroundTransparency = 0.7
    possessFrame.ZIndex = 8
    possessFrame.Parent = screenGui
    
    local possessLabel = Instance.new("TextLabel")
    possessLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
    possessLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
    possessLabel.BackgroundTransparency = 1
    possessLabel.Text = "👻 POSSUÍDO POR " .. (data.possessor or "???"):upper() .. "!"
    possessLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
    possessLabel.TextScaled = true
    possessLabel.Font = Enum.Font.GothamBold
    possessLabel.ZIndex = 9
    possessLabel.Parent = screenGui
    
    -- Pisca
    local blinkThread = task.spawn(function()
        for i = 1, data.duration * 2 do
            possessFrame.BackgroundTransparency = (i % 2 == 0) and 0.7 or 0.85
            task.wait(0.5)
        end
    end)
    
    task.delay(data.duration or 10, function()
        possessFrame:Destroy()
        possessLabel:Destroy()
    end)
end)

-- ============================================================
-- CHAT BUBBLE DO PET
-- ============================================================
RE_PetSpeak.OnClientEvent:Connect(function(targetPlayer, message, emoji)
    if targetPlayer ~= player then return end
    -- Já tratado pelo servidor com BillboardGui
end)

-- ============================================================
-- EVENTO DE CAOS GLOBAL
-- ============================================================
RE_ChaosEvent.OnClientEvent:Connect(function(data)
    if data.type == "global_event" then
        -- Banner de evento global
        local eventBanner = createFrame(screenGui,
            UDim2.new(0.6, 0, 0, 80),
            UDim2.new(0.2, 0, 0.5, -40),
            Color3.fromRGB(255, 50, 50),
            0.1
        )
        eventBanner.ZIndex = 15
        
        local eventLabel = createLabel(eventBanner,
            data.name .. "\n" .. data.desc,
            UDim2.new(1, -10, 1, -10),
            UDim2.new(0, 5, 0, 5),
            Color3.fromRGB(255, 255, 255)
        )
        eventLabel.ZIndex = 16
        
        -- Animação
        eventBanner.BackgroundTransparency = 1
        TweenService:Create(eventBanner, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
        
        task.delay(5, function()
            TweenService:Create(eventBanner, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            task.delay(0.5, function() eventBanner:Destroy() end)
        end)
        
    elseif data.type == "rainbow_chaos" then
        -- Efeito arco-íris na tela
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 165, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(238, 130, 238),
        }
        
        task.spawn(function()
            for i = 1, 20 do
                camera.FieldOfView = 70 + math.sin(i * 0.5) * 10
                task.wait(0.5)
            end
            camera.FieldOfView = 70
        end)
    end
end)

-- ============================================================
-- ATUALIZAÇÃO DA UI
-- ============================================================
RE_UpdateUI.OnClientEvent:Connect(function(data)
    if not data then return end
    
    -- Atualiza HUD
    if data.activePet then
        local petNames = {
            CACHORRO="🐶 Cachorro", GATO="🐱 Gato", PAPAGAIO="🦜 Papagaio",
            HAMSTER="🐹 Hamster", MACACO="🐒 Macaco", DRAGAO="🐉 Dragão",
            UNICORNIO="🦄 Unicórnio", ALIEN="👽 Alien"
        }
        local level = (data.petLevel and data.petLevel[data.activePet]) or 1
        petLabel.Text = (petNames[data.activePet] or "🐾 Pet") .. " | Nv." .. level
    end
    
    if data.coins ~= nil then
        coinsLabel.Text = "💰 " .. tostring(data.coins) .. " moedas"
    end
    
    if data.currentMission then
        missionLabel.Text = "📋 " .. data.currentMission .. " - " .. math.floor(data.missionProgress or 0) .. "%"
        TweenService:Create(progressBar, TweenInfo.new(0.5), {
            Size = UDim2.new((data.missionProgress or 0) / 100, 0, 1, 0)
        }):Play()
    else
        missionLabel.Text = "📋 Sem missão ativa"
        progressBar.Size = UDim2.new(0, 0, 1, 0)
    end
end)

-- ============================================================
-- MENU PRINCIPAL (Botão)
-- ============================================================
local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 50, 0, 50)
menuButton.Position = UDim2.new(1, -60, 0, 10)
menuButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
menuButton.Text = "🐾"
menuButton.TextScaled = true
menuButton.Font = Enum.Font.GothamBold
menuButton.BorderSizePixel = 0
menuButton.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuButton

-- Menu expandido
local menuOpen = false
local menuFrame = createFrame(screenGui,
    UDim2.new(0, 300, 0, 400),
    UDim2.new(1, -320, 0, 70),
    Color3.fromRGB(15, 15, 30),
    0.05
)
menuFrame.Visible = false
menuFrame.ZIndex = 20

local menuTitle = createLabel(menuFrame, "🐾 SEU PET CONTROLA VOCÊ", UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 5), Color3.fromRGB(255, 200, 50))
menuTitle.ZIndex = 21

-- Botões do menu
local menuItems = {
    {text="🎯 Missões", color=Color3.fromRGB(50, 150, 255)},
    {text="🥚 Ovos", color=Color3.fromRGB(255, 200, 50)},
    {text="🐾 Meus Pets", color=Color3.fromRGB(100, 255, 100)},
    {text="🏆 Conquistas", color=Color3.fromRGB(255, 150, 50)},
    {text="📊 Stats", color=Color3.fromRGB(200, 100, 255)},
    {text="❓ Ajuda", color=Color3.fromRGB(150, 150, 255)},
}

for i, item in pairs(menuItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, 45 + (i-1) * 52)
    btn.BackgroundColor3 = item.color
    btn.BackgroundTransparency = 0.3
    btn.Text = item.text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 21
    btn.Parent = menuFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
end

menuButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
    menuButton.Text = menuOpen and "✕" or "🐾"
end)

print("🐾 UI do Pet Controla Você carregada com sucesso!")
=== FIM DO LOCAL SCRIPT ===
--]]

-- ============================================================
-- FIM DO SCRIPT PRINCIPAL
-- ============================================================
print("🐾 Script 'Seu Pet Controla Você' carregado com sucesso!")
print("📌 Lembre-se de criar o LocalScript em StarterPlayerScripts!")
print("💰 Configure os IDs dos GamePasses e Developer Products!")

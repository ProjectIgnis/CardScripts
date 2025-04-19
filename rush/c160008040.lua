--ポセイギョン・アドベンチャラー
--Poseigyon Advencharger
local s,id=GetID()
function s.initial_effect(c)
	-- fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160008007,CARD_JELLYPLUG)
	--All pyro monsters you control gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
	--Check for card in deck to send to GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,1,nil) end
end
	--Send 1 top card of deck to GY to make all pyro monsters you control gain ATK
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.DiscardDeck(tp,1,REASON_COST)
	--Effect
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--無窮機竜カルノール
--Carnot the Eternal Machine
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can only Special Summon "Etermakina Carnord(s)" once per turn
	c:SetSPSummonOnce(id)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--This card gains 1000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return ep==1-tp and re:IsMonsterEffect() end)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Shuffle this card into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function(e) return not e:GetHandler():IsPreviousLocation(LOCATION_HAND|LOCATION_DECK) end)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Register if a player activated a monster effect in the hand or GY this Duel
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsMonsterEffect() or Duel.HasFlagEffect(rp,id) then return end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_HAND or loc==LOCATION_GRAVE then
		Duel.RegisterFlagEffect(rp,id,0,0,0)
	end
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.HasFlagEffect(1-tp,id)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Gains 1000 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
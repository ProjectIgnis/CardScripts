--碧牙の重轟爆速竜
--Blue-Fang Concurrent Burst Dragon
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_BLUETOOTH_B_DRAGON,160013004)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Gain ATK
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
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)<1 then return end
	local tc=g:GetFirst()
	--Effect
	--ATK change
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1500)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	--Cannot attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3207)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e2)
	if tc:IsMonster() and tc:IsLevelAbove(7) and tc:IsRace(RACE_DRAGON) then
		--Attack up to twice
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3201)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e3:SetValue(1)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e3)
	end
end
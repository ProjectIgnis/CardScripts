--王家之劍
--Royal Sword
local s,id=GetID()
local COUNTER_CREST=0x95
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_CREST)
	--Can only place 4 Crest Counters on this card
	c:SetCounterLimit(COUNTER_CREST,4)
	--Equip only to "Fog King"
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,6614221))
	--At the end of the Battle Phase, if the equipped monster battles: Place 1 Crest Counter on this card (max. 4)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) local ec=e:GetHandler():GetEquipTarget() return ec and ec:GetBattledGroupCount()>0 end)
	e1:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_CREST,1) end)
	c:RegisterEffect(e1)
	--Equipped monster gains 800 ATK for each Crest Counter on this counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(function(e,c) return e:GetHandler():GetCounter(COUNTER_CREST)*800 end)
	c:RegisterEffect(e2)
	--Damage
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_names={6614221} --"Fog King"
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:GetEquipTarget():GetControler()==c:GetControler()
		and c:GetEquipTarget():IsAbleToGraveAsCost() and c:GetCounter(COUNTER_CREST)==4 end
	local g=Group.FromCards(c,c:GetEquipTarget())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(4000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,4000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

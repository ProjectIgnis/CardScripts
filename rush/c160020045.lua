--ダイスマイトギャム・ファイヤーラップス
--Dicemite Gyame Fire Laps
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160211067,160019007)
	--dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DICE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)~=2 then return end
	--Effect
	local c=e:GetHandler()
	local d1,d2=Duel.TossDice(tp,2)
	local sum=d1+d2
	if sum==7 or sum==11 then
		local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			--Increase ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	else
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(sum*100)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
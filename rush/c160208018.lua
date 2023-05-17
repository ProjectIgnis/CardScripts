--環幻楽鬼神トランスゴッドブレス
--Trancegodbreath the Music Fiend Deity
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160004029,160208031)
	--Gain piercing damage+trap protection
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and e:GetHandler():CanGetPiercingRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,3,nil)
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	--Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Cannot be destroyed by opponent's trap
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3012)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		--Piercing
		c:AddPiercing(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		--Increase ATK
		local ct=g:FilterCount(Card.IsMonster,nil)
		if ct>0 and c:IsStatus(STATUS_SPSUMMON_TURN) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(ct*1000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
function s.efilter(e,te)
	return te:IsTrapEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
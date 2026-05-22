--不死のデスロード (Anime)
--Invincible Demise Lord (Anime)
--Scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	--If this card is destroyed by battle and sent to the Graveyard: it will be Special Summoned during the End Phase with ATK of 3000, also it cannot be destroyed by card effects. You can only use this effect once in the Duel. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE) end)
	e1:SetCost(s.regcost)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
end
function s.regcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,0,0,1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Special Summon this card from the GY during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.selfspop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	c:RegisterEffect(e2)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	if c and c:IsLocation(LOCATION_GRAVE) and Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3001)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(1)
		c:RegisterEffect(e2)
	end
end

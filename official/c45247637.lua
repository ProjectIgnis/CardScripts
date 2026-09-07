--薔薇の刻印
--Mark of the Rose
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card by banishing 1 Plant monster from your GY, then target 1 face-up monster your opponent controls; equip this card to it
	aux.AddEquipProcedure(c,1,aux.CheckStealEquip,s.eqlimit,s.cost,s.target)
	--Take control of the equipped monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetValue(function(e,c) return e:GetHandler():GetFlagEffectLabel(id) end)
	c:RegisterEffect(e1)
	--Negate this card's effect until your next Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				c:SetFlagEffectLabel(id,1-tp)
				c:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,1))
				--Choose when to reset the negation during your next Standby Phase
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e1:SetRange(LOCATION_SZONE)
				e1:SetCountLimit(1)
				e1:SetCondition(function() return Duel.IsTurnPlayer(tp) end)
				e1:SetOperation(function() Duel.Hint(HINT_CARD,0,id) c:SetFlagEffectLabel(id,tp) e1:Reset() end)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY,2)
				c:RegisterEffect(e1)
			end)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer()) or e:GetHandler():GetEquipTarget()==c
end
function s.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc)
	e:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,tp,0)
end
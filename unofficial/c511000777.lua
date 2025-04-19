--黒翼再戦
--Black Revenge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRelateToBattle()
		and Duel.GetAttacker():IsStatus(STATUS_OPPO_BATTLE)
end
function s.costfilter(c)
	return c:IsSetCard(SET_BLACKWING) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetAttacker():CanChainAttack(0,true) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() then return end
	Duel.ChainAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	tc:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetLabel(tc:GetAttackAnnouncedCount())
	e2:SetLabelObject(tc)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE,2)
	tc:CreateEffectRelation(e2)
	Duel.RegisterEffect(e2,tp)
end
function s.discon(e)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) then e:SetLabel(0) e:SetLabelObject(nil) e:Reset() end
	return tc:GetAttackAnnouncedCount()>e:GetLabel()
end
function s.distg(e,c)
	return c==e:GetLabelObject():GetBattleTarget()
end
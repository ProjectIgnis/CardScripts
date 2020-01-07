--Xyz Cyclone
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if bc:IsControler(tp) then bc=Duel.GetAttacker() end
	e:SetLabelObject(bc)
	return bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:GetBattleTarget():IsStatus(STATUS_OPPO_BATTLE)
end
function s.filter(c,e)
	return c:IsDestructable() and c:IsType(TYPE_SPELL+TYPE_TRAP) and (not e or c:IsCanBeEffectTarget(e))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local bc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
	local g1=sg:Select(tp,1,1,nil)
	sg:Sub(g1)
	Duel.SetTargetCard(g1)
	if bc:GetOverlayCount()>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g2=sg:Select(tp,1,1,nil)
		Duel.SetTargetCard(g2)
		g1:Merge(g2)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

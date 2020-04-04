--Counteroffensive Dragonstrike
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(tp) and tc:IsRace(RACE_DRAGON)
		and (tc:GetBattlePosition()&POS_FACEUP)~=0
		and bc:IsRelateToBattle() and bc:IsControler(1-tp) and bc==Duel.GetAttacker()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- effect
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,3,nil)
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	Duel.Draw(tp,1,REASON_EFFECT)
end

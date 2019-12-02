--変則ギア
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then
		return d and a:GetControler()~=d:GetControler()
			and a:IsAbleToRemove(a:GetControler(),POS_FACEDOWN,REASON_RULE)
			and d:IsAbleToRemove(d:GetControler(),POS_FACEDOWN,REASON_RULE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	if a:IsControler(1-tp) then a,d=d,a end
	local res=Duel.RockPaperScissors()
	if res==tp then
		Duel.Remove(d,POS_FACEDOWN,REASON_RULE)
	else
		Duel.Remove(a,POS_FACEDOWN,REASON_RULE)
	end
end

--ナノブレイカー
--Nanobreaker
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk ==0 then	return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsFaceup() and d:IsLevelBelow(3) and d:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsFaceup() and d:IsLevelBelow(3) then
		Duel.Destroy(d,REASON_EFFECT)
	end
end
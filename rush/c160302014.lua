--反攻の竜撃
--Vengeful Dragon's Counterattack
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:GetPreviousRaceOnField()&RACE_DRAGON>0 and (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return at:IsControler(1-tp) and at:IsRelateToBattle() and #g>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)~=0 then
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		g=g:AddMaximumCheck()
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.filter(c)
	return c:IsMonster() and not c:IsMaximumModeSide()
end
--ワーム・ファルコ
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
end

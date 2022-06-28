-- 落とし蓋
-- Trap Lid
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Change 2 monsters to face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
end
function s.posconfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_GRAVE)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.posconfilter,1,nil,tp)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsCanChangePositionRush()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
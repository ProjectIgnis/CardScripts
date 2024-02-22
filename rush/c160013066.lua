--ライステラス・クライシス
--Rice Terrace Crisis
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Change up 2 monsters to face-down Defense Position
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
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_GRAVE|LOCATION_HAND)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.posconfilter,1,nil,tp)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(12) and c:IsCanTurnSet() and c:IsCanChangePositionRush()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.posfilter2(c)
	return c:IsCanTurnSet() and c:IsCanChangePositionRush()
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(s.posfilter2),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_POSCHANGE)
		Duel.HintSelection(sg,true)
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)<=12
end
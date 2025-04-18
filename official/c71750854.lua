--ボンバー・プレイス
--Bomber Place
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate one of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(Cost.PayLP(600))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.oppfilter(c,tp)
	return c:HasLevel() and c:IsFaceup() and Duel.IsExistingMatchingCard(s.lvrklnkfilter,tp,0,LOCATION_MZONE,1,c,c:GetLevel())
end
function s.lvrklnkfilter(c,lv)
	return c:IsFaceup() and (c:IsLevel(lv) or c:IsRank(lv) or c:IsLink(lv))
end
function s.selffilter(c,tp)
	return c:HasLevel() and c:IsFaceup() and Duel.IsExistingMatchingCard(s.columnfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel(),c:GetColumnGroup())
end
function s.columnfilter(c,lv,columng)
	return columng:IsContains(c) and s.lvrklnkfilter(c,lv)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,6),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetLevel)==6
		and Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_MZONE,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.selffilter,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Choose 1 face-up monster your opponent controls that has a Level, and destroy all other monsters they control with an equal Level/Rank/Link Rating
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO) --"Select your opponent's card"
		local sc=Duel.SelectMatchingCard(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			local g=Duel.GetMatchingGroup(s.lvrklnkfilter,tp,0,LOCATION_MZONE,sc,sc:GetLevel())
			if #g>0 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	elseif op==2 then
		--Choose 1 face-up monster you control that has a Level, and destroy all your opponent's monsters in its column with an equal Level/Rank/Link Rating
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF) --"Select your card"
		local sc=Duel.SelectMatchingCard(tp,s.selffilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			local g=Duel.GetMatchingGroup(s.columnfilter,tp,0,LOCATION_MZONE,nil,sc:GetLevel(),sc:GetColumnGroup())
			if #g>0 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
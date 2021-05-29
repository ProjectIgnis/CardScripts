-- 寿司天使ドラゴンロール
-- Dragon Roll the Sushi Angel
local s,id=GetID()
function s.initial_effect(c)
	--Send to GY and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsStatus(STATUS_SUMMON_TURN)		
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsRace(RACE_FAIRY)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return c:IsLevelBelow(6)
end
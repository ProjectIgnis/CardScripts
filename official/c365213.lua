--光来する奇跡
--Arrive in Light
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--cannot to extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.tdtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--draw or special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.applycon)
	e3:SetTarget(s.applytg)
	e3:SetOperation(s.applyop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_STARDUST_DRAGON}
function s.tdfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_DECK,0,nil)
	if not (#g1>0 or #g2>0) then return end
	local op=-1
	if #g1>0 and #g2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif #g1>0 then
		op=0
	elseif #g2>0 then
		op=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	if op==0 then
		local tc=g1:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	elseif op==1 then
		local tc=g2:Select(tp,1,1,nil):GetFirst()
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,SEQ_DECKTOP)
	end
	Duel.ConfirmDecktop(tp,1)
end
function s.tdtg(e,c)
	return c:IsFaceup() and ((c:IsCode(CARD_STARDUST_DRAGON) and (c:IsType(TYPE_EXTRA) or c:IsLocation(LOCATION_SZONE)))
		or (c:IsType(TYPE_SYNCHRO) and c:ListsCode(CARD_STARDUST_DRAGON)))
end
function s.applycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),1,nil)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local draw=s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
	local spsummon=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return draw or spsummon end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local draw=s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
	local spsummon=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local op=-1
	if draw and spsummon then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif draw then
		op=0
	elseif spsummon then
		op=1
	end
	if op==0 then
		s.drop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.spop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0 end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_TUNER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
end
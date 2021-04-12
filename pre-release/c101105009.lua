--妖眼の相剣師
--Sword Master of the Bewitching Iris
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--tograve
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.hdexcon)
	e2:SetTarget(s.hdextg)
	e2:SetOperation(s.hdexop)
	c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsDisabled),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.hdexfilter(c,tp,loc)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(loc)
end
function s.hdexcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.hdexfilter,1,nil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=eg:IsExists(s.hdexfilter,1,nil,tp,LOCATION_HAND)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=eg:IsExists(s.hdexfilter,1,nil,tp,LOCATION_DECK)
		and Duel.IsPlayerCanDraw(tp,2)
	local b3=eg:IsExists(s.hdexfilter,1,nil,tp,LOCATION_EXTRA)
	if chk==0 then return b1 or b2 or b3 end
	local opt={}
	local sel={}
	if b1 then
		table.insert(opt,aux.Stringid(id,1))
		table.insert(sel,1)
	end
	if b2 then
		table.insert(opt,aux.Stringid(id,2))
		table.insert(sel,2)
	end
	if b3 then
		table.insert(opt,aux.Stringid(id,3))
		table.insert(sel,3)
	end
	local op=sel[Duel.SelectOption(tp,table.unpack(opt))+1]
	e:SetCategory(0)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=eg:Filter(s.hdexfilter,nil,tp,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
	e:SetLabel(op)
end
function s.hdexop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	--Hand effect
	if op==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	--Deck effect
	elseif op==2 then
		Duel.Draw(tp,2,REASON_EFFECT)
	--Extra Deck effect
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=eg:FilterSelect(tp,s.hdexfilter,1,1,nil,tp,LOCATION_EXTRA)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

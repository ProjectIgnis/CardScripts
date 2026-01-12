--JP name
--R.B. Shepherd's Crook
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including an "R.B." monster
	Link.AddProcedure(c,nil,2,3,s.linkmatcheck)
	--Gains 500 ATK for each monster you control, except this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return 500*Duel.GetMatchingGroupCount(nil,c:GetControler(),LOCATION_MZONE,0,e:GetHandler()) end)
	c:RegisterEffect(e1)
	--Set 1 "R.B." Spell/Trap from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Target 3 Level 3 or higher "R.B." monsters; place 2 on the bottom of the Deck in any order, Special Summon the third
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp) return Duel.IsMainPhase(1-tp) end)
	e3:SetTarget(s.tdsptg)
	e3:SetOperation(s.tdspop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RB}
s.material_setcode=SET_RB
function s.linkmatcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_RB,lc,sumtype,tp)
end
function s.setfilter(c)
	return c:IsSetCard(SET_RB) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.tdspfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsSetCard(SET_RB) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.spcheck,1,nil,e,tp,sg)
end
function s.spcheck(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and sg:IsExists(Card.IsAbleToDeck,2,c)
end
function s.tdsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdspfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
end
function s.tdrescon(sg,e,tp,mg)
	return mg:IsExists(s.spcheck,1,sg,e,tp,sg)
end
function s.tdspop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg<2 then return end
	if #tg==2 and Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then Duel.SortDeckbottom(tp,tp,ct) end
		return
	end
	local dg=aux.SelectUnselectGroup(tg,e,tp,2,2,s.tdrescon,1,tp,HINTMSG_TODECK)
	if #dg~=2 then return end
	Duel.HintSelection(dg)
	if Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)==2 then
		local ct=dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then Duel.SortDeckbottom(tp,tp,ct) end
		local sg=tg-dg
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
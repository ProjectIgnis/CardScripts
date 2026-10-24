--カオス・バリアンズ・チェンジ
--Chaos Barian's Change
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "Masquerade" Xyz Monster you control; Special Summon from your Extra Deck, 1 "Number" monster that is 1 Rank higher or 2 Ranks lower than that monster you control, by using it as material (this is treated as an Xyz Summon, transfer its materials)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 3 "Umbral Horror" monsters and/or "Masquerade" Xyz Monsters in your GY; place them on the bottom of the Deck in any order, then draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drwtg)
	e2:SetOperation(s.drwop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MASQUERADE,SET_NUMBER,SET_UMBRAL_HORROR}
function s.masqueradexyzfilter(c,e,tp)
	local mandatory_group=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#mandatory_group<=0 or (#mandatory_group==1 and mandatory_group:IsContains(c)))
		and c:IsSetCard(SET_MASQUERADE) and c:IsXyzMonster() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
function s.spfilter(c,e,tp,mc,rank)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_NUMBER) and mc:IsCanBeXyzMaterial(c,tp)
		and c:IsRank(rank+1,rank-2) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.masqueradexyzfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.masqueradexyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.masqueradexyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local mandatory_group=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if #mandatory_group>1 or (#mandatory_group==1 and not mandatory_group:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()):GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.tdfilter(c)
	return (c:IsSetCard(SET_UMBRAL_HORROR) or (c:IsSetCard(SET_MASQUERADE) and c:IsXyzMonster())) and c:IsMonster()
		and (c:IsAbleToDeck() or c:IsAbleToExtra())
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	local g_extra,g=g:Split(Card.IsXyzMonster,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	end
	if #g_extra>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g_extra,#g_extra,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		local main_deck_count=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if main_deck_count>=2 then
			Duel.SortDeckbottom(tp,tp,main_deck_count)
		end
		if Duel.IsPlayerCanDraw(tp) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
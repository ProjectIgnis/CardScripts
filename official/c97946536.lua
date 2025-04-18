--
--Zektrike Kou-ou
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_INZEKTOR}
function s.cfilter(c,e,tp,ft)
	return c:IsSetCard(SET_INZEKTOR) and c:IsAbleToGraveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and (Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft,c)
		or Duel.IsExistingMatchingCard(s.eqspfilter,tp,LOCATION_DECK,0,1,nil,tp,ft,c))
end
function s.monfilter(c,e,tp,ft,sc)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and (s.monspfilter(c,e,tp,sc) or s.moneqfilter(c,tp,ft,sc))
end
function s.monspfilter(c,e,tp,sc)
	return Duel.GetMZoneCount(tp,sc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.moneqfilter(c,tp,ft,sc)
	return (ft>0 or (sc and sc:IsLocation(LOCATION_SZONE) and sc:GetSequence()<5)) and not c:IsForbidden()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_INZEKTOR),tp,LOCATION_MZONE,0,1,sc)
end
function s.eqspfilter(c,tp,ft,sc)
	return c:IsSetCard(SET_INZEKTOR) and c:IsType(TYPE_EQUIP) and c:IsSpell()
		and (ft>0 or (sc and sc:IsLocation(LOCATION_SZONE) and sc:GetSequence()<5))
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,sc,c)
end
function s.eqfilter(c,ec)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR) and ec:CheckEquipTarget(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if c:IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,e,tp,ft)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	local b2=Duel.IsExistingMatchingCard(s.eqspfilter,tp,LOCATION_DECK,0,1,nil,tp,ft)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	--Special Summon or equip 1 "Inzektor" monster from your Deck
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
		if not sc then return end
		local sp=s.monspfilter(sc,e,tp)
		local eq=s.moneqfilter(sc,tp,ft)
		local op=Duel.SelectEffect(tp,
			{sp,aux.Stringid(id,3)},
			{eq,aux.Stringid(id,4)})
		if op==1 then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local ec=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_INZEKTOR),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if not ec then return end
			Duel.HintSelection(ec,true)
			if not Duel.Equip(tp,sc,ec,true) then return end
			--Equip limit
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
			e1:SetLabelObject(ec)
			sc:RegisterEffect(e1)
		end
	--Equip 1 "Inzektor" Equip Spell from your Deck
	elseif op==2 and ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sc=Duel.SelectMatchingCard(tp,s.eqspfilter,tp,LOCATION_DECK,0,1,1,nil,tp,ft):GetFirst()
		if not sc then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,sc):GetFirst()
		Duel.HintSelection(ec,true)
		if not ec then return end
		Duel.Equip(tp,sc,ec)
	end
end
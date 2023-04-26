--シャルルの叙事詩
--The Epic Poem of Charles
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Infernoble Knight" monster from your hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Equip 1 "Noble Knight" monster from your hand or Deck to 1 "Infernoble Knight Emperor Charles" you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NOBLE_ARMS,SET_INFERNOBLE_KNIGHT,SET_NOBLE_KNIGHT}
s.listed_names={CARD_INFERNOBLE_CHARLES}
function s.cfilter(c,sft,e,tp)
	return c:IsSetCard(SET_NOBLE_ARMS) and c:IsEquipSpell() and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,c,sft)
end
function s.spfilter(c,e,tp,eq,sft)
	return c:IsSetCard(SET_INFERNOBLE_KNIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (eq:IsAbleToGrave() or (sft>0 and eq:CheckEquipTarget(c)
		and eq:CheckUniqueOnField(tp) and not eq:IsForbidden()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then sft=sft-1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,sft,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local eq=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,sft,e,tp):GetFirst()
	if not eq then return end
	Duel.ConfirmCards(1-tp,eq)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,eq,sft):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local eqBool=sft>0 and eq:CheckEquipTarget(tc) and eq:CheckUniqueOnField(tp) and not eq:IsForbidden()
		local tgBool=eq:IsAbleToGrave()
		if eqBool or tgBool then
			Duel.BreakEffect()
			local op=Duel.SelectEffect(tp,
				{eqBool,aux.Stringid(id,2)},
				{tgBool,aux.Stringid(id,3)})
			if op==1 then
				Duel.Equip(tp,eq,tc)
			else
				Duel.SendtoGrave(eq,REASON_EFFECT)
			end
		end
	end
end
function s.eqfilter(c,p)
	return c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsMonster()
		and c:CheckUniqueOnField(p) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsFaceup() and chkc:IsCode(CARD_INFERNOBLE_CHARLES) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCode,CARD_INFERNOBLE_CHARLES),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCode,CARD_INFERNOBLE_CHARLES),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eq=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if eq and Duel.Equip(tp,eq,tc,true) then
		local c=e:GetHandler()
		--Equip Limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(_,_c) return _c==tc end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		eq:RegisterEffect(e1)
		--Increase 500 ATK
		local e2=Effect.CreateEffect(eq)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		eq:RegisterEffect(e2)
	end
	Duel.EquipComplete()
end
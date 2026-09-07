--円卓の聖騎士
--Noble Knights of the Round Table
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During your End Phase: You can activate each of these effects up to once per turn, depending on the total number of "Noble Knight" cards with different names in your GY and/or you control;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NOBLE_KNIGHT,SET_NOBLE_ARMS}
function s.tgfilter(c)
	return c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsMonster() and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==3 and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	local noble_knights_count=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_NOBLE_KNIGHT),tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetCode)
	--● 3+: Send 1 "Noble Knight" card from your Deck to the GY
	local b1=noble_knights_count>=3 and not c:HasFlagEffect(id+1)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	--● 6+: Special Summon 1 "Noble Knight" monster from your hand, then you can equip 1 "Noble Arms" Equip Spell from your hand to that monster
	local b2=noble_knights_count>=6 and not c:HasFlagEffect(id+2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	--● 9+: Target 1 "Noble Knight" monster in your GY; add that target to your hand
	local b3=noble_knights_count>=9 and not c:HasFlagEffect(id+3)
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	--● 12: Draw 1 card
	local b4=noble_knights_count==12 and not c:HasFlagEffect(id+4)
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 or b3 or b4 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	elseif op==4 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	c:RegisterFlagEffect(id+op,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,op+5))
end
function s.eqfilter(c,sc,tp)
	return c:IsSetCard(SET_NOBLE_ARMS) and c:IsEquipSpell() and c:CheckEquipTarget(sc) and c:CheckUniqueOnField(tp)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● 3+: Send 1 "Noble Knight" card from your Deck to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif op==2 then
		--● 6+: Special Summon 1 "Noble Knight" monster from your hand, then you can equip 1 "Noble Arms" Equip Spell from your hand to that monster
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND,0,1,nil,sc,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND,0,1,1,nil,sc,tp):GetFirst()
			if ec then
				Duel.BreakEffect()
				Duel.Equip(tp,ec,sc)
			end
		end
	elseif op==3 then
		--● 9+: Target 1 "Noble Knight" monster in your GY; add that target to your hand
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif op==4 then
		--● 12: Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
--グランドレミコード・ミューゼシア
--Grandoremichord Musesea
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),2,2)
	--to hand (extra)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.xthtg)
	e1:SetOperation(s.xthop)
	c:RegisterEffect(e1)
	--to hand (deck)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x164}
function s.xthfilter1(c,tp)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and Duel.IsExistingMatchingCard(s.xthfilter2,tp,LOCATION_EXTRA,0,1,c,c)
end
function s.xthfilter2(c,ac)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
		and (c:GetScale()+ac:GetScale()) % 2 ~= 0
end
function s.xthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xthfilter1,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.xthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local xtc=Duel.SelectMatchingCard(tp,s.xthfilter1,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if xtc and Duel.SendtoExtraP(xtc,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.xthfilter2,tp,LOCATION_EXTRA,0,1,1,xtc,xtc)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.thfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x164) and c:IsSummonPlayer(tp)
		and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetScale())
end
function s.thfilter2(c,lv)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x164) and c:IsLevel(lv) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.thfilter1,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=eg:FilterSelect(tp,s.thfilter1,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetScale())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
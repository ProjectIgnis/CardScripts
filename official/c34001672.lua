--百鬼羅刹 巨魁ガボンガ
--Goblin Biker Big Gabonga
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Enable the material detaching event
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,3,2)
	--Search 1 "Goblin" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Attack 1 other face-up monster to this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LOST_TARGET==0 end)
	e2:SetTarget(s.fldattchtg)
	e2:SetOperation(s.fldattchop)
	c:RegisterEffect(e2)
	--Attach 1 "Goblin" monster from your Deck to this card as material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.dattchtg)
	e3:SetOperation(s.dattchop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GOBLIN}
function s.thfilter(c)
	return c:IsSetCard(SET_GOBLIN) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.fldattchfilter(c,xyzc,tp)
	return c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
		and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.fldattchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.fldattchfilter(chkc,c,tp) and chkc~=c end
	if chk==0 then return c:IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.fldattchfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,s.fldattchfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,c,tp)
end
function s.fldattchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
function s.dattchfilter(c,xyzc,tp)
	return c:IsSetCard(SET_GOBLIN) and c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.dattchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.dattchfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
	end
end
function s.dattchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.dattchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end
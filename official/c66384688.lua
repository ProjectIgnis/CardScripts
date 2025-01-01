--マジェスペクター・オルト
--Majespecter Orthrus - Nue
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Pendulum Monsters, including a "Majespecter" monster
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),2,2,s.lcheck)
	--Add 2 "Majespecter" Pendulum Monsters to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MAJESPECTER,SET_DRACOSLAYER}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_MAJESPECTER,lc,sumtype,tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MAJESPECTER) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.tefilter(c)
	return c:IsSetCard(SET_MAJESPECTER) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsSetCard({SET_MAJESPECTER,SET_DRACOSLAYER}) and c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalSetCard({SET_MAJESPECTER,SET_DRACOSLAYER}) end)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,2,nil)
	if #g==0 or Duel.SendtoHand(g,tp,REASON_EFFECT)==0 or #g:Match(Card.IsLocation,nil,LOCATION_HAND)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local dg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
	if #dg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	local teg=aux.SelectUnselectGroup(dg,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	if #teg>0 then
		Duel.BreakEffect()
		Duel.SendtoExtraP(teg,tp,REASON_EFFECT)
	end
end
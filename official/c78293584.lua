--フィリアス・ディアベル
--Philias Diabell
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Level 8 or higher "Diabell" monster from your Deck to your hand, or, if only your opponent controls a monster, you can Special Summon it instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	--Make all "Diabell" monsters you currently control gain 500 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DIABELL}
function s.thspfilter(c,e,tp,sp_check)
	return c:IsSetCard(SET_DIABELL) and c:IsLevelAbove(8)
		and (c:IsAbleToHand() or (sp_check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sp_check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sp_check)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local sp_check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	local desc=sp_check and aux.Stringid(id,2) or HINTMSG_ATOHAND
	Duel.Hint(HINT_SELECTMSG,tp,desc)
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_check):GetFirst()
	if not sc then return end
	if sp_check then
		aux.ToHandOrElse(sc,tp,
			function()
				return sp_check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,3)
		)
	else
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DIABELL),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DIABELL),tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--It gains 500 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end